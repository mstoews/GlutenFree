import SwiftUI

/// Photo with a warm gradient + leaf placeholder (matches the prototype's
/// gradient blocks while real CDN photos are wired up).
struct StorePhoto: View {
    let url: String?
    var width: CGFloat? = nil
    var height: CGFloat
    var cornerRadius: CGFloat = Metrics.radiusRich
    var seed: Int = 0

    private static let palettes: [[UInt]] = [
        [0xf5e6cf, 0xe6cfa6],
        [0xe7ead9, 0xcdd8b8],
        [0xf0e4d4, 0xdcc9a8],
        [0xe8e2d0, 0xd2c3a0],
    ]

    var body: some View {
        content
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if let url, let parsed = URL(string: url) {
            AsyncImage(url: parsed) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "leaf.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    private var gradient: [Color] {
        Self.palettes[abs(seed) % Self.palettes.count].map { Color(hex: $0) }
    }
}
