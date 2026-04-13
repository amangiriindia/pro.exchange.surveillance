import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/btst_entity.dart';
import '../../domain/usecases/get_btst_data.dart';

// Events
abstract class BTSTEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBTSTData extends BTSTEvent {}

// States
abstract class BTSTState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BTSTInitial extends BTSTState {}

class BTSTLoading extends BTSTState {}

class BTSTLoaded extends BTSTState {
  final List<BTSTEntity> data;
  BTSTLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class BTSTError extends BTSTState {
  final String message;
  BTSTError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class BTSTBloc extends Bloc<BTSTEvent, BTSTState> {
  final GetBTSTData getBTSTData;

  BTSTBloc({required this.getBTSTData}) : super(BTSTInitial()) {
    on<LoadBTSTData>((event, emit) async {
      emit(BTSTLoading());
      final result = await getBTSTData();
      result.fold(
        (failure) => emit(BTSTError('Server Failure')),
        (data) => emit(BTSTLoaded(data)),
      );
    });
  }
}
