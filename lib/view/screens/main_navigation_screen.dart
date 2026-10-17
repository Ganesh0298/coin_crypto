import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/coins_bloc.dart';
import '../../bloc/coins_event.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_responsive.dart';
import '../../utils/theme_notifier.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'coin_list_screen.dart';
import 'market_statistics_screen.dart';
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
    const MarketStatisticsScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }

    // Trigger API recall when switching to CoinListScreen (0) or MarketStatisticsScreen (2)
    if (index == 0) {
      context.read<CoinBloc>().add(FetchCoinsList());
    } else if (index == 2) {
      context.read<CoinBloc>().add(FetchGlobalMarketData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // IndexedStack maintains state of all screens without rebuilding them on tab switch
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Custom Bottom Navigation Bar
          CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ],
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppStyles.bold.copyWith(
                  fontSize: Responsive.fontSize(context, 22),
                  color: textColor,
                ),
              ),
              SizedBox(height: Responsive.padding(context, 20)),
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 20)),
                decoration: BoxDecoration(
                  gradient: ColorResource.headerGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.padding(context, 30),
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        size: Responsive.padding(context, 36),
                        color: ColorResource.appThemeColor1,
                      ),
                    ),
                    SizedBox(width: Responsive.padding(context, 16)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coin Crypto',
                          style: AppStyles.bold.copyWith(
                            fontSize: Responsive.fontSize(context, 18),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.padding(context, 24)),
              Text(
                'Appearance & Theme',
                style: AppStyles.semiBold.copyWith(
                  fontSize: Responsive.fontSize(context, 16),
                  color: textColor,
                ),
              ),
              SizedBox(height: Responsive.padding(context, 12)),
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: borderColor),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _buildThemeRadio(context, 'System Default', ThemeMode.system, textColor),
                    Divider(height: Responsive.padding(context, 24), color: borderColor),
                    _buildThemeRadio(context, 'Light Mode', ThemeMode.light, textColor),
                    Divider(height: Responsive.padding(context, 24), color: borderColor),
                    _buildThemeRadio(context, 'Dark Mode', ThemeMode.dark, textColor),
                  ],
                ),
              ),
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
                  fontSize: Responsive.fontSize(context, 15),
                  color: isSelected ? ColorResource.appThemeColor1 : textColor,
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? ColorResource.appThemeColor1 : ColorResource.neutral,
                size: Responsive.padding(context, 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
