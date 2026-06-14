# Handoff: Gurufuri — Gluten-Free Restaurant Finder (iOS user app)

## Overview
Gurufuri (グルフリ) is a subscription gluten-free restaurant discovery app for Japan
(Tokyo-first). This package documents the **user-facing iOS app** design: onboarding/login,
store browsing with ward filters, store detail, full menu, wishlist, account, and a
StoreKit-style paywall that gates menus for free-tier users.

It corresponds to the product spec in `design.md` (screen architecture, data model, API
routes, StoreKit 2 flow, approval flow). This handoff covers the **design** of the MVP user
screens — not the admin portal or backend.

## About the Design Files
The files in this bundle are **design references created in HTML/React** — prototypes that
show the intended look, layout, copy, and behavior. **They are not production code to copy.**

The target app (`/Users/murraytoews/Desktop/GlutenFree`) is a **SwiftUI + MVVM** iOS app
(`NavigationStack` for drill-down, `TabView` for the shell — see `design.md`). The task is to
**recreate these designs natively in SwiftUI**, using the app's existing patterns: SwiftUI
views, `NavigationStack`, `.sheet` for the paywall/action sheets, StoreKit 2 for purchases,
`AsyncImage` for the photos that currently use gradient placeholders. Treat the HTML as the
visual + interaction spec, not the implementation.

To **view** the design without any tooling, open `Gurufuri.html` (a standalone, offline
single-file build). To read the **source** of the prototype, see `source/` (commented JSX).

## Fidelity
**High-fidelity.** Final colors, typography, spacing, copy (bilingual JA/EN), and
interactions are all specified. Recreate the UI pixel-accurately in SwiftUI. The only
placeholders are **food photos** — rendered as warm gradient blocks with a leaf glyph;
replace with real CDN photography (`AsyncImage`), keeping the same aspect ratios / corner radii.

---

## Screens / Views

### 1. Login / Onboarding  (`source/app/screens-auth-list.jsx` → `LoginScreen`)
- **Purpose:** First-launch auth. Email/password + Sign in with Apple.
- **Layout:** Full-bleed top hero (~38% height) in an emerald diagonal gradient with two
  faint stroked decorative circles; centered brand lockup (leaf glyph in a rounded translucent
  square + `グルフリ` wordmark + `GURUFURI` overline). Below the hero, a white/dark form region:
  email field, password field (with show/hide eye), primary **ログイン / Log In** button,
  `または / or` divider, black **Appleでサインイン / Sign in with Apple** button, then a
  `新規登録 / Create account` link and version string `Noble Ledger · Gurufuri v0.0.4.66`.
- **Components:**
  - Hero gradient: `linear-gradient(155deg, emerald-600 → emerald-800)`.
  - Headline: SF/system, 21px, weight 800, white — `安心して、外食を。` / `Dine out, worry-free.`
  - Fields: 50px tall, radius 12, leading icon, 16px text; light = white w/ 1px slate border,
    dark = `rgba(118,118,128,0.24)` fill no border.
  - Primary button: emerald, white text, 50px tall, radius 12, weight 700.
  - Apple button: black (light) / white (dark), Apple glyph + label.
- **Behavior:** Any button → authenticated; sets persisted auth flag; lands on the Explore tab.
  Status bar text is white over the emerald hero.

### 2. Store List / Explore  (KEY SCREEN — `StoreListScreen`, `cards.jsx`)
- **Purpose:** Browse vetted GF stores; filter by Tokyo ward; switch layouts.
- **Layout:** Large translucent title bar (`探す / Explore`, subtitle `東京 · グルテンフリー対応`)
  with a **layout segmented control** on the right (Rich / List / Grid). Below: a search field
  (display-only), a horizontally-scrolling **ward chip** row (`すべて`, `渋谷区`, `新宿区`, `港区`,
  `目黒区`, `世田谷区`, `台東区`), a result count + `近い順 / Nearest` sort affordance, then the
  store collection.
