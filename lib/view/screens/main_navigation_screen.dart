import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import 'coin_list_screen.dart';
import 'market_stats_screen.dart';
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
    const MarketStatsScreen(),
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ColorResource.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorResource.surface,
          selectedItemColor: ColorResource.appThemeColor1,
          unselectedItemColor: ColorResource.textSecondary,
          selectedLabelStyle: AppStyles.semiBold.copyWith(fontSize: 12),
          unselectedLabelStyle: AppStyles.regular.copyWith(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'Markets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
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
    return Scaffold(
      backgroundColor: ColorResource.appMainBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Profile',
                style: AppStyles.semiBold.copyWith(fontSize: 22, color: ColorResource.textPrimary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: ColorResource.headerGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
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
                          'Crypto Researcher',
                          style: AppStyles.semiBold.copyWith(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'pro.researcher@coinpilot.io',
                          style: AppStyles.regular.copyWith(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Preferences & Settings',
                style: AppStyles.semiBold.copyWith(fontSize: 16, color: ColorResource.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(Icons.notifications_outlined, 'Price Alerts', 'Manage push notifications'),
              _buildSettingTile(Icons.currency_exchange_rounded, 'Default Currency', 'USD (\$ - US Dollar)'),
              _buildSettingTile(Icons.security_rounded, 'Security & API Keys', 'Configured with CoinGecko API'),
              _buildSettingTile(Icons.info_outline_rounded, 'About CoinPilot', 'Version 1.0.0 (Interview Demo)'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: ColorResource.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: ColorResource.appThemeColor1),
        title: Text(title, style: AppStyles.semiBold.copyWith(fontSize: 14, color: ColorResource.textPrimary)),
        subtitle: Text(subtitle, style: AppStyles.regular.copyWith(fontSize: 12, color: ColorResource.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorResource.textSecondary),
        onTap: () {},
      ),
    );
  }
}
