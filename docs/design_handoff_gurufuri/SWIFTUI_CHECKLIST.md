# SwiftUI Build Checklist — Gurufuri iOS

A view-by-view order of operations for recreating the design in
`/Users/murraytoews/Desktop/GlutenFree`. Build top-down: foundations → models →
reusable components → screens → navigation/state → StoreKit. Check items off as you go.

Pair this with `README.md` (exact tokens, copy, layouts) and the images in `screenshots/`.

---

## 0. Foundations
- [ ] **Color tokens** → `Color` extension or asset catalog with light/dark variants.
  - `brandEmerald` 700 `#047857` (light) / 600 `#059669` (dark) · `emerald800 #065f46` · `emeraldSoft`
  - `accentIndigo` 700 `#4338ca` (only if you keep the accent option)
  - Surfaces: `pageBg`, `cardBg`, `card2Bg`, `ink`, `sub`, `hint`, `separator`, `fill` (see README → Neutrals)
  - **Fixed GF colors** (never themed): `gfCertified #047857/#059669`, `gfOnRequest #b45309/#d97706`, `gfHidden #dc2626`
  - `systemRed #ff3b30` (heart/destructive), `starGold #f5a623`
  - Prefer semantic `Color` sets in `Assets.xcassets` so dark mode is automatic.
- [ ] **Typography** → system font (`.system(size:weight:)`); titles use weight `.heavy/.bold` and
  tight tracking (`-0.01…-0.02em` ≈ `.tracking(-0.4)`); prices use `.monospacedDigit()`.
- [ ] **Spacing/radius** → constants: page padding 16, card padding 14–18; radii rows 12–14,
  cards 16, rich cards 18, sheets 20–22, pills `.capsule`.
- [ ] **Localization** → `Localizable.strings` (ja/en) for all copy in README; the prototype's
  `{ ja, en }` pairs map 1:1. Decide: follow system language or in-app toggle (prototype toggles).

## 1. Models (from `design.md` + `source/app/data.jsx`)
- [ ] `Ward { id, nameJa, nameEn }`
- [ ] `Store { id, wardId, name, address, lat, lng, isGfOriented, openingHours, status, … }`
  plus display fields used by cards: cuisine, priceLevel (1–3), rating, reviews, station, distance, blurb.
- [ ] `OpeningHour { day:Int(0=Sun), open:String"HHMM", close:String }` → helper `isOpenNow(_:)`
  (open when `open != close` and now ∈ [open, close]).
- [ ] `MenuItem { id, name, priceYen, imageUrl?, gfStatus, gfNote?, sortOrder, isAvailable }`
- [ ] `enum GFStatus { certified, onRequest, containsHiddenGluten }` → computed `color`, `iconName`
  (SF Symbol), `label`, `blurb`.
- [ ] `enum SubscriptionStatus { free, active, expired, revoked }` on the user/session.

## 2. Reusable components
- [ ] `GFBadge(status:style:)` — three styles: **pill** (soft bg + icon + label), **dot**
  (colored dot + label), **tag** (solid color, white text). Ship `pill` as default.
