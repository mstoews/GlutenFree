import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case unauthorized                 // 401 (after a failed refresh)
    case paymentRequired              // 402 — surface the paywall
    case notFound
    case server(status: Int, message: String)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Unexpected response from the server."
        case .unauthorized: return "Your session has expired. Please sign in again."
        case .paymentRequired: return "A subscription is required to view this."
        case .notFound: return "Not found."
        case let .server(status, message):
            return message.isEmpty ? "Server error (\(status))." : message
        case let .decoding(error): return "Couldn’t read the server response. \(error.localizedDescription)"
        case let .transport(error): return error.localizedDescription
        }
    }

    var isPaymentRequired: Bool {
        if case .paymentRequired = self { return true }
        return false
    }
}
