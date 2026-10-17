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
import '../../utils/app_responsive.dart';
import '../../utils/custom_navigation.dart';
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
  String _selectedSortBy = 'market_cap';
  bool _isAscending = false;
  double? _filterMinPrice;
  double? _filterMaxPrice;
  double? _filterMinVolume;
  int? _filterRankLimit;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CoinBloc>();
    if (bloc.state is CoinListSuccess) {
      final state = bloc.state as CoinListSuccess;
      _displayedCoins = state.coins;
      _currentTab = state.activeTab;
    } else {
      bloc.add(FetchCoinsList());
    }
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
              Container(
                padding: EdgeInsets.fromLTRB(
                  Responsive.padding(context, 20),
                  Responsive.padding(context, 55),
                  Responsive.padding(context, 20),
                  Responsive.padding(context, 20),
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
                              child: Icon(Icons.currency_bitcoin, color: Colors.white, size: Responsive.padding(context, 24)),
                            ),
                            SizedBox(width: Responsive.padding(context, 12)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coin Crypto',
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
                          icon: Icon(Icons.notifications, color: Colors.white, size: Responsive.padding(context, 22)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.padding(context, 16)),
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
              SizedBox(height: Responsive.padding(context, 14)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 16.0)),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Trending',].map((tab) {
                            final isSelected = _currentTab == tab;
                            return Padding(
                              padding: EdgeInsets.only(right: Responsive.padding(context, 8.0)),
                              child: ChoiceChip(
                                label: Text(tab),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (_currentTab != tab) {
                                    setState(() {
                                      _currentTab = tab;
                                      _displayedCoins = [];
                                    });
                                    context.read<CoinBloc>().add(FilterCoinsTab(tab));
                                  }
                                },
                                selectedColor: ColorResource.appThemeColor1,
                                backgroundColor: surfaceColor,
                                labelStyle: AppStyles.medium.copyWith(
                                  fontSize: Responsive.fontSize(context, 13),
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
                    SizedBox(width: Responsive.padding(context, 8)),

                    InkWell(
                      onTap: () => _showSortBottomSheet(context, surfaceColor, borderColor, textColor, subTextColor),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 8)),
                        decoration: BoxDecoration(
                          color: _selectedSortBy != 'market_cap' || _isAscending
                              ? ColorResource.appThemeColor1.withValues(alpha: 0.15)
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: _selectedSortBy != 'market_cap' || _isAscending
                                ? ColorResource.appThemeColor1
                                : borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          size: Responsive.padding(context, 20),
                          color: _selectedSortBy != 'market_cap' || _isAscending
                              ? ColorResource.appThemeColor1
                              : textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.padding(context, 6)),


                    InkWell(
                      onTap: () => _showFilterBottomSheet(context, surfaceColor, borderColor, textColor, subTextColor),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 8)),
                        decoration: BoxDecoration(
                          color: _hasActiveFilters()
                              ? ColorResource.appThemeColor1.withValues(alpha: 0.15)
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: _hasActiveFilters()
                                ? ColorResource.appThemeColor1
                                : borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: Responsive.padding(context, 20),
                          color: _hasActiveFilters()
                              ? ColorResource.appThemeColor1
                              : textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.padding(context, 10)),

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
                    if ((state is CoinLoading && _displayedCoins.isEmpty) ||
                        (state is CoinLoading && state.loadingFor != 'RefreshCoinsList' && _displayedCoins.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
                            ),
                            SizedBox(height: Responsive.padding(context, 16)),
                            Text(
                              'Fetching crypto coins...',
                              style: AppStyles.medium.copyWith(
                                color: subTextColor,
                                fontSize: Responsive.fontSize(context, 13),
                              ),
                            ),
                          ],
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
                        padding: EdgeInsets.fromLTRB(
                          Responsive.padding(context, 16),
                          Responsive.padding(context, 4),
                          Responsive.padding(context, 16),
                          Responsive.padding(context, 90),
                        ),
                        itemCount: _displayedCoins.length + (state is MoreCoinsSuccess && state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _displayedCoins.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: Responsive.padding(context, 20)),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final coin = _displayedCoins[index];
                          return TweenAnimationBuilder<double>(
                            key: ValueKey('${coin.id}_$index'),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 250 + (index % 8) * 40),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 16),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildFuturisticCoinCard(context, coin, surfaceColor, borderColor, textColor, subTextColor),
                          );
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

  bool _hasActiveFilters() {
    return _filterMinPrice != null ||
        _filterMaxPrice != null ||
        _filterMinVolume != null ||
        _filterRankLimit != null;
  }

  void _showSortBottomSheet(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDefaultSort = _selectedSortBy == 'market_cap' && !_isAscending;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.padding(context, 20),
                Responsive.padding(context, 12),
                Responsive.padding(context, 20),
                Responsive.padding(context, 30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Grab Handle Bar
                  Center(
                    child: Container(
                      width: Responsive.padding(context, 40),
                      height: 4,
                      margin: EdgeInsets.only(bottom: Responsive.padding(context, 16)),
                      decoration: BoxDecoration(
                        color: subTextColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(Responsive.padding(context, 8)),
                            decoration: BoxDecoration(
                              color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.swap_vert_rounded, color: ColorResource.appThemeColor1, size: Responsive.padding(context, 20)),
                          ),
                          SizedBox(width: Responsive.padding(context, 10)),
                          Text(
                            'Sort Coins',
                            style: AppStyles.bold.copyWith(
                              fontSize: Responsive.fontSize(context, 18),
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!isDefaultSort)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 10), vertical: Responsive.padding(context, 4)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedSortBy = 'market_cap';
                                  _isAscending = false;
                                });
                                context.read<CoinBloc>().add(SortCoins(sortBy: 'market_cap', isAscending: false));
                                CustomNavigation.pop(ctx);
                              },
                              icon: Icon(Icons.refresh_rounded, size: Responsive.padding(context, 15), color: ColorResource.danger),
                              label: Text(
                                'Reset Sort',
                                style: AppStyles.medium.copyWith(
                                  fontSize: Responsive.fontSize(context, 13),
                                  color: ColorResource.danger,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: subTextColor, size: Responsive.padding(context, 22)),
                            onPressed: () => CustomNavigation.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    'HIGH TO LOW (DESCENDING)',
                    style: AppStyles.bold.copyWith(
                      fontSize: Responsive.fontSize(context, 11),
                      color: subTextColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('Market Cap', 'market_cap', false, Icons.pie_chart_rounded, setModalState, ctx, textColor, borderColor, surfaceColor),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('Price', 'price', false, Icons.attach_money_rounded, setModalState, ctx, textColor, borderColor, surfaceColor),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('24h Change (Highest Gainers)', 'change_24h', false, Icons.trending_up_rounded, setModalState, ctx, textColor, borderColor, surfaceColor),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('24h Trading Volume', 'volume', false, Icons.bar_chart_rounded, setModalState, ctx, textColor, borderColor, surfaceColor),

                  SizedBox(height: Responsive.padding(context, 16)),
                  Text(
                    'LOW TO HIGH (ASCENDING)',
                    style: AppStyles.bold.copyWith(
                      fontSize: Responsive.fontSize(context, 11),
                      color: subTextColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('Price (Lowest First)', 'price', true, Icons.price_change_outlined, setModalState, ctx, textColor, borderColor, surfaceColor),
                  SizedBox(height: Responsive.padding(context, 8)),
                  _buildSortCard('24h Change (Top Losers)', 'change_24h', true, Icons.trending_down_rounded, setModalState, ctx, textColor, borderColor, surfaceColor),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortCard(
    String title,
    String sortBy,
    bool isAscending,
    IconData icon,
    StateSetter setModalState,
    BuildContext modalContext,
    Color textColor,
    Color borderColor,
    Color surfaceColor,
  ) {
    final isSelected = _selectedSortBy == sortBy && _isAscending == isAscending;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSortBy = sortBy;
          _isAscending = isAscending;
        });
        context.read<CoinBloc>().add(SortCoins(sortBy: sortBy, isAscending: isAscending));
        CustomNavigation.pop(modalContext);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 14),
          vertical: Responsive.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorResource.appThemeColor1.withValues(alpha: 0.08) : surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? ColorResource.appThemeColor1 : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: Responsive.padding(context, 20),
              color: isSelected ? ColorResource.appThemeColor1 : ColorResource.neutral,
            ),
            SizedBox(width: Responsive.padding(context, 12)),
            Expanded(
              child: Text(
                title,
                style: AppStyles.medium.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  color: isSelected ? ColorResource.appThemeColor1 : textColor,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 4)),
                decoration: BoxDecoration(
                  color: ColorResource.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: ColorResource.success,
                  size: Responsive.padding(context, 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final minPriceController = TextEditingController(
      text: _filterMinPrice != null ? _filterMinPrice.toString() : '',
    );
    final maxPriceController = TextEditingController(
      text: _filterMaxPrice != null ? _filterMaxPrice.toString() : '',
    );

    double? tempMinVol = _filterMinVolume;
    int? tempRankLimit = _filterRankLimit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.padding(context, 20),
                Responsive.padding(context, 12),
                Responsive.padding(context, 20),
                MediaQuery.of(ctx).viewInsets.bottom + Responsive.padding(context, 30),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Container(
                        width: Responsive.padding(context, 40),
                        height: 4,
                        margin: EdgeInsets.only(bottom: Responsive.padding(context, 16)),
                        decoration: BoxDecoration(
                          color: subTextColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(Responsive.padding(context, 8)),
                              decoration: BoxDecoration(
                                color: ColorResource.appThemeColor1.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.tune_rounded, color: ColorResource.appThemeColor1, size: Responsive.padding(context, 20)),
                            ),
                            SizedBox(width: Responsive.padding(context, 10)),
                            Text(
                              'Filter Coins',
                              style: AppStyles.bold.copyWith(
                                fontSize: Responsive.fontSize(context, 18),
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: subTextColor, size: Responsive.padding(context, 22)),
                          onPressed: () => CustomNavigation.pop(ctx),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.padding(context, 18)),

                    Text(
                      'Price Range (\$ USD)',
                      style: AppStyles.semiBold.copyWith(
                        fontSize: Responsive.fontSize(context, 14),
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.padding(context, 10)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              prefixStyle: AppStyles.medium.copyWith(color: subTextColor),
                              hintText: 'Min Price',
                              hintStyle: AppStyles.regular.copyWith(
                                fontSize: Responsive.fontSize(context, 12),
                                color: subTextColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.padding(context, 12),
                                vertical: Responsive.padding(context, 12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF27272A)
                                  : ColorResource.appMainBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: const BorderSide(color: ColorResource.appThemeColor1, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.padding(context, 12)),
                        Text('-', style: AppStyles.bold.copyWith(color: subTextColor)),
                        SizedBox(width: Responsive.padding(context, 12)),
                        Expanded(
                          child: TextField(
                            controller: maxPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              prefixStyle: AppStyles.medium.copyWith(color: subTextColor),
                              hintText: 'Max Price',
                              hintStyle: AppStyles.regular.copyWith(
                                fontSize: Responsive.fontSize(context, 12),
                                color: subTextColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.padding(context, 12),
                                vertical: Responsive.padding(context, 12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF27272A)
                                  : ColorResource.appMainBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: const BorderSide(color: ColorResource.appThemeColor1, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.padding(context, 20)),


                    Text(
                      'Market Cap Rank',
                      style: AppStyles.semiBold.copyWith(
                        fontSize: Responsive.fontSize(context, 14),
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.padding(context, 10)),
                    Wrap(
                      spacing: Responsive.padding(context, 8),
                      runSpacing: Responsive.padding(context, 8),
                      children: [
                        _buildFilterChoiceChip('All Ranks', null, tempRankLimit, (val) => setModalState(() => tempRankLimit = val), textColor, borderColor),
                        _buildFilterChoiceChip('Top 10', 10, tempRankLimit, (val) => setModalState(() => tempRankLimit = val), textColor, borderColor),
                        _buildFilterChoiceChip('Top 50', 50, tempRankLimit, (val) => setModalState(() => tempRankLimit = val), textColor, borderColor),
                        _buildFilterChoiceChip('Top 100', 100, tempRankLimit, (val) => setModalState(() => tempRankLimit = val), textColor, borderColor),
                      ],
                    ),
                    SizedBox(height: Responsive.padding(context, 20)),


                    Text(
                      'Minimum 24h Volume',
                      style: AppStyles.semiBold.copyWith(
                        fontSize: Responsive.fontSize(context, 14),
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.padding(context, 10)),
                    Wrap(
                      spacing: Responsive.padding(context, 8),
                      runSpacing: Responsive.padding(context, 8),
                      children: [
                        _buildFilterChoiceChip('Any Volume', null, tempMinVol, (val) => setModalState(() => tempMinVol = val), textColor, borderColor),
                        _buildFilterChoiceChip('> \$1M', 1000000.0, tempMinVol, (val) => setModalState(() => tempMinVol = val), textColor, borderColor),
                        _buildFilterChoiceChip('> \$10M', 10000000.0, tempMinVol, (val) => setModalState(() => tempMinVol = val), textColor, borderColor),
                        _buildFilterChoiceChip('> \$100M', 100000000.0, tempMinVol, (val) => setModalState(() => tempMinVol = val), textColor, borderColor),
                      ],
                    ),
                    SizedBox(height: Responsive.padding(context, 28)),


                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              padding: EdgeInsets.symmetric(vertical: Responsive.padding(context, 14)),
                            ),
                            onPressed: () {
                              setState(() {
                                _filterMinPrice = null;
                                _filterMaxPrice = null;
                                _filterMinVolume = null;
                                _filterRankLimit = null;
                              });
                              context.read<CoinBloc>().add(ResetCoinFilters());
                              CustomNavigation.pop(ctx);
                            },
                            child: Text(
                              'Reset Filters',
                              style: AppStyles.medium.copyWith(
                                fontSize: Responsive.fontSize(context, 14),
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.padding(context, 12)),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorResource.appThemeColor1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              padding: EdgeInsets.symmetric(vertical: Responsive.padding(context, 14)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              final minP = double.tryParse(minPriceController.text.trim());
                              final maxP = double.tryParse(maxPriceController.text.trim());

                              setState(() {
                                _filterMinPrice = minP;
                                _filterMaxPrice = maxP;
                                _filterMinVolume = tempMinVol;
                                _filterRankLimit = tempRankLimit;
                              });

                              context.read<CoinBloc>().add(
                                    ApplyAdvancedFilters(
                                      minPrice: minP,
                                      maxPrice: maxP,
                                      minVolume: tempMinVol,
                                      rankLimit: tempRankLimit,
                                    ),
                                  );

                              CustomNavigation.pop(ctx);
                            },
                            child: Text(
                              'Apply Filters',
                              style: AppStyles.bold.copyWith(
                                fontSize: Responsive.fontSize(context, 14),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChoiceChip<T>(
    String label,
    T? value,
    T? groupValue,
    ValueChanged<T?> onSelected,
    Color textColor,
    Color borderColor,
  ) {
    final isSelected = value == groupValue;

    return ChoiceChip(
      avatar: isSelected
          ? Icon(Icons.check_circle_rounded, size: Responsive.padding(context, 16), color: Colors.white)
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? value : null);
      },
      selectedColor: ColorResource.appThemeColor1,
      backgroundColor: Colors.transparent,
      labelStyle: AppStyles.medium.copyWith(
        fontSize: Responsive.fontSize(context, 12),
        color: isSelected ? Colors.white : textColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: isSelected ? ColorResource.appThemeColor1 : borderColor,
          width: isSelected ? 1.5 : 1.0,
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
    final volume = coin.totalVolume;
    final supply = coin.circulatingSupply;

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.padding(context, 12)),
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
            CustomNavigation.push(
              context,
              CoinDetailScreen(
                coinId: coin.id,
                coinName: coin.name,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 14.0)),
            child: Column(
              children: [
                Row(
                  children: [
                    // Rank
                    Container(
                      width: Responsive.padding(context, 28),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${coin.marketCapRank ?? '-'}',
                        style: AppStyles.medium.copyWith(
                          fontSize: Responsive.fontSize(context, 12),
                          color: subTextColor,
                        ),
                      ),
                    ),
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Image.network(
                        coin.image,
                        width: Responsive.padding(context, 36),
                        height: Responsive.padding(context, 36),
                        errorBuilder: (context, error, stackTrace) => CircleAvatar(
                          radius: Responsive.padding(context, 18),
                          backgroundColor: ColorResource.appThemeColor1,
                          child: Icon(Icons.currency_bitcoin, color: Colors.white, size: Responsive.padding(context, 18)),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.padding(context, 12)),
                    // Name & Market Cap
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coin.name,
                            style: AppStyles.semiBold.copyWith(
                              fontSize: Responsive.fontSize(context, 15),
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Responsive.padding(context, 2)),
                          Text(
                            marketCap > 0 ? 'MCap: \$${_formatNumber(marketCap)}' : coin.symbol.toUpperCase(),
                            style: AppStyles.regular.copyWith(
                              fontSize: Responsive.fontSize(context, 12),
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.padding(context, 12)),
                    // Price & 24h Change
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatPrice(price),
                          style: AppStyles.semiBold.copyWith(
                            fontSize: Responsive.fontSize(context, 15),
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: Responsive.padding(context, 4)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context, 8),
                            vertical: Responsive.padding(context, 3),
                          ),
                          decoration: BoxDecoration(
                            color: isPositive ? ColorResource.success.withValues(alpha: 0.12) : ColorResource.danger.withValues(alpha: 0.12),
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
                                '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                style: AppStyles.medium.copyWith(
                                  fontSize: Responsive.fontSize(context, 11),
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
                // Volume & Supply Row
                if (volume != null || supply != null) ...[
                  SizedBox(height: Responsive.padding(context, 10)),
                  Divider(height: 1, color: borderColor.withValues(alpha: 0.6)),
                  SizedBox(height: Responsive.padding(context, 8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (volume != null)
                        Row(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: Responsive.padding(context, 14), color: subTextColor),
                            SizedBox(width: Responsive.padding(context, 4)),
                            Text(
                              '24h Vol: ',
                              style: AppStyles.regular.copyWith(
                                fontSize: Responsive.fontSize(context, 11),
                                color: subTextColor,
                              ),
                            ),
                            Text(
                              '\$${_formatNumber(volume)}',
                              style: AppStyles.medium.copyWith(
                                fontSize: Responsive.fontSize(context, 11),
                                color: textColor,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      if (supply != null)
                        Row(
                          children: [
                            Icon(Icons.pie_chart_outline_rounded, size: Responsive.padding(context, 14), color: subTextColor),
                            SizedBox(width: Responsive.padding(context, 4)),
                            Text(
                              'Supply: ',
                              style: AppStyles.regular.copyWith(
                                fontSize: Responsive.fontSize(context, 11),
                                color: subTextColor,
                              ),
                            ),
                            Text(
                              '${_formatNumber(supply)} ${coin.symbol.toUpperCase()}',
                              style: AppStyles.medium.copyWith(
                                fontSize: Responsive.fontSize(context, 11),
                                color: textColor,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1.0) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(4)}';
    }
  }

  String _formatNumber(double number) {
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
}
