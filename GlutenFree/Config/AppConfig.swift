import Foundation

/// App-wide configuration. Change `baseURL` to point at your backend.
///
/// Release builds target the production API at https://api.gurufuri-jp.com
/// (Cloud Run behind Firebase Hosting). DEBUG builds default to the local
/// Go backend on :8090; override per-run with a `GF_API_BASE_URL` launch
/// environment variable. The iOS Simulator reaches your Mac via `localhost`.
/// Plain HTTP to localhost requires an ATS exception (see the project's Info
/// settings: "App Transport Security Settings" → "Allow Local Networking" = YES).
enum AppConfig {
    /// Backend base URL (no trailing slash). In DEBUG, a `GF_API_BASE_URL`
    /// launch environment variable overrides it (used for simulator runs/tests).
    static var baseURL: URL {
        #if DEBUG
        if let raw = ProcessInfo.processInfo.environment["GF_API_BASE_URL"],
           let url = URL(string: raw) {
            return url
        }
        return URL(string: "http://localhost:8090")!
        #else
        return URL(string: "https://api.gurufuri-jp.com")!
        #endif
    }

    /// StoreKit auto-renewable subscription product identifiers.
    /// Must match App Store Connect (and the local .storekit config for testing).
    static let annualProductID = "com.glutenfree.sub.annual"
    static let monthlyProductID = "com.glutenfree.sub.monthly"
    static let subscriptionProductIDs: [String] = [annualProductID, monthlyProductID]
}
