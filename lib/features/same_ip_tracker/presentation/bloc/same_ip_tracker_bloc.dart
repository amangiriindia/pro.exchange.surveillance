import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/ip_city_lookup.dart';
import '../../domain/entities/same_ip_entity.dart';
import '../../domain/usecases/get_same_ip_data.dart';

abstract class SameIPTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSameIPData extends SameIPTrackerEvent {}

class LoadMoreSameIPData extends SameIPTrackerEvent {}

abstract class SameIPTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameIPTrackerInitial extends SameIPTrackerState {}

class SameIPTrackerLoading extends SameIPTrackerState {}

class SameIPTrackerLoaded extends SameIPTrackerState {
  final List<SameIPEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;
  final Map<String, String> resolvedCityByIp;

  SameIPTrackerLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.resolvedCityByIp = const {},
  });

  SameIPTrackerLoaded copyWith({
    List<SameIPEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
    Map<String, String>? resolvedCityByIp,
  }) {
    return SameIPTrackerLoaded(
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

class SameIPTrackerError extends SameIPTrackerState {
  final String message;
  SameIPTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

class SameIPTrackerBloc extends Bloc<SameIPTrackerEvent, SameIPTrackerState> {
  final GetSameIPData getSameIPData;
  static const int _pageSize = 20;

  int _reloadGeneration = 0;

  SameIPTrackerBloc({required this.getSameIPData})
    : super(SameIPTrackerInitial()) {
    on<LoadSameIPData>(_onLoadSameIPData);
    on<LoadMoreSameIPData>(_onLoadMoreSameIPData);
  }

  Future<void> _onLoadSameIPData(
    LoadSameIPData event,
    Emitter<SameIPTrackerState> emit,
  ) async {
    _reloadGeneration++;
    final reloadGen = _reloadGeneration;

    emit(SameIPTrackerLoading());
    final result = await getSameIPData(page: 1, sizePerPage: _pageSize);
    await result.fold(
      (failure) async => emit(SameIPTrackerError('Server Failure')),
      (data) async {
        emit(
          SameIPTrackerLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
            resolvedCityByIp: const {},
          ),
        );

        final cityMap = await IpCityLookup.instance.prefetchBatch(
          data.map((e) => (ip: e.ipAddress, backendCity: null)),
        );

        if (reloadGen != _reloadGeneration) return;
        final s = state;
        if (s is! SameIPTrackerLoaded) return;
        emit(s.copyWith(resolvedCityByIp: cityMap));
      },
    );
  }

  Future<void> _onLoadMoreSameIPData(
    LoadMoreSameIPData event,
    Emitter<SameIPTrackerState> emit,
  ) async {
    final current = state;
    if (current is! SameIPTrackerLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.currentPage + 1;
    final result = await getSameIPData(page: nextPage, sizePerPage: _pageSize);
    await result.fold(
      (failure) async => emit(current.copyWith(isLoadingMore: false)),
      (data) async {
        final merged = [...current.data, ...data];
        final expectedLen = merged.length;
        final expectedPage = nextPage;

        emit(
          SameIPTrackerLoaded(
            merged,
            currentPage: nextPage,
            isLoadingMore: false,
            hasMore: data.length >= _pageSize,
            resolvedCityByIp: current.resolvedCityByIp,
          ),
        );

        final patch = await IpCityLookup.instance.prefetchBatch(
          data.map((e) => (ip: e.ipAddress, backendCity: null)),
        );

        final s = state;
        if (s is! SameIPTrackerLoaded) return;
        if (s.currentPage != expectedPage || s.data.length != expectedLen) {
          return;
        }
        emit(s.copyWith(resolvedCityByIp: {...s.resolvedCityByIp, ...patch}));
      },
    );
  }
}
