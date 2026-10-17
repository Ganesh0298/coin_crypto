import 'package:dio/dio.dart';
import '../../utils/app_strings.dart';
import '../local/secure_storage.dart';
import '../response/coin_market_list_response.dart';
import '../response/coin_details_response.dart';
import '../response/coin_chart_response.dart';
import '../response/global_market_response.dart';
import '../response/trend_coins_response.dart';
import '../response/top_gainers_losers_response.dart';
import 'logging_interceptor.dart';

class ApiProvider {
  Dio? _dio;

  ApiProvider() {
    final BaseOptions options = BaseOptions(
      baseUrl: AppStrings.baseUrl,
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => true,
      followRedirects: false,
      headers: {
        'content-type': 'application/json',
        'x-cg-demo-api-key': AppStrings.coinGeckoApiKey,
      },
    );

    _dio = Dio(options);

    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.startsWith('/coins/') ||
              options.path.startsWith('/search/') ||
              options.path.startsWith('/global')) {
            options.headers.remove('authorization');
            return handler.next(options);
          }

          final storageService = await SecureStorageService.instance;
          final token = await storageService.accessToken;

          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
      ),
    );

    _dio?.interceptors.add(LoggingInterceptor());
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          return data["message"] ?? data["data"] ?? "Something went wrong";
        }

        return "Error: ${error.response?.statusCode}";
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout with API server";
        case DioExceptionType.sendTimeout:
          return "Send timeout with API server";
        case DioExceptionType.receiveTimeout:
          return "Receive timeout with API server";
        case DioExceptionType.connectionError:
          return "No internet connection";
        case DioExceptionType.cancel:
          return "Request was cancelled";
        default:
          return "Unexpected error occurred";
      }
    }

    return error.toString();
  }

  Future<List<CoinMarketListResponse>> fetchCoinsList({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio!.get(
        AppStrings.coinList,
        queryParameters: {
          'vs_currency': 'usd',
          'per_page': perPage,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;

        return data
            .map(
              (json) => CoinMarketListResponse.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();
      }

      throw Exception(
        'Failed to fetch coins. Status code: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Failed to fetch coins: ${_handleError(e)}');
    }
  }

  Future<CoinDetailsResponse> fetchCoinDetails(String coinId) async {
    try {
      final response = await _dio!.get('${AppStrings.coinDetail}$coinId');
      if (response.statusCode == 200) {
        return CoinDetailsResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch coin details: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch coin details: ${_handleError(e)}');
    }
  }

  Future<MarketChartResponse> fetchCoinChart(String coinId, {String days = '7'}) async {
    try {
      final response = await _dio!.get(
        '${AppStrings.coinDetail}$coinId${AppStrings.coinChart}',
        queryParameters: {'vs_currency': 'usd', 'days': days},
      );
      if (response.statusCode == 200) {
        return MarketChartResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch coin chart: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch coin chart: ${_handleError(e)}');
    }
  }

  Future<TrendingCoinResponse> fetchTrendingCoins() async {
    try {
      final response = await _dio!.get(AppStrings.trending);
      if (response.statusCode == 200) {
        return TrendingCoinResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch trending coins: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch trending coins: ${_handleError(e)}');
    }
  }

  Future<TopGainersLosersResponse> fetchTopGainersLosers() async {
    try {
      final response = await _dio!.get(AppStrings.topGainersLosers);
      if (response.statusCode == 200) {
        return TopGainersLosersResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch top gainers/losers: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch top gainers/losers: ${_handleError(e)}');
    }
  }

  Future<GlobalMarketResponse> fetchGlobalMarket() async {
    try {
      final response = await _dio!.get(AppStrings.global);
      if (response.statusCode == 200) {
        return GlobalMarketResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch global market: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to fetch global market: ${_handleError(e)}');
    }
  }
}
