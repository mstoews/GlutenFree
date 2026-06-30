import Combine
import Foundation
import StoreKit

/// StoreKit 2 wrapper: loads products, drives purchases, and forwards each
/// signed transaction to the backend (`/subscription/verify`), which performs
/// the authoritative verification.
@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var trialEligible = false
    @Published var isPurchasing = false
    @Published var errorMessage: String?

    private let session: SessionStore
    private var updatesTask: Task<Void, Never>?

    init(session: SessionStore) {
        self.session = session
        updatesTask = listenForTransactions()
    }

    deinit { updatesTask?.cancel() }

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: AppConfig.subscriptionProductIDs)
                .sorted { $0.price < $1.price }
            if let annual = products.first(where: { $0.id == AppConfig.annualProductID }),
               annual.subscription?.introductoryOffer != nil {
                trialEligible = (try? await annual.subscription?.isEligibleForIntroOffer) ?? false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Returns true once the backend confirms an active subscription.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                return try await handle(verification)
            case .userCancelled:
                return false
            case .pending:
                errorMessage = "Your purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Restore: re-send current entitlements to the backend.
    @discardableResult
    func restore() async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        var restored = false
        for await entitlement in Transaction.currentEntitlements {
            if (try? await handle(entitlement)) == true { restored = true }
        }
        if !restored { await session.loadSubscription() }
        return restored
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await update in Transaction.updates {
                _ = try? await self?.handle(update)
            }
        }
    }

    @discardableResult
    private func handle(_ verification: VerificationResult<Transaction>) async throws -> Bool {
        try await session.verifySubscription(signedTransaction: verification.jwsRepresentation)
        if case .verified(let transaction) = verification {
            await transaction.finish()
        }
        return session.isSubscribed
    }
}
