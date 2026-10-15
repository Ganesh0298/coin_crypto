
import '../data/api/api_provider.dart';
import '../data/response/coin_market_list_response.dart';


class CoinRepository {
  ApiProvider apiProvider = ApiProvider();

  Future<List<CoinMarketListResponse>> fetchCoinsList({
    required int page,
    required int perPage,
  }) {
    return apiProvider.fetchCoinsList(
      page: page,
      perPage: perPage,
    );
  }
}