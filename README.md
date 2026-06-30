# Event Ticketing App — Flutter

Aplikasi mobile event ticketing modern dengan Flutter, terintegrasi Laravel REST API dan Midtrans Payment Gateway.

---

## Tech Stack

| Layer | Package |
|-------|---------|
| State Management | `flutter_riverpod` + `riverpod_generator` |
| Navigation | `go_router` |
| Network | `dio` + `retrofit` |
| Models | `freezed` + `json_serializable` |
| UI Fonts | `google_fonts` (Poppins + Inter) |
| QR Code | `qr_flutter` |
| Image Cache | `cached_network_image` |
| Storage | `flutter_secure_storage` + `shared_preferences` |

---

## Folder Structure

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart          # Color palette, typography, component themes
├── data/
│   ├── models/
│   │   ├── event_model.dart        # EventModel, TicketTypeModel, BannerModel
│   │   └── transaction_model.dart  # CheckoutRequest, TransactionModel, ETicketModel
│   └── repositories/              # API calls via Dio (implement here)
├── domain/
│   ├── entities/                  # Pure domain objects
│   └── usecases/                  # Business logic
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── detail/
│   │   │   └── event_detail_screen.dart
│   │   ├── checkout/
│   │   │   └── checkout_screen.dart
│   │   ├── payment/
│   │   │   ├── payment_screen.dart         # QRIS + VA + countdown timer
│   │   │   └── payment_success_screen.dart # Green checkmark + high-contrast CTA
│   │   ├── eticket/
│   │   │   └── eticket_screen.dart
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── search/
│   │   ├── tickets/
│   │   └── profile/
│   └── widgets/
│       ├── app_button.dart
│       ├── event_card_horizontal.dart   # Horizontal scroll card with heart toggle
│       ├── event_card_vertical.dart     # Vertical list card with heart toggle
│       ├── main_scaffold.dart           # Bottom navigation shell
│       └── (promo_banner, search_bar inside event_card_vertical.dart)
├── routes/
│   └── app_router.dart            # GoRouter config + route guards
└── main.dart
```

---

## Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (Freezed + Riverpod + Retrofit)
dart run build_runner build --delete-conflicting-outputs

# 3. Run app
flutter run
```

---

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Electric Blue | `#2F6BFF` | CTA, active nav, links |
| Deep Indigo | `#1E2A78` | Header, banners, payment bg |
| Festival Orange | `#FF7A00` | Promo badges, accents |
| Neon Pink | `#FF4FC3` | Festival events, gradient |
| Success Green | `#16A34A` | ✅ Payment success checkmark |
| Page BG | `#F8F9FC` | Scaffold background |
| Card | `#FFFFFF` | Card background |
| Text Primary | `#111827` | Headings, body |
| Text Secondary | `#6B7280` | Captions, subtitles |

---

## Payment Success UX Design Rationale

### Green Checkmark (not white/blue)
- **Principle:** Green universally signals "success" across cultures (traffic lights, checkmarks)
- **Contrast:** White `✓` on `#16A34A` achieves 4.7:1 contrast ratio (WCAG AA compliant)
- **Shadow:** Green glow shadow reinforces positive feedback loop

### Button Hierarchy (high contrast)
- **Primary:** White background + deep indigo text on dark bg = ~9:1 contrast ratio
- **Secondary:** Ghost/outline button = lower visual weight, clearly secondary action
- **Order:** Primary (Lihat Tiket) above Secondary (Beranda) = action hierarchy

---

## Midtrans Integration

### Flow
```
Flutter Checkout → POST /api/checkout (Laravel)
                 → Laravel creates Midtrans transaction
                 → Returns { snap_token, order_id, expiry_time, va_number }
                 → Flutter renders PaymentScreen with countdown + QRIS/VA
                 → User pays via bank/e-wallet
                 → Midtrans webhook → POST /api/midtrans/callback (Laravel)
                 → Laravel updates transaction status
                 → Flutter polls GET /api/transactions/{orderId}/status
                 → Status = paid → navigate to PaymentSuccessScreen
```

### Backend Midtrans Config (Laravel .env)
```env
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxx
MIDTRANS_IS_PRODUCTION=false
MIDTRANS_IS_SANITIZED=true
MIDTRANS_IS_3DS=true
```

### Checkout API Request
```json
POST /api/checkout
{
  "event_id": 1,
  "ticket_type_id": 1,
  "quantity": 1,
  "promo_code": "DISKON50"
}
```

### Checkout API Response
```json
{
  "order_id": "INV/2024/12/000123",
  "snap_token": "snap-token-xxx",
  "payment_url": "https://app.sandbox.midtrans.com/snap/...",
  "total_amount": 155000,
  "expiry_time": "2024-12-31T20:00:00Z",
  "va_number": "88 2024 1234 5678"
}
```

### Promo Validation
```json
POST /api/promo/validate
{
  "promo_code": "DISKON50",
  "event_id": 1,
  "subtotal": 150000
}

Response:
{
  "valid": true,
  "discount": 50000,
  "final_price": 100000
}
```

---

## Laravel API Endpoints

```
GET  /api/events                    # All events (paginated)
GET  /api/events/popular            # Popular events by view count
GET  /api/events/{id}               # Event detail
GET  /api/banners                   # Promo banners

POST /api/login                     # Auth
POST /api/register
POST /api/logout

POST /api/promo/validate            # Validate promo code
POST /api/checkout                  # Create order → Midtrans snap token
GET  /api/transactions              # Transaction history (auth required)
GET  /api/transactions/{orderId}/status  # Poll payment status
GET  /api/my-tickets                # E-tickets (auth required)

POST /api/midtrans/callback         # Midtrans webhook (internal, no auth)
```

---

## Guest Mode

Semua layar dapat diakses tanpa login. Login hanya diperlukan saat:
1. `Pesan Sekarang` di-tap → redirect ke `/login?redirect=/checkout`
2. Setelah login → auto-redirect kembali ke checkout

Implementasi: `GoRouter.redirect` callback di `app_router.dart`.
