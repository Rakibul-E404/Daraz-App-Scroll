import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'promo_chip.dart';

class DarazAppBar extends StatelessWidget {
  final User? user;
  final bool innerBoxIsScrolled;

  const DarazAppBar({super.key, this.user, required this.innerBoxIsScrolled});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 155,
      floating: true,
      pinned: false,
      snap: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: const Color(0xFFFF6D00),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _AppBarBackground(user: user),
      ),
    );
  }
}

/// ── Background content of the flexible space ─────────────────────
class _AppBarBackground extends StatelessWidget {
  final User? user;

  const _AppBarBackground({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6D00), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GreetingRow(user: user),
              const SizedBox(height: 10),
              const _SearchBar(),
              const SizedBox(height: 10),
              const _PromoRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Greeting row ──────────────────────────────────────────────────
class _GreetingRow extends StatelessWidget {
  final User? user;

  const _GreetingRow({this.user});

  @override
  Widget build(BuildContext context) {
    final initial = user?.name.firstname.isNotEmpty == true
        ? user!.name.firstname[0].toUpperCase()
        : 'G';
    final name = user?.name.firstname ?? 'Guest';

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white24,
            child: Text(
              initial,
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
                'Hello, $name 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Text(
                'What are you shopping for today?',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
      ],
    );
  }
}

/// ── Search bar ────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search in Daraz...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
    );
  }
}

/// ── Promo chips row ───────────────────────────────────────────────
class _PromoRow extends StatelessWidget {
  const _PromoRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          PromoChip('🔥 Flash Sale', Colors.red[700]!),
          const SizedBox(width: 8),
          PromoChip('🆕 New Arrivals', Colors.blue[700]!),
          const SizedBox(width: 8),
          PromoChip('🚚 Free Delivery', Colors.green[700]!),
          const SizedBox(width: 8),
          PromoChip('💸 Under \$20', Colors.purple[700]!),
        ],
      ),
    );
  }
}
