import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_responsive.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final navBorder = isDark ? const Color(0xFF27272A) : ColorResource.border;

    final horizontalMargin = Responsive.setWidth(context, 6);
    final verticalBottomPadding = Responsive.setHeight(context, 2.2);

    return Positioned(
      left: horizontalMargin,
      right: horizontalMargin,
      bottom: verticalBottomPadding,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 16),
          vertical: Responsive.padding(context, 8),
        ),
        decoration: BoxDecoration(
          color: navBg.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: navBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.show_chart_rounded, 'Chart', isDark),
            _buildNavItem(context, 1, Icons.favorite_rounded, 'Watchlist', isDark),
            _buildNavItem(
              context, 2,  Icons.query_stats_rounded, 'Market', isDark,
            ),
            _buildNavItem(context, 3, Icons.person_rounded, 'Profile', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isDark) {
    final isSelected = currentIndex == index;
    final unselectedColor = isDark ? Colors.white70 : ColorResource.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? Responsive.padding(context, 18) : Responsive.padding(context, 12),
          vertical: Responsive.padding(context, 10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorResource.appThemeColor1 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Responsive.padding(context, 20),
              color: isSelected ? Colors.white : unselectedColor,
            ),
            if (isSelected) ...[
              SizedBox(width: Responsive.padding(context, 8)),
              Text(
                label,
                style: AppStyles.semiBold.copyWith(
                  fontSize: Responsive.fontSize(context, 13),
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
