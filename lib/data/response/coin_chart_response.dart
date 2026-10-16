class MarketChartResponse {
  final List<MarketDataPoint> prices;
  final List<MarketDataPoint> marketCaps;
  final List<MarketDataPoint> totalVolumes;

  const MarketChartResponse({
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
  });

  factory MarketChartResponse.fromJson(Map<String, dynamic> json) {
    return MarketChartResponse(
      prices: (json['prices'] as List<dynamic>)
          .map((e) => MarketDataPoint.fromJson(e as List<dynamic>))
          .toList(),
      marketCaps: (json['market_caps'] as List<dynamic>)
          .map((e) => MarketDataPoint.fromJson(e as List<dynamic>))
          .toList(),
      totalVolumes: (json['total_volumes'] as List<dynamic>)
          .map((e) => MarketDataPoint.fromJson(e as List<dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prices': prices.map((e) => e.toJson()).toList(),
      'market_caps': marketCaps.map((e) => e.toJson()).toList(),
      'total_volumes': totalVolumes.map((e) => e.toJson()).toList(),
    };
  }
}

class MarketDataPoint {
  final int timestamp;
  final double value;

  const MarketDataPoint({
    required this.timestamp,
    required this.value,
  });

  factory MarketDataPoint.fromJson(List<dynamic> json) {
    return MarketDataPoint(
      timestamp: (json[0] as num).toInt(),
      value: (json[1] as num).toDouble(),
    );
  }

  List<dynamic> toJson() => [timestamp, value];

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}