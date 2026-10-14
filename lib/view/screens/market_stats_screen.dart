import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/crypto_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class MarketStatsScreen extends StatelessWidget {
  const MarketStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResource.appMainBgColor,
      body: SafeArea(
        child: BlocBuilder<CryptoCubit, CryptoState>(
          builder: (context, state) {
            final stats = state.globalStats;
            final totalMarketCap =
                stats['total_market_cap']?['usd'] ?? 2450000000000.0;
            final totalVolume = stats['total_volume']?['usd'] ?? 85000000000.0;
            final btcDominance = stats['market_cap_percentage']?['btc'] ?? 52.4;
            final ethDominance = stats['market_cap_percentage']?['eth'] ?? 17.8;
            final activeCoins = stats['active_cryptocurrencies'] ?? 14250;

            // Gainers & Losers
            final coins = state.allCoins;
            final gainers = List.of(coins)
              ..sort(
                (a, b) => b.priceChangePercentage24h.compareTo(
                  a.priceChangePercentage24h,
                ),
              );
            final topGainers = gainers.take(3).toList();
            final losers = List.of(coins)
              ..sort(
                (a, b) => a.priceChangePercentage24h.compareTo(
                  b.priceChangePercentage24h,
                ),
              );
            final topLosers = losers.take(3).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: ColorResource.appThemeColor1,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Market Statistics',
                      style: AppStyles.semiBold.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Global Overview Cards
                        Text(
                          'Global Crypto Overview',
                          style: AppStyles.semiBold.copyWith(
                            fontSize: 18,
                            color: ColorResource.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                'Total Market Cap',
                                '\$${(totalMarketCap / 1e12).toStringAsFixed(2)}T',
                                '+2.4%',
                                true,
                                Icons.public_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                '24h Volume',
                                '\$${(totalVolume / 1e9).toStringAsFixed(1)}B',
                                '+5.1%',
                                true,
                                Icons.bar_chart_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                'Active Coins',
                                '$activeCoins',
                                'Live',
                                true,
                                Icons.token_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                'Market Sentiment',
                                'Bullish (74)',
                                'Greed',
                                true,
                                Icons.trending_up_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Market Dominance
                        Text(
                          'Market Dominance',
                          style: AppStyles.semiBold.copyWith(
                            fontSize: 18,
                            color: ColorResource.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorResource.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.card,
                            border: Border.all(color: ColorResource.border),
                          ),
                          child: Column(
                            children: [
                              _buildDominanceRow(
                                'Bitcoin (BTC)',
                                btcDominance,
                                ColorResource.appThemeColor1,
                              ),
                              const SizedBox(height: 16),
                              _buildDominanceRow(
                                'Ethereum (ETH)',
                                ethDominance,
                                ColorResource.appThemeColor2,
                              ),
                              const SizedBox(height: 16),
                              _buildDominanceRow(
                                'Other Altcoins',
                                (100 - (btcDominance + ethDominance)).toDouble(), // Added .toDouble() here
                                ColorResource.frequencyColor,
                              ),

                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Top Gainers
                        Text(
                          'Top Gainers (24h)',
                          style: AppStyles.semiBold.copyWith(
                            fontSize: 18,
                            color: ColorResource.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...topGainers.map((coin) => _buildMiniCoinCard(coin)),
                        const SizedBox(height: 24),
                        // Top Losers
                        Text(
                          'Top Losers (24h)',
                          style: AppStyles.semiBold.copyWith(
                            fontSize: 18,
                            color: ColorResource.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...topLosers.map((coin) => _buildMiniCoinCard(coin)),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    String badge,
    bool isPositive,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: ColorResource.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: ColorResource.appThemeColor1, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorResource.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  badge,
                  style: AppStyles.medium.copyWith(
                    fontSize: 10,
                    color: ColorResource.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppStyles.regular.copyWith(
              fontSize: 12,
              color: ColorResource.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.semiBold.copyWith(
              fontSize: 16,
              color: ColorResource.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDominanceRow(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppStyles.medium.copyWith(
                fontSize: 14,
                color: ColorResource.textPrimary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppStyles.semiBold.copyWith(
                fontSize: 14,
                color: ColorResource.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: ColorResource.appMainBgColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCoinCard(coin) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: ColorResource.border),
      ),
      child: Row(
        children: [
          Image.network(
            coin.image,
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.currency_bitcoin, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin.name,
                  style: AppStyles.semiBold.copyWith(
                    fontSize: 14,
                    color: ColorResource.textPrimary,
                  ),
                ),
                Text(
                  coin.symbol,
                  style: AppStyles.regular.copyWith(
                    fontSize: 12,
                    color: ColorResource.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${coin.currentPrice.toStringAsFixed(2)}',
                style: AppStyles.semiBold.copyWith(
                  fontSize: 14,
                  color: ColorResource.textPrimary,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                style: AppStyles.medium.copyWith(
                  fontSize: 12,
                  color: isPositive
                      ? ColorResource.success
                      : ColorResource.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
