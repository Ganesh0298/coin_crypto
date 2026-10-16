import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/coins_repo.dart';
import 'coin_detail_event.dart';
import 'coin_detail_state.dart';

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  final CoinRepository coinRepository;

  CoinDetailBloc(this.coinRepository) : super(CoinDetailInitial()) {
    on<FetchCoinDetailData>((event, emit) async {
      emit(CoinDetailLoading());
      try {
        final detailsFuture = coinRepository.fetchCoinDetails(event.coinId);
        final chartFuture = coinRepository.fetchCoinChart(event.coinId, days: event.days);

        final results = await Future.wait([detailsFuture, chartFuture]);

        emit(CoinDetailSuccess(
          details: results[0] as dynamic,
          chart: results[1] as dynamic,
          selectedDays: event.days,
        ));
      } catch (e) {
        emit(CoinDetailError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<ChangeChartTimeframe>((event, emit) async {
      final currentState = state;
      if (currentState is CoinDetailSuccess) {
        try {
          final chart = await coinRepository.fetchCoinChart(event.coinId, days: event.days);
          emit(CoinDetailSuccess(
            details: currentState.details,
            chart: chart,
            selectedDays: event.days,
          ));
        } catch (e) {
          // Keep old chart if error
        }
      }
    });
  }
}
