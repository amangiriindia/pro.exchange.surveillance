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

// States
abstract class SameDeviceTrackerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameDeviceTrackerInitial extends SameDeviceTrackerState {}

class SameDeviceTrackerLoading extends SameDeviceTrackerState {}

class SameDeviceTrackerLoaded extends SameDeviceTrackerState {
  final List<SameDeviceEntity> data;
  SameDeviceTrackerLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class SameDeviceTrackerError extends SameDeviceTrackerState {
  final String message;
  SameDeviceTrackerError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SameDeviceTrackerBloc extends Bloc<SameDeviceTrackerEvent, SameDeviceTrackerState> {
  final GetSameDeviceData getSameDeviceData;

  SameDeviceTrackerBloc({required this.getSameDeviceData}) : super(SameDeviceTrackerInitial()) {
    on<LoadSameDeviceData>((event, emit) async {
      emit(SameDeviceTrackerLoading());
      final result = await getSameDeviceData();
      result.fold(
        (failure) => emit(SameDeviceTrackerError('Server Failure')),
        (data) => emit(SameDeviceTrackerLoaded(data)),
      );
    });
  }
}
