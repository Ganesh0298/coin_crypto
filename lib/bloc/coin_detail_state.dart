import '../data/response/coin_details_response.dart';
import '../data/response/coin_chart_response.dart';

abstract class CoinDetailState {}

class CoinDetailInitial extends CoinDetailState {}

class CoinDetailLoading extends CoinDetailState {}

class CoinDetailSuccess extends CoinDetailState {
  final CoinDetailsResponse details;
  final MarketChartResponse chart;
  final String selectedDays;

  CoinDetailSuccess({
    required this.details,
    required this.chart,
    required this.selectedDays,
  });
}

class CoinDetailError extends CoinDetailState {
  final String message;

  CoinDetailError(this.message);
}
