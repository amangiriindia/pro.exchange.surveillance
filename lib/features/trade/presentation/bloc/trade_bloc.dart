import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/ip_city_lookup.dart';
import 'trade_event.dart';
import 'trade_state.dart';
import '../../domain/usecases/get_trade_count.dart';
import '../../domain/usecases/get_trades.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final GetTrades getTrades;
  final GetTradeCount getTradeCount;
  static const int _pageSize = 100;

  int _reloadGeneration = 0;

  TradeBloc({required this.getTrades, required this.getTradeCount})
    : super(TradeInitial()) {
    on<LoadTrades>(_onLoadTrades);
    on<LoadMoreTrades>(_onLoadMoreTrades);
  }

  Future<void> _onLoadTrades(LoadTrades event, Emitter<TradeState> emit) async {
    _reloadGeneration++;
    final reloadGen = _reloadGeneration;

    emit(TradeLoading());
    final tradesResult = await getTrades(page: 1, sizePerPage: _pageSize);
    final countResult = await getTradeCount();

    await tradesResult.fold(
      (failure) async {
        emit(TradeError(message: failure));
      },
      (paginated) async {
        int todayTradeCount = 0;
        countResult.fold(
          (_) {},
          (count) => todayTradeCount = count.totalTrades,
        );

        emit(
          TradeLoaded(
            trades: paginated.trades,
            totalRecords: paginated.totalRecords,
            todayTradeCount: todayTradeCount,
            totalPages: paginated.totalPages,
            currentPage: paginated.currentPage,
            hasMore: paginated.currentPage < paginated.totalPages,
            resolvedCityByIp: const {},
          ),
        );

        final cityMap = await IpCityLookup.instance.prefetchBatch(
          paginated.trades.map((t) => (ip: t.ipAddress, backendCity: t.city)),
        );

        if (reloadGen != _reloadGeneration) return;
        final s = state;
        if (s is! TradeLoaded) return;
        emit(s.copyWith(resolvedCityByIp: cityMap));
      },
    );
  }

  Future<void> _onLoadMoreTrades(
    LoadMoreTrades event,
    Emitter<TradeState> emit,
  ) async {
    final current = state;
    if (current is! TradeLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await getTrades(page: nextPage, sizePerPage: _pageSize);

    await result.fold(
      (_) async {
        emit(current.copyWith(isLoadingMore: false));
      },
      (paginated) async {
        final mergedTrades = [...current.trades, ...paginated.trades];
        final expectedLen = mergedTrades.length;
        final expectedPage = paginated.currentPage;

        emit(
          TradeLoaded(
            trades: mergedTrades,
            totalRecords: paginated.totalRecords,
            todayTradeCount: current.todayTradeCount,
            totalPages: paginated.totalPages,
            currentPage: paginated.currentPage,
            isLoadingMore: false,
            hasMore: paginated.currentPage < paginated.totalPages,
            resolvedCityByIp: current.resolvedCityByIp,
          ),
        );

        final patch = await IpCityLookup.instance.prefetchBatch(
          paginated.trades.map((t) => (ip: t.ipAddress, backendCity: t.city)),
        );

        final s = state;
        if (s is! TradeLoaded) return;
        if (s.currentPage != expectedPage || s.trades.length != expectedLen) {
          return;
        }
        emit(s.copyWith(resolvedCityByIp: {...s.resolvedCityByIp, ...patch}));
      },
    );
  }
}
