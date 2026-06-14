import SwiftUI

/// Store card in the three Explore layouts (rich hero / list row / grid tile).
/// (Named StoreCardView to avoid clashing with the `StoreCard` model.)
struct StoreCardView: View {
    let store: StoreCard
    let layout: StoreLayout
    @EnvironmentObject private var saved: SavedStore

    var body: some View {
        switch layout {
        case .rich: richCard
        case .list: listRow
        case .grid: gridTile
        }
    }

    private var isSaved: Bool { saved.isSaved(store.id) }
    private var seed: Int { store.id.hashValue }

    // MARK: - Rich

    private var richCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            StorePhoto(url: store.photoUrl, height: 152, cornerRadius: 0, seed: seed)
                .overlay(alignment: .topLeading) {
                    if store.isGfOriented { gfOrientedTag.padding(10) }
                }
                .overlay(alignment: .topTrailing) { heartButton(overPhoto: true).padding(8) }
                .overlay(alignment: .bottomLeading) { GFBadge(status: store.status).padding(10) }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(store.name)
                        .font(.system(size: 16.5, weight: .heavy))
                        .tracking(-0.3)
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    if store.rating > 0 { StarRating(rating: store.rating, reviews: store.reviewCount) }
                }
                metaLine
                if !store.blurb.isEmpty {
                    Text(store.blurb).font(.system(size: 13)).foregroundStyle(Theme.sub).lineLimit(2)
                }
            }
            .padding(14)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.radiusRich, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Metrics.radiusRich).stroke(Theme.separator, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - List

    private var listRow: some View {
        HStack(spacing: 12) {
            StorePhoto(url: store.photoUrl, width: 70, height: 70, cornerRadius: 12, seed: seed)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(store.name).font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.ink).lineLimit(1)
                    if store.rating > 0 { StarRating(rating: store.rating, size: 10) }
                }
                HStack(spacing: 6) {
                    Text(store.cuisine).foregroundStyle(Theme.sub)
                    PriceMark(level: store.priceLevel)
                    Text(store.nearestStation).foregroundStyle(Theme.hint).lineLimit(1)
                }
                .font(.system(size: 12))
                GFBadge(status: store.status, short: true)
            }
            Spacer(minLength: 0)
            heartButton(overPhoto: false)
        }
        .padding(12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.radiusRow, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Metrics.radiusRow).stroke(Theme.separator, lineWidth: 0.5))
    }

    // MARK: - Grid

    private var gridTile: some View {
        VStack(alignment: .leading, spacing: 0) {
            StorePhoto(url: store.photoUrl, height: 112, cornerRadius: 0, seed: seed)
                .overlay(alignment: .topLeading) { GFBadge(status: store.status, short: true).padding(7) }
                .overlay(alignment: .topTrailing) { heartButton(overPhoto: true).padding(6) }
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.ink).lineLimit(1)
                HStack(spacing: 5) {
                    if store.rating > 0 { StarRating(rating: store.rating, size: 9) }
                    Text(store.cuisine).font(.system(size: 11)).foregroundStyle(Theme.sub).lineLimit(1)
                }
            }
            .padding(10)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Metrics.radiusCard).stroke(Theme.separator, lineWidth: 0.5))
    }

    // MARK: - Pieces

    private var metaLine: some View {
        HStack(spacing: 6) {
            Text(store.cuisine).foregroundStyle(Theme.sub)
            Text("·").foregroundStyle(Theme.hint)
            PriceMark(level: store.priceLevel)
            Text("·").foregroundStyle(Theme.hint)
            HStack(spacing: 2) {
                Image(systemName: "mappin.and.ellipse").font(.system(size: 10))
                Text(store.nearestStation).lineLimit(1)
            }
            .foregroundStyle(Theme.sub)
        }
        .font(.system(size: 12))
    }

    private var gfOrientedTag: some View {
        HStack(spacing: 3) {
            Image(systemName: "leaf.fill").font(.system(size: 9))
            Text("GF対応店").font(.system(size: 11, weight: .bold))
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .foregroundStyle(Theme.brand700)
        .clipShape(Capsule())
    }

    private func heartButton(overPhoto: Bool) -> some View {
        Button {
            saved.toggle(store)
        } label: {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSaved ? Theme.systemRed : (overPhoto ? Color.white : Theme.hint))
                .frame(width: overPhoto ? 32 : 28, height: overPhoto ? 32 : 28)
                .background(overPhoto ? Color.black.opacity(0.28) : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
