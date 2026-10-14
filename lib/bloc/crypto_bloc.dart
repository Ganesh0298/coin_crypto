import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/coin_model.dart';
import '../services/crypto_api_service.dart';

// --- States ---
class CryptoState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final List<CoinModel> allCoins;
  final List<CoinModel> displayedCoins;
  final String searchQuery;
  final String selectedCategory; // 'All', 'Gainers', 'Losers', 'Watchlist'
  final String sortBy; // 'Rank', 'Price', '24h Change'
  final Map<String, dynamic> globalStats;

  const CryptoState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.allCoins = const [],
    this.displayedCoins = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.sortBy = 'Rank',
    this.globalStats = const {},
  });

  CryptoState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<CoinModel>? allCoins,
    List<CoinModel>? displayedCoins,
    String? searchQuery,
    String? selectedCategory,
    String? sortBy,
    Map<String, dynamic>? globalStats,
  }) {
    return CryptoState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      allCoins: allCoins ?? this.allCoins,
      displayedCoins: displayedCoins ?? this.displayedCoins,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      globalStats: globalStats ?? this.globalStats,
    );
  }
}

// --- Cubit / Bloc ---
class CryptoCubit extends Cubit<CryptoState> {
  final CryptoApiService _apiService;

  CryptoCubit(this._apiService) : super(const CryptoState()) {
    loadMarkets();
  }

  Future<void> loadMarkets() async {
    emit(state.copyWith(isLoading: true, hasError: false, errorMessage: ''));
    try {
      final coins = await _apiService.fetchTopCoins();
      final stats = await _apiService.fetchGlobalMarketStats();

      emit(state.copyWith(
        isLoading: false,
        allCoins: coins,
        globalStats: stats,
      ));
      _applyFilterAndSort();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        allCoins: CoinModel.mockCoins, // Fallback
      ));
      _applyFilterAndSort();
    }
  }

  void searchCoins(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilterAndSort();
  }

  void filterByCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
    _applyFilterAndSort();
  }

  void sortCoins(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
    _applyFilterAndSort();
  }

  void toggleWatchlist(String coinId) {
    final updatedAll = state.allCoins.map((coin) {
      if (coin.id == coinId) {
        coin.isWatchlisted = !coin.isWatchlisted;
      }
      return coin;
    }).toList();

    emit(state.copyWith(allCoins: updatedAll));
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    List<CoinModel> result = List.from(state.allCoins);

    // 1. Search Query Filter
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result.where((coin) =>
          coin.name.toLowerCase().contains(q) ||
          coin.symbol.toLowerCase().contains(q)).toList();
    }

    // 2. Category Filter
    switch (state.selectedCategory) {
      case 'Gainers':
        result = result.where((coin) => coin.priceChangePercentage24h > 0).toList();
        break;
      case 'Losers':
        result = result.where((coin) => coin.priceChangePercentage24h < 0).toList();
        break;
      case 'Watchlist':
        result = result.where((coin) => coin.isWatchlisted).toList();
        break;
      case 'All':
      default:
        break;
    }

    // 3. Sorting
    switch (state.sortBy) {
      case 'Price':
        result.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case '24h Change':
        result.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        break;
      case 'Rank':
      default:
        result.sort((a, b) => a.marketCapRank.compareTo(b.marketCapRank));
        break;
    }

    emit(state.copyWith(displayedCoins: result));
  }
}
