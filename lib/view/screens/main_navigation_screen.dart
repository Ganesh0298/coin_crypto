import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/theme_notifier.dart';
import 'coin_list_screen.dart';
import 'watchlist_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CoinListScreen(),
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final navBorder = isDark ? const Color(0xFF27272A) : ColorResource.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating Innovative BottomAppBar
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: navBg.withOpacity(0.98),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: navBorder, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.show_chart_rounded, 'Chart', isDark),
                  _buildNavItem(1, Icons.favorite_rounded, 'Watchlist', isDark),
                  _buildNavItem(2, Icons.person_rounded, 'Profile', isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final unselectedColor = isDark ? Colors.white70 : ColorResource.textSecondary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorResource.appThemeColor1 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : unselectedColor,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppStyles.semiBold.copyWith(fontSize: 13, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : ColorResource.border;
    final textColor = isDark ? Colors.white : ColorResource.textPrimary;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.textSecondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Profile',
                style: AppStyles.bold.copyWith(fontSize: 22, color: textColor),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: ColorResource.headerGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 36, color: ColorResource.appThemeColor1),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coin crypto',
                          style: AppStyles.bold.copyWith(fontSize: 18, color: Colors.white),
                        ),
                        // const SizedBox(height: 4),
                        // Text(
                        //   'pro.trader@coinpilot.io',
                        //   style: AppStyles.regular.copyWith(fontSize: 13, color: Colors.white70),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Appearance & Theme',
                style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: borderColor),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _buildThemeRadio(context, 'System Default', ThemeMode.system, textColor),
                    Divider(height: 24, color: borderColor),
                    _buildThemeRadio(context, 'Light Mode', ThemeMode.light, textColor),
                    Divider(height: 24, color: borderColor),
                    _buildThemeRadio(context, 'Dark Mode', ThemeMode.dark, textColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Preferences & Settings',
                style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(Icons.notifications_outlined, 'Price Alerts', 'Manage push notifications', surfaceColor, borderColor, textColor, subTextColor),
              _buildSettingTile(Icons.currency_exchange_rounded, 'Default Currency', 'USD (\$ - US Dollar)', surfaceColor, borderColor, textColor, subTextColor),
              _buildSettingTile(Icons.security_rounded, 'Security & API Keys', 'Configured with CoinGecko API', surfaceColor, borderColor, textColor, subTextColor),
              _buildSettingTile(Icons.info_outline_rounded, 'About CoinPilot', 'Version 1.0.0 (Pro Terminal)', surfaceColor, borderColor, textColor, subTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeRadio(BuildContext context, String title, ThemeMode mode, Color textColor) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        final isSelected = themeNotifier.themeMode == mode;
        return InkWell(
          onTap: () {
            themeNotifier.setThemeMode(mode);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.medium.copyWith(
                  fontSize: 15,
                  color: isSelected ? ColorResource.appThemeColor1 : textColor,
                ),
              ),
              Radio<ThemeMode>(
                value: mode,
                groupValue: themeNotifier.themeMode,
                activeColor: ColorResource.appThemeColor1,
                onChanged: (val) {
                  if (val != null) {
                    themeNotifier.setThemeMode(val);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: ColorResource.appThemeColor1),
        title: Text(title, style: AppStyles.semiBold.copyWith(fontSize: 14, color: textColor)),
        subtitle: Text(subtitle, style: AppStyles.regular.copyWith(fontSize: 12, color: subTextColor)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subTextColor),
        onTap: () {},
      ),
    );
  }
}
