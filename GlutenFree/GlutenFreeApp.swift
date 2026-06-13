import SwiftUI

@main
struct GlutenFreeApp: App {
    @StateObject private var session: SessionStore
    @StateObject private var subscriptions: SubscriptionManager

    init() {
        let session = SessionStore()
        _session = StateObject(wrappedValue: session)
        _subscriptions = StateObject(wrappedValue: SubscriptionManager(session: session))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(subscriptions)
        }
    }
}
