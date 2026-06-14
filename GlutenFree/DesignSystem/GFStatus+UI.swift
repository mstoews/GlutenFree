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

    /// Full Japanese label (e.g. "認証済み").
    var labelJa: String {
        switch self {
        case .certified: return "認証済み"
        case .onRequest: return "要相談"
        case .containsHiddenGluten: return "隠れ小麦あり"
        }
    }

    /// Short Japanese label for compact badges (e.g. "認証").
    var shortJa: String {
        switch self {
        case .certified: return "認証"
        case .onRequest: return "相談"
        case .containsHiddenGluten: return "注意"
        }
    }
}
