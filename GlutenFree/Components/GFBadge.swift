import SwiftUI

enum GFBadgeStyle { case pill, dot, tag }

struct GFBadge: View {
    let status: GFStatus
    var style: GFBadgeStyle = .pill
    var short: Bool = false

    private var text: String { short ? status.shortJa : status.labelJa }

    var body: some View {
        switch style {
        case .pill:
            HStack(spacing: 4) {
                Image(systemName: status.iconName).font(.system(size: 10, weight: .bold))
                Text(text).font(.system(size: 11, weight: .bold))
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(status.badgeBackground)
            .foregroundStyle(status.color)
            .clipShape(Capsule())
        case .dot:
            HStack(spacing: 5) {
                Circle().fill(status.dotColor).frame(width: 7, height: 7)
                Text(text).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.sub)
            }
        case .tag:
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(status.color)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
    }
}
