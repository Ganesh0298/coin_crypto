import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_responsive.dart';
import '../../utils/custom_navigation.dart';

import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate to MainNavigationScreen after 2.5 seconds using CustomNavigation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        CustomNavigation.pushReplacement(context, const MainNavigationScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Logo Container
                Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 24)),
                  decoration: BoxDecoration(
                    gradient: ColorResource.headerGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorResource.appThemeColor1.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.currency_bitcoin_rounded,
                    size: Responsive.padding(context, 64),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: Responsive.padding(context, 24)),
                Text(
                  'Coin Crypto',
                  style: AppStyles.bold.copyWith(
                    fontSize: Responsive.fontSize(context, 26),
                    color: isDark ? Colors.white : ColorResource.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: Responsive.padding(context, 8)),
                SizedBox(
                  width: Responsive.padding(context, 32),
                  height: Responsive.padding(context, 32),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
