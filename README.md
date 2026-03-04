# 🛍️ Daraz-Style Flutter App

A Flutter product listing app built around a **correct scroll, gesture, and state architecture** — not just a UI demo.

---
## 📱Screenshots:
<table>
  <tr>
    <td><img alt="image" src="https://github.com/user-attachments/assets/fe0c3ae9-1752-4f2a-89da-0841f81a12fb" width="300"/>
</td>
    <td>
      <img alt="image" src="https://github.com/user-attachments/assets/f868fb9b-c998-4a5a-b1ab-35b6d72eae05" width="300"/>
    </td>
    <td>
      <img alt="image" src="https://github.com/user-attachments/assets/ec5f7d5d-4f9a-4a7d-a7a2-335fbfd57fcc" width="300"/>
    </td>
    <td><img alt="image" src="https://github.com/user-attachments/assets/96383ff8-e9bc-45e1-932b-77ee96debfd1" width="300" />
</td>
  </tr>
</table>

---
## 👆 How Horizontal Swipe Was Implemented

`PageView` uses `PageScrollPhysics()` — it handles drag natively, giving the **follow-finger trail** feel where the next tab slides in as you swipe. On release it snaps to the nearest page.

A `PageController` listener keeps the tab indicator in sync as the page position changes fractionally during the drag:

```dart
pageController.addListener(() {
  final rounded = pageController.page!.round();
  if (rounded != currentTab.value) {
    currentTab.value = rounded;  // tab indicator slides in real time
  }
});
```

When a tab label is tapped, `animateToPage()` is called with `Curves.easeOutCubic` for a smooth programmatic transition.

### Why Not `NeverScrollableScrollPhysics` + `GestureDetector`?

Earlier versions used a manual `GestureDetector` to classify pan gestures:

```
if dx > dy * 1.5 after 8px movement → horizontal → animateToPage()
else → vertical → falls through to ListView
```

This works but produces **jump-cut switching** — there is no in-between frame, the page just appears. The current `PageScrollPhysics` approach lets Flutter's scroll system do the work, giving a native feel where content actually follows your finger.

---

## 📌 Who Owns the Vertical Scroll and Why

Each tab's `ListView` owns its own vertical scroll via `primary: true`.

`primary: true` tells the `ListView` to use the `PrimaryScrollController` from its context. Inside `NestedScrollView`, that controller is automatically wired to the outer scroll coordinator — so the header collapses when the inner list scrolls, without any manual `ScrollController` passing.

```
NestedScrollView coordinator
        │
        └── PrimaryScrollController
                    │
                    └── ListView (primary: true)  ←  inner scroll owner per tab
```

### Why `NestedScrollView` and not `CustomScrollView`?

`CustomScrollView` requires one scroll owner for everything. Putting a `PageView` inside it forces one of two broken patterns:

| Pattern | Problem |
|---|---|
| `shrinkWrap: true` on inner `ListView` | Items render but list can't scroll — content clips at viewport bottom |
| `SliverFillRemaining` wrapping `PageView` | Flutter throws: *"RenderViewport does not support returning intrinsic dimensions"* |

`NestedScrollView` separates the outer scroll (header) from the inner scroll (content) at the framework level — exactly the problem it was designed for.

### Tab Scroll Position Preservation

Three mechanisms work together to ensure switching tabs never resets scroll position:

| Mechanism | What it does |
|---|---|
| `AutomaticKeepAliveClientMixin` | Prevents `PageView` from destroying off-screen tab widgets and their state |
| `PageStorageKey('tab_$index')` | Saves and restores `ListView` scroll offset via Flutter's `PageStorage` bucket system |
| `PageController(keepPage: true)` | Remembers which page index was active across widget tree rebuilds |

Switching tabs only calls `pageController.animateToPage()` — the individual `ListView` scroll positions are never touched or reset.

---

## ⚖️ Trade-offs & Limitations

| Trade-off | Reason |
|---|---|
| `floatHeaderSlivers: true` required | Without it, inner `PageView` scroll does not collapse the outer header — the list inside `PageView` simply doesn't trigger header collapse |
| `floating + snap` on `SliverAppBar` | `pinned: false` maximises screen space. `snap` prevents the awkward half-open header state |
| `primary: true` on each tab's `ListView` | Only one `ListView` can be primary per route — works here because each tab is in its own widget tree branch, each getting a separate coordinator context from `NestedScrollView` |
| No mock data in production | API errors show an error view with Retry button. Real users always get real data or a clear error message — never silent fake data |
| `ACCESS_NETWORK_STATE` permission breaks emulator | This permission conflicts with the emulator's virtual network adapter on some versions. Only `INTERNET` permission should be added |

---

## 🚀 Run Instructions

```bash
flutter pub get
flutter run
```

**Login credentials:** `rakibul` / `rakibul123`
*(Credentials are pre-filled — just tap Sign In)*

---

