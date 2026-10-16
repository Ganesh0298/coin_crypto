abstract class CoinDetailEvent {}

class FetchCoinDetailData extends CoinDetailEvent {
  final String coinId;
  final String days;

  FetchCoinDetailData({required this.coinId, this.days = '7'});
}

class ChangeChartTimeframe extends CoinDetailEvent {
  final String coinId;
  final String days;

  ChangeChartTimeframe({required this.coinId, required this.days});
}
