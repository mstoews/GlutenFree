# iOS app — local dev setup

SwiftUI + MVVM, **iOS 16+**, talks to the Go backend (`glutenfree-go-server`).

## Run it

1. **Start the backend** (separate repo `~/projects/glutenfree/glutenfree-go-server`):
   ```bash
   make postgres && make createdb && make migrateup && make server
   ```
   The backend defaults to `:8080`. If another service owns 8080 on your Mac,
   run it elsewhere (e.g. `HTTP_SERVER_ADDRESS=0.0.0.0:8090` in `app.env`) and
   update `baseURL` below to match.

2. **Point the app at it** — `GlutenFree/Config/AppConfig.swift`:
   ```swift
   static let baseURL = URL(string: "http://localhost:8080")!
   ```
   The iOS Simulator reaches your Mac via `localhost`.

3. **Allow HTTP to localhost (dev only)** — plain HTTP needs an ATS exception.
   In Xcode: target **GlutenFree → Info** → add **App Transport Security
   Settings** → **Allow Local Networking = YES** (or, for quick dev, **Allow
   Arbitrary Loads = YES**). Remove before shipping; production should use HTTPS.

4. **StoreKit testing without App Store Connect** — `GlutenFree/GlutenFree.storekit`
   defines the `com.glutenfree.sub.monthly` product. Wire it up:
   **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration →
   GlutenFree.storekit**. (If Xcode won't open the file, recreate via
   *File → New → File → StoreKit Configuration File* and add a product with id
   `com.glutenfree.sub.monthly`.)

5. **Build & run** on an iOS 16+ simulator.

## What works end-to-end

- Register / sign in (tokens stored in Keychain; auto-refresh on 401)
- Stores tab: ward-filtered, paginated list → store detail (hours, Apple/Google
  Maps directions) → **GF menu gated by 402** → paywall → StoreKit purchase →
  backend verify → menu unlocks
- Account tab: subscription status, subscribe, restore, sign out

## Architecture

```
Config/        AppConfig (base URL, product ids)
Models/        Codable DTOs matching backend JSON
Networking/    APIClient (async, bearer, 401-refresh, 402->paywall) + APIError
Auth/          KeychainStore + SessionStore (auth state, ObservableObject)
StoreKit/      SubscriptionManager (purchase -> /subscription/verify)
Features/      Auth, Stores (list/detail/menu + view models), Account, Paywall
App/           RootView (auth gate) + MainTabView
Shared/        InfoStateView, Formatters
```

Non-SwiftUI `ObservableObject` files import **Combine** explicitly (SwiftUI
re-exports it, plain Foundation files don't).
