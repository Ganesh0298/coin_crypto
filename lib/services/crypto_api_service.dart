import 'package:dio/dio.dart';
import '../models/coin_model.dart';

class CryptoApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  CryptoApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));
  }

  Future<List<CoinModel>> fetchTopCoins() async {
    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': 50,
          'page': 1,
          'sparkline': true,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List data = response.data;
        return data.map((json) => CoinModel.fromJson(json)).toList();
      } else {
        return CoinModel.mockCoins;
      }
    } catch (e) {
      // Fallback to rich mock data if offline or rate limited
      return CoinModel.mockCoins;
    }
  }

  Future<Map<String, dynamic>> fetchGlobalMarketStats() async {
    try {
      final response = await _dio.get('/global');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] ?? {};
      }
    } catch (e) {
      // Return mock global stats on failure
    }
    return {
      'active_cryptocurrencies': 14250,
      'total_market_cap': {'usd': 2450000000000.0},
      'total_volume': {'usd': 85000000000.0},
      'market_cap_percentage': {'btc': 52.4, 'eth': 17.8},
      'market_cap_change_percentage_24h_usd': 2.15,
    };
  }
}
