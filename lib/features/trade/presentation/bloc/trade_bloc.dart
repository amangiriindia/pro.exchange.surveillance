import 'package:flutter_bloc/flutter_bloc.dart';
import 'trade_event.dart';
import 'trade_state.dart';
import '../../domain/usecases/get_trades.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final GetTrades getTrades;
  static const int _pageSize = 100;

  TradeBloc({required this.getTrades}) : super(TradeInitial()) {
    on<LoadTrades>(_onLoadTrades);
    on<LoadMoreTrades>(_onLoadMoreTrades);
  }

  Future<void> _onLoadTrades(LoadTrades event, Emitter<TradeState> emit) async {
    emit(TradeLoading());
    final result = await getTrades(page: 1, sizePerPage: _pageSize);
    result.fold(
      (failure) => emit(TradeError(message: failure)),
      (paginated) => emit(
        TradeLoaded(
          trades: paginated.trades,
          totalRecords: paginated.totalRecords,
          totalPages: paginated.totalPages,
          currentPage: paginated.currentPage,
          hasMore: paginated.currentPage < paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreTrades(
    LoadMoreTrades event,
    Emitter<TradeState> emit,
  ) async {
    final current = state;
    if (current is! TradeLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await getTrades(page: nextPage, sizePerPage: _pageSize);
    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (paginated) => emit(
        TradeLoaded(
          trades: [...current.trades, ...paginated.trades],
          totalRecords: paginated.totalRecords,
          totalPages: paginated.totalPages,
          currentPage: paginated.currentPage,
          isLoadingMore: false,
          hasMore: paginated.currentPage < paginated.totalPages,
        ),
      ),
    );
  }
}
