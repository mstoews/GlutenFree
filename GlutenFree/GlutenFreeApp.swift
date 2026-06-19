import SwiftUI

@main
struct GlutenFreeApp: App {
    @StateObject private var session: SessionStore
    @StateObject private var subscriptions: SubscriptionManager
    @StateObject private var saved = SavedStore()
    @StateObject private var language = LanguageManager()

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
                .environmentObject(saved)
                .environmentObject(language)
                .environment(\.locale, language.locale)
                .id(language.language)
                .preferredColorScheme(Self.forcedColorScheme)
        }
    }

    /// DEBUG-only: force light/dark via the `GF_FORCE_APPEARANCE` launch env
    /// (`light`/`dark`) for deterministic screenshots. Otherwise follows the system.
    private static var forcedColorScheme: ColorScheme? {
        #if DEBUG
        switch ProcessInfo.processInfo.environment["GF_FORCE_APPEARANCE"] {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
        #else
        return nil
        #endif
    }
}
