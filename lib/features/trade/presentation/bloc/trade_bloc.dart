import 'package:flutter_bloc/flutter_bloc.dart';
import 'trade_event.dart';
import 'trade_state.dart';
import '../../domain/usecases/get_trades.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final GetTrades getTrades;

  TradeBloc({required this.getTrades}) : super(TradeInitial()) {
    on<LoadTrades>(_onLoadTrades);
  }

  void _onLoadTrades(LoadTrades event, Emitter<TradeState> emit) async {
    emit(TradeLoading());
    final result = await getTrades();
    result.fold(
      (failure) => emit(const TradeError(message: 'Failed to load trades')),
      (trades) => emit(TradeLoaded(trades: trades)),
    );
  }
}
