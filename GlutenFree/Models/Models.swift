import Foundation

// JSON uses snake_case; the decoder is configured with
// .convertFromSnakeCase, so Swift properties stay camelCase. Timestamps are
// kept as ISO-8601 strings (the backend is the source of truth for expiry).

// MARK: - Auth

struct AuthUser: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let subscriptionStatus: String
    let subExpiresAt: String?
}

struct LoginResponse: Codable {
    let accessToken: String
    let accessTokenExpiresAt: String
    let refreshToken: String
    let refreshTokenExpiresAt: String
    let sessionId: String
    let user: AuthUser
}

struct RefreshResponse: Codable {
    let accessToken: String
    let accessTokenExpiresAt: String
}

struct SubscriptionStatus: Codable, Equatable {
    let subscriptionStatus: String
    let isActive: Bool
    let subExpiresAt: String?
}

struct VerifyResponse: Codable {
    let subscriptionStatus: String
    let subExpiresAt: String?
    let originalTxId: String
    let environment: String
}

// MARK: - Wards & stores

struct Ward: Codable, Identifiable, Hashable {
    let id: Int
    let nameJa: String
    let nameEn: String
}

struct StoreCard: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let ward: Ward
    let isGfOriented: Bool
    let gfStatus: String
    let cuisine: String
    let priceLevel: Int
    let rating: Double
    let reviewCount: Int
    let nearestStation: String
    let blurb: String
    let address: String
    let photoUrl: String?

    var status: GFStatus { GFStatus(rawValue: gfStatus) ?? .onRequest }
}

struct StoreListResponse: Codable {
    let tier: String
    let nextCursor: String?
    let stores: [StoreCard]
}

struct OpeningHour: Codable, Hashable, Identifiable {
    let day: Int        // 0 = Sunday
    let open: String    // "HHMM"
    let close: String   // "HHMM"
    var id: Int { day }
}

struct StoreDetail: Codable, Identifiable {
    let id: String
    let name: String
    let ward: Ward
    let address: String
    let latitude: Double
    let longitude: Double
    let isGfOriented: Bool
    let openingHours: [OpeningHour]
    let approvedAt: String?
}

// MARK: - Menu

enum GFStatus: String, Codable {
    case certified
    case onRequest = "on_request"
    case containsHiddenGluten = "contains_hidden_gluten"

    var label: String {
        switch self {
        case .certified: return "Certified GF"
        case .onRequest: return "GF on request"
        case .containsHiddenGluten: return "Contains gluten"
        }
    }
}

struct MenuItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let priceYen: Int
    let imageUrl: String?
    let gfStatus: String
    let gfNote: String?
    let sortOrder: Int

    var status: GFStatus { GFStatus(rawValue: gfStatus) ?? .onRequest }

    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct MenuResponse: Codable {
    let storeId: String
    let items: [MenuItem]
}
