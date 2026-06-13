import Foundation

/// App-wide configuration. Change `baseURL` to point at your backend.
///
/// Local dev note: the GlutenFree Go backend defaults to :8080, but if another
/// service already owns 8080 on your machine, run it on a free port and update
/// this. The iOS Simulator reaches your Mac via `localhost`. Plain HTTP to
/// localhost requires an ATS exception (see the project's Info settings:
/// "App Transport Security Settings" → "Allow Local Networking" = YES for dev).
enum AppConfig {
    /// Backend base URL (no trailing slash).
    static let baseURL = URL(string: "http://localhost:8080")!

    /// StoreKit auto-renewable subscription product identifiers.
    /// Must match App Store Connect (and the local .storekit config for testing).
    static let subscriptionProductIDs: [String] = ["com.glutenfree.sub.monthly"]
}
