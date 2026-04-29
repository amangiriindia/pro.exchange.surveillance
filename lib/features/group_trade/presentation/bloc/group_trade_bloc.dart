import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/ip_city_lookup.dart';
import 'group_trade_event.dart';
import 'group_trade_state.dart';
import '../../domain/usecases/get_group_trades.dart';

class GroupTradeBloc extends Bloc<GroupTradeEvent, GroupTradeState> {
  final GetGroupTrades getGroupTrades;
  static const int _pageSize = 100;

  int _reloadGeneration = 0;

  GroupTradeBloc({required this.getGroupTrades}) : super(GroupTradeInitial()) {
    on<LoadGroupTrades>(_onLoadGroupTrades);
    on<LoadMoreGroupTrades>(_onLoadMoreGroupTrades);
  }

  Future<void> _onLoadGroupTrades(
    LoadGroupTrades event,
    Emitter<GroupTradeState> emit,
  ) async {
    _reloadGeneration++;
    final reloadGen = _reloadGeneration;

    emit(GroupTradeLoading());
    final result = await getGroupTrades(page: 1, sizePerPage: _pageSize);
    await result.fold(
      (failure) async => emit(GroupTradeError(message: failure)),
      (paginated) async {
        emit(
          GroupTradeLoaded(
            items: paginated.items,
            totalRecords: paginated.totalRecords,
            totalPages: paginated.totalPages,
            currentPage: paginated.currentPage,
            hasMore: paginated.currentPage < paginated.totalPages,
            resolvedCityByIp: const {},
          ),
        );

        final cityMap = await IpCityLookup.instance.prefetchBatch(
          paginated.items.map((t) => (ip: t.ipAddress, backendCity: t.city)),
        );

        if (reloadGen != _reloadGeneration) return;
        final s = state;
        if (s is! GroupTradeLoaded) return;
        emit(s.copyWith(resolvedCityByIp: cityMap));
      },
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
    await result.fold(
      (failure) async => emit(current.copyWith(isLoadingMore: false)),
      (paginated) async {
        final mergedItems = [...current.items, ...paginated.items];
        final expectedLen = mergedItems.length;
        final expectedPage = paginated.currentPage;

        emit(
          current.copyWith(
            items: mergedItems,
            totalRecords: paginated.totalRecords,
            totalPages: paginated.totalPages,
            currentPage: paginated.currentPage,
            isLoadingMore: false,
            hasMore: paginated.currentPage < paginated.totalPages,
            resolvedCityByIp: current.resolvedCityByIp,
          ),
        );

        final patch = await IpCityLookup.instance.prefetchBatch(
          paginated.items.map((t) => (ip: t.ipAddress, backendCity: t.city)),
        );

        final s = state;
        if (s is! GroupTradeLoaded) return;
        if (s.currentPage != expectedPage || s.items.length != expectedLen) {
          return;
        }
        emit(s.copyWith(resolvedCityByIp: {...s.resolvedCityByIp, ...patch}));
      },
    );
  }
}
