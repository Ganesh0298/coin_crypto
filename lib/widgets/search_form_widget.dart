import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class SearchFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SearchFormWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search cryptocurrencies (e.g. Bitcoin, BTC)...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : ColorResource.border;
    final textColor = isDark ? Colors.white : ColorResource.textPrimary;
    final hintColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppStyles.regular.copyWith(
          fontSize: 14,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppStyles.regular.copyWith(
            fontSize: 14,
            color: hintColor,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ColorResource.appThemeColor1,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear!();
                    } else {
                      onChanged('');
                    }
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
