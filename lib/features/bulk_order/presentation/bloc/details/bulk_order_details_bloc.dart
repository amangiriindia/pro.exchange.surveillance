import 'package:flutter_bloc/flutter_bloc.dart';
import 'bulk_order_details_event.dart';
import 'bulk_order_details_state.dart';
import '../../../domain/usecases/get_bulk_order_details.dart';

class BulkOrderDetailsBloc
    extends Bloc<BulkOrderDetailsEvent, BulkOrderDetailsState> {
  final GetBulkOrderDetails getBulkOrderDetails;

  BulkOrderDetailsBloc({required this.getBulkOrderDetails})
    : super(BulkOrderDetailsInitial()) {
    on<LoadBulkOrderDetails>(_onLoadBulkOrderDetails);
  }

  void _onLoadBulkOrderDetails(
    LoadBulkOrderDetails event,
    Emitter<BulkOrderDetailsState> emit,
  ) async {
    emit(BulkOrderDetailsLoading());
    final result = await getBulkOrderDetails(event.alertId);
    result.fold(
      (failure) => emit(BulkOrderDetailsError(message: failure.toString())),
      (data) => emit(BulkOrderDetailsLoaded(details: data)),
    );
  }
}
