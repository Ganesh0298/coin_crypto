import '../data/api/api_provider.dart';
import '../data/response/coin_market_list_response.dart';
import '../data/response/coin_details_response.dart';
import '../data/response/coin_chart_response.dart';
import '../data/response/global_market_response.dart';
import '../data/response/trend_coins_response.dart';
import '../data/response/top_gainers_losers_response.dart';

class CoinRepository {
  final ApiProvider apiProvider = ApiProvider();

  Future<List<CoinMarketListResponse>> fetchCoinsList({
    required int page,
    required int perPage,
  }) {
    return apiProvider.fetchCoinsList(
      page: page,
      perPage: perPage,
    );
  }

  Future<CoinDetailsResponse> fetchCoinDetails(String coinId) {
    return apiProvider.fetchCoinDetails(coinId);
  }

  Future<MarketChartResponse> fetchCoinChart(String coinId, {String days = '7'}) {
    return apiProvider.fetchCoinChart(coinId, days: days);
  }

  Future<TrendingCoinResponse> fetchTrendingCoins() {
    return apiProvider.fetchTrendingCoins();
  }

  Future<TopGainersLosersResponse> fetchTopGainersLosers() {
    return apiProvider.fetchTopGainersLosers();
  }

  Future<GlobalMarketResponse> fetchGlobalMarket() {
    return apiProvider.fetchGlobalMarket();
  }


}
