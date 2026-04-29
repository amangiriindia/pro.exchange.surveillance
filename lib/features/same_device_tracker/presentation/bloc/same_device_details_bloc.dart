import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/same_device_detail_entity.dart';
import '../../domain/usecases/get_same_device_details.dart';

abstract class SameDeviceDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSameDeviceDetails extends SameDeviceDetailsEvent {
  final int alertId;
  LoadSameDeviceDetails(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

abstract class SameDeviceDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameDeviceDetailsInitial extends SameDeviceDetailsState {}

class SameDeviceDetailsLoading extends SameDeviceDetailsState {}

class SameDeviceDetailsLoaded extends SameDeviceDetailsState {
  final List<SameDeviceDetailEntity> details;
  SameDeviceDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class SameDeviceDetailsError extends SameDeviceDetailsState {
  final String message;
  SameDeviceDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SameDeviceDetailsBloc
    extends Bloc<SameDeviceDetailsEvent, SameDeviceDetailsState> {
  final GetSameDeviceDetails getSameDeviceDetails;

  SameDeviceDetailsBloc({required this.getSameDeviceDetails})
    : super(SameDeviceDetailsInitial()) {
    on<LoadSameDeviceDetails>((event, emit) async {
      emit(SameDeviceDetailsLoading());
      final result = await getSameDeviceDetails(event.alertId);
      result.fold(
        (failure) => emit(SameDeviceDetailsError('Server Failure')),
        (details) => emit(SameDeviceDetailsLoaded(details)),
      );
    });
  }
}