- **Three layout directions (the explored variations, switchable live):**
  - **Rich** — full-bleed photo hero cards (radius 18): GF-oriented tag + GF status tag on the
    photo, heart top-right; below, name (16.5px/800), cuisine · price · station, rating w/ reviews,
    blurb.
  - **List** — compact rows (radius 14): 70px rounded thumb, name + inline star, cuisine · price ·
    distance, GF badge, trailing heart.
  - **Grid** — 2-up tiles (radius 16): photo with GF badge + heart, name, star + cuisine.
- **Density** (compact / regular / comfy) scales gaps, padding, photo heights, thumb sizes
  (see `DENS` map in `cards.jsx`).

### 3. Store Detail  (`screens-detail.jsx` → `StoreDetailScreen`)
- **Purpose:** Hours, GF assurance, address → maps, menu preview (gated).
- **Layout (scroll):** 256px photo hero with translucent back + heart buttons; a card that
  overlaps the hero by -22px (radius 20 top) holding: GF-oriented + **Open now / Closed** pills,
  store name (24px/800), rating · cuisine · price, blurb. Then a **GF assurance callout**
  (tinted to the store's status with icon + blurb), a **Location** card (address row → opens an
  iOS action sheet; nearest station; phone), an **Opening hours** card (Mon→Sun, today
  highlighted in the accent color, `定休日 / Closed` for closed days), and a **Menu preview**.
- **Menu gating (free tier):** preview card is blurred (`blur(5px)`) with a centered lock chip
  (`全N品をGurufuri+で解放 / Unlock all N items`) and an Unlock pill; the pinned bottom CTA reads
  **メニューを解放（メンバー限定） / Unlock full menu** with a lock icon. Subscribed users see the
  real preview and **メニューを見る / View full menu**.
- **Address action sheet:** Apple Maps (bold) / Google Maps / Copy address / Cancel.
  In SwiftUI: `MKMapItem.openInMaps` and `comgooglemaps://` w/ HTTPS fallback (per `design.md`).

### 4. Menu  (`MenuScreen`)
- **Purpose:** Full item list, paid-tier only.
- **Layout:** Back nav bar (store name + `メニュー · 全N品`), a GF-status legend (3 colored dots
  with labels), then a card listing items sorted **certified → on_request →
  contains_hidden_gluten**. Each row: 60px rounded photo, name (14.5px/700), GF note, GF badge,
  trailing price (tabular). Footer disclaimer that GF info is store-submitted + internally reviewed.

### 5. Wishlist / Saved  (`WishlistScreen`)
- **Purpose:** Saved stores per user.
- **Layout:** Large `お気に入り / Saved` title with count. Empty state = circular heart glyph +
  `まだ保存がありません / Nothing saved yet` + helper. Populated = store collection (list/grid).

### 6. Account  (`AccountScreen`)
- **Purpose:** Profile, subscription, settings.
- **Layout:** Profile card (gradient avatar initial, name, email, chevron). **Subscription card**
  (accent gradient) that reflects entitlement: free → `未加入 / Free` + `From ¥480/mo` +
  **アップグレード / Upgrade** (opens paywall); subscribed → `有効 / Active` + renewal date +
  **管理 / Manage**. Settings list (dietary prefs, contact, report a store [Soon], terms).
  Version footer.

### 7. Paywall  (`screens-paywall.jsx` → `Paywall`)
- **Purpose:** StoreKit 2 subscription gate. **Surfaces on the first menu tap** (the
  `GET /stores/:id/menu` → `402` gate), not at login. Also reachable from Account → Upgrade.
- **Layout:** Presented bottom sheet, 94% height, radius 22 top, grabber + close (×). Emerald
  hero with a `Gurufuri+` badge (sparkle), headline `全メニューを、解放しよう。 / Unlock every menu.`,
  store-contextual subtext. Benefits list (4 items, accent check chips). Two selectable plan
  cards — **Annual ¥3,800/yr** (selected default, `おすすめ / Best value` badge, `¥317/mo · 2
  months free`) and **Monthly ¥480/mo**. Auto-renew fine print. Pinned CTA (Apple glyph +
  `¥X/期間で続ける / Continue — ¥X`). Footer: Restore / Terms / Privacy.
