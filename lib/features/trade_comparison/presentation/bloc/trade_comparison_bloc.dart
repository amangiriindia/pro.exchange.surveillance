import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/ip_city_lookup.dart';
import '../../domain/entities/trade_comparison_entity.dart';
import '../../domain/usecases/get_trade_comparison_data.dart';

abstract class TradeComparisonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTradeComparisonData extends TradeComparisonEvent {}

class LoadMoreTradeComparisonData extends TradeComparisonEvent {}

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
  final Map<String, String> resolvedCityByIp;

  TradeComparisonLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.resolvedCityByIp = const {},
  });

  TradeComparisonLoaded copyWith({
    List<TradeComparisonEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
    Map<String, String>? resolvedCityByIp,
  }) {
    return TradeComparisonLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      resolvedCityByIp: resolvedCityByIp ?? this.resolvedCityByIp,
    );
  }

  @override
  List<Object?> get props => [
    data,
    currentPage,
    isLoadingMore,
    hasMore,
    resolvedCityByIp,
  ];
}

class TradeComparisonError extends TradeComparisonState {
  final String message;
  TradeComparisonError(this.message);
  @override
  List<Object?> get props => [message];
}

class TradeComparisonBloc
    extends Bloc<TradeComparisonEvent, TradeComparisonState> {
  final GetTradeComparisonData getTradeComparisonData;
  static const int _pageSize = 20;

  int _reloadGeneration = 0;

  TradeComparisonBloc({required this.getTradeComparisonData})
    : super(TradeComparisonInitial()) {
    on<LoadTradeComparisonData>(_onLoadTradeComparisonData);
    on<LoadMoreTradeComparisonData>(_onLoadMoreTradeComparisonData);
  }

  Future<void> _onLoadTradeComparisonData(
    LoadTradeComparisonData event,
    Emitter<TradeComparisonState> emit,
  ) async {
    _reloadGeneration++;
    final reloadGen = _reloadGeneration;

    emit(TradeComparisonLoading());
    final result = await getTradeComparisonData(
      page: 1,
      sizePerPage: _pageSize,
    );
    await result.fold(
      (failure) async => emit(TradeComparisonError('Server Failure')),
      (data) async {
        emit(
          TradeComparisonLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
            resolvedCityByIp: const {},
          ),
        );

        final cityMap = await IpCityLookup.instance.prefetchBatch(
          data.map((e) => (ip: e.ipAddress, backendCity: e.city)),
        );

        if (reloadGen != _reloadGeneration) return;
        final s = state;
        if (s is! TradeComparisonLoaded) return;
        emit(s.copyWith(resolvedCityByIp: cityMap));
      },
    );
  }

  Future<void> _onLoadMoreTradeComparisonData(
    LoadMoreTradeComparisonData event,
    Emitter<TradeComparisonState> emit,
  ) async {
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
    await result.fold(
      (failure) async => emit(current.copyWith(isLoadingMore: false)),
      (data) async {
        final merged = [...current.data, ...data];
        final expectedLen = merged.length;
        final expectedPage = nextPage;

        emit(
          TradeComparisonLoaded(
            merged,
            currentPage: nextPage,
            isLoadingMore: false,
            hasMore: data.length >= _pageSize,
            resolvedCityByIp: current.resolvedCityByIp,
          ),
        );

        final patch = await IpCityLookup.instance.prefetchBatch(
          data.map((e) => (ip: e.ipAddress, backendCity: e.city)),
        );

        final s = state;
        if (s is! TradeComparisonLoaded) return;
        if (s.currentPage != expectedPage || s.data.length != expectedLen) {
          return;
        }
        emit(s.copyWith(resolvedCityByIp: {...s.resolvedCityByIp, ...patch}));
      },
    );
  }
}
