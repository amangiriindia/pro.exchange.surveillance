import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/same_ip_detail_entity.dart';
import '../../domain/usecases/get_same_ip_details.dart';

// Events
abstract class SameIPDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSameIPDetails extends SameIPDetailsEvent {
  final int alertId;
  LoadSameIPDetails(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

// States
abstract class SameIPDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SameIPDetailsInitial extends SameIPDetailsState {}

class SameIPDetailsLoading extends SameIPDetailsState {}

class SameIPDetailsLoaded extends SameIPDetailsState {
  final List<SameIPDetailEntity> details;
  SameIPDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class SameIPDetailsError extends SameIPDetailsState {
  final String message;
  SameIPDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SameIPDetailsBloc extends Bloc<SameIPDetailsEvent, SameIPDetailsState> {
  final GetSameIPDetails getSameIPDetails;

  SameIPDetailsBloc({required this.getSameIPDetails})
    : super(SameIPDetailsInitial()) {
    on<LoadSameIPDetails>((event, emit) async {
      emit(SameIPDetailsLoading());
      final result = await getSameIPDetails(event.alertId);
      result.fold(
        (failure) => emit(SameIPDetailsError('Server Failure')),
        (details) => emit(SameIPDetailsLoaded(details)),
      );
    });
  }
}
