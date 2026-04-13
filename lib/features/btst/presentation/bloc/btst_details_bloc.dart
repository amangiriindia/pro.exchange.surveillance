import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/btst_detail_entity.dart';
import '../../domain/usecases/get_btst_details.dart';

// Events
abstract class BTSTDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBTSTDetails extends BTSTDetailsEvent {
  final String uName;
  LoadBTSTDetails(this.uName);
  @override
  List<Object?> get props => [uName];
}

// States
abstract class BTSTDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BTSTDetailsInitial extends BTSTDetailsState {}

class BTSTDetailsLoading extends BTSTDetailsState {}

class BTSTDetailsLoaded extends BTSTDetailsState {
  final List<BTSTDetailEntity> details;
  BTSTDetailsLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class BTSTDetailsError extends BTSTDetailsState {
  final String message;
  BTSTDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class BTSTDetailsBloc extends Bloc<BTSTDetailsEvent, BTSTDetailsState> {
  final GetBTSTDetails getBTSTDetails;

  BTSTDetailsBloc({required this.getBTSTDetails}) : super(BTSTDetailsInitial()) {
    on<LoadBTSTDetails>((event, emit) async {
      emit(BTSTDetailsLoading());
      final result = await getBTSTDetails(event.uName);
      result.fold(
        (failure) => emit(BTSTDetailsError('Server Failure')),
        (details) => emit(BTSTDetailsLoaded(details)),
      );
    });
  }
}
