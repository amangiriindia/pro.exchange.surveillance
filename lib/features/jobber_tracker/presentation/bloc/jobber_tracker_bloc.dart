import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../domain/usecases/get_jobber_tracker_data.dart';

// Events
abstract class JobberTrackerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadJobberTrackerData extends JobberTrackerEvent {}

// States
abstract class JobberTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobberTrackerInitial extends JobberTrackerState {}

class JobberTrackerLoading extends JobberTrackerState {}

class JobberTrackerLoaded extends JobberTrackerState {
  final List<JobberTrackerEntity> data;
  JobberTrackerLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class JobberTrackerError extends JobberTrackerState {
  final String message;
  JobberTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class JobberTrackerBloc extends Bloc<JobberTrackerEvent, JobberTrackerState> {
  final GetJobberTrackerData getJobberTrackerData;

  JobberTrackerBloc({required this.getJobberTrackerData}) : super(JobberTrackerInitial()) {
    on<LoadJobberTrackerData>((event, emit) async {
      emit(JobberTrackerLoading());
      final result = await getJobberTrackerData();
      result.fold(
        (failure) => emit(JobberTrackerError('Server Failure')),
        (data) => emit(JobberTrackerLoaded(data)),
      );
    });
  }
}
