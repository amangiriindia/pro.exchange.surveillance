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

class LoadMoreTradeComparisonData extends TradeComparisonEvent {}

// States
abstract class TradeComparisonState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TradeComparisonInitial extends TradeComparisonState {}

class TradeComparisonLoading extends TradeComparisonState {}

class TradeComparisonLoaded extends TradeComparisonState {
  final List<TradeComparisonEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  TradeComparisonLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  TradeComparisonLoaded copyWith({
    List<TradeComparisonEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return TradeComparisonLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
}

class TradeComparisonError extends TradeComparisonState {
  final String message;
  TradeComparisonError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class TradeComparisonBloc
    extends Bloc<TradeComparisonEvent, TradeComparisonState> {
  final GetTradeComparisonData getTradeComparisonData;
  static const int _pageSize = 20;

  TradeComparisonBloc({required this.getTradeComparisonData})
    : super(TradeComparisonInitial()) {
    on<LoadTradeComparisonData>((event, emit) async {
      emit(TradeComparisonLoading());
      final result = await getTradeComparisonData(
        page: 1,
        sizePerPage: _pageSize,
      );
      result.fold(
        (failure) => emit(TradeComparisonError('Server Failure')),
        (data) => emit(
          TradeComparisonLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadMoreTradeComparisonData>((event, emit) async {
      final current = state;
      if (current is! TradeComparisonLoaded ||
          current.isLoadingMore ||
          !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getTradeComparisonData(
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
  }
}
