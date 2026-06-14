import SwiftUI

enum StoreLayout: String, CaseIterable {
    case rich, list, grid

    var icon: String {
        switch self {
        case .rich: return "rectangle.grid.1x2"
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

struct LayoutSwitcher: View {
    @Binding var layout: StoreLayout

    var body: some View {
        HStack(spacing: 2) {
            ForEach(StoreLayout.allCases, id: \.self) { option in
                Button { layout = option } label: {
                    Image(systemName: option.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 32, height: 28)
                        .background(layout == option ? Theme.card : Color.clear)
                        .foregroundStyle(layout == option ? Theme.brand : Theme.sub)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Theme.card2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
