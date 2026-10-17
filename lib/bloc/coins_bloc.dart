import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/response/coin_market_list_response.dart';
import '../repo/coins_repo.dart';
import 'coins_event.dart';
import 'coins_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinRepository coinRepository;

  int _currentPage = 1;
  final int _perPage = 15;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<CoinMarketListResponse> _allCoins = [];
  List<CoinMarketListResponse> _trendingCoins = [];
  List<CoinMarketListResponse> _topGainers = [];
  List<CoinMarketListResponse> _topLosers = [];

  String _activeTab = 'All';
  String _searchQuery = '';


  String _sortBy = 'market_cap';
  bool _sortAscending = false;
  double? _minPrice;
  double? _maxPrice;
  double? _minVolume;
  int? _rankLimit;

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  List<CoinMarketListResponse> _getActiveList() {
    if (_activeTab == 'Trending') {
      return _trendingCoins;
    } else if (_activeTab == 'Top Gainers') {
      return _topGainers;
    } else if (_activeTab == 'Top Losers') {
      return _topLosers;
    }
    return _allCoins;
  }

  List<CoinMarketListResponse> _applyFiltersAndSorting(List<CoinMarketListResponse> source) {
    var list = List<CoinMarketListResponse>.from(source);


    if (_searchQuery.isNotEmpty) {
      list = list.where((coin) {
        return coin.name.toLowerCase().contains(_searchQuery) ||
            coin.symbol.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_minPrice != null) {
      list = list.where((coin) => (coin.currentPrice ?? 0.0) >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      list = list.where((coin) => (coin.currentPrice ?? 0.0) <= _maxPrice!).toList();
    }


    if (_minVolume != null) {
      list = list.where((coin) => (coin.totalVolume ?? 0.0) >= _minVolume!).toList();
    }


    if (_rankLimit != null) {
      list = list.where((coin) => (coin.marketCapRank ?? 99999) <= _rankLimit!).toList();
    }

    list.sort((a, b) {
      int cmp = 0;
      switch (_sortBy) {
        case 'price':
          cmp = (a.currentPrice ?? 0.0).compareTo(b.currentPrice ?? 0.0);
          break;
        case 'change_24h':
          cmp = (a.priceChangePercentage24h ?? 0.0).compareTo(b.priceChangePercentage24h ?? 0.0);
          break;
        case 'volume':
          cmp = (a.totalVolume ?? 0.0).compareTo(b.totalVolume ?? 0.0);
          break;
        case 'market_cap':
        default:
          cmp = (a.marketCap ?? 0.0).compareTo(b.marketCap ?? 0.0);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  CoinBloc(this.coinRepository) : super(CoinInitial()) {
    on<FetchCoinsList>((event, emit) async {
      emit(CoinLoading(loadingFor: 'FetchCoinsList'));

      try {
        final coins = await coinRepository.fetchCoinsList(
          page: 1,
          perPage: _perPage,
        );

        _allCoins = coins;
        _currentPage = 1;
        _hasMore = coins.length == _perPage;
        _searchQuery = '';
        _activeTab = 'All';

        final processed = _applyFiltersAndSorting(_allCoins);
        emit(CoinListSuccess(processed, activeTab: _activeTab));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'FetchCoinsList'));
      }
    });

    on<FetchMoreCoins>((event, emit) async {
      if (!_hasMore || _isLoadingMore || _searchQuery.isNotEmpty ||
          _activeTab != 'All') {
        return;
      }

      _isLoadingMore = true;

      try {
        final nextPage = _currentPage + 1;

        final newCoins = await coinRepository.fetchCoinsList(
          page: nextPage,
          perPage: _perPage,
        );

        if (newCoins.isNotEmpty) {
          _allCoins = [..._allCoins, ...newCoins];
          _currentPage = nextPage;
        }

        _hasMore = newCoins.length == _perPage;

        final processed = _applyFiltersAndSorting(_allCoins);
        emit(
          MoreCoinsSuccess(
            coins: processed,
            hasMore: _hasMore,
          ),
        );
      } catch (e) {
        emit(CoinError(_cleanError(e), 'FetchMoreCoins'));
      } finally {
        _isLoadingMore = false;
      }
    });

    on<SearchCoins>((event, emit) {
      _searchQuery = event.query.trim().toLowerCase();
      final activeList = _getActiveList();
      final processed = _applyFiltersAndSorting(activeList);
      emit(CoinSearchSuccess(processed));
    });

    on<FilterCoinsTab>((event, emit) async {
      _activeTab = event.tab;
      _searchQuery = '';

      if (_activeTab == 'Trending' && _trendingCoins.isEmpty) {
        emit(CoinLoading(loadingFor: 'FetchTrending'));
        try {
          final res = await coinRepository.fetchTrendingCoins();
          _trendingCoins = res.coins.map((item) {
            final price = item.data?.price ?? 0.0;
            final change24h = item.data?.priceChangePercentage24h['usd'] ?? 0.0;
            return CoinMarketListResponse(
              id: item.id,
              symbol: item.symbol,
              name: item.name,
              image: item.large ?? item.small ?? item.thumb ?? '',
              currentPrice: price,
              marketCapRank: item.marketCapRank,
              priceChangePercentage24h: change24h,
            );
          }).toList();
        } catch (e) {
          _trendingCoins = _allCoins.take(5).toList();
        }
      }

      final activeList = _getActiveList();
      final processed = _applyFiltersAndSorting(activeList);
      emit(CoinListSuccess(processed, activeTab: _activeTab));
    });

    on<SortCoins>((event, emit) {
      _sortBy = event.sortBy;
      _sortAscending = event.isAscending;

      final activeList = _getActiveList();
      final processed = _applyFiltersAndSorting(activeList);
      emit(CoinListSuccess(processed, activeTab: _activeTab));
    });

    on<ApplyAdvancedFilters>((event, emit) {
      _minPrice = event.minPrice;
      _maxPrice = event.maxPrice;
      _minVolume = event.minVolume;
      _rankLimit = event.rankLimit;

      final activeList = _getActiveList();
      final processed = _applyFiltersAndSorting(activeList);
      emit(CoinListSuccess(processed, activeTab: _activeTab));
    });

    on<ResetCoinFilters>((event, emit) {
      _minPrice = null;
      _maxPrice = null;
      _minVolume = null;
      _rankLimit = null;
      _sortBy = 'market_cap';
      _sortAscending = false;

      final activeList = _getActiveList();
      final processed = _applyFiltersAndSorting(activeList);
      emit(CoinListSuccess(processed, activeTab: _activeTab));
    });

    on<RefreshCoinsList>((event, emit) async {
      emit(CoinLoading(loadingFor: 'RefreshCoinsList'));

      try {
        final coins = await coinRepository.fetchCoinsList(
          page: 1,
          perPage: _perPage,
        );

        _allCoins = coins;
        _trendingCoins.clear();
        _topGainers.clear();
        _topLosers.clear();
        _currentPage = 1;
        _hasMore = coins.length == _perPage;
        _searchQuery = '';
        _activeTab = 'All';

        final processed = _applyFiltersAndSorting(_allCoins);
        emit(CoinListSuccess(processed, activeTab: _activeTab));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'RefreshCoinsList'));
      }
    });

    on<FetchCoinDetailData>((event, emit) async {
      emit(CoinDetailLoading());
      try {
        final detailsFuture = coinRepository.fetchCoinDetails(event.coinId);
        final chartFuture = coinRepository.fetchCoinChart(
            event.coinId, days: event.days);

        final results = await Future.wait([detailsFuture, chartFuture]);

        emit(CoinDetailSuccess(
          details: results[0] as dynamic,
          chart: results[1] as dynamic,
          selectedDays: event.days,
        ));
      } catch (e) {
        emit(CoinDetailError(_cleanError(e)));
      }
    });

    on<ChangeChartTimeframe>((event, emit) async {
      final currentState = state;
      if (currentState is CoinDetailSuccess) {
        try {
          final chart = await coinRepository.fetchCoinChart(
              event.coinId, days: event.days);
          emit(CoinDetailSuccess(
            details: currentState.details,
            chart: chart,
            selectedDays: event.days,
          ));
        } catch (e) {

        }
      }
    });

    on<FetchGlobalMarketData>((event, emit) async {
      emit(GlobalMarketLoading());
      try {
        final globalMarket = await coinRepository.fetchGlobalMarket();
        emit(GlobalListSuccess(globalMarket));
      } catch (e) {
        emit(GlobalMarketError(_cleanError(e)));
      }
    });
  }
}
