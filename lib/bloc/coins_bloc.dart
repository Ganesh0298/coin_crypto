import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/response/coin_market_list_response.dart';
import '../repo/coins_repo.dart';
import 'coins_event.dart';
import 'coins_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinRepository coinRepository;

  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<CoinMarketListResponse> _allCoins = [];
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

        emit(CoinListSuccess(_allCoins));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'FetchCoinsList'));
      }
    });

    on<FetchMoreCoins>((event, emit) async {
      if (!_hasMore || _isLoadingMore || _searchQuery.isNotEmpty) {
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

      final filteredCoins = _allCoins.where((coin) {
        return coin.name.toLowerCase().contains(_searchQuery) ||
            coin.symbol.toLowerCase().contains(_searchQuery);
      }).toList();

      emit(CoinSearchSuccess(filteredCoins));
    });

    on<RefreshCoinsList>((event, emit) async {
      emit(CoinLoading(loadingFor: 'RefreshCoinsList'));

      try {
        final coins = await coinRepository.fetchCoinsList(
          page: 1,
          perPage: _perPage,
        );

        _allCoins = coins;
        _currentPage = 1;
        _hasMore = coins.length == _perPage;
        _searchQuery = '';

        emit(CoinListSuccess(_allCoins));
      } catch (e) {
        emit(CoinError(_cleanError(e), 'RefreshCoinsList'));
      }
    });
  }
}