import SwiftUI

struct WardChips: View {
    let wards: [Ward]
    let selected: Int?
    let onSelect: (Int?) -> Void
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: Text("すべて"), isSelected: selected == nil) { onSelect(nil) }
                ForEach(wards) { ward in
                    chip(label: Text(verbatim: wardName(ward)), isSelected: selected == ward.id) { onSelect(ward.id) }
                }
            }
            .padding(.horizontal, Metrics.page)
            .padding(.vertical, 8)
        }
    }

    private func wardName(_ ward: Ward) -> String {
        locale.language.languageCode?.identifier == "ja" ? ward.nameJa : ward.nameEn
    }

    private func chip(label: Text, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            label
                .font(.system(size: 14, weight: isSelected ? .bold : .semibold))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected ? Theme.brand : Theme.card)
                .foregroundStyle(isSelected ? Color.white : Theme.ink)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.separator, lineWidth: isSelected ? 0 : 1))
        }
        .buttonStyle(.plain)
    }
}
