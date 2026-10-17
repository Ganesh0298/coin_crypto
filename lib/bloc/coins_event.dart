abstract class CoinEvent {}

class FetchCoinsList extends CoinEvent {}

class FetchMoreCoins extends CoinEvent {}

class SearchCoins extends CoinEvent {
  final String query;

  SearchCoins({required this.query});
}

class RefreshCoinsList extends CoinEvent {}

class FilterCoinsTab extends CoinEvent {
  final String tab;

  FilterCoinsTab(this.tab);
}

class SortCoins extends CoinEvent {
  final String sortBy;
  final bool isAscending;

  SortCoins({required this.sortBy, this.isAscending = false});
}

class ApplyAdvancedFilters extends CoinEvent {
  final double? minPrice;
  final double? maxPrice;
  final double? minVolume;
  final int? rankLimit;

  ApplyAdvancedFilters({
    this.minPrice,
    this.maxPrice,
    this.minVolume,
    this.rankLimit,
  });
}

class ResetCoinFilters extends CoinEvent {}

class FetchCoinDetailData extends CoinEvent {
  final String coinId;
  final String days;

  FetchCoinDetailData({required this.coinId, this.days = '7'});
}

class ChangeChartTimeframe extends CoinEvent {
  final String coinId;
  final String days;

  ChangeChartTimeframe({required this.coinId, required this.days});
}

class FetchGlobalMarketData extends CoinEvent {}
