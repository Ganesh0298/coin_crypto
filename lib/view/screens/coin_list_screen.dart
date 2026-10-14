import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/crypto_bloc.dart';
import '../../widgets/search_form_widget.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/coin_card_widget.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResource.appMainBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: ColorResource.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'CoinPilot Research',
                            style: AppStyles.semiBold.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        onPressed: () {
                          context.read<CryptoCubit>().loadMarkets();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Separate Search Form Widget
                  SearchFormWidget(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<CryptoCubit>().searchCoins(query);
                    },
                    onClear: () {
                      context.read<CryptoCubit>().searchCoins('');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Category Filter Chips & Sort Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: BlocBuilder<CryptoCubit, CryptoState>(
                      builder: (context, state) {
                        final categories = ['All', 'Gainers', 'Losers', 'Watchlist'];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((cat) {
                              final isSelected = state.selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<CryptoCubit>().filterByCategory(cat);
                                  },
                                  selectedColor: ColorResource.appThemeColor1,
                                  backgroundColor: ColorResource.surface,
                                  labelStyle: AppStyles.medium.copyWith(
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : ColorResource.textPrimary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : ColorResource.border,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort Popup Menu
                  BlocBuilder<CryptoCubit, CryptoState>(
                    builder: (context, state) {
                      return PopupMenuButton<String>(
                        onSelected: (sort) {
                          context.read<CryptoCubit>().sortCoins(sort);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'Rank', child: Text('Sort by Rank', style: AppStyles.regular)),
                          PopupMenuItem(value: 'Price', child: Text('Sort by Price', style: AppStyles.regular)),
                          PopupMenuItem(value: '24h Change', child: Text('Sort by 24h Change', style: AppStyles.regular)),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: ColorResource.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: ColorResource.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded, size: 16, color: ColorResource.appThemeColor1),
                              const SizedBox(width: 4),
                              Text(state.sortBy, style: AppStyles.medium.copyWith(fontSize: 12, color: ColorResource.textPrimary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Coin List / States
            Expanded(
              child: BlocBuilder<CryptoCubit, CryptoState>(
                builder: (context, state) {
                  if (state.isLoading && state.allCoins.isEmpty) {
                    return const LoadingStateWidget();
                  }

                  if (state.hasError && state.allCoins.isEmpty) {
                    return ErrorStateWidget(
                      errorMessage: state.errorMessage,
                      onRetry: () => context.read<CryptoCubit>().loadMarkets(),
                    );
                  }

                  if (state.displayedCoins.isEmpty) {
                    return EmptyStateWidget(
                      title: 'No Cryptocurrencies Found',
                      subtitle: state.selectedCategory == 'Watchlist'
                          ? 'Your watchlist is empty. Tap the heart icon on any coin to add it here.'
                          : 'No coins match your search query or filter criteria.',
                      icon: state.selectedCategory == 'Watchlist' ? Icons.favorite_border_rounded : Icons.search_off_rounded,
                      actionLabel: 'Reset Filters',
                      onActionPressed: () {
                        _searchController.clear();
                        context.read<CryptoCubit>().searchCoins('');
                        context.read<CryptoCubit>().filterByCategory('All');
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: state.displayedCoins.length,
                    itemBuilder: (context, index) {
                      final coin = state.displayedCoins[index];
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
