import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/trade_comparison_entity.dart';
import '../../domain/usecases/get_trade_comparison_data.dart';

// Events
abstract class TradeComparisonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTradeComparisonData extends TradeComparisonEvent {}

// States
abstract class TradeComparisonState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TradeComparisonInitial extends TradeComparisonState {}

class TradeComparisonLoading extends TradeComparisonState {}

class TradeComparisonLoaded extends TradeComparisonState {
  final List<TradeComparisonEntity> data;
  TradeComparisonLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class TradeComparisonError extends TradeComparisonState {
  final String message;
  TradeComparisonError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class TradeComparisonBloc extends Bloc<TradeComparisonEvent, TradeComparisonState> {
  final GetTradeComparisonData getTradeComparisonData;

  TradeComparisonBloc({required this.getTradeComparisonData}) : super(TradeComparisonInitial()) {
    on<LoadTradeComparisonData>((event, emit) async {
      emit(TradeComparisonLoading());
      final result = await getTradeComparisonData();
      result.fold(
        (failure) => emit(TradeComparisonError('Server Failure')),
        (data) => emit(TradeComparisonLoaded(data)),
      );
    });
  }
}
