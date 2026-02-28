import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../product_card.dart';

class TabBody extends StatefulWidget {
  final List<Product>            products;
  final bool                     loading;
  final String?                  error;
  final Future<void> Function()  onRefresh;

  const TabBody({
    super.key,
    required this.products,
    required this.loading,
    required this.onRefresh,
    this.error,
  });

  @override
  State<TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<TabBody>
    with AutomaticKeepAliveClientMixin {

  // Keeps this tab's scroll position alive when switching tabs.
  // Without this, PageView destroys off-screen tabs and resets scroll.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    // ── Loading state ─────────────────────────────────────────
    if (widget.loading && widget.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6D00)),
      );
    }

    // ── Error state ───────────────────────────────────────────
    if (widget.error != null && widget.products.isEmpty) {
      return _ErrorView(
        message:   widget.error!,
        onRetry:   widget.onRefresh,
      );
    }

    // ── Empty state ───────────────────────────────────────────
    if (widget.products.isEmpty && !widget.loading) {
      return const _EmptyView();
    }

    // ── Product list ──────────────────────────────────────────
    // primary:true connects this ListView to the PrimaryScrollController
    // that NestedScrollView provides — coordinates header collapse.
    // AlwaysScrollableScrollPhysics ensures pull-to-refresh fires
    // even when items don't fill the screen.
    return RefreshIndicator(
      onRefresh:    widget.onRefresh,
      color:        const Color(0xFFFF6D00),
      displacement: 20,
      child: ListView.builder(
        primary:     true,
        physics:     const AlwaysScrollableScrollPhysics(),
        padding:     const EdgeInsets.only(top: 8, bottom: 32),
        itemCount:   widget.products.length,
        itemBuilder: (_, i) => ProductCard(product: widget.products[i]),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String               message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Could not load products',
              style: TextStyle(
                color:      Colors.grey[500],
                fontSize:   15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style:     TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh),
              label:     const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty view ────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
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
}