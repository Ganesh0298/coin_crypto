import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/response/coin_market_list_response.dart';
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

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

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

        emit(CoinListSuccess(_allCoins, activeTab: _activeTab));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'FetchCoinsList'));
      }
    });

    on<FetchMoreCoins>((event, emit) async {
      if (!_hasMore || _isLoadingMore || _searchQuery.isNotEmpty || _activeTab != 'All') {
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

        emit(
          MoreCoinsSuccess(
            coins: _allCoins,
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

      final targetList = _activeTab == 'Trending'
          ? _trendingCoins
          : _activeTab == 'Top Gainers'
              ? _topGainers
              : _activeTab == 'Top Losers'
                  ? _topLosers
                  : _allCoins;

      final filteredCoins = targetList.where((coin) {
        return coin.name.toLowerCase().contains(_searchQuery) ||
            coin.symbol.toLowerCase().contains(_searchQuery);
      }).toList();

      emit(CoinSearchSuccess(filteredCoins));
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
      } else if ((_activeTab == 'Top Gainers' || _activeTab == 'Top Losers') && _topGainers.isEmpty) {
        emit(CoinLoading(loadingFor: 'FetchGainersLosers'));
        try {
          final res = await coinRepository.fetchTopGainersLosers();
          _topGainers = res.topGainers.map((g) => CoinMarketListResponse(
            id: g.id,
            symbol: g.symbol,
            name: g.name,
            image: g.image,
            currentPrice: g.usd,
            marketCapRank: g.marketCapRank,
            priceChangePercentage24h: g.usd24hChange,
            totalVolume: g.usd24hVol,
          )).toList();

          _topLosers = res.topLosers.map((l) => CoinMarketListResponse(
            id: l.id,
            symbol: l.symbol,
            name: l.name,
            image: l.image,
            currentPrice: l.usd,
            marketCapRank: l.marketCapRank,
            priceChangePercentage24h: l.usd24hChange,
            totalVolume: l.usd24hVol,
          )).toList();
        } catch (e) {
          _topGainers = List.from(_allCoins)..sort((a, b) => (b.priceChangePercentage24h ?? 0).compareTo(a.priceChangePercentage24h ?? 0));
          _topLosers = List.from(_allCoins)..sort((a, b) => (a.priceChangePercentage24h ?? 0).compareTo(b.priceChangePercentage24h ?? 0));
        }
      }

      List<CoinMarketListResponse> activeList = _allCoins;
      if (_activeTab == 'Trending') {
        activeList = _trendingCoins;
      } else if (_activeTab == 'Top Gainers') {
        activeList = _topGainers;
      } else if (_activeTab == 'Top Losers') {
        activeList = _topLosers;
      }

      emit(CoinListSuccess(activeList, activeTab: _activeTab));
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

        emit(CoinListSuccess(_allCoins, activeTab: _activeTab));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'RefreshCoinsList'));
      }
    });
  }
}
