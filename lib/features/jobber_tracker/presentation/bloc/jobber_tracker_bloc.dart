import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../domain/usecases/get_jobber_tracker_data.dart';

abstract class JobberTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadJobberTrackerData extends JobberTrackerEvent {}

class LoadMoreJobberTrackerData extends JobberTrackerEvent {}

abstract class JobberTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobberTrackerInitial extends JobberTrackerState {}

class JobberTrackerLoading extends JobberTrackerState {}

class JobberTrackerLoaded extends JobberTrackerState {
  final List<JobberTrackerEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  JobberTrackerLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  JobberTrackerLoaded copyWith({
    List<JobberTrackerEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return JobberTrackerLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
}

class JobberTrackerError extends JobberTrackerState {
  final String message;
  JobberTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

class JobberTrackerBloc extends Bloc<JobberTrackerEvent, JobberTrackerState> {
  final GetJobberTrackerData getJobberTrackerData;
  static const int _pageSize = 20;

  JobberTrackerBloc({required this.getJobberTrackerData})
    : super(JobberTrackerInitial()) {
    on<LoadJobberTrackerData>((event, emit) async {
      emit(JobberTrackerLoading());
      final result = await getJobberTrackerData(
        page: 1,
        sizePerPage: _pageSize,
      );
      result.fold(
        (failure) => emit(JobberTrackerError('Server Failure')),
        (data) => emit(
          JobberTrackerLoaded(
            data,
            currentPage: 1,
            hasMore: data.length >= _pageSize,
          ),
        ),
      );
    });

    on<LoadMoreJobberTrackerData>((event, emit) async {
      final current = state;
      if (current is! JobberTrackerLoaded ||
          current.isLoadingMore ||
          !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getJobberTrackerData(
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
