import Combine
import Foundation

private struct StoredTokens: Codable {
    var accessToken: String
    var refreshToken: String
}

/// Owns auth state: tokens (persisted in Keychain), the current user, and the
/// subscription status. Wires the shared `APIClient` so authorized requests
/// attach the bearer token and refresh once on 401.
@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var user: AuthUser? { didSet { persistUser() } }
    @Published private(set) var subscription: SubscriptionStatus?

    private static let cachedUserKey = "gf.cachedUser"
    @Published private(set) var isAuthenticated = false
    @Published var authError: String?
    @Published var isWorking = false

    let api = APIClient()

    private var tokens: StoredTokens? {
        didSet { isAuthenticated = tokens != nil }
    }

    init() {
        api.tokenProvider = { [weak self] in self?.tokens?.accessToken }
        api.tokenRefresher = { [weak self] in await self?.refreshTokens() ?? false }
        restore()
    }

    var isSubscribed: Bool { subscription?.isActive ?? false }

    /// Called once at startup. A session restored from the Keychain is already
    /// authenticated but has no subscription loaded yet — fetch it so gated UI
    /// (e.g. the store-detail "view menu" CTA) reflects the real status.
    /// Otherwise fall back to DEBUG autologin.
    func bootstrap() async {
        if isAuthenticated {
            await loadSubscription()
        } else {
            await bootstrapAutologin()
        }
    }

    /// DEBUG-only: auto sign-in when `GF_AUTOLOGIN_EMAIL`/`GF_AUTOLOGIN_PASSWORD`
    /// launch env vars are present (simulator runs / UI tests).
    func bootstrapAutologin() async {
        #if DEBUG
        let env = ProcessInfo.processInfo.environment
        guard !isAuthenticated,
              let email = env["GF_AUTOLOGIN_EMAIL"],
              let password = env["GF_AUTOLOGIN_PASSWORD"] else { return }
        await login(email: email, password: password)
        #endif
    }

    // MARK: Auth actions

    func register(email: String, password: String) async {
        authError = nil
        isWorking = true
        defer { isWorking = false }
        do {
            _ = try await api.register(email: email, password: password)
            await performLogin(email: email, password: password)
        } catch {
            authError = message(for: error)
        }
    }

    func login(email: String, password: String) async {
        authError = nil
        isWorking = true
        defer { isWorking = false }
        await performLogin(email: email, password: password)
    }

    private func performLogin(email: String, password: String) async {
        do {
            let resp = try await api.login(email: email, password: password)
            tokens = StoredTokens(accessToken: resp.accessToken, refreshToken: resp.refreshToken)
            user = resp.user
            persist()
            await loadSubscription()
        } catch {
            authError = message(for: error)
        }
    }

    func logout() {
        tokens = nil
        user = nil
        subscription = nil
        persist()
    }

    // MARK: Subscription

    func loadSubscription() async {
        do {
            subscription = try await api.subscriptionStatus()
        } catch APIError.unauthorized {
            logout()
        } catch {
            // Keep whatever we had; transient failures shouldn't sign the user out.
        }
    }

    /// Sends a StoreKit signed transaction to the backend and updates state.
    func verifySubscription(signedTransaction: String) async throws {
        let resp = try await api.verifySubscription(signedTransaction: signedTransaction)
        subscription = SubscriptionStatus(
            subscriptionStatus: resp.subscriptionStatus,
            isActive: resp.subscriptionStatus == "active",
            subExpiresAt: resp.subExpiresAt
        )
        if let u = user {
            user = AuthUser(id: u.id, email: u.email,
                            subscriptionStatus: resp.subscriptionStatus, subExpiresAt: resp.subExpiresAt)
        }
    }

    // MARK: Tokens

    private func refreshTokens() async -> Bool {
        guard let refreshToken = tokens?.refreshToken else { return false }
        do {
            let resp = try await api.refresh(refreshToken: refreshToken)
            if var current = tokens {
                current.accessToken = resp.accessToken
                tokens = current
                persist()
            }
            return true
        } catch {
            logout()
            return false
        }
    }

    private func restore() {
        if let data = KeychainStore.load(),
           let stored = try? JSONDecoder().decode(StoredTokens.self, from: data) {
            tokens = stored
        }
        // The user object isn't security-sensitive (the user's own email); cache
        // it so a restored session shows the real profile, not "Guest".
        if let data = UserDefaults.standard.data(forKey: Self.cachedUserKey),
           let cached = try? JSONDecoder().decode(AuthUser.self, from: data) {
            user = cached
        }
    }

    private func persistUser() {
        if let user, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: Self.cachedUserKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.cachedUserKey)
        }
    }

    private func persist() {
        if let tokens, let data = try? JSONEncoder().encode(tokens) {
            KeychainStore.save(data)
        } else {
            KeychainStore.clear()
        }
    }

    private func message(for error: Error) -> String {
        (error as? APIError)?.errorDescription ?? error.localizedDescription
    }
}
