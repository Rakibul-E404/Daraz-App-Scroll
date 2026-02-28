import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Image app bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight:    320,
            pinned:            true,
            backgroundColor:   Colors.white,
            foregroundColor:   Colors.black87,
            surfaceTintColor:  Colors.transparent,
            elevation:         0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32),
                child: CachedNetworkImage(
                  imageUrl:   p.image,
                  fit:        BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFFF6D00)),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Main info card ───────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:        const Color(0xFFFF6D00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: const TextStyle(
                            color:      Color(0xFFFF6D00),
                            fontSize:   10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                          height:     1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating row
                      Row(
                        children: [
                          // Stars
                          Row(
                            children: List.generate(5, (i) {
                              final full  = i < p.rating.rate.floor();
                              final half  = !full &&
                                  i < p.rating.rate &&
                                  (p.rating.rate - i) >= 0.5;
                              return Icon(
                                full
                                    ? Icons.star
                                    : half
                                    ? Icons.star_half
                                    : Icons.star_border,
                                color: Colors.amber[600],
                                size:  18,
                              );
                            }),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${p.rating.rate}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${p.rating.count} reviews)',
                            style: TextStyle(
                              color:    Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize:   28,
                              fontWeight: FontWeight.w900,
                              color:      Color(0xFFFF6D00),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\$${(p.price * 1.2).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize:      14,
                              color:         Colors.grey[400],
                              decoration:    TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:        Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '20% OFF',
                              style: TextStyle(
                                color:      Colors.red[600],
                                fontSize:   11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'inclusive of all taxes',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Delivery info card ───────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon:  Icons.local_shipping_outlined,
                        title: 'Free Delivery',
                        sub:   'Delivered in 3–5 business days',
                        color: Colors.green[600]!,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon:  Icons.replay_outlined,
                        title: '30-Day Returns',
                        sub:   'Easy return & exchange policy',
                        color: Colors.blue[600]!,
                      ),
                      const Divider(height: 20),
                      _InfoRow(
                        icon:  Icons.verified_outlined,
                        title: 'Authentic Product',
                        sub:   '100% genuine products guaranteed',
                        color: const Color(0xFFFF6D00),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Quantity selector ────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      _QuantityButton(
                        icon:    Icons.remove,
                        onTap:   _decrement,
                        enabled: _quantity > 1,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _QuantityButton(
                        icon:  Icons.add,
                        onTap: _increment,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Description ──────────────────────────────────
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Description',
                        style: TextStyle(
                          fontSize:   16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.description,
                        style: TextStyle(
                          fontSize: 14,
                          color:    Colors.grey[600],
                          height:   1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Total price summary ──────────────────────────
                Container(
                  color:   Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${(p.price * _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize:   20,
                              fontWeight: FontWeight.w900,
                              color:      Color(0xFFFF6D00),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_quantity × \$${p.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Bottom padding for the fixed buttons
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom action buttons ────────────────────────────────────
      bottomNavigationBar: _BottomActions(
        product:  p,
        quantity: _quantity,
      ),
    );
  }
}

/// ── Delivery / policy info row ────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   sub;
  final Color    color;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:     const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:        color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              sub,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

/// ── Quantity +/- button ───────────────────────────────────────────
class _QuantityButton extends StatelessWidget {
  final IconData   icon;
  final VoidCallback onTap;
  final bool       enabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width:  36,
        height: 36,
        decoration: BoxDecoration(
          color:        enabled
              ? const Color(0xFFFF6D00).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? const Color(0xFFFF6D00).withOpacity(0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Icon(
          icon,
          size:  18,
          color: enabled ? const Color(0xFFFF6D00) : Colors.grey[400],
        ),
      ),
    );
  }
}

/// ── Bottom action bar ─────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  final Product product;
  final int     quantity;

  const _BottomActions({
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${product.title.split(' ').take(3).join(' ')} added to cart!'),
                    backgroundColor: const Color(0xFFFF6D00),
                    behavior:        SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon:  const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6D00),
                side: const BorderSide(color: Color(0xFFFF6D00)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Buy Now
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Buying ${quantity}x for \$${(product.price * quantity).toStringAsFixed(2)}'),
                    backgroundColor: Colors.green[600],
                    behavior:        SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon:  const Icon(Icons.bolt),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}