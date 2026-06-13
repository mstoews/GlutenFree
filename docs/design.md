# Gluten-free restaurant finder — iOS app design

## Overview

A subscription-based gluten-free restaurant discovery app for Japan (Tokyo-first). Users pay to access the full store and menu database. Stores are submitted via a separate admin portal and go live only after internal review.

---

## Technical stack

| Concern | Decision |
|---|---|
| iOS UI | SwiftUI + MVVM |
| Navigation | `NavigationStack` (iOS 16+) for browse drill-down, `TabView` for shell |
| Subscriptions | StoreKit 2 (`Product.purchase()`, `Transaction.currentEntitlements`) |
| Maps deep-link | `MKMapItem.openInMaps` for Apple Maps; `comgooglemaps://` + HTTPS fallback for Google Maps |
| Auth | Email/password + Sign in with Apple (required by App Store if any social auth is offered) |
| Backend | Go REST API + PostgreSQL |
| Image storage | Presigned S3 PUT → CloudFront CDN |
| Ward data | Static `wards.json` in app bundle; also served at `GET /wards` for admin portal |
| Store admin | Web portal (TypeScript/Next.js or Angular) — faster image upload iteration, no App Store review cycle |

---

## Screen architecture

### User app (iOS)

#### Authentication
- **Onboarding** — first-launch intro
- **Login** — email + Sign in with Apple
- **Register**

#### Tab bar
| Tab | Phase |
|---|---|
| Stores | MVP |
| Map | Later |
| Wishlist | Later |
| Account | MVP |

#### Browse flow (Stores tab)
```
Store list
  ├── Filter by ward (chip/picker)
  └── Train line filter [later]
        ↓
Store detail
  ├── Name · opening hours · GF-oriented flag
  └── Address tap → Apple Maps / Google Maps (action sheet)
        ↓
Menu
  └── Photo · name · price · GF note per item
        ↓
Apple Maps / Google Maps (external)
  ├── MKMapItem.openInMaps
  └── comgooglemaps:// with HTTPS fallback
```

#### Account flow
```
Profile
  ↓
Subscription (StoreKit 2 / IAP)
  ↓
Contact (support channel)
  ↓
Report store [later]
  ↓
Wishlist [later]
```

#### Content gating
- Free tier: store list returns name + ward only
- Paid tier: full store detail + menu
- `GET /stores/:id/menu` returns `402` for free-tier users
- Paywall surfaces on first menu tap, not at login

---

### Store admin portal (web)

#### Authentication
- Email/password login (Google SSO optional)

#### Screens
```
Dashboard
  └── Store status · last-updated
        ↓
Store profile editor
  └── Name · address · opening hours · GF-oriented flag
        ↓
Menu manager
  └── Item list · reorder · delete
        ↓
Menu item editor
  ├── Photo · name · price · GF note
  └── Image: presigned S3 PUT upload
```

---

## StoreKit 2 — subscription purchase flow

```
1. User taps subscribe
   └── Product.purchase() called

2. PurchaseResult.success
   └── JWS payload in transaction

3. POST /subscription/verify
   └── body: { signedTransaction: string }

4. Verify JWS signature
   └── Apple root cert, local verify only (no App Store API call)

5. Update user subscription status
   └── Return new status → content unlocked

[Background] App Store Server Notifications webhook
   └── Handles renewals, DID_FAIL_TO_RENEW, EXPIRED, REVOKE
```

### Go JWS verification notes
- Parse `x5c` header from signed transaction
- Validate certificate chain against Apple root CA (`apple.com/certificateauthority`)
- Verify ECDSA payload signature — `golang-jwt/jwt` handles this
- No per-transaction Apple API call required
- Webhook: `POST /webhooks/apple` — handle `SUBSCRIBED`, `DID_RENEW`, `DID_FAIL_TO_RENEW`, `EXPIRED`, `REVOKE`

---

## Store approval flow

```
Store admin submits
  └── via admin web portal
        ↓
store.status = pending
  └── enters review queue
        ↓
Internal team reviews
  └── internal admin web tool
        ↓               ↓
  Approved           Rejected
      ↓                  ↓
  Live in app        Can edit + resubmit
                     └── rejection_reason stored
```

### Approval rules
- First submit → goes to `pending`
- Once approved, minor store edits go live immediately (no re-review)
- Rejected stores can edit and resubmit → back to `pending`
- Rejection requires a reason (stored on the `stores` table)

---

## Data model

