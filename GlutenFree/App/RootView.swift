import SwiftUI

/// Switches between the auth flow and the main tabs based on session state.
struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .animation(.default, value: session.isAuthenticated)
    }
}
