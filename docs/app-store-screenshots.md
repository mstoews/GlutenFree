# App Store Connect screenshots

`scripts/appstore_screenshots.sh` captures the store listing screenshots by
driving the real app in the simulator via `GlutenFreeUITests/AppStoreShots`.

## Run it

```bash
cd ~/projects/glutenfree/glutenfree-go-server && make server   # backend on :8090
cd ~/projects/glutenfree/gluten-free-ios
scripts/appstore_screenshots.sh                # full matrix, ~10 min
scripts/appstore_screenshots.sh iphone-6.9     # one size
scripts/appstore_screenshots.sh iphone-6.9 en  # one size, one locale
```

Output lands in `screenshots/<size>/<locale>/NN-screen.png`.

## What it produces

| Size       | Device               | Pixels      | Locales |
| ---------- | -------------------- | ----------- | ------- |
| `iphone-6.9` | iPhone 17 Pro Max  | 1320 × 2868 | ja, en  |
| `ipad-13`    | iPad Pro 13-inch (M5) | 2064 × 2752 | ja, en  |

Six screens each: Explore (rich), Explore (grid), store detail, unlocked menu,
Saved, Account. App Store Connect derives every smaller size from these two, so
a universal app needs no other captures.

The script overrides the simulator status bar to 9:41 with full signal and
battery, and verifies every PNG's pixel dimensions after export.

## Requirements

- The Go backend on `:8090` (`GF_API_BASE_URL` overrides the host).
- The `demo@example.com` account with an **active subscription** — otherwise
  the menu screen captures as the paywall instead of the unlocked menu.

## How it works

`xcodebuild test` runs one `AppStoreShots` method per device × locale. The test
attaches each screenshot via `XCTAttachment`; the script then pulls them out of
the result bundle with `xcresulttool export attachments` and renames them from
the exported UUIDs back to `NN-screen.png` using `manifest.json`. Attachments
XCUITest adds on its own — screen recordings, UI snapshots, synthesized events —
are filtered out.

Parallel testing is disabled deliberately: it runs on a throwaway clone device,
and the status bar override would not follow.

### Locale handling

There is one test method per locale — `testCaptureJapanese`,
`testCaptureEnglish` — and the script picks the method. This is not cosmetic:

> **Environment set on `xcodebuild` does not reach the test runner.** The runner
> is a separate process inside the simulator. An env-driven locale therefore
> falls back to its default *silently*, and every locale captures identically.
> `TEST_RUNNER_`-prefixed settings are supposed to bridge this and did not work
> here, so the locale is baked into the test name instead.

Each method sets the language three ways, all of which must agree:
`-AppleLanguages`/`-AppleLocale` for the OS, and `-gf.languageOverride` for
`LanguageManager`'s persisted in-app toggle.

### Why the element queries look the way they do

- **Never pass `-gf.selectedTab`.** Launch arguments land in `NSArgumentDomain`,
  which outranks anything `@AppStorage` writes back — pinning the key freezes
  the `TabView` on Explore for the whole run, and Saved/Account then capture as
  duplicates of the previous screen. The script uninstalls the app between runs
  to reset the tab instead. (`-gf.paywallSeen 1` is passed on purpose: it is
  read-only, and suppresses the onboarding paywall that can race the
  subscription check at launch.)
- **Tab lookup is device-dependent.** iPhone renders a real `TabBar` element, so
  the tabs are addressed by position — SwiftUI only intermittently lifts a
  `Label`'s SF Symbol identifier onto the tab button. iPadOS 26 renders the same
  `TabView` as a floating strip of loose buttons at the *top* of the window with
  no `TabBar` container at all, so there the symbol identifier is the only
  handle, and the topmost match wins (card hearts share the `heart` identifier).
- **Store cards are found by text height.** Explore cards are plain views with
  an `onTapGesture`, so the title is a `staticText`, not a button. The title is
  the only text in a card at ≥18pt, which separates it from the badges, price
  marks and `·` separators around it.
- **Nothing matches on a hardcoded store name.** `AppStoreScreens.swift`,
  `PhaseBScreens.swift` and `PhaseCScreens.swift` all wait on
  `米粉キッチン こめこ`. That store is still in the approved catalog, but it now
  sits sixth in the default order — below the fold, so it cannot be tapped
  without scrolling first. Matching the first visible card avoids the problem
  entirely and survives the next catalog change.

## Known content gaps

The captures are only as good as the catalog behind them. As of the current
shared Neon data (20 approved stores, same on local and production):

| Field | Populated |
| --- | --- |
| `photo_url` | 0/20 — every card and hero image renders the placeholder gradient |
| `rating`, `review_count` | 2/20 — no star ratings |
| `cuisine`, `nearest_station`, `blurb` | 2/20 — the card meta line renders with gaps |
| `gf_status` | 20/20, but all `on_request` — the green 認証済み badge never appears |
| menu `price_yen` | 0/12 — every menu row shows ¥0 |
| menu `image_url`, `gf_note` | 0/12 |

Populate the catalog through the operator portal and re-run the script; no
changes to the harness are needed.
