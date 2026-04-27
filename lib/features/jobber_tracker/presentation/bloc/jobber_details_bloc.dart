import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/jobber_detail_entity.dart';
import '../../domain/usecases/get_jobber_details.dart';

// Events
abstract class JobberDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadJobberDetails extends JobberDetailsEvent {
  final int alertId;
  LoadJobberDetails(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

// States
abstract class JobberDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobberDetailsInitial extends JobberDetailsState {}

class JobberDetailsLoading extends JobberDetailsState {}

class JobberDetailsLoaded extends JobberDetailsState {
  final List<JobberDetailEntity> details;
  JobberDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class JobberDetailsError extends JobberDetailsState {
  final String message;
  JobberDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class JobberDetailsBloc extends Bloc<JobberDetailsEvent, JobberDetailsState> {
  final GetJobberDetails getJobberDetails;

  JobberDetailsBloc({required this.getJobberDetails})
    : super(JobberDetailsInitial()) {
    on<LoadJobberDetails>((event, emit) async {
      emit(JobberDetailsLoading());
      final result = await getJobberDetails(event.alertId);
      result.fold(
        (failure) => emit(JobberDetailsError('Server Failure')),
        (details) => emit(JobberDetailsLoaded(details)),
      );
    });
  }
}
