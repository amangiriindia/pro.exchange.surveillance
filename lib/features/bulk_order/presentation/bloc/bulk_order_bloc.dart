import 'package:flutter_bloc/flutter_bloc.dart';
import 'bulk_order_event.dart';
import 'bulk_order_state.dart';
import '../../domain/usecases/get_bulk_orders.dart';

class BulkOrderBloc extends Bloc<BulkOrderEvent, BulkOrderState> {
  final GetBulkOrders getBulkOrders;

  BulkOrderBloc({required this.getBulkOrders}) : super(BulkOrderInitial()) {
    on<LoadBulkOrders>(_onLoadBulkOrders);
  }

  void _onLoadBulkOrders(LoadBulkOrders event, Emitter<BulkOrderState> emit) async {
    emit(BulkOrderLoading());
    final result = await getBulkOrders();
    result.fold(
      (failure) => emit(const BulkOrderError(message: 'Failed to load bulk orders')),
      (trades) => emit(BulkOrderLoaded(trades: trades)),
    );
  }
}
