# iOS app — local dev setup

SwiftUI + MVVM, **iOS 16+**, talks to the Go backend (`glutenfree-go-server`).

## Run it

1. **Start the backend** (separate repo `~/projects/glutenfree/glutenfree-go-server`):
   ```bash
   make server        # reads app.env
   ```
   `app.env` sets `HTTP_SERVER_ADDRESS=0.0.0.0:8090` and points `DB_SOURCE` at the
   **shared Neon database** — the same data production serves. Nothing else to
   start: no local Postgres, no migrations.

   Sanity check:
   ```bash
   curl localhost:8090/health     # -> {"status":"ok"}
   ```

   *Want a throwaway local DB instead of Neon?* Only then do you need
   `make postgres && make createdb && make migrateup`, with `DB_SOURCE` overridden
   to `postgresql://root:secret@localhost:5432/glutenfree?sslmode=disable`.

2. **Point the app at it** — nothing to do by default.
   `GlutenFree/Config/AppConfig.swift` already resolves:

   | Build   | Base URL                                    |
   |---------|---------------------------------------------|
   | DEBUG   | `http://localhost:8090` (matches `app.env`) |
   | RELEASE | `https://api.gurufuri-jp.com`               |

   Override per-run with the `GF_API_BASE_URL` environment variable — e.g. to aim
   a debug build at production without touching code:
   ```bash
   SIMCTL_CHILD_GF_API_BASE_URL=https://api.gurufuri-jp.com \
     xcrun simctl launch booted com.glutenfree.gf
   ```
   In Xcode: **Product → Scheme → Edit Scheme → Run → Arguments → Environment
   Variables**. The Simulator reaches your Mac via `localhost`.

3. **App Transport Security — no exception needed.**
   iOS does not apply ATS to loopback, so `http://localhost:8090` works with no
   Info.plist changes, and this project deliberately has none. (Verified: the app
   gets `200`s from the local server with zero ATS keys set.)

   `NSAllowsLocalNetworking = YES` is only needed to reach your Mac by LAN IP or a
   `.local` hostname — not for `localhost`.

4. **StoreKit testing without App Store Connect** — `GlutenFree/GlutenFree.storekit`
   defines the `com.glutenfree.sub.monthly` product. Wire it up:
   **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration →
   GlutenFree.storekit**. (If Xcode won't open the file, recreate via
   *File → New → File → StoreKit Configuration File* and add a product with id
   `com.glutenfree.sub.monthly`.)

5. **Build & run** on an iOS 16+ simulator (⌘R), or from the command line:

   ```bash
   SIM=$(xcrun simctl list devices booted -j \
     | python3 -c 'import sys,json;d=json.load(sys.stdin)["devices"];print(next(x["udid"] for v in d.values() for x in v))')

   xcodebuild -project GlutenFree.xcodeproj -scheme GlutenFree -configuration Debug \
     -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath /tmp/gf-dd build

   xcrun simctl install "$SIM" /tmp/gf-dd/Build/Products/Debug-iphonesimulator/GlutenFree.app
   xcrun simctl launch  "$SIM" com.glutenfree.gf
   xcrun simctl io      "$SIM" screenshot /tmp/gf.png
   ```

   Bundle id `com.glutenfree.gf`, scheme `GlutenFree`.

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
