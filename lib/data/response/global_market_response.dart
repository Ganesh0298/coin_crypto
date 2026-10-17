class GlobalMarketResponse {
  final GlobalMarketData? data;

  GlobalMarketResponse({this.data});

  factory GlobalMarketResponse.fromJson(Map<String, dynamic> json) {
    return GlobalMarketResponse(
      data: json['data'] != null
          ? GlobalMarketData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data?.toJson(),
  };
}

class GlobalMarketData {
  final int? activeCryptocurrencies;
  final int? upcomingIcos;
  final int? ongoingIcos;
  final int? endedIcos;
  final int? markets;

  final Map<String, double> totalMarketCap;
  final Map<String, double> totalVolume;
  final Map<String, double> marketCapPercentage;

  final double? marketCapChangePercentage24hUsd;
  final double? volumeChangePercentage24hUsd;
  final int? updatedAt;

  GlobalMarketData({
    this.activeCryptocurrencies,
    this.upcomingIcos,
    this.ongoingIcos,
    this.endedIcos,
    this.markets,
    this.totalMarketCap = const {},
    this.totalVolume = const {},
    this.marketCapPercentage = const {},
    this.marketCapChangePercentage24hUsd,
    this.volumeChangePercentage24hUsd,
    this.updatedAt,
  });

  factory GlobalMarketData.fromJson(Map<String, dynamic> json) {
    return GlobalMarketData(
      activeCryptocurrencies: json['active_cryptocurrencies'] as int?,
      upcomingIcos: json['upcoming_icos'] as int?,
      ongoingIcos: json['ongoing_icos'] as int?,
      endedIcos: json['ended_icos'] as int?,
      markets: json['markets'] as int?,
      totalMarketCap: _parseDoubleMap(json['total_market_cap']),
      totalVolume: _parseDoubleMap(json['total_volume']),
      marketCapPercentage: _parseDoubleMap(json['market_cap_percentage']),
      marketCapChangePercentage24hUsd:
      (json['market_cap_change_percentage_24h_usd'] as num?)
          ?.toDouble(),
      volumeChangePercentage24hUsd:
      (json['volume_change_percentage_24h_usd'] as num?)
          ?.toDouble(),
      updatedAt: json['updated_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'active_cryptocurrencies': activeCryptocurrencies,
    'upcoming_icos': upcomingIcos,
    'ongoing_icos': ongoingIcos,
    'ended_icos': endedIcos,
    'markets': markets,
    'total_market_cap': totalMarketCap,
    'total_volume': totalVolume,
    'market_cap_percentage': marketCapPercentage,
    'market_cap_change_percentage_24h_usd':
    marketCapChangePercentage24hUsd,
    'volume_change_percentage_24h_usd': volumeChangePercentage24hUsd,
    'updated_at': updatedAt,
  };

  static Map<String, double> _parseDoubleMap(dynamic value) {
    if (value is! Map) return {};

    return value.map<String, double>(
          (key, value) => MapEntry(
        key.toString(),
        (value as num).toDouble(),
      ),
    );
  }
}