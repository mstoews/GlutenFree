import SwiftUI

// Semantic GF-status styling — fixed colors (never themed by the accent).
extension GFStatus {
    var color: Color {
        switch self {
        case .certified: return Color(hex: 0x047857)
        case .onRequest: return Color(hex: 0xb45309)
        case .containsHiddenGluten: return Color(hex: 0xdc2626)
        }
    }

    var dotColor: Color {
        switch self {
        case .certified: return Color(hex: 0x059669)
        case .onRequest: return Color(hex: 0xd97706)
        case .containsHiddenGluten: return Color(hex: 0xdc2626)
        }
    }

    var badgeBackground: Color {
        switch self {
        case .certified: return Color(hex: 0x10b981, alpha: 0.12)
        case .onRequest: return Color(hex: 0xf59e0b, alpha: 0.14)
        case .containsHiddenGluten: return Color(hex: 0xdc2626, alpha: 0.12)
        }
    }

    var iconName: String {
        switch self {
        case .certified: return "checkmark.shield.fill"
        case .onRequest: return "bubble.left"
        case .containsHiddenGluten: return "exclamationmark.triangle.fill"
        }
    }

    /// Full localized status label (ja "認証済み" / en "Certified").
    var labelJa: String {
        switch self {
        case .certified: return String(localized: "認証済み")
        case .onRequest: return String(localized: "要相談")
        case .containsHiddenGluten: return String(localized: "隠れ小麦あり")
        }
    }

    /// Short localized label for compact badges (ja "認証" / en "OK").
    var shortJa: String {
        switch self {
        case .certified: return String(localized: "認証")
        case .onRequest: return String(localized: "相談")
        case .containsHiddenGluten: return String(localized: "注意")
        }
    }

    /// Reassurance line shown on the store-detail callout.
    var assuranceBody: String {
        switch self {
        case .certified: return String(localized: "専用調理・検査済み。コンタミ対策あり。")
        case .onRequest: return String(localized: "スタッフにGF対応をご相談いただけます。")
        case .containsHiddenGluten: return String(localized: "一部メニューに小麦が含まれます。ご注意ください。")
        }
    }
}
