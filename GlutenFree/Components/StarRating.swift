import SwiftUI

struct StarRating: View {
    let rating: Double
    var reviews: Int? = nil
    var size: CGFloat = 11

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").font(.system(size: size)).foregroundStyle(Theme.star)
            Text(String(format: "%.1f", rating))
                .font(.system(size: size + 2, weight: .bold))
                .foregroundStyle(Theme.ink)
            if let reviews {
                Text("(\(reviews))").font(.system(size: size + 1)).foregroundStyle(Theme.hint)
            }
        }
    }
}

struct PriceMark: View {
    let level: Int   // 1..3

    var body: some View {
        let clamped = max(1, min(level, 3))
        return HStack(spacing: 0) {
            Text(String(repeating: "¥", count: clamped)).foregroundStyle(Theme.sub)
            Text(String(repeating: "¥", count: 3 - clamped)).foregroundStyle(Theme.hint)
        }
        .font(.system(size: 13, weight: .semibold))
    }
}