### `users`
| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `email` | `string` | |
| `apple_user_id` | `string` | nullable |
| `subscription_status` | `enum` | `free \| active \| expired \| revoked` |
| `sub_expires_at` | `timestamp` | nullable |

### `wards`
| Field | Type | Notes |
|---|---|---|
| `id` | `int` | PK |
| `name_ja` | `string` | Japanese name |
| `name_en` | `string` | English name |

### `stores`
| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `ward_id` | `int` | FK → wards |
| `name` | `string` | |
| `address` | `string` | |
| `latitude` | `float` | geocoded at upload |
| `longitude` | `float` | geocoded at upload |
| `is_gf_oriented` | `bool` | store-level GF flag |
| `opening_hours` | `jsonb` | see format below |
| `status` | `enum` | `draft \| pending \| approved \| rejected` |
| `rejection_reason` | `text` | nullable |
| `approved_at` | `timestamp` | nullable |

**Opening hours format:**
```json
[
  { "day": 0, "open": "1100", "close": "2200" },
  { "day": 1, "open": "1100", "close": "2200" }
]
```
`day` is 0-indexed from Sunday. Store as JSONB; expose typed Go struct.

### `store_admins`
| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `store_id` | `uuid` | FK → stores |
| `email` | `string` | |
| `password_hash` | `string` | |

### `menu_items`
| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `store_id` | `uuid` | FK → stores |
| `name` | `string` | |
| `price_yen` | `int` | price in yen |
| `image_url` | `string` | nullable, CDN URL |
| `gf_status` | `enum` | `certified \| on_request \| contains_hidden_gluten` |
| `gf_note` | `text` | nullable, free-text elaboration |
| `sort_order` | `int` | drag-reorder by admin |
| `is_available` | `bool` | |

### `subscription_receipts`
| Field | Type | Notes |
|---|---|---|
| `id` | `uuid` | PK |
| `user_id` | `uuid` | FK → users |
| `original_tx_id` | `string` | StoreKit 2 original transaction ID |
| `product_id` | `string` | App Store product identifier |
| `environment` | `enum` | `sandbox \| production` |
| `status` | `enum` | `active \| expired \| revoked \| billing_retry` |
| `expires_at` | `timestamp` | |

### Relationships
```
users          ||--o{  subscription_receipts  : has
wards          ||--o{  stores                 : groups
stores         ||--o{  menu_items             : contains
stores         ||--o{  store_admins           : managed by
```

---

## API route table

### User app
```
POST /auth/register
POST /auth/login
POST /auth/apple                      Sign in with Apple token exchange
GET  /wards                           no auth, bundle fallback
GET  /stores?ward_id=&cursor=         auth; free: name+ward only
GET  /stores/:id                      auth; paid: full detail
GET  /stores/:id/menu                 auth + paid → 402 if free tier
POST /subscription/verify             body: { signedTransaction: string }
GET  /subscription/status
```

### Store admin (`/admin/*`)
```
POST   /auth/login
GET    /store
PUT    /store                         live-edit if approved; no re-review for minor changes
POST   /store/submit                  first submit or resubmit after rejection
GET    /store/menu
POST   /store/menu
PUT    /store/menu/:id
DELETE /store/menu/:id
POST   /store/menu/:id/upload-url     returns presigned S3 PUT URL
PUT    /store/menu/:id/image/confirm  sets image_url after upload completes
```

### Internal ops (admin JWT role)
```
GET  /internal/stores?status=pending
POST /internal/stores/:id/approve
POST /internal/stores/:id/reject      body: { reason: string }
```

---

## Image upload pipeline

```
Camera / file picker
  └── HEIC or JPEG
        ↓
Compress client-side (target < 500 KB)
        ↓
POST /admin/store/menu/:id/upload-url
  └── server returns presigned S3 PUT URL (TTL: 5 min)
        ↓
PUT directly to S3 (from browser/app)
        ↓
PUT /admin/store/menu/:id/image/confirm
  └── server sets menu_item.image_url = CDN URL
```

---

## Later features (phase 2+)

| Feature | Notes |
|---|---|
| Map view (tab) | MapKit pin map filtered by current ward |
| Train line filter | Requires station-to-ward mapping dataset |
| Wishlist | Heart icon on store cards → saved list per user |
| Report store | Flag incorrect GF claims; feeds internal moderation queue |
| Food category search | Tag-based; requires `category` field on `menu_items` |
| Push notifications | New store in subscribed ward; `APNs` via Go backend |
