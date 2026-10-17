import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/coins_bloc.dart';
import '../../bloc/coins_event.dart';
import '../../bloc/coins_state.dart';
import '../../data/response/global_market_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_responsive.dart';
import '../../utils/app_styles.dart';
import '../../widgets/state_widgets.dart';

class MarketStatisticsScreen extends StatefulWidget {
  const MarketStatisticsScreen({super.key});

  @override
  State<MarketStatisticsScreen> createState() => _MarketStatisticsScreenState();
}

class _MarketStatisticsScreenState extends State<MarketStatisticsScreen> {
  GlobalMarketData? _marketData;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CoinBloc>();
    if (bloc.state is GlobalListSuccess) {
      _marketData = (bloc.state as GlobalListSuccess).globalMarket.data;
    } else {
      bloc.add(FetchGlobalMarketData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16161A) : ColorResource.surface;
    final borderColor = isDark ? const Color(0xFF27272A) : ColorResource.border;
    final textColor = isDark ? Colors.white : ColorResource.textPrimary;
    final subTextColor = isDark ? const Color(0xFF9CA3AF) : ColorResource.textSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: BlocConsumer<CoinBloc, CoinState>(
            listener: (context, state) {
              if (state is GlobalListSuccess) {
                setState(() {
                  _marketData = state.globalMarket.data;
                });
              } else if (state is GlobalMarketError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ColorResource.danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is GlobalMarketLoading && _marketData == null) {
                return const LoadingStateWidget(
                  message: 'Fetching live global market statistics...',
                );
              }

              if (state is GlobalMarketError && _marketData == null) {
                return ErrorStateWidget(
                  errorMessage: state.message,
                  onRetry: () {
                    context.read<CoinBloc>().add(FetchGlobalMarketData());
                  },
                );
              }

              final data = _marketData;
              if (data == null) {
                return ErrorStateWidget(
                  errorMessage: 'No market statistics data available.',
                  onRetry: () {
                    context.read<CoinBloc>().add(FetchGlobalMarketData());
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CoinBloc>().add(FetchGlobalMarketData());
                },
                color: ColorResource.appThemeColor1,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Top Header
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          Responsive.padding(context, 20),
                          Responsive.padding(context, 55),
                          Responsive.padding(context, 20),
                          Responsive.padding(context, 24),
                        ),
                        decoration: const BoxDecoration(
                          gradient: ColorResource.headerGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x332563EB),
                              blurRadius: 24,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(Responsive.padding(context, 10)),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                      ),
                                      child: Icon(
                                        Icons.query_stats_rounded,
                                        color: Colors.white,
                                        size: Responsive.padding(context, 24),
                                      ),
                                    ),
                                    SizedBox(width: Responsive.padding(context, 12)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Market Statistics',
                                          style: AppStyles.bold.copyWith(
                                            fontSize: Responsive.fontSize(context, 20),
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                    size: Responsive.padding(context, 22),
                                  ),
                                  onPressed: () {
                                    context.read<CoinBloc>().add(FetchGlobalMarketData());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        Responsive.padding(context, 16),
                        Responsive.padding(context, 20),
                        Responsive.padding(context, 16),
                        Responsive.padding(context, 90),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Section 1: Global Crypto Overview
                          Text(
                            'Global Crypto Overview',
                            style: AppStyles.bold.copyWith(
                              fontSize: Responsive.fontSize(context, 18),
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 12)),

                          // Cards Row 1
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Total Market Cap',
                                  value: _formatCurrency(data.totalMarketCap['usd']),
                                  changePercentage: data.marketCapChangePercentage24hUsd,
                                  icon: Icons.account_balance_wallet_rounded,
                                  surfaceColor: surfaceColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              ),
                              SizedBox(width: Responsive.padding(context, 12)),
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: '24h Volume',
                                  value: _formatCurrency(data.totalVolume['usd']),
                                  changePercentage: data.volumeChangePercentage24hUsd,
                                  icon: Icons.bar_chart_rounded,
                                  surfaceColor: surfaceColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.padding(context, 12)),

                          // Cards Row 2
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Active Cryptos',
                                  value: _formatFormattedInt(data.activeCryptocurrencies),
                                  badgeText: 'Active',
                                  icon: Icons.token_rounded,
                                  surfaceColor: surfaceColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              ),
                              SizedBox(width: Responsive.padding(context, 12)),
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Active Markets',
                                  value: _formatFormattedInt(data.markets),
                                  badgeText: 'Global',
                                  icon: Icons.storefront_rounded,
                                  surfaceColor: surfaceColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: Responsive.padding(context, 24)),

                          // Section 2: Market Dominance
                          Text(
                            'Market Dominance Share',
                            style: AppStyles.bold.copyWith(
                              fontSize: Responsive.fontSize(context, 18),
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 12)),

                          _buildDominanceCard(
                            context: context,
                            dominanceMap: data.marketCapPercentage,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),

                          SizedBox(height: Responsive.padding(context, 24)),

                          // Section 3: ICO Status
                          Text(
                            'ICO Activity Status',
                            style: AppStyles.bold.copyWith(
                              fontSize: Responsive.fontSize(context, 18),
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 12)),

