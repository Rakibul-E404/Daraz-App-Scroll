import 'package:flutter/material.dart';

const double kTabBarHeight = 48.0;

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int                    currentTab;
  final List<String>           tabLabels;
  final ValueChanged<int>      onTabSelected;

  const TabBarDelegate({
    required this.currentTab,
    required this.tabLabels,
    required this.onTabSelected,
  });

  @override double get minExtent => kTabBarHeight;
  @override double get maxExtent => kTabBarHeight;

  @override
  bool shouldRebuild(TabBarDelegate old) =>
      old.currentTab != currentTab;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color:       Colors.white,
      elevation:   overlapsContent ? 2 : 0,
      shadowColor: Colors.black12,
      child: Row(
        children: List.generate(
          tabLabels.length,
              (i) => Expanded(
            child: _TabItem(
              label:      tabLabels[i],
              isSelected: currentTab == i,
              onTap:      () => onTabSelected(i),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single tab item ───────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final bool   isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:    onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration:  const Duration(milliseconds: 200),
        height:    kTabBarHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:      isSelected
                ? const Color(0xFFFF6D00)
                : Colors.grey[500],
          ),
          child: Text(label),
        ),
      ),
    );
  }
}