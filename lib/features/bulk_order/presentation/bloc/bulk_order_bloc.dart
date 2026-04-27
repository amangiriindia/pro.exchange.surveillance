import 'package:flutter_bloc/flutter_bloc.dart';
import 'bulk_order_event.dart';
import 'bulk_order_state.dart';
import '../../domain/usecases/get_bulk_orders.dart';

class BulkOrderBloc extends Bloc<BulkOrderEvent, BulkOrderState> {
  final GetBulkOrders getBulkOrders;
  static const int _pageSize = 20;

  BulkOrderBloc({required this.getBulkOrders}) : super(BulkOrderInitial()) {
    on<LoadBulkOrders>(_onLoadBulkOrders);
    on<LoadMoreBulkOrders>(_onLoadMoreBulkOrders);
  }

  void _onLoadBulkOrders(
    LoadBulkOrders event,
    Emitter<BulkOrderState> emit,
  ) async {
    emit(BulkOrderLoading());
    final result = await getBulkOrders(page: 1, sizePerPage: _pageSize);
    result.fold(
      (failure) =>
          emit(const BulkOrderError(message: 'Failed to load bulk orders')),
      (trades) => emit(
        BulkOrderLoaded(
          trades: trades,
          currentPage: 1,
          hasMore: trades.length >= _pageSize,
        ),
      ),
    );
  }

  void _onLoadMoreBulkOrders(
    LoadMoreBulkOrders event,
    Emitter<BulkOrderState> emit,
  ) async {
    final current = state;
    if (current is! BulkOrderLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final result = await getBulkOrders(page: nextPage, sizePerPage: _pageSize);

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (trades) => emit(
        current.copyWith(
          trades: [...current.trades, ...trades],
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: trades.length >= _pageSize,
        ),
      ),
    );
  }
}
