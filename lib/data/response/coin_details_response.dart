class CoinDetailsResponse {
  final String id;
  final String symbol;
  final String name;
  final String? webSlug;

  final String? assetPlatformId;
  final Map<String, dynamic> platforms;
  final Map<String, dynamic> detailPlatforms;

  final int? blockTimeInMinutes;
  final String? hashingAlgorithm;
  final List<String> categories;

  final bool? previewListing;
  final dynamic publicNotice;
  final List<dynamic> additionalNotices;

  final Map<String, dynamic> localization;
  final Map<String, dynamic> description;
  final Map<String, dynamic> links;
  final Map<String, dynamic> image;

  final String? countryOrigin;
  final String? genesisDate;
  final double? listingPrice;
  final String? listingCurrency;
  final dynamic listingTimestamp;
  final String? listingSource;
  final String? listingSourceUrl;
  final bool? hasSupplyBreakdown;

  final double? sentimentVotesUpPercentage;
  final double? sentimentVotesDownPercentage;

  final Map<String, dynamic> icoData;
  final int? watchlistPortfolioUsers;
  final int? marketCapRank;
  final int? marketCapRankWithRehypothecated;

  final MarketData? marketData;

  CoinDetailsResponse({
    required this.id,
    required this.symbol,
    required this.name,
    this.webSlug,
    this.assetPlatformId,
    this.platforms = const {},
    this.detailPlatforms = const {},
    this.blockTimeInMinutes,
    this.hashingAlgorithm,
    this.categories = const [],
    this.previewListing,
    this.publicNotice,
    this.additionalNotices = const [],
    this.localization = const {},
    this.description = const {},
    this.links = const {},
    this.image = const {},
    this.countryOrigin,
    this.genesisDate,
    this.listingPrice,
    this.listingCurrency,
    this.listingTimestamp,
    this.listingSource,
    this.listingSourceUrl,
    this.hasSupplyBreakdown,
    this.sentimentVotesUpPercentage,
    this.sentimentVotesDownPercentage,
    this.icoData = const {},
    this.watchlistPortfolioUsers,
    this.marketCapRank,
    this.marketCapRankWithRehypothecated,
    this.marketData,
  });

  factory CoinDetailsResponse.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) => value is num ? value.toDouble() : null;

    int? toInt(dynamic value) => value is num ? value.toInt() : null;

    Map<String, dynamic> toMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return <String, dynamic>{};
    }

    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return <String>[];
    }

    return CoinDetailsResponse(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      webSlug: json['web_slug'] as String?,
      assetPlatformId: json['asset_platform_id'] as String?,

      platforms: toMap(json['platforms']),
      detailPlatforms: toMap(json['detail_platforms']),

      blockTimeInMinutes: toInt(json['block_time_in_minutes']),
      hashingAlgorithm: json['hashing_algorithm'] as String?,
      categories: toStringList(json['categories']),

      previewListing: json['preview_listing'] as bool?,
      publicNotice: json['public_notice'],
      additionalNotices: json['additional_notices'] is List
          ? List<dynamic>.from(json['additional_notices'])
          : <dynamic>[],

      localization: toMap(json['localization']),
      description: toMap(json['description']),
      links: toMap(json['links']),
      image: toMap(json['image']),

      countryOrigin: json['country_origin'] as String?,
      genesisDate: json['genesis_date'] as String?,
      listingPrice: toDouble(json['listing_price']),
      listingCurrency: json['listing_currency'] as String?,
      listingTimestamp: json['listing_timestamp'],
      listingSource: json['listing_source'] as String?,
      listingSourceUrl: json['listing_source_url'] as String?,
      hasSupplyBreakdown: json['has_supply_breakdown'] as bool?,

      sentimentVotesUpPercentage: toDouble(
        json['sentiment_votes_up_percentage'],
      ),
      sentimentVotesDownPercentage: toDouble(
        json['sentiment_votes_down_percentage'],
      ),

      icoData: toMap(json['ico_data']),
      watchlistPortfolioUsers: toInt(json['watchlist_portfolio_users']),
      marketCapRank: toInt(json['market_cap_rank']),
      marketCapRankWithRehypothecated: toInt(
        json['market_cap_rank_with_rehypothecated'],
      ),
      marketData: json['market_data'] != null && json['market_data'] is Map
          ? MarketData.fromJson(Map<String, dynamic>.from(json['market_data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'web_slug': webSlug,
      'asset_platform_id': assetPlatformId,
      'platforms': platforms,
      'detail_platforms': detailPlatforms,
      'block_time_in_minutes': blockTimeInMinutes,
      'hashing_algorithm': hashingAlgorithm,
      'categories': categories,
      'preview_listing': previewListing,
      'public_notice': publicNotice,
      'additional_notices': additionalNotices,
      'localization': localization,
      'description': description,
      'links': links,
      'image': image,
      'country_origin': countryOrigin,
      'genesis_date': genesisDate,
      'listing_price': listingPrice,
      'listing_currency': listingCurrency,
      'listing_timestamp': listingTimestamp,
      'listing_source': listingSource,
      'listing_source_url': listingSourceUrl,
      'has_supply_breakdown': hasSupplyBreakdown,
      'sentiment_votes_up_percentage': sentimentVotesUpPercentage,
      'sentiment_votes_down_percentage': sentimentVotesDownPercentage,
      'ico_data': icoData,
      'watchlist_portfolio_users': watchlistPortfolioUsers,
      'market_cap_rank': marketCapRank,
      'market_cap_rank_with_rehypothecated': marketCapRankWithRehypothecated,
    };
  }
}

class MarketData {
  final double? currentPriceUsd;
  final double? marketCapUsd;
  final double? totalVolumeUsd;
  final double? high24hUsd;
  final double? low24hUsd;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final double? priceChangePercentage30d;
  final double? priceChangePercentage1y;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double? athUsd;
  final double? athChangePercentageUsd;
  final String? athDateUsd;
  final double? atlUsd;
  final double? atlChangePercentageUsd;
  final String? atlDateUsd;
  final double? fullyDilutedValuationUsd;

  MarketData({
    this.currentPriceUsd,
    this.marketCapUsd,
    this.totalVolumeUsd,
    this.high24hUsd,
    this.low24hUsd,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.priceChangePercentage30d,
    this.priceChangePercentage1y,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.athUsd,
    this.athChangePercentageUsd,
    this.athDateUsd,
    this.atlUsd,
    this.atlChangePercentageUsd,
    this.atlDateUsd,
    this.fullyDilutedValuationUsd,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) => value is num ? value.toDouble() : null;

    Map<String, dynamic>? toMap(dynamic val) => val is Map ? Map<String, dynamic>.from(val) : null;

    final currentPrice = toMap(json['current_price']);
    final marketCap = toMap(json['market_cap']);
    final totalVolume = toMap(json['total_volume']);
    final high24h = toMap(json['high_24h']);
    final low24h = toMap(json['low_24h']);
    final ath = toMap(json['ath']);
    final athChangePercentage = toMap(json['ath_change_percentage']);
    final athDate = toMap(json['ath_date']);
    final atl = toMap(json['atl']);
    final atlChangePercentage = toMap(json['atl_change_percentage']);
    final atlDate = toMap(json['atl_date']);
    final fdv = toMap(json['fully_diluted_valuation']);

    return MarketData(
      currentPriceUsd: currentPrice != null ? toDouble(currentPrice['usd']) : null,
      marketCapUsd: marketCap != null ? toDouble(marketCap['usd']) : null,
      totalVolumeUsd: totalVolume != null ? toDouble(totalVolume['usd']) : null,
      high24hUsd: high24h != null ? toDouble(high24h['usd']) : null,
      low24hUsd: low24h != null ? toDouble(low24h['usd']) : null,
      priceChangePercentage24h: toDouble(json['price_change_percentage_24h']),
      priceChangePercentage7d: toDouble(json['price_change_percentage_7d']),
      priceChangePercentage30d: toDouble(json['price_change_percentage_30d']),
      priceChangePercentage1y: toDouble(json['price_change_percentage_1y']),
      circulatingSupply: toDouble(json['circulating_supply']),
      totalSupply: toDouble(json['total_supply']),
      maxSupply: toDouble(json['max_supply']),
      athUsd: ath != null ? toDouble(ath['usd']) : null,
      athChangePercentageUsd: athChangePercentage != null ? toDouble(athChangePercentage['usd']) : null,
      athDateUsd: athDate != null ? athDate['usd'] as String? : null,
      atlUsd: atl != null ? toDouble(atl['usd']) : null,
      atlChangePercentageUsd: atlChangePercentage != null ? toDouble(atlChangePercentage['usd']) : null,
      atlDateUsd: atlDate != null ? atlDate['usd'] as String? : null,
      fullyDilutedValuationUsd: fdv != null ? toDouble(fdv['usd']) : null,
    );
  }
}
