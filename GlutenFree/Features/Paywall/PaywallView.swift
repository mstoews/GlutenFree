import SwiftUI
import StoreKit

/// Shown when the user hits paid content (a 402) or taps Subscribe. Loads
/// products and drives the purchase; `onSubscribed` fires once the backend
/// confirms an active subscription.
struct PaywallView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    var onSubscribed: () -> Void = {}

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)
                Text("Unlock GF menus")
                    .font(.title.bold())
                Text("Subscribe to see verified gluten-free dishes, prices, and notes for every store.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                if subscriptions.isLoadingProducts {
                    ProgressView()
                } else if subscriptions.products.isEmpty {
                    Text("Subscriptions are unavailable right now.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(subscriptions.products, id: \.id) { product in
                        Button {
                            purchase(product)
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice).bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }

                Button("Restore purchases") {
                    Task {
                        if await subscriptions.restore() { onSubscribed(); dismiss() }
                    }
                }
                .font(.footnote)

                if let error = subscriptions.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await subscriptions.loadProducts() }
            .overlay {
                if subscriptions.isPurchasing {
                    ZStack {
                        Color.black.opacity(0.15).ignoresSafeArea()
                        ProgressView().controlSize(.large)
                    }
                }
            }
        }
    }

    private func purchase(_ product: Product) {
        Task {
            if await subscriptions.purchase(product) { onSubscribed(); dismiss() }
        }
    }
}
