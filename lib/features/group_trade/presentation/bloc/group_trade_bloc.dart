import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_trade_event.dart';
import 'group_trade_state.dart';
import '../../domain/usecases/get_group_trades.dart';

class GroupTradeBloc extends Bloc<GroupTradeEvent, GroupTradeState> {
  final GetGroupTrades getGroupTrades;
  static const int _pageSize = 100;

  GroupTradeBloc({required this.getGroupTrades}) : super(GroupTradeInitial()) {
    on<LoadGroupTrades>(_onLoadGroupTrades);
    on<LoadMoreGroupTrades>(_onLoadMoreGroupTrades);
  }

  Future<void> _onLoadGroupTrades(
    LoadGroupTrades event,
    Emitter<GroupTradeState> emit,
  ) async {
    emit(GroupTradeLoading());
    final result = await getGroupTrades(page: 1, sizePerPage: _pageSize);
    result.fold(
      (failure) => emit(GroupTradeError(message: failure)),
      (paginated) => emit(GroupTradeLoaded(
        items: paginated.items,
        totalRecords: paginated.totalRecords,
        totalPages: paginated.totalPages,
        currentPage: paginated.currentPage,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }

  Future<void> _onLoadMoreGroupTrades(
    LoadMoreGroupTrades event,
    Emitter<GroupTradeState> emit,
  ) async {
    final current = state;
    if (current is! GroupTradeLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await getGroupTrades(page: nextPage, sizePerPage: _pageSize);
    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (paginated) => emit(current.copyWith(
        items: [...current.items, ...paginated.items],
        totalRecords: paginated.totalRecords,
        totalPages: paginated.totalPages,
        currentPage: paginated.currentPage,
        isLoadingMore: false,
        hasMore: paginated.currentPage < paginated.totalPages,
      )),
    );
  }
}
