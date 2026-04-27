import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/same_device_entity.dart';
import '../../domain/usecases/get_same_device_data.dart';

// Events
abstract class SameDeviceTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSameDeviceData extends SameDeviceTrackerEvent {}

class LoadMoreSameDeviceData extends SameDeviceTrackerEvent {}

// States
abstract class SameDeviceTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameDeviceTrackerInitial extends SameDeviceTrackerState {}

class SameDeviceTrackerLoading extends SameDeviceTrackerState {}

class SameDeviceTrackerLoaded extends SameDeviceTrackerState {
  final List<SameDeviceEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  SameDeviceTrackerLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  SameDeviceTrackerLoaded copyWith({
    List<SameDeviceEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return SameDeviceTrackerLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
}

class SameDeviceTrackerError extends SameDeviceTrackerState {
  final String message;
  SameDeviceTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SameDeviceTrackerBloc
    extends Bloc<SameDeviceTrackerEvent, SameDeviceTrackerState> {
  final GetSameDeviceData getSameDeviceData;
  static const int _pageSize = 20;

  SameDeviceTrackerBloc({required this.getSameDeviceData})
    : super(SameDeviceTrackerInitial()) {
    on<LoadSameDeviceData>((event, emit) async {
      emit(SameDeviceTrackerLoading());
      final result = await getSameDeviceData(page: 1, sizePerPage: _pageSize);
      result.fold(
        (failure) => emit(SameDeviceTrackerError('Server Failure')),
        (data) => emit(
          SameDeviceTrackerLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadMoreSameDeviceData>((event, emit) async {
      final current = state;
      if (current is! SameDeviceTrackerLoaded ||
          current.isLoadingMore ||
          !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getSameDeviceData(
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
