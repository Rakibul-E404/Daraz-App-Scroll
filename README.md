# 🛍️ Daraz-Style Flutter App

A Flutter product listing app built around a **correct scroll and gesture architecture** — not just a UI demo.

---

## 🚀 Run Instructions
```bash
flutter pub get
flutter run
```

**Demo login:** `johnd` / `m38rmF$`  
*(Credentials are pre-filled — just tap Sign In)*

---

## 📁 Project Structure
```
lib/
├── main.dart
├── models/
│   ├── product.dart
│   └── user.dart
├── services/
│   └── api_service.dart          # HTTP + mock fallback
├── providers/
│   ├── auth_provider.dart        # login state
│   └── products_provider.dart    # product list + refresh
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart          # orchestrator only
│   └── profile_screen.dart
└── widgets/
    ├── product_card.dart
    └── home/
        ├── daraz_app_bar.dart    # collapsible banner
        ├── promo_chip.dart       # pill chip widget
        ├── tab_bar_delegate.dart # sticky tab bar
        └── tab_body.dart         # scrollable list per tab
```

---

## 🏗️ Scroll Architecture

### The Single Responsibility Rule

Each layer owns exactly one job:
```
NestedScrollView
├── [outer]  drives header collapse only
├── DarazAppBar (floating + snap)
├── TabBarDelegate (pinned)
└── [inner]  PageView body
    └── TabBody ListView (primary: true)
        └── owns vertical scroll per tab
```

### Why `NestedScrollView` and not `CustomScrollView`?

`CustomScrollView` requires a single scroll owner for everything. That means the `PageView` content must either:
- Use `shrinkWrap` → clips content, can't scroll past visible area
- Use `SliverFillRemaining` → crashes with intrinsic dimension error

`NestedScrollView` separates outer (header) and inner (content) scrolling cleanly — exactly the problem it was designed to solve.

---

## 👆 Horizontal Swipe — How It Works

`PageView` is set to `NeverScrollableScrollPhysics()` — it **cannot scroll by touch**.

A `GestureDetector` wraps the entire body and manually classifies every pan gesture:
```
onPanUpdate:
  dx = |current.x - start.x|
  dy = |current.y - start.y|

  if dx < 8 && dy < 8 → too early, keep waiting
  if dx > dy * 1.5    → HORIZONTAL → switch tab on finger-up
  else                → VERTICAL   → falls through to ListView
```

On `onPanEnd`, if classified as horizontal and velocity > 200 px/s:
```
velocity < -200  →  next tab
velocity > +200  →  previous tab
```

**Why this matters:** Flutter's built-in `HorizontalDragGestureRecognizer` and `VerticalDragGestureRecognizer` compete using an arena. With nested scrollables, the arena resolution is unpredictable. Manual classification removes the arena entirely — we decide, not the framework.

---

## 📌 Who Owns the Vertical Scroll?

Each tab's `ListView` owns its own vertical scroll with `primary: true`.

`primary: true` tells the `ListView` to use the `PrimaryScrollController` from its context. Inside `NestedScrollView`, that controller is automatically wired to the outer scroll coordinator — so the header collapses when the inner list scrolls, without any manual `ScrollController` passing.
```
NestedScrollView coordinator
        │
        └── PrimaryScrollController
                    │
                    └── ListView (primary: true)  ← inner scroll owner
```

---

## 🔒 Tab Scroll Position Preservation

Two mechanisms work together:

| Mechanism | What it does |
|---|---|
| `AutomaticKeepAliveClientMixin` | Prevents `PageView` from destroying off-screen tab widgets |
| `PageStorageKey('tab_$index')` | Saves and restores `ListView` scroll offset via Flutter's `PageStorage` |
| `PageController(keepPage: true)` | Remembers which page was open across rebuilds |

Switching tabs calls only `pageController.animateToPage()` — the `ListView` scroll controllers are never touched.

---

## 🔄 Pull-to-Refresh

`RefreshIndicator` wraps each tab's `ListView` individually.

`AlwaysScrollableScrollPhysics` on the `ListView` ensures the overscroll gesture triggers even when the list has fewer items than the screen height.

---

## ⚖️ Trade-offs & Limitations

| Trade-off | Reason |
|---|---|
| `floatHeaderSlivers: true` required | Without it, the header only responds to the outer coordinator scroll — the list inside `PageView` doesn't trigger header collapse |
| `floating + snap` on `SliverAppBar` | `pinned: false` means the header fully disappears. Using `pinned: true` would keep it visible but takes up space. Snap prevents the awkward half-open state |
| Gesture threshold `dx > dy * 1.5` | Very diagonal swipes won't register as horizontal. Intentional — reduces false positives while scrolling vertically |
| `primary: true` on `ListView` | Only one `ListView` can be primary per route. Since each tab is in its own widget tree branch inside `PageView`, this works correctly — each tab gets its own coordinator context from `NestedScrollView` |
| API fallback to mock data | `fakestoreapi.com` is a public free API that can be slow or down. All 19 products are hardcoded as fallback so the app never shows a blank screen |

---

## 🔑 Login Credentials

| Username | Password |
|---|---|
| `rakibul` | `rakibul` |
| `` | `` |
| `` | `` |
| `` | `` |

> Credentials are validated locally first — login works even if the API is unreachable.