- [ ] `StorePhoto` — `AsyncImage` with a gradient + `leaf.fill` placeholder while loading/empty
  (matches the prototype's gradient blocks). Parameterize corner radius + height.
- [ ] `StarRating(rating:reviews:)` — `star.fill` gold + value + `(reviews)`.
- [ ] `PriceMark(level:)` — `¥` × level in `sub`, remainder in `hint`.
- [ ] `WardChips` — horizontal `ScrollView` of capsule toggles; selected = filled accent.
- [ ] `StoreCard` — 3 layouts (**rich** hero / **list** row / **grid** tile). Start with rich.
- [ ] `GurufuriTabBar` — `TabView` (Explore / Saved / Account) with SF Symbols
  (`magnifyingglass`, `heart`/`heart.fill`, `person`); saved-count badge via `.badge()`.
- [ ] `SectionHeader`, `InfoRow`, `MenuItemRow`, `PlanCard` (paywall).
- [ ] **SF Symbol map** (README → Assets): heart→`heart(.fill)`, shield→`checkmark.shield.fill`,
  lock→`lock.fill`, leaf→`leaf.fill`, train→`tram.fill`, sparkle→`sparkles`, pin→`mappin.and.ellipse`,
  clock→`clock`, chat→`bubble.left`, alert→`exclamationmark.triangle.fill`, nav→`location.north.fill`.

## 3. Screens (build in this order)

### 3.1 LoginView  · `screenshots/01-login.png`
- [ ] Emerald gradient hero (`LinearGradient`, 155°, e600→e800) + decorative stroked circles
  (overlay `Circle().stroke()`), brand lockup (leaf in rounded translucent square + `グルフリ`).
- [ ] Form: email + secure field (show/hide), primary **Log In**, `or` divider, black
  **Sign in with Apple** (`SignInWithAppleButton`), `Create account`, version footer.
- [ ] Status bar style `.dark` content over the hero (light text).

### 3.2 ExploreView (Store List — KEY SCREEN) · `02-explore-rich.png`, `03-explore-grid.png`
- [ ] Large title `探す/Explore` + subtitle; trailing **layout switcher** (segmented: rich/list/grid).
- [ ] Search field (can be a real `.searchable` later), `WardChips`, result count + sort label.
- [ ] `LazyVStack`/`LazyVGrid` of `StoreCard` per layout; density affects spacing/sizes.
- [ ] Heart toggles save; pushes `StoreDetailView` on tap (`NavigationStack` value-based nav).

### 3.3 StoreDetailView · `07-store-detail.png`, `08-detail-menu-locked.png`
- [ ] 256pt photo hero; translucent back + heart overlay buttons.
- [ ] Overlapping card (radius 20 top, −22pt): GF-oriented + Open-now/Closed pills, name (24/heavy),
  rating·cuisine·price, blurb.
- [ ] GF assurance callout (tinted to status). Location card (address row → maps sheet; station; phone).
  Opening-hours card (today highlighted, `定休日/Closed`).
- [ ] **Menu preview gating:** free → blurred preview (`.blur(radius:5)`) + lock overlay + CTA
  **Unlock full menu**; subscribed → real preview + **View full menu**. Pinned bottom CTA bar.
- [ ] Address → `.confirmationDialog`: Apple Maps (`MKMapItem.openInMaps`), Google Maps
  (`comgooglemaps://` + HTTPS fallback), Copy, Cancel.

### 3.4 PaywallView (`.sheet`, `.presentationDetents([.large])`) · `09-paywall.png`
- [ ] Grabber + close; emerald hero with `Gurufuri+` badge + headline + store-contextual subtext.
- [ ] Benefits list (4, accent check chips). Two `PlanCard`s (Annual default w/ badge, Monthly).
- [ ] Auto-renew fine print. Pinned CTA (Apple glyph + dynamic price). Restore / Terms / Privacy.
- [ ] **Trigger:** first menu tap on free tier (the `402` gate). On purchase success → dismiss →
  open the originating store's menu.

### 3.5 MenuView · `10-menu.png`
- [ ] Nav bar (store name + `メニュー · 全N品`); GF legend (3 dots). Items sorted
  certified → onRequest → hidden. `MenuItemRow` (photo, name, note, badge, price). Footer disclaimer.

### 3.6 SavedView (Wishlist) · `05-wishlist-empty.png`
- [ ] Large title + count. Empty state (heart glyph + message). Populated = `StoreCard` collection.

### 3.7 AccountView · `04-account.png`
- [ ] Profile card. **Subscription card** reflects `SubscriptionStatus`: free → Upgrade (opens paywall);
  active → renewal date + Manage. Settings list. Version footer.

## 4. Navigation & State
- [ ] App shell = `TabView`; each tab owns a `NavigationStack`.
- [ ] Session/store in an `@Observable` (or `ObservableObject`): `isLoggedIn`, `subscription`,
  `savedStoreIDs`, selected `ward`, and a `paywall` presentation item `{ store }`.
- [ ] Persist `isLoggedIn`, `subscription`, `savedStoreIDs` (UserDefaults/Keychain as appropriate).
- [ ] Detail/Menu are pushed (tab bar hidden via `.toolbar(.hidden, for: .tabBar)`); Paywall + maps
  are sheets/dialogs.

## 5. StoreKit 2 (per `design.md`)
- [ ] Define products (monthly / annual) in `Products.storekit` + App Store Connect.
- [ ] `Product.purchase()` → verify transaction → `POST /subscription/verify { signedTransaction }`
  → update `subscription`. Listen to `Transaction.updates`. Restore via `AppStore.sync()`.
- [ ] Gate `GET /stores/:id/menu` (server returns `402` for free) and mirror client-side: free menu
  tap → Paywall, not the request.

## 6. Data & assets
- [ ] Replace gradient placeholders with real photos (`AsyncImage`, presigned-S3 → CloudFront pipeline).
- [ ] `wards.json` in bundle as fallback (also `GET /wards`).
- [ ] Use `source/app/data.jsx` fixtures for SwiftUI Previews and tests.

## 7. QA pass
- [ ] Light + dark parity (system colors). Dynamic Type doesn't break rows.
- [ ] Open-now logic across days incl. closed days. JA/EN strings everywhere.
- [ ] Free vs. subscribed flows; restore purchases; paywall returns to the right menu.
- [ ] 44pt minimum hit targets; VoiceOver labels on icon-only buttons (back, heart, layout switcher).
