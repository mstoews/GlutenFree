import SwiftUI

struct StoreDetailView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var saved: SavedStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let card: StoreCard

    @StateObject private var vm = StoreDetailViewModel()
    @State private var showDirections = false
    @State private var showPaywall = false

    private var isSaved: Bool { saved.isSaved(card.id) }
    private var openState: OpenState { OpenStatus.now(vm.detail?.openingHours ?? []) }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.page.ignoresSafeArea()
            scroll
            topBar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .task { await vm.load(api: session.api, id: card.id) }
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeName: card.name)
        }
    }

    // MARK: Scroll body

    private var scroll: some View {
        ScrollView {
            VStack(spacing: 0) {
                StorePhoto(url: card.photoUrl, height: 300, cornerRadius: 0, seed: card.id.hashValue)
                VStack(spacing: 14) {
                    infoCard
                    assuranceCallout
                    accessSection
                    if let detail = vm.detail, !detail.openingHours.isEmpty {
                        hoursSection(detail.openingHours)
                    }
                }
                .padding(.horizontal, Metrics.page)
                .padding(.top, -26)
                .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: Info card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if card.isGfOriented { gfOrientedTag }
                if openState != .unknown { openPill }
                Spacer(minLength: 0)
            }
            Text(card.name)
                .font(.system(size: 24, weight: .heavy)).tracking(-0.4)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                if card.rating > 0 {
                    StarRating(rating: card.rating, reviews: card.reviewCount)
                    dot
                }
                if !card.cuisine.isEmpty {
                    Text(card.cuisine).foregroundStyle(Theme.sub)
                    dot
                }
                PriceMark(level: card.priceLevel)
            }
            .font(.system(size: 13))

            if !card.blurb.isEmpty {
                Text(card.blurb)
                    .font(.system(size: 14)).foregroundStyle(Theme.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.separator, lineWidth: 0.5))
    }

    private var dot: some View { Text("·").foregroundStyle(Theme.hint) }

    private var gfOrientedTag: some View {
        HStack(spacing: 3) {
            Image(systemName: "leaf.fill").font(.system(size: 9))
            Text("GF対応店").font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(Theme.brand700)
        .padding(.horizontal, 9).padding(.vertical, 4)
        .background(Theme.brandSoft)
        .clipShape(Capsule())
    }

    private var openPill: some View {
        HStack(spacing: 4) {
            Circle().fill(openState.isOpen ? Theme.brand600 : Theme.hint).frame(width: 7, height: 7)
            Text(openState.labelJa).font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(openState.isOpen ? Theme.brand700 : Theme.sub)
        .padding(.horizontal, 9).padding(.vertical, 4)
        .background(openState.isOpen ? Theme.brandSoft : Theme.card2)
        .clipShape(Capsule())
    }

    // MARK: Assurance callout

    private var assuranceCallout: some View {
        HStack(spacing: 12) {
            Image(systemName: card.status.iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(card.status.dotColor)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(card.status.labelJa)
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.ink)
                Text(card.status.assuranceBody)
                    .font(.system(size: 13)).foregroundStyle(Theme.sub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.status.badgeBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: Access

    private var accessSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("場所・アクセス")
            VStack(spacing: 0) {
                accessRow(icon: "mappin.and.ellipse", label: "住所",
                          value: vm.detail?.address ?? "—",
                          tappable: vm.detail != nil) {
                    showDirections = true
                }
                .confirmationDialog("経路を開く", isPresented: $showDirections, titleVisibility: .visible) {
                    Button("Appleマップ") { openMaps(.apple) }
                    Button("Googleマップ") { openMaps(.google) }
                    Button("キャンセル", role: .cancel) {}
                }
                if !card.nearestStation.isEmpty {
                    rowDivider
                    accessRow(icon: "tram.fill", label: "最寄り駅",
                              value: card.nearestStation, tappable: false, action: nil)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
        }
    }

    @ViewBuilder
    private func accessRow(icon: String, label: String, value: String,
                           tappable: Bool, action: (() -> Void)?) -> some View {
        let content = HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 15)).foregroundStyle(Theme.brand).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 11)).foregroundStyle(Theme.hint)
                Text(value).font(.system(size: 15)).foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            if tappable {
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.hint)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .contentShape(Rectangle())

        if tappable, let action {
            Button(action: action) { content }.buttonStyle(.plain)
        } else {
            content
        }
    }

    private var rowDivider: some View {
        Divider().overlay(Theme.separator).padding(.leading, 48)
    }

    // MARK: Hours

    private func hoursSection(_ hours: [OpeningHour]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("営業時間")
            VStack(spacing: 0) {
                ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
                    HStack {
                        Text(Formatters.weekdayJa(hour.day) + "曜日")
                            .font(.system(size: 14)).foregroundStyle(Theme.ink)
                        Spacer()
                        Text("\(Formatters.clock(hour.open)) – \(Formatters.clock(hour.close))")
                            .font(.system(size: 14)).foregroundStyle(Theme.sub)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    if index < hours.count - 1 {
                        Divider().overlay(Theme.separator).padding(.horizontal, 14)
                    }
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.sub)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
    }

    // MARK: Floating top bar

    private var topBar: some View {
        HStack {
            circleButton(icon: "chevron.left") { dismiss() }
            Spacer()
            circleButton(icon: isSaved ? "heart.fill" : "heart",
                         tint: isSaved ? Theme.systemRed : Theme.ink) {
                saved.toggle(card)
            }
        }
        .padding(.horizontal, Metrics.page)
        .padding(.top, 6)
    }

    private func circleButton(icon: String, tint: Color = Theme.ink, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Sticky CTA

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider().overlay(Theme.separator)
            Group {
                if session.isSubscribed {
                    NavigationLink {
                        MenuView(storeID: card.id, storeName: card.name)
                    } label: {
                        ctaLabel("メニューを見る", systemImage: "fork.knife")
                    }
                } else {
                    Button { showPaywall = true } label: {
                        ctaLabel("メニューを解放（メンバー限定）", systemImage: "lock.fill")
                    }
                }
            }
            .padding(.horizontal, Metrics.page)
            .padding(.top, 10)
            .padding(.bottom, 6)
        }
        .background(Theme.card)
    }

    private func ctaLabel(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).font(.system(size: 15, weight: .semibold))
            Text(text).font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity).frame(height: 52)
        .background(Theme.brand).foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: Maps

    private enum MapProvider { case apple, google }

    private func openMaps(_ provider: MapProvider) {
        guard let detail = vm.detail else { return }
        let lat = detail.latitude, lng = detail.longitude
        let name = detail.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url: URL?
        switch provider {
        case .apple:
            url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(name)")
        case .google:
            if let app = URL(string: "comgooglemaps://?q=\(lat),\(lng)"),
               UIApplication.shared.canOpenURL(app) {
                url = app
            } else {
                url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lng)")
            }
        }
        if let url { openURL(url) }
    }
}