                          _buildIcoCard(
                            context: context,
                            ongoing: data.ongoingIcos ?? 0,
                            upcoming: data.upcomingIcos ?? 0,
                            ended: data.endedIcos ?? 0,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    double? changePercentage,
    String? badgeText,
    required IconData icon,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final bool isPositive = (changePercentage ?? 0.0) >= 0;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 8)),
                decoration: BoxDecoration(
                  color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ColorResource.appThemeColor1,
                  size: Responsive.padding(context, 20),
                ),
              ),
              if (changePercentage != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 8),
                    vertical: Responsive.padding(context, 3),
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? ColorResource.success.withValues(alpha: 0.12)
                        : ColorResource.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                        size: Responsive.padding(context, 16),
                        color: isPositive ? ColorResource.success : ColorResource.danger,
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                        style: AppStyles.medium.copyWith(
                          fontSize: Responsive.fontSize(context, 11),
                          color: isPositive ? ColorResource.success : ColorResource.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (badgeText != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 8),
                    vertical: Responsive.padding(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    badgeText,
                    style: AppStyles.medium.copyWith(
                      fontSize: Responsive.fontSize(context, 11),
                      color: ColorResource.appThemeColor1,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: Responsive.padding(context, 14)),
          Text(
            title,
            style: AppStyles.regular.copyWith(
              fontSize: Responsive.fontSize(context, 12),
              color: subTextColor,
            ),
          ),
          SizedBox(height: Responsive.padding(context, 4)),
          Text(
            value,
            style: AppStyles.bold.copyWith(
              fontSize: Responsive.fontSize(context, 17),
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDominanceCard({
    required BuildContext context,
    required Map<String, double> dominanceMap,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    if (dominanceMap.isEmpty) {
      return Container(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'Dominance data unavailable',
            style: AppStyles.regular.copyWith(color: subTextColor),
          ),
        ),
      );
    }

    final entries = dominanceMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    // Show top 5 coins + "Others"
    final topEntries = entries.take(5).toList();
    double topSum = topEntries.fold(0.0, (sum, item) => sum + item.value);
    final othersPercentage = (100.0 - topSum).clamp(0.0, 100.0);

    return Container(
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
          ...topEntries.map((entry) {
            final color = _getCoinColor(entry.key);
            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.padding(context, 14)),
              child: _buildDominanceProgressRow(
                context: context,
                symbol: entry.key.toUpperCase(),
                percentage: entry.value,
                color: color,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            );
          }),
          if (othersPercentage > 0)
            _buildDominanceProgressRow(
              context: context,
              symbol: 'OTHERS',
              percentage: othersPercentage,
              color: ColorResource.appThemeColor2,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
        ],
      ),
    );
  }

  Widget _buildDominanceProgressRow({
    required BuildContext context,
    required String symbol,
    required double percentage,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    final clampedProgress = (percentage / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: Responsive.padding(context, 8)),
                Text(
                  symbol,
                  style: AppStyles.medium.copyWith(
                    fontSize: Responsive.fontSize(context, 13),
                    color: textColor,
                  ),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: AppStyles.bold.copyWith(
                fontSize: Responsive.fontSize(context, 13),
                color: textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.padding(context, 8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: clampedProgress,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildIcoCard({
    required BuildContext context,
    required int ongoing,
    required int upcoming,
    required int ended,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIcoStatItem(
            context: context,
            title: 'Ongoing',
            value: '$ongoing',
            icon: Icons.play_circle_fill_rounded,
            color: ColorResource.success,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          Container(
            height: Responsive.padding(context, 40),
            width: 1,
            color: borderColor,
          ),
          _buildIcoStatItem(
            context: context,
            title: 'Upcoming',
            value: '$upcoming',
            icon: Icons.upcoming_rounded,
            color: ColorResource.appThemeColor1,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          Container(
            height: Responsive.padding(context, 40),
            width: 1,
            color: borderColor,
          ),
          _buildIcoStatItem(
            context: context,
            title: 'Ended',
            value: '$ended',
            icon: Icons.check_circle_rounded,
            color: ColorResource.unselectedLabelColor,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildIcoStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: Responsive.padding(context, 22)),
        SizedBox(height: Responsive.padding(context, 6)),
        Text(
          value,
          style: AppStyles.bold.copyWith(
            fontSize: Responsive.fontSize(context, 16),
            color: textColor,
          ),
        ),
        SizedBox(height: Responsive.padding(context, 2)),
        Text(
          title,
          style: AppStyles.regular.copyWith(
            fontSize: Responsive.fontSize(context, 12),
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  Color _getCoinColor(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return const Color(0xFFF7931A);
      case 'eth':
        return const Color(0xFF627EEA);
      case 'usdt':
        return const Color(0xFF26A17B);
      case 'bnb':
        return const Color(0xFFF3BA2F);
      case 'sol':
        return const Color(0xFF14F195);
      case 'xrp':
        return const Color(0xFF00AAE4);
      case 'usdc':
        return const Color(0xFF2775CA);
      case 'ada':
        return const Color(0xFF0033AD);
      case 'doge':
        return const Color(0xFFC2A633);
      case 'trx':
        return const Color(0xFFEF0027);
      default:
        return ColorResource.appThemeColor1;
    }
  }

  String _formatCurrency(double? value) {
    if (value == null || value == 0) return '\$0.00';
    if (value >= 1e12) {
      return '\$${(value / 1e12).toStringAsFixed(2)}T';
    } else if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${value.toStringAsFixed(2)}';
    }
  }

  String _formatFormattedInt(int? value) {
    if (value == null) return '0';
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year $hour:$minute';
  }
}
