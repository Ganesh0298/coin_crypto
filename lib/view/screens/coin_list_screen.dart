import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _currentTab = 'All';

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
          child: Column(
            children: [
              // Top AppBar & Market Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.35)),
                              ),
                              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CoinCrypto',
                                  style: AppStyles.bold.copyWith(
                                    fontSize: 20,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                // const SizedBox(height: 2),
                                // Text(
                                //   'Global Crypto Terminal',
                                //   style: AppStyles.regular.copyWith(
                                //     fontSize: 12,
                                //     color: Colors.white70,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {

                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
              const SizedBox(height: 14),
              // Filter Tabs (All, Trending, Top Gainers, Top Losers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Trending', 'Top Gainers', 'Top Losers'].map((tab) {
                      final isSelected = _currentTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tab),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _currentTab = tab;
                            });
                            context.read<CoinBloc>().add(FilterCoinsTab(tab));
                          },
                          selectedColor: ColorResource.appThemeColor1,
                          backgroundColor: surfaceColor,
                          labelStyle: AppStyles.medium.copyWith(
                            fontSize: 13,
                            color: isSelected ? Colors.white : textColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : borderColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Coin List / States
              Expanded(
                child: BlocConsumer<CoinBloc, CoinState>(
                  listener: (context, state) {
                    if (state is CoinListSuccess) {
                      setState(() {
                        _displayedCoins = state.coins;
                        _currentTab = state.activeTab;
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
                    if (state is CoinLoading && _displayedCoins.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                        ),
                      );
                    }

                    if (state is CoinError && _displayedCoins.isEmpty) {
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
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
                          return _buildFuturisticCoinCard(context, coin, surfaceColor, borderColor, textColor, subTextColor);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticCoinCard(
    BuildContext context,
    CoinMarketListResponse coin,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final priceChange = coin.priceChangePercentage24h ?? 0.0;
    final isPositive = priceChange >= 0;
    final price = coin.currentPrice ?? 0.0;
    final marketCap = coin.marketCap ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoinDetailScreen(
                  coinId: coin.id,
                  coinName: coin.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${coin.marketCapRank ?? '-'}',
                    style: AppStyles.medium.copyWith(fontSize: 12, color: subTextColor),
                  ),
                ),
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Image.network(
                    coin.image,
                    width: 38,
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                      radius: 19,
                      backgroundColor: ColorResource.appThemeColor1,
                      child: Icon(Icons.currency_bitcoin, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Market Cap
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: AppStyles.semiBold.copyWith(fontSize: 15, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        marketCap > 0 ? 'MCap: ${_formatLargeNumber(marketCap)}' : coin.symbol.toUpperCase(),
                        style: AppStyles.regular.copyWith(fontSize: 12, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Price & 24h Change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(price),
                      style: AppStyles.semiBold.copyWith(fontSize: 15, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPositive ? ColorResource.success.withOpacity(0.12) : ColorResource.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                            size: 16,
                            color: isPositive ? ColorResource.success : ColorResource.danger,
                          ),
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

  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '\$${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '\$${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '\$${(number / 1e6).toStringAsFixed(2)}M';
    } else {
      return '\$${number.toStringAsFixed(0)}';
    }
  }
}