- **Behavior:** Choosing a plan + Continue (or Restore) → marks subscribed, dismisses the sheet,
  and **opens the menu for the originating store**. SwiftUI: present as `.sheet`, drive purchase
  with `Product.purchase()`, verify via `POST /subscription/verify` (signed JWS), then unlock.

---

## Interactions & Behavior
- **Navigation:** Tab shell (Explore / Saved / Account). Store tap → Detail (push). Detail
  → Menu (push, or Paywall if free). Detail/Menu hide the tab bar (full-screen pushes).
- **Save/wishlist:** Heart toggles on cards + detail hero; badge count on the Saved tab;
  persisted.
- **Paywall trigger:** free-tier menu tap; persists entitlement; re-taps go straight to Menu.
- **Action sheet & paywall:** slide-up, backdrop `rgba(0,0,0,0.45)`, ease
  `cubic-bezier(.2,.8,.2,1)`, ~280–320ms. (In SwiftUI use native `.sheet` / `.confirmationDialog`.)
- **Open-now logic:** computed from `opening_hours` vs. current weekday/time; `"HHMM"` where
  `open == close` means closed. Demo "now" = Friday 13:20.
- **No hover/scale press states** (touch app); restrained motion per the design system.

## State Management
- `loggedIn` (persisted) — gates the app vs. login.
- `tab` — `stores | wishlist | account`.
- Navigation stack — `detailId`, `menuId` (pushed views).
- `ward` — active ward filter (0 = all).
- `saved` — Set of store IDs (persisted).
- `subscribed` — entitlement (persisted); gates menu + Account card + paywall.
- `paywall` — `{ store: id | null }` (open + origin context).
- Tweaks (design-time options, see below) — `lang`, `dark`, `accent`, `layout`, `density`, `badge`.
- **Data fetching (production):** `GET /wards`, `GET /stores?ward_id=&cursor=`, `GET /stores/:id`,
  `GET /stores/:id/menu` (402 if free), `GET/POST /subscription/*` — see `design.md` API table.

## Design Tokens
Sourced from the NobleLedger design system (`colors_and_type.css`). Emerald is the lead brand
color; indigo is the alternate accent. GF-status colors are **fixed/semantic** (they encode
trust, never re-skinned by the accent).

**Brand / accent**
- Emerald: 600 `#059669`, **700 `#047857` (primary, light)**, 800 `#065f46`, soft `rgba(5,150,105,0.12)`, 50 `#ecfdf5`
- Indigo (alt accent): 600 `#4f46e5`, 700 `#4338ca`, 800 `#3730a3`, soft `rgba(79,70,229,0.12)`, 50 `#eef2ff`
- Primary in dark mode uses the 600 step for contrast.

**GF status (semantic — do not theme)**
- Certified: fg `#047857`, bg `rgba(16,185,129,0.12)`, dot `#059669`, icon = shield
- On request: fg `#b45309`, bg `rgba(245,158,11,0.14)`, dot `#d97706`, icon = chat
- Hidden gluten: fg `#dc2626`, bg `rgba(220,38,38,0.12)`, dot `#dc2626`, icon = alert

**Neutrals / surfaces**
- Light: page `#f2f2f7`, card `#ffffff`, ink `#11141a`, sub `#6b7280`, hint `#9aa1ac`,
  separator `rgba(60,60,67,0.12)`, fill `rgba(118,118,128,0.10)`.
- Dark: page `#000000`, card `#1c1c1e`, card2 `#2c2c2e`, ink `#f5f5f7`, sub `rgba(235,235,245,0.62)`,
  hint `rgba(235,235,245,0.38)`, separator `rgba(255,255,255,0.10)`.
- iOS system red (destructive / saved heart): `#ff3b30`. Star: `#f5a623`.

