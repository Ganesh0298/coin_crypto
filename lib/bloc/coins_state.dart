import '../../data/response/coin_market_list_response.dart';

abstract class CoinState {}

class CoinInitial extends CoinState {}

class CoinLoading extends CoinState {
  final String loadingFor;

  CoinLoading({required this.loadingFor});
}

class CoinError extends CoinState {
  final String message;
  final String errorFor;

  CoinError(this.message, this.errorFor);
}

class CoinListSuccess extends CoinState {
  final List<CoinMarketListResponse> coins;
  final String activeTab;

  CoinListSuccess(this.coins, {this.activeTab = 'All'});
}

class MoreCoinsSuccess extends CoinState {
  final List<CoinMarketListResponse> coins;
  final bool hasMore;

  MoreCoinsSuccess({
    required this.coins,
    required this.hasMore,
  });
}

class CoinSearchSuccess extends CoinState {
  final List<CoinMarketListResponse> coins;

  CoinSearchSuccess(this.coins);
}
