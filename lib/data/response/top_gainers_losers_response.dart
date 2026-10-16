class TopGainersLosersResponse {
  final List<CoinPerformance> topGainers;
  final List<CoinPerformance> topLosers;

  const TopGainersLosersResponse({
    required this.topGainers,
    required this.topLosers,
  });

  factory TopGainersLosersResponse.fromJson(Map<String, dynamic> json) {
    return TopGainersLosersResponse(
      topGainers: (json['top_gainers'] as List<dynamic>? ?? [])
          .map((e) => CoinPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLosers: (json['top_losers'] as List<dynamic>? ?? [])
          .map((e) => CoinPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_gainers': topGainers.map((e) => e.toJson()).toList(),
      'top_losers': topLosers.map((e) => e.toJson()).toList(),
    };
  }
}

class CoinPerformance {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final int? marketCapRank;
  final double usd;
  final double usd24hVol;
  final double usd24hChange;
  final double usd1hChange;
  final double usd7dChange;
  final double usd14dChange;
  final double usd30dChange;
  final double usd60dChange;
  final double? usd200dChange;
  final double? usd1yChange;

  const CoinPerformance({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    this.marketCapRank,
    required this.usd,
    required this.usd24hVol,
    required this.usd24hChange,
    required this.usd1hChange,
    required this.usd7dChange,
    required this.usd14dChange,
    required this.usd30dChange,
    required this.usd60dChange,
    this.usd200dChange,
    this.usd1yChange,
  });

  factory CoinPerformance.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) => (value as num).toDouble();

    return CoinPerformance(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      usd: toDouble(json['usd']),
      usd24hVol: toDouble(json['usd_24h_vol']),
      usd24hChange: toDouble(json['usd_24h_change']),
      usd1hChange: toDouble(json['usd_1h_change']),
      usd7dChange: toDouble(json['usd_7d_change']),
      usd14dChange: toDouble(json['usd_14d_change']),
      usd30dChange: toDouble(json['usd_30d_change']),
      usd60dChange: toDouble(json['usd_60d_change']),
      usd200dChange: (json['usd_200d_change'] as num?)?.toDouble(),
      usd1yChange: (json['usd_1y_change'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'market_cap_rank': marketCapRank,
      'usd': usd,
      'usd_24h_vol': usd24hVol,
      'usd_24h_change': usd24hChange,
      'usd_1h_change': usd1hChange,
      'usd_7d_change': usd7dChange,
      'usd_14d_change': usd14dChange,
      'usd_30d_change': usd30dChange,
      'usd_60d_change': usd60dChange,
      'usd_200d_change': usd200dChange,
      'usd_1y_change': usd1yChange,
    };
  }
}