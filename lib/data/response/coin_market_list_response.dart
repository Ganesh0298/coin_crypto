
class CoinMarketListResponse {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double? currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? fullyDilutedValuation;
  final double? totalVolume;
  final double? high24h;
  final double? low24h;
  final double? priceChange24h;
  final double? priceChangePercentage24h;
  final double? marketCapChange24h;
  final double? marketCapChangePercentage24h;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double? ath;
  final double? athChangePercentage;
  final String? athDate;
  final double? atl;
  final double? atlChangePercentage;
  final String? atlDate;
  final dynamic roi;
  final String? lastUpdated;

  CoinMarketListResponse({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.fullyDilutedValuation,
    this.totalVolume,
    this.high24h,
    this.low24h,
    this.priceChange24h,
    this.priceChangePercentage24h,
    this.marketCapChange24h,
    this.marketCapChangePercentage24h,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.ath,
    this.athChangePercentage,
    this.athDate,
    this.atl,
    this.atlChangePercentage,
    this.atlDate,
    this.roi,
    this.lastUpdated,
  });

  factory CoinMarketListResponse.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) =>
        value is num ? value.toDouble() : null;

    return CoinMarketListResponse(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      currentPrice: toDouble(json['current_price']),
      marketCap: toDouble(json['market_cap']),
      marketCapRank: json['market_cap_rank'] as int?,
      fullyDilutedValuation:
      toDouble(json['fully_diluted_valuation']),
      totalVolume: toDouble(json['total_volume']),
      high24h: toDouble(json['high_24h']),
      low24h: toDouble(json['low_24h']),
      priceChange24h: toDouble(json['price_change_24h']),
      priceChangePercentage24h:
      toDouble(json['price_change_percentage_24h']),
      marketCapChange24h:
      toDouble(json['market_cap_change_24h']),
      marketCapChangePercentage24h:
      toDouble(json['market_cap_change_percentage_24h']),
      circulatingSupply: toDouble(json['circulating_supply']),
      totalSupply: toDouble(json['total_supply']),
      maxSupply: toDouble(json['max_supply']),
      ath: toDouble(json['ath']),
      athChangePercentage:
      toDouble(json['ath_change_percentage']),
      athDate: json['ath_date'] as String?,
      atl: toDouble(json['atl']),
      atlChangePercentage:
      toDouble(json['atl_change_percentage']),
      atlDate: json['atl_date'] as String?,
      roi: json['roi'],
      lastUpdated: json['last_updated'] as String?,
    );
  }
}
