import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/coins_bloc.dart';
import '../../bloc/coins_event.dart';
import '../../bloc/coins_state.dart';
import '../../repo/coins_repo.dart';
import '../../data/response/coin_chart_response.dart';
import '../../data/response/coin_details_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_responsive.dart';

class CoinDetailScreen extends StatefulWidget {
  final String coinId;
  final String coinName;

  const CoinDetailScreen({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  // Target market cap comparison presets (in USD)
  final Map<String, double> _compareTargets = {
    'Bitcoin': 1350000000000.0,
    'Ethereum': 350000000000.0,
    'Solana': 80000000000.0,
    'BNB': 85000000000.0,
  };

  String _selectedCompareTarget = 'Bitcoin';
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : ColorResource.border;
    final textColor = isDark ? Colors.white : ColorResource.textPrimary;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.textSecondary;

    return BlocProvider(
      create: (context) => CoinBloc(CoinRepository())
        ..add(FetchCoinDetailData(coinId: widget.coinId, days: '7')),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: ColorResource.appThemeColor1,
          elevation: 0,
          title: Text(
            widget.coinName,
            style: AppStyles.semiBold.copyWith(
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.white,
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<CoinBloc, CoinState>(
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
                  padding: EdgeInsets.all(Responsive.padding(context, 24.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: Responsive.padding(context, 48), color: ColorResource.danger),
                      SizedBox(height: Responsive.padding(context, 16)),
                      Text(
                        state.message,
                        style: AppStyles.medium.copyWith(fontSize: Responsive.fontSize(context, 14), color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.padding(context, 16)),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CoinBloc>().add(FetchCoinDetailData(coinId: widget.coinId));
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
              final marketData = details.marketData;

              final imageUrl = details.image['large'] ?? details.image['small'] ?? '';
              final symbol = details.symbol.toUpperCase();
              final rawDesc = details.description['en'] ?? 'No description available.';
              final categories = details.categories;
              final sentimentUp = details.sentimentVotesUpPercentage ?? 50.0;
              final sentimentDown = details.sentimentVotesDownPercentage ?? 50.0;

              double latestPrice = marketData?.currentPriceUsd ?? 0.0;
              double calculatedPriceChange = marketData?.priceChangePercentage24h ?? 0.0;

              if (latestPrice == 0.0 && chart.prices.isNotEmpty) {
                latestPrice = chart.prices.last.value;
                if (chart.prices.length > 24) {
                  final prevPrice = chart.prices[chart.prices.length - 24].value;
                  calculatedPriceChange = ((latestPrice - prevPrice) / prevPrice) * 100;
                }
              }

              // High/Low in chart timeframe
              double chartMinPrice = 0.0;
              double chartMaxPrice = 0.0;
              if (chart.prices.isNotEmpty) {
                chartMinPrice = chart.prices.map((p) => p.value).reduce((a, b) => a < b ? a : b);
                chartMaxPrice = chart.prices.map((p) => p.value).reduce((a, b) => a > b ? a : b);
              }

              final marketCap = marketData?.marketCapUsd ?? 0.0;
              final totalVolume = marketData?.totalVolumeUsd ?? 0.0;
              final circulatingSupply = marketData?.circulatingSupply ?? 0.0;
              final maxSupply = marketData?.maxSupply ?? marketData?.totalSupply;
              final high24h = marketData?.high24hUsd ?? chartMaxPrice;
              final low24h = marketData?.low24hUsd ?? chartMinPrice;

              return SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(details, imageUrl, symbol, surfaceColor, borderColor, textColor, subTextColor),
                    SizedBox(height: Responsive.padding(context, 16)),

                    // Price & Interactive Chart Card
                    _buildInteractiveChartCard(
                      context: context,
                      latestPrice: latestPrice,
                      priceChange: calculatedPriceChange,
                      chart: chart,
                      selectedDays: state.selectedDays,
                      chartMinPrice: chartMinPrice,
                      chartMaxPrice: chartMaxPrice,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    SizedBox(height: Responsive.padding(context, 20)),

                    // Price & Market Cap Compare Calculator
                    _buildMarketCapCompareSection(
                      symbol: symbol,
                      coinName: details.name,
                      currentPrice: latestPrice,
                      circulatingSupply: circulatingSupply,
                      currentMarketCap: marketCap,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    SizedBox(height: Responsive.padding(context, 20)),

                    // 24h Price Range Slider
                    if (high24h > 0 && low24h > 0)
                      _buildPriceRangeCard(
                        currentPrice: latestPrice,
                        low24h: low24h,
                        high24h: high24h,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    if (high24h > 0 && low24h > 0) SizedBox(height: Responsive.padding(context, 20)),

                    // Circulating & Total Supply Progress
                    if (circulatingSupply > 0)
                      _buildSupplyCard(
                        symbol: symbol,
                        circulatingSupply: circulatingSupply,
                        totalSupply: marketData?.totalSupply,
                        maxSupply: maxSupply,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    if (circulatingSupply > 0) SizedBox(height: Responsive.padding(context, 20)),

                    // Market Key Statistics Grid
                    Text(
                      'Market Statistics',
                      style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 16), color: textColor),
                    ),
                    SizedBox(height: Responsive.padding(context, 10)),
                    _buildMarketStatsGrid(
                      marketCap: marketCap,
                      totalVolume: totalVolume,
                      fdv: marketData?.fullyDilutedValuationUsd,
                      marketCapRank: details.marketCapRank,
                      ath: marketData?.athUsd,
                      athChange: marketData?.athChangePercentageUsd,
                      atl: marketData?.atlUsd,
                      atlChange: marketData?.atlChangePercentageUsd,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    SizedBox(height: Responsive.padding(context, 20)),

                    // Market Sentiment Bar
                    _buildSentimentCard(sentimentUp, sentimentDown, surfaceColor, borderColor, textColor, subTextColor),
                    SizedBox(height: Responsive.padding(context, 20)),

                    // Technical Info & Categories
                    _buildTechInfoGrid(details, categories, surfaceColor, borderColor, textColor, subTextColor),
                    SizedBox(height: Responsive.padding(context, 20)),

                    // About Description with Expandable Text
                    _buildAboutSection(rawDesc, details.name, surfaceColor, borderColor, textColor, subTextColor),
                    SizedBox(height: Responsive.padding(context, 32)),
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

  Widget _buildHeaderCard(
    CoinDetailsResponse details,
    String imageUrl,
    String symbol,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 18)),
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
              width: Responsive.padding(context, 48),
              height: Responsive.padding(context, 48),
              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                radius: Responsive.padding(context, 24),
                backgroundColor: ColorResource.appThemeColor1,
                child: const Icon(Icons.currency_bitcoin, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: Responsive.padding(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.name,
                  style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 19), color: textColor),
                ),
                SizedBox(height: Responsive.padding(context, 2)),
                Text(
                  symbol,
                  style: AppStyles.medium.copyWith(fontSize: Responsive.fontSize(context, 13), color: subTextColor),
                ),
              ],
            ),
          ),
          if (details.marketCapRank != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 12),
                vertical: Responsive.padding(context, 6),
              ),
              decoration: BoxDecoration(
                color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Rank #${details.marketCapRank}',
                style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 12), color: ColorResource.appThemeColor1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractiveChartCard({
    required BuildContext context,
    required double latestPrice,
    required double priceChange,
    required MarketChartResponse chart,
    required String selectedDays,
    required double chartMinPrice,
    required double chartMaxPrice,
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final isPositive = priceChange >= 0;

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 18)),
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
                  Text('Price', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 12), color: subTextColor)),
                  SizedBox(height: Responsive.padding(context, 4)),
                  Text(
                    latestPrice > 0 ? _formatPrice(latestPrice) : 'N/A',
                    style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 24), color: textColor),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 10),
                  vertical: Responsive.padding(context, 6),
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? ColorResource.success : ColorResource.danger).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: Responsive.padding(context, 18),
                      color: isPositive ? ColorResource.success : ColorResource.danger,
                    ),
                    SizedBox(width: Responsive.padding(context, 4)),
                    Text(
                      '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                      style: AppStyles.semiBold.copyWith(
                        fontSize: Responsive.fontSize(context, 13),
                        color: isPositive ? ColorResource.success : ColorResource.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 18)),

          // Interactive Timeframe Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeframeChip(context, '1', '24H', selectedDays, subTextColor),
              _buildTimeframeChip(context, '7', '7D', selectedDays, subTextColor),
              _buildTimeframeChip(context, '30', '1M', selectedDays, subTextColor),
              _buildTimeframeChip(context, '90', '3M', selectedDays, subTextColor),
              _buildTimeframeChip(context, '365', '1Y', selectedDays, subTextColor),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 16)),

          // High/Low Summary Bar for chart timeframe
          if (chartMaxPrice > 0)
            Padding(
              padding: EdgeInsets.only(bottom: Responsive.padding(context, 12.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Low: ${_formatPrice(chartMinPrice)}', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
                  Text('High: ${_formatPrice(chartMaxPrice)}', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
                ],
              ),
            ),

          // Interactive Chart Widget
          SizedBox(
            height: Responsive.setHeight(context, 26),
            child: chart.prices.isEmpty
                ? const Center(child: Text('No chart data available'))
                : LineChart(_buildInteractiveLineChartData(chart.prices, isDark, isPositive)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeChip(
    BuildContext context,
    String value,
    String label,
    String selectedValue,
    Color subTextColor,
  ) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        context.read<CoinBloc>().add(ChangeChartTimeframe(coinId: widget.coinId, days: value));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 14),
          vertical: Responsive.padding(context, 7),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorResource.appThemeColor1 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppStyles.medium.copyWith(
            fontSize: Responsive.fontSize(context, 12),
            color: isSelected ? Colors.white : subTextColor,
          ),
        ),
      ),
    );
  }

  LineChartData _buildInteractiveLineChartData(List<MarketDataPoint> prices, bool isDark, bool isPositive) {
    final spots = prices.map((p) => FlSpot(p.timestamp.toDouble(), p.value)).toList();
    final minY = prices.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = prices.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final lineColor = isPositive ? ColorResource.success : ColorResource.appThemeColor1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: isDark ? const Color(0xFF27272A) : ColorResource.border,
          strokeWidth: 1,
        ),
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: minY * 0.995,
      maxY: maxY * 1.005,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => isDark ? const Color(0xFF27272A) : Colors.black87,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
              final dateStr = '${_monthName(date.month)} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              return LineTooltipItem(
                '${_formatPrice(spot.y)}\n$dateStr',
                AppStyles.semiBold.copyWith(fontSize: 12, color: Colors.white),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withValues(alpha: 0.30),
                lineColor.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  // Market Cap & Price Comparison Section
  Widget _buildMarketCapCompareSection({
    required String symbol,
    required String coinName,
    required double currentPrice,
    required double circulatingSupply,
    required double currentMarketCap,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final targetMarketCap = _compareTargets[_selectedCompareTarget] ?? 1350000000000.0;

    double simulatedPrice = 0.0;
    double multiplier = 1.0;

    if (circulatingSupply > 0) {
      simulatedPrice = targetMarketCap / circulatingSupply;
      if (currentPrice > 0) {
        multiplier = simulatedPrice / currentPrice;
      }
    } else if (currentMarketCap > 0 && currentPrice > 0) {
      multiplier = targetMarketCap / currentMarketCap;
      simulatedPrice = currentPrice * multiplier;
    }

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 18)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 8)),
                decoration: BoxDecoration(
                  color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.compare_arrows_rounded, color: ColorResource.appThemeColor1, size: Responsive.padding(context, 20)),
              ),
              SizedBox(width: Responsive.padding(context, 10)),
              Expanded(
                child: Text(
                  'Price & Market Cap Compare',
                  style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 16), color: textColor),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 12)),
          Text(
            'See what 1 $symbol would be worth if $coinName reached the market cap of another major coin:',
            style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 12), color: subTextColor),
          ),
          SizedBox(height: Responsive.padding(context, 14)),

          // Compare Target Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _compareTargets.keys.map((targetName) {
                final isSelected = _selectedCompareTarget == targetName;
                return Padding(
                  padding: EdgeInsets.only(right: Responsive.padding(context, 8.0)),
                  child: ChoiceChip(
                    label: Text(targetName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCompareTarget = targetName;
                        });
                      }
                    },
                    selectedColor: ColorResource.appThemeColor1,
                    backgroundColor: Colors.transparent,
                    labelStyle: AppStyles.medium.copyWith(
                      fontSize: Responsive.fontSize(context, 12),
                      color: isSelected ? Colors.white : textColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(color: isSelected ? Colors.transparent : borderColor),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 16)),

          // Simulation Result Box
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 14)),
            decoration: BoxDecoration(
              color: ColorResource.appThemeColor1.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: ColorResource.appThemeColor1.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price at $_selectedCompareTarget MCap',
                      style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor),
                    ),
                    SizedBox(height: Responsive.padding(context, 4)),
                    Text(
                      _formatPrice(simulatedPrice),
                      style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 20), color: ColorResource.appThemeColor1),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 10),
                    vertical: Responsive.padding(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: ColorResource.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch, color: ColorResource.success, size: Responsive.padding(context, 14)),
                      SizedBox(width: Responsive.padding(context, 4)),
                      Text(
                        '${multiplier.toStringAsFixed(1)}x',
                        style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 13), color: ColorResource.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 24h Price Range Slider Widget
  Widget _buildPriceRangeCard({
    required double currentPrice,
    required double low24h,
    required double high24h,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    double progress = 0.5;
    if (high24h > low24h) {
      progress = ((currentPrice - low24h) / (high24h - low24h)).clamp(0.0, 1.0);
    }

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('24h Price Range', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 14), color: textColor)),
          SizedBox(height: Responsive.padding(context, 12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: borderColor,
              valueColor: const AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
              minHeight: 8,
            ),
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('24h Low: ${_formatPrice(low24h)}', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
              Text('24h High: ${_formatPrice(high24h)}', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  // Circulating & Max Supply Progress Widget
  Widget _buildSupplyCard({
    required String symbol,
    required double circulatingSupply,
    required double? totalSupply,
    required double? maxSupply,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    double? supplyPercentage;
    final total = maxSupply ?? totalSupply;
    if (total != null && total > 0) {
      supplyPercentage = (circulatingSupply / total) * 100;
    }

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Supply Details', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 14), color: textColor)),
              if (supplyPercentage != null)
                Text(
                  '${supplyPercentage.toStringAsFixed(1)}% Minted',
                  style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 12), color: ColorResource.appThemeColor1),
                ),
            ],
          ),
          if (supplyPercentage != null) ...[
            SizedBox(height: Responsive.padding(context, 10)),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: (supplyPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: borderColor,
                valueColor: const AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                minHeight: 8,
              ),
            ),
          ],
          SizedBox(height: Responsive.padding(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Circulating Supply', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
                  SizedBox(height: Responsive.padding(context, 2)),
                  Text('${_formatLargeNumber(circulatingSupply)} $symbol', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 13), color: textColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Max Supply', style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: subTextColor)),
                  SizedBox(height: Responsive.padding(context, 2)),
                  Text(total != null ? '${_formatLargeNumber(total)} $symbol' : '∞ Unlimited', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 13), color: textColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Key Statistics Grid
  Widget _buildMarketStatsGrid({
    required double marketCap,
    required double totalVolume,
    required double? fdv,
    required int? marketCapRank,
    required double? ath,
    required double? athChange,
    required double? atl,
    required double? atlChange,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final volToMcRatio = marketCap > 0 ? (totalVolume / marketCap) : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Responsive.padding(context, 12),
      mainAxisSpacing: Responsive.padding(context, 12),
      childAspectRatio: 2.1,
      children: [
        _buildStatCard('Market Cap', marketCap > 0 ? '\$${_formatLargeNumber(marketCap)}' : 'N/A', Icons.pie_chart_rounded, surfaceColor, borderColor, textColor, subTextColor),
        _buildStatCard('24h Trading Vol', totalVolume > 0 ? '\$${_formatLargeNumber(totalVolume)}' : 'N/A', Icons.bar_chart_rounded, surfaceColor, borderColor, textColor, subTextColor),
        _buildStatCard('Vol / Market Cap', volToMcRatio > 0 ? '${(volToMcRatio * 100).toStringAsFixed(2)}%' : 'N/A', Icons.sync_alt_rounded, surfaceColor, borderColor, textColor, subTextColor),
        _buildStatCard('FDV Valuation', fdv != null && fdv > 0 ? '\$${_formatLargeNumber(fdv)}' : 'N/A', Icons.account_balance_wallet_rounded, surfaceColor, borderColor, textColor, subTextColor),
        _buildStatCard('All-Time High', ath != null ? _formatPrice(ath) : 'N/A', Icons.north_east_rounded, surfaceColor, borderColor, textColor, subTextColor, extraText: athChange != null ? '${athChange.toStringAsFixed(1)}%' : null),
        _buildStatCard('All-Time Low', atl != null ? _formatPrice(atl) : 'N/A', Icons.south_east_rounded, surfaceColor, borderColor, textColor, subTextColor, extraText: atlChange != null ? '+${atlChange.toStringAsFixed(1)}%' : null),
      ],
    );
  }

  // Market Sentiment
  Widget _buildSentimentCard(
    double sentimentUp,
    double sentimentDown,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Community Sentiment', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 14), color: textColor)),
          SizedBox(height: Responsive.padding(context, 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bullish: ${sentimentUp.toStringAsFixed(1)}%', style: AppStyles.medium.copyWith(fontSize: Responsive.fontSize(context, 12), color: ColorResource.success)),
              Text('Bearish: ${sentimentDown.toStringAsFixed(1)}%', style: AppStyles.medium.copyWith(fontSize: Responsive.fontSize(context, 12), color: ColorResource.danger)),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: (sentimentUp / 100).clamp(0.0, 1.0),
              backgroundColor: ColorResource.danger,
              valueColor: const AlwaysStoppedAnimation<Color>(ColorResource.success),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // Technical Info & Categories
  Widget _buildTechInfoGrid(
    CoinDetailsResponse details,
    List<String> categories,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Info', style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 16), color: textColor)),
        SizedBox(height: Responsive.padding(context, 10)),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: Responsive.padding(context, 12),
          mainAxisSpacing: Responsive.padding(context, 12),
          childAspectRatio: 2.1,
          children: [
            _buildStatCard('Hashing Algorithm', details.hashingAlgorithm ?? 'N/A', Icons.code_rounded, surfaceColor, borderColor, textColor, subTextColor),
            _buildStatCard('Genesis Date', details.genesisDate ?? 'N/A', Icons.calendar_today_rounded, surfaceColor, borderColor, textColor, subTextColor),
            _buildStatCard('Watchlist Users', '${details.watchlistPortfolioUsers ?? 0}', Icons.favorite_rounded, surfaceColor, borderColor, textColor, subTextColor),
            _buildStatCard('Block Time', details.blockTimeInMinutes != null ? '${details.blockTimeInMinutes} min' : 'N/A', Icons.timer_rounded, surfaceColor, borderColor, textColor, subTextColor),
          ],
        ),
        if (categories.isNotEmpty) ...[
          SizedBox(height: Responsive.padding(context, 16)),
          Text('Categories', style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 14), color: textColor)),
          SizedBox(height: Responsive.padding(context, 8)),
          Wrap(
            spacing: Responsive.padding(context, 8),
            runSpacing: Responsive.padding(context, 8),
            children: categories.take(6).map((cat) => Chip(
              label: Text(cat, style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 11), color: textColor)),
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill), side: BorderSide(color: borderColor)),
            )).toList(),
          ),
        ],
      ],
    );
  }

  // About / Description with Expandable Text
  Widget _buildAboutSection(
    String rawDesc,
    String name,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final cleanDesc = rawDesc.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About $name', style: AppStyles.bold.copyWith(fontSize: Responsive.fontSize(context, 16), color: textColor)),
        SizedBox(height: Responsive.padding(context, 10)),
        Container(
          padding: EdgeInsets.all(Responsive.padding(context, 16)),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cleanDesc,
                maxLines: _isDescriptionExpanded ? 100 : 4,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.regular.copyWith(
                  fontSize: Responsive.fontSize(context, 13),
                  color: subTextColor,
                  height: 1.5,
                ),
              ),
              if (cleanDesc.length > 180) ...[
                SizedBox(height: Responsive.padding(context, 8)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    _isDescriptionExpanded ? 'Read Less' : 'Read More',
                    style: AppStyles.semiBold.copyWith(
                      fontSize: Responsive.fontSize(context, 13),
                      color: ColorResource.appThemeColor1,
                    ),
                  ),
                ),
              ],
            ],
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
    Color subTextColor, {
    String? extraText,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 10)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 7)),
            decoration: BoxDecoration(
              color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: Responsive.padding(context, 18), color: ColorResource.appThemeColor1),
          ),
          SizedBox(width: Responsive.padding(context, 8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppStyles.regular.copyWith(fontSize: Responsive.fontSize(context, 10), color: subTextColor)),
                SizedBox(height: Responsive.padding(context, 2)),
                Text(
                  value,
                  style: AppStyles.semiBold.copyWith(fontSize: Responsive.fontSize(context, 12), color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (extraText != null)
                  Text(
                    extraText,
                    style: AppStyles.medium.copyWith(
                      fontSize: Responsive.fontSize(context, 10),
                      color: extraText.startsWith('-') ? ColorResource.danger : ColorResource.success,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1.0) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 0.0001) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }

  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}
