/**
// ═══════════════════════════════════════════════════════════════
// SCROLL + GESTURE ARCHITECTURE
// ═══════════════════════════════════════════════════════════════
//
// 1. HORIZONTAL SWIPE
//    PageView uses NeverScrollableScrollPhysics — disabled by touch.
//    GestureDetector wraps the NestedScrollView body and classifies
//    pan gestures: if |dx| > |dy| * 1.5 after 8px → horizontal.
//    On finger up, animateToPage() is called. Vertical gestures
//    fall through to the active tab's ListView untouched.
//
// 2. SCROLL OWNERSHIP
//    NestedScrollView owns the outer scroll (header collapse).
//    Each tab's ListView uses PrimaryScrollController.of(context)
//    which NestedScrollView provides automatically — this is how
//    Flutter connects inner scroll views to the NestedScrollView
//    coordinator without manual ScrollController wiring.
//    Each tab's scroll position is preserved in a KeepAlive wrapper.
//
// 3. HEADER COLLAPSE
//    SliverAppBar with pinned:false, floating:true, snap:true gives
//    the best UX — header hides on scroll down, reappears on scroll up.
//    floatHeaderSlivers:true on NestedScrollView ensures the header
//    responds to inner scroll events correctly.
//
// 4. TAB POSITION PRESERVATION
//    AutomaticKeepAliveClientMixin on each _TabBody keeps the
//    ListView's scroll position alive when switching tabs.
//    PageView with keepPage:true on PageController also helps.
//
// 5. PULL TO REFRESH
//    RefreshIndicator wraps each tab's ListView individually.
//    This works because the ListView is the primary scroll view
//    inside NestedScrollView's body.
// ═══════════════════════════════════════════════════════════════



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../widgets/product_card.dart';

const List<String> _kTabLabels = ['All', 'Electronics', 'Jewelery', 'Clothing'];
const double _kTabBarHeight = 48.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // keepPage:true preserves which page we're on across rebuilds
  final PageController _pageController = PageController(keepPage: true);

  int _currentTab = 0;

  // Gesture state
  double _dragStartX   = 0;
  double _dragStartY   = 0;
  bool   _dragDecided  = false;
  bool   _isHorizontal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_currentTab == index) return;
    setState(() => _currentTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onPanStart(DragStartDetails d) {
    _dragStartX   = d.globalPosition.dx;
    _dragStartY   = d.globalPosition.dy;
    _dragDecided  = false;
    _isHorizontal = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragDecided) return;
    final dx = (d.globalPosition.dx - _dragStartX).abs();
    final dy = (d.globalPosition.dy - _dragStartY).abs();
    if (dx < 8 && dy < 8) return;
    _dragDecided  = true;
    _isHorizontal = dx > dy * 1.5;
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_isHorizontal) return;
    final v = d.velocity.pixelsPerSecond.dx;
    if (v < -200 && _currentTab < _kTabLabels.length - 1) {
      _switchTab(_currentTab + 1);
    } else if (v > 200 && _currentTab > 0) {
      _switchTab(_currentTab - 1);
    }
  }

  List<Product> _productsForTab(int tab, ProductsProvider p) {
    switch (tab) {
      case 0:  return p.all;
      case 1:  return p.electronics;
      case 2:  return p.jewelery;
      case 3:  return [...p.menClothing, ...p.womenClothing];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final products = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: GestureDetector(
          onPanStart:  _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd:    _onPanEnd,
          behavior: HitTestBehavior.translucent,
          child: NestedScrollView(
            // floatHeaderSlivers:true — the header reacts to inner
            // scroll events, not just the outer coordinator scroll.
            // This is what makes the banner collapse when you scroll
            // the product list inside the PageView.
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _DarazAppBar(
                user: auth.user,
                innerBoxIsScrolled: innerBoxIsScrolled,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  currentTab:    _currentTab,
                  onTabSelected: _switchTab,
                ),
              ),
            ],
            // PageView fills the remaining space that NestedScrollView
            // calculates after laying out the header slivers.
            // No SizedBox, no MediaQuery math, no intrinsic crash.
            body: PageView.builder(
              controller: _pageController,
              physics:    const NeverScrollableScrollPhysics(),
              itemCount:  _kTabLabels.length,
              itemBuilder: (context, index) => _TabBody(
                key:       PageStorageKey('tab_$index'),
                tabIndex:  index,
                products:  _productsForTab(index, products),
                loading:   products.loading,
                error:     products.error,
                onRefresh: () => products.refresh(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Collapsible App Bar
// floating+snap = hides on scroll down, snaps back on scroll up
// ════════════════════════════════════════════════════════════════
class _DarazAppBar extends StatelessWidget {
  final User? user;
  final bool  innerBoxIsScrolled;

  const _DarazAppBar({
    this.user,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 155,
      floating:      true,   // collapses/expands with scroll
      pinned:        false,  // fully hides when collapsed
      snap:          true,   // snaps fully open or closed — no half states
      forceElevated: innerBoxIsScrolled,
      backgroundColor: const Color(0xFFFF6D00),
      automaticallyImplyLeading: false,
      elevation: 0,
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.person_outline, color: Colors.white),
      //     onPressed: () => Navigator.pushNamed(context, '/profile'),
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      //     onPressed: () {},
      //   ),
      //   const SizedBox(width: 4),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6D00), Color(0xFFE65100)],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Greeting row ───────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: CircleAvatar(

                          radius: 17,
                          backgroundColor: Colors.white24,
                          child: Text(
                            user?.name.firstname.isNotEmpty == true
                                ? user!.name.firstname[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name.firstname ?? 'Guest'} 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'What are you shopping for today?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification bell
                      const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ── Search bar ─────────────────────────────────
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search,
                            color: Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search in Daraz...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ── Promo chips ────────────────────────────────
                  SingleChildScrollView(
                    // physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _PromoChip('🔥 Flash Sale', Colors.red[700]!),
                        const SizedBox(width: 8),
                        _PromoChip('🆕 New Arrivals', Colors.blue[700]!),
                        const SizedBox(width: 8),
                        _PromoChip('🚚 Free Delivery', Colors.green[700]!),
                        const SizedBox(width: 8),
                        _PromoChip('💸 Under \$20', Colors.purple[700]!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoChip extends StatelessWidget {
  final String text;
  final Color  color;
  const _PromoChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Sticky Tab Bar Delegate
// ════════════════════════════════════════════════════════════════
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int               currentTab;
  final ValueChanged<int> onTabSelected;

  const _TabBarDelegate({
    required this.currentTab,
    required this.onTabSelected,
  });

  @override double get minExtent => _kTabBarHeight;
  @override double get maxExtent => _kTabBarHeight;

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.currentTab != currentTab;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color:       Colors.white,
      elevation:   overlapsContent ? 2 : 0,
      shadowColor: Colors.black12,
      child: Row(
        children: List.generate(
          _kTabLabels.length,
              (i) => Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _kTabBarHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: currentTab == i
                          ? const Color(0xFFFF6D00)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: currentTab == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: currentTab == i
                        ? const Color(0xFFFF6D00)
                        : Colors.grey[500],
                  ),
                  child: Text(_kTabLabels[i]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Tab Body
// AutomaticKeepAliveClientMixin preserves scroll position when
// switching tabs — the ListView is not destroyed and recreated.
// ════════════════════════════════════════════════════════════════
class _TabBody extends StatefulWidget {
  final int              tabIndex;
  final List<Product>    products;
  final bool             loading;
  final String?          error;
  final Future<void> Function() onRefresh;

  const _TabBody({
    super.key,
    required this.tabIndex,
    required this.products,
    required this.loading,
    required this.onRefresh,
    this.error,
  });

  @override
  State<_TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<_TabBody>
    with AutomaticKeepAliveClientMixin {

  // Keep this tab's scroll state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    if (widget.loading && widget.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
      );
    }

    if (widget.error != null && widget.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Could not load products',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.error!,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.products.isEmpty && !widget.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No products found',
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
            ),
          ],
        ),
      );
    }

    // ── The actual scrollable list ──────────────────────────────
    // AlwaysScrollableScrollPhysics ensures pull-to-refresh works
    // even when there are few items that don't fill the screen.
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFFFF6D00),
      displacement: 20,
      child: ListView.builder(
        // NestedScrollView provides a PrimaryScrollController to
        // its body. Using primary:true connects this ListView to
        // that controller, which coordinates with the header collapse.
        primary:     true,
        physics:     const AlwaysScrollableScrollPhysics(),
        padding:     const EdgeInsets.only(top: 8, bottom: 32),
        itemCount:   widget.products.length,
        itemBuilder: (context, i) {
          final product = widget.products[i];
          return ProductCard(product: product);
        },
      ),
    );
  }
}*/






