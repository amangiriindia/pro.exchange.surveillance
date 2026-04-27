import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/same_ip_entity.dart';
import '../../domain/usecases/get_same_ip_data.dart';

// Events
abstract class SameIPTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSameIPData extends SameIPTrackerEvent {}

class LoadMoreSameIPData extends SameIPTrackerEvent {}

// States
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

  SameIPTrackerLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  SameIPTrackerLoaded copyWith({
    List<SameIPEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return SameIPTrackerLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
}

class SameIPTrackerError extends SameIPTrackerState {
  final String message;
  SameIPTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SameIPTrackerBloc extends Bloc<SameIPTrackerEvent, SameIPTrackerState> {
  final GetSameIPData getSameIPData;
  static const int _pageSize = 20;

  SameIPTrackerBloc({required this.getSameIPData})
    : super(SameIPTrackerInitial()) {
    on<LoadSameIPData>((event, emit) async {
      emit(SameIPTrackerLoading());
      final result = await getSameIPData(page: 1, sizePerPage: _pageSize);
      result.fold(
        (failure) => emit(SameIPTrackerError('Server Failure')),
        (data) => emit(
          SameIPTrackerLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadMoreSameIPData>((event, emit) async {
      final current = state;
      if (current is! SameIPTrackerLoaded ||
          current.isLoadingMore ||
          !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getSameIPData(
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
