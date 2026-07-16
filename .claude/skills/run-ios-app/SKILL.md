---
name: run-ios-app
description: Build, launch and drive the GlutenFree (グルフリ) iOS app in the simulator, wired to the Go backend. Use when asked to run, start, screenshot, or verify a change in the iOS app.
---

# Run the GlutenFree iOS app in the simulator

SwiftUI + MVVM, iOS 16+. Scheme `GlutenFree`, bundle id `com.glutenfree.gf`.
Verified working on Xcode 26.6 / iPhone 17 simulator.

## 1. The backend must be running first

A DEBUG build talks to `http://localhost:8090`. Without it the app launches but
the Explore tab shows an error.

```bash
cd ~/projects/glutenfree/glutenfree-go-server
make server                       # reads app.env: :8090, DB_SOURCE -> shared Neon
curl -sf localhost:8090/health    # -> {"status":"ok"}
```

`app.env` already points at the shared **Neon** database, so **no local Postgres
and no migrations are needed**. (`docs/ios-dev.md` used to claim `:8080` + a local
Postgres — both wrong.)

To skip the local backend entirely and hit production instead, see step 4.

## 2. Build

```bash
cd ~/projects/glutenfree/gluten-free-ios

# udid of an already-booted sim, else boot one:
SIM=$(xcrun simctl list devices booted -j \
  | python3 -c 'import sys,json;d=json.load(sys.stdin)["devices"];print(next((x["udid"] for v in d.values() for x in v),""))')
[ -z "$SIM" ] && SIM=$(xcrun simctl list devices available -j \
  | python3 -c 'import sys,json;d=json.load(sys.stdin)["devices"];print(next(x["udid"] for v in d.values() for x in v if "iPhone" in x["name"]))') \
  && xcrun simctl boot "$SIM"

xcodebuild -project GlutenFree.xcodeproj -scheme GlutenFree -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath /tmp/gf-dd build
```

Takes a few minutes cold. `** BUILD SUCCEEDED **` is the line to look for.

## 3. Install, launch, look

```bash
open -a Simulator
xcrun simctl install   "$SIM" /tmp/gf-dd/Build/Products/Debug-iphonesimulator/GlutenFree.app
xcrun simctl terminate "$SIM" com.glutenfree.gf 2>/dev/null
xcrun simctl launch    "$SIM" com.glutenfree.gf
sleep 6
xcrun simctl io        "$SIM" screenshot /tmp/gf.png
```

**Read `/tmp/gf.png`.** A blank/black frame means it didn't really launch.

Expected: either the login screen (グルフリ / GURUFURI, email + password + Sign in
with Apple) or, if a Keychain session survives, the **Explore** tab with
restaurant cards, ward chips (Chiyoda/Chuo/…) and an Explore/Saved/Account tab bar.

## 4. Point it somewhere else

`AppConfig.baseURL`: DEBUG → `http://localhost:8090`, RELEASE →
`https://api.gurufuri-jp.com`. A `GF_API_BASE_URL` env var overrides it in DEBUG.
`simctl` passes env through with a `SIMCTL_CHILD_` prefix:

```bash
SIMCTL_CHILD_GF_API_BASE_URL=https://api.gurufuri-jp.com \
  xcrun simctl launch "$SIM" com.glutenfree.gf
```

Useful when you don't want to run a local backend at all — production serves the
same Neon data over HTTPS.

## 5. Prove it's really talking to the backend

Launching only proves the entrypoint resolves. Confirm real traffic:

```bash
tail -5 /tmp/gf-ios-backend.log     # or wherever `make server` logs
```

An app-originated call looks like:

```
[GIN] 200 | GET "/stores?cursor=a28799b1-..."
```

The cursor param is the giveaway — only the app paginates that way.

## Gotchas

- **ATS needs no exception.** iOS does not apply App Transport Security to
  loopback, so plain `http://localhost:8090` works and the project has no ATS
  keys. Don't go hunting for one. (`NSAllowsLocalNetworking` is only for LAN IPs
  / `.local` hostnames.)
- **Port 8090 collides.** Test harnesses in this workspace have bound `:8090`
  before. If login fails oddly, check `lsof -nP -iTCP:8090 -sTCP:LISTEN` for a
  stray server answering instead of `make server`.
- **The app only sees `status = 'approved'` stores.** An empty Explore tab is
  usually a catalog problem, not an app bug — check the operator portal.
- **`simctl install` keeps the app container**, so a previous Keychain session
  survives a reinstall; the app may open straight to Explore rather than login.
- **Driving the UI** (typing/tapping) has no simctl equivalent — use the
  `GlutenFreeUITests` XCUITest target if you need real interaction.