**Typography**
- App UI uses the iOS system font (`-apple-system / SF Pro`). Brand reference face in the design
  system is **Inter var**; mono is IBM Plex Mono. In SwiftUI use the system font.
- Scale (px): caption 11–12, body 13–15, row title 14.5–16.5/700–800, screen title 22–24/800,
  store-detail name 24/800. Letter-spacing −0.01 to −0.02em on titles. Tabular numerals for prices.

**Spacing / radius / shadow**
- 4-pt grid. Page padding 16px. Card inner padding 14–18px.
- Radius: rows 12–14, cards 16, rich cards 18, sheets/hero 20–22, pills/chips 999.
- Shadows are subtle: light cards `0 1px 3px rgba(0,0,0,0.05)` to `0 2px 10px rgba(0,0,0,0.07)`;
  dark uses a hairline outline instead of shadow.
- Device frame: 402×874 (iPhone), 48px corner radius (prototype chrome only).

## Tweaks (design-time variants, not app settings)
The prototype exposes a Tweaks panel to explore directions; bake the chosen defaults into the app:
**Language** JA/EN · **Dark mode** · **Accent** emerald/indigo · **Store-list layout**
rich/list/grid · **Density** compact/regular/comfy · **GF badge style** pill/dot/tag.
Recommended shipping defaults: Japanese, system light/dark, emerald, **rich** layout, regular
density, **pill** badges.

## Assets
- **Food photos:** placeholders only (warm gradient + leaf glyph). Replace with real photography
  via the CDN pipeline in `design.md` (presigned S3 → CloudFront), loaded with `AsyncImage`.
- **Icons:** a small stroke icon set (`source/app/icons.jsx`) — back, chevron, search, pin, clock,
  star, heart, shield, chat, alert, info, sliders, nav, phone, list, grid, user, apple, mail, eye,
  check, yen, train, leaf, lock, sparkle. Map these to SF Symbols in SwiftUI (e.g. heart →
  `heart` / `heart.fill`, shield → `checkmark.shield.fill`, lock → `lock.fill`, leaf → `leaf.fill`,
  train → `tram.fill`, sparkle → `sparkles`).
- **Fonts:** none to bundle for the app (system font). Inter var ships with the design system if
  brand parity is needed on marketing surfaces.
- **Brand mark:** leaf glyph in a rounded translucent square + `グルフリ / GURUFURI` wordmark
  (defined in `source/app/screens-auth-list.jsx` → `Wordmark`).

## Sample content
`source/app/data.jsx` holds six realistic Tokyo GF stores (bilingual names, wards, hours, menus
with per-item GF status + notes/prices). Useful as fixtures for previews and tests; not real data.

## Files
- `SWIFTUI_CHECKLIST.md` — view-by-view SwiftUI build order (foundations → models → components → screens → StoreKit).
- `screenshots/` — per-screen reference renders (login, explore rich/grid, detail, locked menu, paywall, menu, wishlist, account).
- `Gurufuri.html` — standalone, offline, single-file build of the full prototype (open to view).
- `source/index.html` — entry point + script load order.
- `source/app/data.jsx` — stores, wards, GF-status meta, days (bilingual).
- `source/app/icons.jsx` — icon set + `t()` / `fmtHours()` / `money()` helpers.
- `source/app/components.jsx` — theme (`useTheme`), GF badge, photo, tab bar, top bar, action sheet, ward chips, segmented.
- `source/app/cards.jsx` — store card (rich/list/grid) + collection + density map.
- `source/app/screens-auth-list.jsx` — Login + Store List + Wordmark + field.
- `source/app/screens-detail.jsx` — Store Detail + Menu + Wishlist + Account.
- `source/app/screens-paywall.jsx` — Paywall + plan cards.
- `source/app/app.jsx` — navigation, entitlement gating, theme wiring, Tweaks panel.

> Note: the live prototype source loads the NobleLedger design-system bundle for the iPhone
> frame + tokens (not included here). Use `Gurufuri.html` to run/view it standalone; use the
> `source/` JSX as the precise spec for the SwiftUI implementation.
