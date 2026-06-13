import Foundation

/// Thin async HTTP client for the GlutenFree backend.
///
/// `tokenProvider` / `tokenRefresher` are injected by `SessionStore`: authorized
/// requests attach the current bearer token, and a 401 triggers a single
/// refresh-and-retry. A 402 is surfaced as `APIError.paymentRequired` so the UI
/// can show the paywall.
final class APIClient {
    let baseURL: URL
    var tokenProvider: () -> String? = { nil }
    var tokenRefresher: () async -> Bool = { false }

    private let decoder: JSONDecoder
    private let encoder = JSONEncoder()

    init(baseURL: URL = AppConfig.baseURL) {
        self.baseURL = baseURL
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: Endpoints

    func register(email: String, password: String) async throws -> AuthUser {
        try await send(path: "/auth/register", method: "POST",
                       body: RegisterBody(email: email, password: password), authorized: false)
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        try await send(path: "/auth/login", method: "POST",
                       body: LoginBody(email: email, password: password), authorized: false)
    }

    func refresh(refreshToken: String) async throws -> RefreshResponse {
        try await send(path: "/auth/refresh", method: "POST",
                       body: RefreshBody(refreshToken: refreshToken), authorized: false, allowRefresh: false)
    }

    func subscriptionStatus() async throws -> SubscriptionStatus {
        try await send(path: "/subscription/status", authorized: true)
    }

    func verifySubscription(signedTransaction: String) async throws -> VerifyResponse {
        try await send(path: "/subscription/verify", method: "POST",
                       body: VerifyBody(signedTransaction: signedTransaction), authorized: true)
    }

    func wards() async throws -> [Ward] {
        try await send(path: "/wards", authorized: false)
    }

    func stores(wardID: Int?, cursor: String?) async throws -> StoreListResponse {
        var query: [URLQueryItem] = []
        if let wardID { query.append(URLQueryItem(name: "ward_id", value: String(wardID))) }
        if let cursor { query.append(URLQueryItem(name: "cursor", value: cursor)) }
        return try await send(path: "/stores", query: query, authorized: true)
    }

    func storeDetail(id: String) async throws -> StoreDetail {
        try await send(path: "/stores/\(id)", authorized: true)
    }

    func menu(storeID: String) async throws -> MenuResponse {
        try await send(path: "/stores/\(storeID)/menu", authorized: true)
    }

    // MARK: Core

    private func send<T: Decodable>(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Encodable? = nil,
        authorized: Bool,
        allowRefresh: Bool = true
    ) async throws -> T {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }
        if !query.isEmpty { comps.queryItems = query }
        guard let url = comps.url else { throw APIError.invalidResponse }

        var req = URLRequest(url: url)
        req.httpMethod = method
        if let body {
            req.httpBody = try encoder.encode(AnyEncodable(body))
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if authorized, let token = tokenProvider() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError.transport(error)
        }
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        switch http.statusCode {
        case 200...299:
            do { return try decoder.decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        case 401:
            if authorized, allowRefresh, await tokenRefresher() {
                return try await send(path: path, method: method, query: query,
                                      body: body, authorized: authorized, allowRefresh: false)
            }
            throw APIError.unauthorized
        case 402:
            throw APIError.paymentRequired
        case 404:
            throw APIError.notFound
        default:
            throw APIError.server(status: http.statusCode, message: Self.extractMessage(data))
        }
    }

    private static func extractMessage(_ data: Data) -> String {
        struct ErrBody: Decodable { let error: String? }
        return (try? JSONDecoder().decode(ErrBody.self, from: data))?.error ?? ""
    }
}

// MARK: - Request bodies (explicit keys; no global case conversion)

private struct RegisterBody: Encodable { let email: String; let password: String }
private struct LoginBody: Encodable { let email: String; let password: String }
private struct VerifyBody: Encodable { let signedTransaction: String } // camelCase matches Apple/backend
private struct RefreshBody: Encodable {
    let refreshToken: String
    enum CodingKeys: String, CodingKey { case refreshToken = "refresh_token" }
}

/// Type-erased Encodable so the generic core can take an optional body.
private struct AnyEncodable: Encodable {
    private let encodeTo: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { encodeTo = wrapped.encode }
    func encode(to encoder: Encoder) throws { try encodeTo(encoder) }
}
