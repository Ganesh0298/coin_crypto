class TrendingCoinResponse {
  final List<TrendingCoinItem> coins;

  TrendingCoinResponse({required this.coins});

  factory TrendingCoinResponse.fromJson(Map<String, dynamic> json) {
    return TrendingCoinResponse(
      coins: (json['coins'] as List<dynamic>? ?? [])
          .map((e) => TrendingCoinItem.fromJson(e['item']))
          .toList(),
    );
  }
}

class TrendingCoinItem {
  final String id;
  final int coinId;
  final String name;
  final String symbol;
  final int? marketCapRank;
  final String? thumb;
  final String? small;
  final String? large;
  final String? slug;
  final double? priceBtc;
  final int? score;
  final TrendingCoinData? data;

  TrendingCoinItem({
    required this.id,
    required this.coinId,
    required this.name,
    required this.symbol,
    this.marketCapRank,
    this.thumb,
    this.small,
    this.large,
    this.slug,
    this.priceBtc,
    this.score,
    this.data,
  });

  factory TrendingCoinItem.fromJson(Map<String, dynamic> json) {
    return TrendingCoinItem(
      id: json['id'] ?? '',
      coinId: (json['coin_id'] as num).toInt(),
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      thumb: json['thumb'],
      small: json['small'],
      large: json['large'],
      slug: json['slug'],
      priceBtc: (json['price_btc'] as num?)?.toDouble(),
      score: (json['score'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : TrendingCoinData.fromJson(json['data']),
    );
  }
}

class TrendingCoinData {
  final double? price;
  final String? priceBtc;
  final Map<String, double> priceChangePercentage24h;
  final String? marketCap;
  final String? marketCapBtc;
  final String? totalVolume;
  final String? totalVolumeBtc;
  final String? sparkline;
  final dynamic content;

  TrendingCoinData({
    this.price,
    this.priceBtc,
    this.priceChangePercentage24h = const {},
    this.marketCap,
    this.marketCapBtc,
    this.totalVolume,
    this.totalVolumeBtc,
    this.sparkline,
    this.content,
  });

  factory TrendingCoinData.fromJson(Map<String, dynamic> json) {
    return TrendingCoinData(
      price: (json['price'] as num?)?.toDouble(),
      priceBtc: json['price_btc']?.toString(),
      priceChangePercentage24h:
      (json['price_change_percentage_24h'] as Map<String, dynamic>?)
          ?.map((key, value) =>
          MapEntry(key, (value as num).toDouble())) ??
          {},
      marketCap: json['market_cap'],
      marketCapBtc: json['market_cap_btc']?.toString(),
      totalVolume: json['total_volume'],
      totalVolumeBtc: json['total_volume_btc']?.toString(),
      sparkline: json['sparkline'],
      content: json['content'],
    );
  }
}