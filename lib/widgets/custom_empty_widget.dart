import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../utils/app_images.dart';

class CustomEmptyWidget extends StatelessWidget {
  const CustomEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : ColorResource.textInputColor;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.unselectedLabelColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.noDataFoundImage,
              height: MediaQuery.of(context).size.height * 0.12,
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.02),
            Text(
              "No data found",
              style: AppStyles.semiBold.copyWith(
                color: textColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.002),
            Text(
              "No records available at the moment",
              style: AppStyles.medium.copyWith(
                color: subTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
