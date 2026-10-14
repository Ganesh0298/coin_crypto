import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/crypto_bloc.dart';
import '../../widgets/coin_card_widget.dart';
import '../../widgets/state_widgets.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResource.appMainBgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: ColorResource.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Watchlist',
                        style: AppStyles.semiBold.copyWith(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your favorite crypto assets',
                        style: AppStyles.regular.copyWith(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CryptoCubit, CryptoState>(
                builder: (context, state) {
                  final watchlistedCoins = state.allCoins.where((coin) => coin.isWatchlisted).toList();

                  if (watchlistedCoins.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Your Watchlist is Empty',
                      subtitle: 'Tap the heart icon on any cryptocurrency card in the market list to add it to your watchlist.',
                      icon: Icons.favorite_border_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: watchlistedCoins.length,
                    itemBuilder: (context, index) {
                      final coin = watchlistedCoins[index];
                      return CoinCardWidget(
                        coin: coin,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoinDetailScreen(coin: coin),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
