abstract class CoinEvent {}

class FetchCoinsList extends CoinEvent {}

class FetchMoreCoins extends CoinEvent {}

class SearchCoins extends CoinEvent {
  final String query;

  SearchCoins({required this.query});
}

class RefreshCoinsList extends CoinEvent {}

class FilterCoinsTab extends CoinEvent {
  final String tab; // 'All', 'Trending', 'Top Gainers', 'Top Losers', 'Watchlist'

  FilterCoinsTab(this.tab);
}
