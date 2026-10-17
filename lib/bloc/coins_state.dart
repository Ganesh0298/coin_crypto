import '../data/response/coin_market_list_response.dart';
import '../data/response/coin_details_response.dart';
import '../data/response/coin_chart_response.dart';
import '../data/response/global_market_response.dart';

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

class CoinDetailLoading extends CoinState {}

class CoinDetailSuccess extends CoinState {
  final CoinDetailsResponse details;
  final MarketChartResponse chart;
  final String selectedDays;

  CoinDetailSuccess({
    required this.details,
    required this.chart,
    required this.selectedDays,
  });
}

class CoinDetailError extends CoinState {
  final String message;

  CoinDetailError(this.message);
}




class GlobalMarketLoading extends CoinState {}

class GlobalListSuccess extends CoinState {
  final GlobalMarketResponse globalMarket;

  GlobalListSuccess(this.globalMarket);
}

class GlobalMarketError extends CoinState {
  final String message;

  GlobalMarketError(this.message);
}