///
///
///
/// todo:: deviding
///
///
///




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../widgets/home/daraz_app_bar.dart';
import '../widgets/home/tab_bar_delegate.dart';
import '../widgets/home/tab_body.dart';

const List<String> kTabLabels = ['All', 'Electronics', 'Jewelery', 'Clothing'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(keepPage: true);

  int    _currentTab   = 0;
  double _dragStartX   = 0;
  double _dragStartY   = 0;
  bool   _dragDecided  = false;
  bool   _isHorizontal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Switch tab programmatically ───────────────────────────────
  void _switchTab(int index) {
    if (_currentTab == index) return;
    setState(() => _currentTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // ── Gesture: classify pan as horizontal or vertical ───────────
  void _onPanStart(DragStartDetails d) {
    _dragStartX   = d.globalPosition.dx;
    _dragStartY   = d.globalPosition.dy;
    _dragDecided  = false;
    _isHorizontal = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragDecided) return;
    final dx = (d.globalPosition.dx - _dragStartX).abs();
    final dy = (d.globalPosition.dy - _dragStartY).abs();
    if (dx < 8 && dy < 8) return;
    _dragDecided  = true;
    _isHorizontal = dx > dy * 1.5;
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_isHorizontal) return;
    final v = d.velocity.pixelsPerSecond.dx;
    if (v < -200 && _currentTab < kTabLabels.length - 1) {
      _switchTab(_currentTab + 1);
    } else if (v > 200 && _currentTab > 0) {
      _switchTab(_currentTab - 1);
    }
  }

  // ── Map tab index → product list ──────────────────────────────
  List<Product> _productsForTab(int tab, ProductsProvider p) {
    switch (tab) {
      case 0:  return p.all;
      case 1:  return p.electronics;
      case 2:  return p.jewelery;
      case 3:  return [...p.menClothing, ...p.womenClothing];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final products = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: GestureDetector(
          onPanStart:  _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd:    _onPanEnd,
          behavior: HitTestBehavior.translucent,
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              DarazAppBar(
                user:               auth.user,
                innerBoxIsScrolled: innerBoxIsScrolled,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: TabBarDelegate(
                  currentTab:    _currentTab,
                  tabLabels:     kTabLabels,
                  onTabSelected: _switchTab,
                ),
              ),
            ],
            body: PageView.builder(
              controller: _pageController,
              physics:    const NeverScrollableScrollPhysics(),
              itemCount:  kTabLabels.length,
              itemBuilder: (context, index) => TabBody(
                key:       PageStorageKey('tab_$index'),
                products:  _productsForTab(index, products),
                loading:   products.loading,
                error:     products.error,
                onRefresh: () => products.refresh(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}