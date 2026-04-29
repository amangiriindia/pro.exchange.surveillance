import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/btst_entity.dart';
import '../../domain/usecases/get_btst_data.dart';

abstract class BTSTEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBTSTData extends BTSTEvent {}

class LoadMoreBTSTData extends BTSTEvent {}

abstract class BTSTState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BTSTInitial extends BTSTState {}

class BTSTLoading extends BTSTState {}

class BTSTLoaded extends BTSTState {
  final List<BTSTEntity> data;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  BTSTLoaded(
    this.data, {
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  BTSTLoaded copyWith({
    List<BTSTEntity>? data,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return BTSTLoaded(
      data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [data, currentPage, isLoadingMore, hasMore];
}

class BTSTError extends BTSTState {
  final String message;
  BTSTError(this.message);
  @override
  List<Object?> get props => [message];
}

class BTSTBloc extends Bloc<BTSTEvent, BTSTState> {
  final GetBTSTData getBTSTData;
  static const int _pageSize = 20;

  BTSTBloc({required this.getBTSTData}) : super(BTSTInitial()) {
    on<LoadBTSTData>((event, emit) async {
      emit(BTSTLoading());
      final result = await getBTSTData(page: 1, sizePerPage: _pageSize);
      result.fold(
        (failure) => emit(BTSTError('Server Failure')),
        (data) => emit(
          BTSTLoaded(data, currentPage: 1, hasMore: data.length >= _pageSize),
        ),
      );
    });

    on<LoadMoreBTSTData>((event, emit) async {
      final current = state;
      if (current is! BTSTLoaded || current.isLoadingMore || !current.hasMore) {
        return;
      }

      emit(current.copyWith(isLoadingMore: true));
      final nextPage = current.currentPage + 1;
      final result = await getBTSTData(page: nextPage, sizePerPage: _pageSize);
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
