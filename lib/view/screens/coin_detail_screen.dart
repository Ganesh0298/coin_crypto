import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/coin_detail_bloc.dart';
import '../../bloc/coin_detail_event.dart';
import '../../bloc/coin_detail_state.dart';
import '../../repo/coins_repo.dart';
import '../../data/response/coin_chart_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class CoinDetailScreen extends StatelessWidget {
  final String coinId;
  final String coinName;

  const CoinDetailScreen({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : ColorResource.border;
    final textColor = isDark ? Colors.white : ColorResource.textPrimary;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.textSecondary;

    return BlocProvider(
      create: (context) => CoinDetailBloc(CoinRepository())
        ..add(FetchCoinDetailData(coinId: coinId, days: '7')),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: ColorResource.appThemeColor1,
          elevation: 0,
          title: Text(
            coinName,
            style: AppStyles.semiBold.copyWith(fontSize: 18, color: Colors.white),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent,statusBarIconBrightness: Brightness.light),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<CoinDetailBloc, CoinDetailState>(
          builder: (context, state) {
            if (state is CoinDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                ),
              );
            }

            if (state is CoinDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: ColorResource.danger),
                      const SizedBox(height: 16),
                      Text(state.message, style: AppStyles.medium.copyWith(fontSize: 14, color: textColor), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CoinDetailBloc>().add(FetchCoinDetailData(coinId: coinId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CoinDetailSuccess) {
              final details = state.details;
              final chart = state.chart;
              final imageUrl = details.image['large'] ?? details.image['small'] ?? '';
              final symbol = details.symbol.toUpperCase();
              final desc = details.description['en'] ?? 'No description available.';
              final categories = details.categories;
              final sentimentUp = details.sentimentVotesUpPercentage ?? 50.0;
              final sentimentDown = details.sentimentVotesDownPercentage ?? 50.0;

              double latestPrice = 0.0;
              double calculatedPriceChange = 0.0;
              if (chart.prices.isNotEmpty) {
                latestPrice = chart.prices.last.value;
                if (chart.prices.length > 24) {
                  final prevPrice = chart.prices[chart.prices.length - 24].value;
                  calculatedPriceChange = ((latestPrice - prevPrice) / prevPrice) * 100;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.card,
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                radius: 25,
                                backgroundColor: ColorResource.appThemeColor1,
                                child: Icon(Icons.currency_bitcoin, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  details.name,
                                  style: AppStyles.bold.copyWith(fontSize: 20, color: textColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  symbol,
                                  style: AppStyles.medium.copyWith(fontSize: 14, color: subTextColor),
                                ),
                              ],
                            ),
                          ),
                          if (details.marketCapRank != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ColorResource.appThemeColor1.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'Rank #${details.marketCapRank}',
                                style: AppStyles.semiBold.copyWith(fontSize: 13, color: ColorResource.appThemeColor1),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Price & Chart Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.card,
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Latest Price', style: AppStyles.regular.copyWith(fontSize: 12, color: subTextColor)),
                                  const SizedBox(height: 4),
                                  Text(
                                    latestPrice > 0 ? '\$${latestPrice.toStringAsFixed(latestPrice > 10 ? 2 : 4)}' : 'N/A',
                                    style: AppStyles.bold.copyWith(fontSize: 24, color: textColor),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (calculatedPriceChange >= 0 ? ColorResource.success : ColorResource.danger).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      calculatedPriceChange >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                      size: 18,
                                      color: calculatedPriceChange >= 0 ? ColorResource.success : ColorResource.danger,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${calculatedPriceChange >= 0 ? '+' : ''}${calculatedPriceChange.toStringAsFixed(2)}%',
                                      style: AppStyles.semiBold.copyWith(
                                        fontSize: 13,
                                        color: calculatedPriceChange >= 0 ? ColorResource.success : ColorResource.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Timeframe Selectors
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['1', '7', '30', '90', '365'].map((days) {
                              final isSelected = state.selectedDays == days;
                              final label = days == '1' ? '24H' : days == '7' ? '7D' : days == '30' ? '1M' : days == '90' ? '3M' : '1Y';
                              return GestureDetector(
                                onTap: () {
                                  context.read<CoinDetailBloc>().add(ChangeChartTimeframe(coinId: coinId, days: days));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ColorResource.appThemeColor1 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    label,
                                    style: AppStyles.medium.copyWith(
                                      fontSize: 13,
                                      color: isSelected ? Colors.white : subTextColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: chart.prices.isEmpty
                                ? const Center(child: Text('No chart data available'))
                                : LineChart(
                                    _buildLineChartData(chart.prices, isDark),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Market Sentiment Bar
                    Text(
                      'Market Sentiment',
                      style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
                    ),
                    const SizedBox(height: 10),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bullish: ${sentimentUp.toStringAsFixed(1)}%', style: AppStyles.medium.copyWith(fontSize: 13, color: ColorResource.success)),
                              Text('Bearish: ${sentimentDown.toStringAsFixed(1)}%', style: AppStyles.medium.copyWith(fontSize: 13, color: ColorResource.danger)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: sentimentUp / 100,
                              backgroundColor: ColorResource.danger,
                              valueColor: const AlwaysStoppedAnimation<Color>(ColorResource.success),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Project Statistics Grid
                    Text(
                      'Advanced Analytics & Statistics',
                      style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _buildStatCard('Hashing Algorithm', details.hashingAlgorithm ?? 'N/A', Icons.code_rounded, surfaceColor, borderColor, textColor, subTextColor),
                        _buildStatCard('Genesis Date', details.genesisDate ?? 'N/A', Icons.calendar_today_rounded, surfaceColor, borderColor, textColor, subTextColor),
                        _buildStatCard('Watchlist Users', '${details.watchlistPortfolioUsers ?? 0}', Icons.favorite_rounded, surfaceColor, borderColor, textColor, subTextColor),
                        _buildStatCard('Market Cap Rank', '#${details.marketCapRank ?? 'N/A'}', Icons.military_tech_rounded, surfaceColor, borderColor, textColor, subTextColor),
                      ],
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Categories',
                        style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.take(6).map((cat) => Chip(
                          label: Text(cat, style: AppStyles.regular.copyWith(fontSize: 12, color: textColor)),
                          backgroundColor: surfaceColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: borderColor)),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // About Description
                    Text(
                      'About ${details.name}',
                      style: AppStyles.semiBold.copyWith(fontSize: 16, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.card,
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        desc.replaceAll(RegExp(r'<[^>]*>'), ''), // Strip HTML tags
                        style: AppStyles.regular.copyWith(fontSize: 14, color: subTextColor, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<MarketDataPoint> prices, bool isDark) {
    final spots = prices.map((p) => FlSpot(p.timestamp.toDouble(), p.value)).toList();
    final minY = prices.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = prices.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: isDark ? const Color(0xFF27272A) : ColorResource.border,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: minY * 0.99,
      maxY: maxY * 1.01,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: ColorResource.appThemeColor1,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorResource.appThemeColor1.withOpacity(0.35),
                ColorResource.appThemeColor1.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorResource.appThemeColor1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: ColorResource.appThemeColor1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppStyles.regular.copyWith(fontSize: 11, color: subTextColor)),
                const SizedBox(height: 2),
                Text(value, style: AppStyles.semiBold.copyWith(fontSize: 13, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
