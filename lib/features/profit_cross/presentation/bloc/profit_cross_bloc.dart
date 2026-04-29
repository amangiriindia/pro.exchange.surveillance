import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profit_cross_entity.dart';
import '../../domain/entities/order_duration_entity.dart';
import '../../domain/usecases/get_profit_cross_data.dart';
import '../../domain/usecases/get_order_duration_details.dart';

abstract class ProfitCrossEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfitCrossData extends ProfitCrossEvent {}

class LoadMoreProfitCrossData extends ProfitCrossEvent {}

class LoadOrderDurationDetails extends ProfitCrossEvent {
  final int alertId;
  LoadOrderDurationDetails(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

abstract class ProfitCrossState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfitCrossInitial extends ProfitCrossState {}

class ProfitCrossLoading extends ProfitCrossState {}

class ProfitCrossLoaded extends ProfitCrossState {
  final List<ProfitCrossEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  ProfitCrossLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  ProfitCrossLoaded copyWith({
    List<ProfitCrossEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ProfitCrossLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
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

class ProfitCrossBloc extends Bloc<ProfitCrossEvent, ProfitCrossState> {
  final GetProfitCrossData getProfitCrossData;
  final GetOrderDurationDetails getOrderDurationDetails;
  static const int _pageSize = 20;

  ProfitCrossBloc({
    required this.getProfitCrossData,
    required this.getOrderDurationDetails,
  }) : super(ProfitCrossInitial()) {
    on<LoadProfitCrossData>((event, emit) async {
      emit(ProfitCrossLoading());
      final result = await getProfitCrossData(page: 1, sizePerPage: _pageSize);
      result.fold(
        (failure) => emit(ProfitCrossError('Server Failure')),
        (data) => emit(
          ProfitCrossLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadMoreProfitCrossData>((event, emit) async {
      final current = state;
      if (current is! ProfitCrossLoaded ||
          current.isLoadingMore ||
          !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getProfitCrossData(
        page: nextPage,
        sizePerPage: _pageSize,
      );
      result.fold(
        (failure) => emit(current.copyWith(isLoadingMore: false)),
        (data) => emit(
          current.copyWith(
            data: [...current.data, ...data],
            currentPage: nextPage,
            isLoadingMore: false,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadOrderDurationDetails>((event, emit) async {
      emit(OrderDurationLoading());
      final result = await getOrderDurationDetails(event.alertId);
      result.fold(
        (failure) => emit(ProfitCrossError('Server Failure')),
        (details) => emit(OrderDurationLoaded(details)),
      );
    });
  }
}
