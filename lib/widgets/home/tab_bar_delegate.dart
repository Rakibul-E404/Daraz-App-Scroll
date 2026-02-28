import 'package:flutter/material.dart';

const double kTabBarHeight = 48.0;

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int currentTab;
  final List<String> tabLabels;
  final ValueChanged<int> onTabSelected;

  const TabBarDelegate({
    required this.currentTab,
    required this.tabLabels,
    required this.onTabSelected,
  });

  @override
  double get minExtent => kTabBarHeight;

  @override
  double get maxExtent => kTabBarHeight;

  @override
  bool shouldRebuild(TabBarDelegate old) => old.currentTab != currentTab;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black12,
      child: Row(
        children: List.generate(
          tabLabels.length,
          (i) => Expanded(
            child: _TabItem(
              label: tabLabels[i],
              isSelected: currentTab == i,
              onTap: () => onTabSelected(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      overlayColor: MaterialStateProperty.all(
        const Color(0xFFFF6D00).withOpacity(0.08),
      ),
      child: SizedBox(
        height: kTabBarHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Label with smooth color + weight transition
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                color: isSelected ? const Color(0xFFFF6D00) : Colors.grey[500]!,
              ),
              child: Text(label),
            ),
            // Sliding bottom indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF6D00)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
