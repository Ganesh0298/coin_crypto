import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/coins_bloc.dart';
import '../../bloc/coins_event.dart';
import '../../bloc/coins_state.dart';
import '../../data/response/coin_market_list_response.dart';
import '../../widgets/search_form_widget.dart';
import '../../widgets/custom_empty_widget.dart';
import '../../widgets/custom_error_widget.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import 'coin_detail_screen.dart';

class CoinListScreen extends StatefulWidget {
  const CoinListScreen({super.key});

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CoinMarketListResponse> _displayedCoins = [];

  @override
  void initState() {
    super.initState();
    context.read<CoinBloc>().add(FetchCoinsList());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CoinBloc>().add(FetchMoreCoins());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResource.appMainBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Futuristic Header Banner
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: ColorResource.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x332563EB),
                    blurRadius: 20,
                    offset: Offset(0, 10),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CoinPilot Terminal',
                                style: AppStyles.bold.copyWith(
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Live Crypto Intelligence & Analytics',
                                style: AppStyles.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CoinBloc>().add(RefreshCoinsList());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Search Form Widget
                  SearchFormWidget(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<CoinBloc>().add(SearchCoins(query: query));
                    },
                    onClear: () {
                      _searchController.clear();
                      context.read<CoinBloc>().add(SearchCoins(query: ''));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Market Statistics Quick Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricPill('Market Status', 'Bullish 🟢', Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricPill('Global Gas', '12 Gwei ⚡', ColorResource.appThemeColor1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Bloc Consumer / Builder for Coin List
            Expanded(
              child: BlocConsumer<CoinBloc, CoinState>(
                listener: (context, state) {
                  if (state is CoinListSuccess) {
                    setState(() {
                      _displayedCoins = state.coins;
                    });
                  } else if (state is MoreCoinsSuccess) {
                    setState(() {
                      _displayedCoins = state.coins;
                    });
                  } else if (state is CoinSearchSuccess) {
                    setState(() {
                      _displayedCoins = state.coins;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is CoinLoading && state.loadingFor == 'FetchCoinsList' && _displayedCoins.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                      ),
                    );
                  }

                  if (state is CoinError && state.errorFor == 'FetchCoinsList' && _displayedCoins.isEmpty) {
                    return const CustomErrorWidget();
                  }

                  if (_displayedCoins.isEmpty) {
                    return const CustomEmptyWidget();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CoinBloc>().add(RefreshCoinsList());
                    },
                    color: ColorResource.appThemeColor1,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _displayedCoins.length + (state is MoreCoinsSuccess && state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _displayedCoins.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        final coin = _displayedCoins[index];
                        return _buildFuturisticCoinCard(context, coin);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: ColorResource.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.regular.copyWith(fontSize: 12, color: ColorResource.textSecondary)),
          Text(value, style: AppStyles.semiBold.copyWith(fontSize: 12, color: accentColor)),
        ],
      ),
    );
  }

  Widget _buildFuturisticCoinCard(BuildContext context, CoinMarketListResponse coin) {
    final priceChange = coin.priceChangePercentage24h ?? 0.0;
    final isPositive = priceChange >= 0;
    final price = coin.currentPrice ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: ColorResource.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            // Navigate to Coin Detail Screen
            // Note: CoinDetailScreen accepts CoinModel or we can pass coin data
            // Let's check CoinDetailScreen constructor if needed or pass converted model.
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '#${coin.marketCapRank ?? '-'}',
                    style: AppStyles.medium.copyWith(fontSize: 12, color: ColorResource.textSecondary),
                  ),
                ),
                // Coin Logo with glow
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorResource.appThemeColor1.withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Image.network(
                      coin.image,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 20,
                        backgroundColor: ColorResource.appThemeColor1,
                        child: Icon(Icons.currency_bitcoin, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name & Symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: AppStyles.semiBold.copyWith(fontSize: 15, color: ColorResource.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorResource.appThemeColor1.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          coin.symbol.toUpperCase(),
                          style: AppStyles.medium.copyWith(fontSize: 10, color: ColorResource.appThemeColor1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Price & 24h Change Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(price),
                      style: AppStyles.semiBold.copyWith(fontSize: 15, color: ColorResource.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositive ? ColorResource.success.withOpacity(0.12) : ColorResource.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 14,
                            color: isPositive ? ColorResource.success : ColorResource.danger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                            style: AppStyles.medium.copyWith(
                              fontSize: 11,
                              color: isPositive ? ColorResource.success : ColorResource.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1.0) {
      return '\$${price.toStringAsFixed(price > 1000 ? 2 : 2)}';
    } else {
      return '\$${price.toStringAsFixed(4)}';
    }
  }
}
