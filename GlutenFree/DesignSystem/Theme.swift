import SwiftUI

/// Gurufuri design tokens (see docs/design_handoff_gurufuri/README.md).
enum Theme {
    // Brand — emerald. 700 in light, 600 in dark for contrast.
    static let brand = Color.adaptive(light: Color(hex: 0x047857), dark: Color(hex: 0x059669))
    static let brand600 = Color(hex: 0x059669)
    static let brand700 = Color(hex: 0x047857)
    static let brand800 = Color(hex: 0x065f46)
    static let brandSoft = Color(hex: 0x059669, alpha: 0.12)

    // Surfaces
    static let page = Color.adaptive(light: Color(hex: 0xf2f2f7), dark: Color(hex: 0x000000))
    static let card = Color.adaptive(light: .white, dark: Color(hex: 0x1c1c1e))
    static let card2 = Color.adaptive(light: Color(hex: 0xe9e9ee), dark: Color(hex: 0x2c2c2e))
    static let ink = Color.adaptive(light: Color(hex: 0x11141a), dark: Color(hex: 0xf5f5f7))
    static let sub = Color.adaptive(light: Color(hex: 0x6b7280), dark: Color(white: 0.92, opacity: 0.62))
    static let hint = Color.adaptive(light: Color(hex: 0x9aa1ac), dark: Color(white: 0.92, opacity: 0.38))
    static let separator = Color.adaptive(light: Color(hex: 0x3c3c43, alpha: 0.12), dark: Color(white: 1, opacity: 0.10))

    // Fixed accents
    static let star = Color(hex: 0xf5a623)
    static let systemRed = Color(hex: 0xff3b30)
}

// Named Metrics (not Layout) to avoid clashing with SwiftUI's Layout protocol.
enum Metrics {
    static let page: CGFloat = 16
    static let cardPadding: CGFloat = 14
    static let radiusRow: CGFloat = 14
    static let radiusCard: CGFloat = 16
    static let radiusRich: CGFloat = 18
    static let radiusSheet: CGFloat = 22
}
