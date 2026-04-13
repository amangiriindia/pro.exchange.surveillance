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

// States
abstract class SameIPTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameIPTrackerInitial extends SameIPTrackerState {}

class SameIPTrackerLoading extends SameIPTrackerState {}

class SameIPTrackerLoaded extends SameIPTrackerState {
  final List<SameIPEntity> data;
  SameIPTrackerLoaded(this.data);
  @override
  List<Object?> get props => [data];
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

  SameIPTrackerBloc({required this.getSameIPData}) : super(SameIPTrackerInitial()) {
    on<LoadSameIPData>((event, emit) async {
      emit(SameIPTrackerLoading());
      final result = await getSameIPData();
      result.fold(
        (failure) => emit(SameIPTrackerError('Server Failure')),
        (data) => emit(SameIPTrackerLoaded(data)),
      );
    });
  }
}