## 📁 Project Structure

```
lib/
├── main.dart                         # GetMaterialApp + global bindings
├── models/
│   ├── product.dart                  # Product, Rating models
│   └── user.dart                     # User, UserName, UserAddress models
├── services/
│   └── api_service.dart              # HTTP calls to fakestoreapi.com
├── controllers/
│   ├── auth_controller.dart          # Login state (GetxController)
│   ├── products_controller.dart      # Product list + refresh (GetxController)
│   └── home_controller.dart          # Tab index + PageController (GetxController)
├── screens/
│   ├── login_screen.dart             # Login form
│   ├── home_screen.dart              # Orchestrator — NestedScrollView + PageView
│   ├── profile_screen.dart           # User profile + logout
│   └── product_detail_screen.dart    # Product detail with quantity selector
└── widgets/
    ├── product_card.dart             # List item card with shimmer placeholder
    └── home/
        ├── daraz_app_bar.dart        # Collapsible SliverAppBar
        ├── promo_chip.dart           # Horizontal scrolling promo pill
        ├── tab_bar_delegate.dart     # Sticky SliverPersistentHeader tab bar
        └── tab_body.dart             # Scrollable list per tab (KeepAlive)
```

---

## 🏗️ Scroll Architecture

### Layer Ownership — One Job Per Layer

```
Scaffold
└── SafeArea
    └── NestedScrollView  (outer scroll — header collapse only)
        ├── DarazAppBar   (floating + snap SliverAppBar)
        ├── TabBarDelegate (pinned sticky tab bar)
        └── body: PageView (horizontal tab switching)
            └── TabBody → ListView (primary: true)
                          └── owns vertical scroll per tab
```

### Header Collapse Behaviour

`SliverAppBar` is configured with:

| Property | Value | Effect |
|---|---|---|
| `floating` | `true` | Header collapses on scroll down, reappears on scroll up |
| `pinned` | `false` | Header fully hides — more screen space for content |
| `snap` | `true` | Snaps fully open or fully closed — no awkward half-states |
| `floatHeaderSlivers` | `true` on `NestedScrollView` | Inner scroll (inside `PageView`) drives outer header collapse |

---

## ⚡ State Management — GetX

The app uses **GetX** (`get: ^4.6.6`). Three controllers manage all state:

### `AuthController`
- Validates credentials locally first (`rakibul` / `rakibul123`)
- If valid, calls `fakestoreapi.com/auth/login` with the API's own credentials to get a real token
- Overrides the API-returned user profile with your own name, email, and address constants
- Falls back to an offline profile if network is unavailable
- `reassemble()` implemented so hot reload instantly refreshes the profile from updated constants

### `ProductsController`
- `onInit()` calls `loadProducts()` automatically when the screen opens
- `getAllProducts()` fetches from `fakestoreapi.com/products`
- On failure, `error` observable is set — UI shows error view with Retry button
- `refresh()` clears `_all` and re-fetches — Retry button calls this
- Category getters (`electronics`, `jewelery`, `menClothing`, `womenClothing`, `all`) filter reactively

### `HomeController`
- Owns `PageController` lifecycle (`onInit` → `onClose`)
- `currentTab` observable drives tab indicator rebuilds via `Obx`
- `switchTab()` calls `animateToPage()` for tap-switching
- `_onPageChanged` listener keeps `currentTab` in sync during drag

### Why GetX over Provider?

| Provider | GetX |
|---|---|
| `context.watch<T>()` rebuilds entire widget subtree | `Obx(() => ...)` rebuilds only the exact widget wrapped |
| `ChangeNotifier.notifyListeners()` triggers all listeners | Observable `.value` change triggers only its own `Obx` instances |
| Requires `BuildContext` to access controllers | `Get.find<T>()` works anywhere — O(1) registry lookup |

---

## 🖼️ Fast Scroll — No Blank Flash

Fast vertical scrolling previously caused blank white frames. Three fixes applied:

| Problem | Fix |
|---|---|
| `CachedNetworkImage` showed white while loading from cache | `_ShimmerBox` — animated grey placeholder, exact same 90×90 size as image |
| `cacheExtent: 500` — Flutter destroyed widgets just outside viewport, fast flings outran it | Raised to `cacheExtent: 1200` — pre-renders ~4 extra cards beyond visible area |
| No stable key on cards — Flutter recycled wrong widget during fast scroll | `ValueKey(product.id)` — Flutter always maps the right product to the right widget |

---

## 🔑 Login

| Field | Value |
|---|---|
| Username | `rakibul` |
| Password | `rakibul123` |

Credentials are pre-filled. The app validates locally first, then optionally calls the API. If the network is down, login still succeeds with an offline profile.

To change credentials, update these three constants in `auth_controller.dart`:

```dart
static const _myUsername = 'rakibul';
static const _myPassword = 'rakibul123';
static const _myName     = 'Rakibul';
```

```

