import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profit_cross_entity.dart';
import '../../domain/entities/order_duration_entity.dart';
import '../../domain/usecases/get_profit_cross_data.dart';
import '../../domain/usecases/get_order_duration_details.dart';

// Events
abstract class ProfitCrossEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfitCrossData extends ProfitCrossEvent {}

class LoadOrderDurationDetails extends ProfitCrossEvent {
  final String symbol;
  LoadOrderDurationDetails(this.symbol);
  @override
  List<Object?> get props => [symbol];
}

// States
abstract class ProfitCrossState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfitCrossInitial extends ProfitCrossState {}

class ProfitCrossLoading extends ProfitCrossState {}

class ProfitCrossLoaded extends ProfitCrossState {
  final List<ProfitCrossEntity> data;
  ProfitCrossLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class ProfitCrossError extends ProfitCrossState {
  final String message;
  ProfitCrossError(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderDurationLoading extends ProfitCrossState {}

class OrderDurationLoaded extends ProfitCrossState {
  final List<OrderDurationEntity> details;
  OrderDurationLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

// Bloc
class ProfitCrossBloc extends Bloc<ProfitCrossEvent, ProfitCrossState> {
  final GetProfitCrossData getProfitCrossData;
  final GetOrderDurationDetails getOrderDurationDetails;

  ProfitCrossBloc({
    required this.getProfitCrossData,
    required this.getOrderDurationDetails,
  }) : super(ProfitCrossInitial()) {
    on<LoadProfitCrossData>((event, emit) async {
      emit(ProfitCrossLoading());
      final result = await getProfitCrossData();
      result.fold(
        (failure) => emit(ProfitCrossError('Server Failure')),
        (data) => emit(ProfitCrossLoaded(data)),
      );
    });

    on<LoadOrderDurationDetails>((event, emit) async {
      emit(OrderDurationLoading());
      final result = await getOrderDurationDetails(event.symbol);
      result.fold(
        (failure) => emit(ProfitCrossError('Server Failure')),
        (details) => emit(OrderDurationLoaded(details)),
      );
    });
  }
}
