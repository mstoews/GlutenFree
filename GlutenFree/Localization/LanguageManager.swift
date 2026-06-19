import SwiftUI
import Combine
import ObjectiveC

// MARK: - Runtime language bundle

private var bundleLanguageKey: UInt8 = 0

/// `Bundle.main` subclass that redirects localized-string lookups to a chosen
/// `<code>.lproj`. This lets the app language change at runtime — `Text("…")`,
/// `String(localized:)` and `NSLocalizedString` all resolve through the main
/// bundle, so swapping its lookup path re-localizes the whole app on rebuild.
final class LocalizedBundle: Bundle, @unchecked Sendable {
    nonisolated override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let path = objc_getAssociatedObject(self, &bundleLanguageKey) as? String,
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    /// Point `Bundle.main` string lookups at `<code>.lproj` (nil = system default).
    nonisolated static func setAppLanguage(_ code: String?) {
        if !(Bundle.main is LocalizedBundle) {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }
        let path = code.flatMap { Bundle.main.path(forResource: $0, ofType: "lproj") }
        objc_setAssociatedObject(Bundle.main, &bundleLanguageKey, path, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Language manager

/// The app's display language, with a persisted manual override applied at
/// runtime. Drives both the bundle redirect (for localized strings) and the
/// SwiftUI environment `\.locale` (for formatting + locale-aware data).
@MainActor
final class LanguageManager: ObservableObject {
    enum Language: String, CaseIterable, Identifiable {
        case ja, en
        var id: String { rawValue }
        var displayName: String { self == .ja ? "日本語" : "English" }
    }

    @Published var language: Language {
        didSet {
            guard language != oldValue else { return }
            UserDefaults.standard.set(language.rawValue, forKey: Self.overrideKey)
            Bundle.setAppLanguage(language.rawValue)
        }
    }

    /// Locale to push into the SwiftUI environment.
    var locale: Locale { Locale(identifier: language.rawValue) }

    private static let overrideKey = "gf.languageOverride"

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.overrideKey)
        let resolved = saved.flatMap(Language.init(rawValue:)) ?? Self.systemDefault
        language = resolved                 // didSet does not fire during init
        Bundle.setAppLanguage(resolved.rawValue)
    }

    /// First launch with no override: follow the system's preferred language.
    private static var systemDefault: Language {
        let code = Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "ja"
        return code == "en" ? .en : .ja
    }
}
