import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../injection_container.dart';
import '../../../../core/widget/page_header.dart';
import '../../domain/entities/trade_entity.dart';
import '../bloc/trade_bloc.dart';
import '../bloc/trade_event.dart';
import '../bloc/trade_state.dart';
import '../widgets/trade_table.dart';

class TradePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const TradePage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TradeBloc>()..add(const LoadTrades()),
      child: TradeView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class TradeView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const TradeView({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<TradeView> createState() => _TradeViewState();
}

class _TradeViewState extends State<TradeView> {
  bool _fetchPending = false;
  String? _selectedDate;
  DateTimeRange? _customDateRange;
  String? _selectedExchange;
  String? _selectedSymbol;

  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      _selectedExchange = null;
      _selectedSymbol = null;
    });
  }

  void _onRefresh() {
    _fetchPending = false;
    context.read<TradeBloc>().add(const LoadTrades());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final s = context.read<TradeBloc>().state;
    if (s is TradeLoaded && s.hasMore && !s.isLoadingMore) {
      _fetchPending = true;
      context.read<TradeBloc>().add(const LoadMoreTrades());

      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<TradeEntity> _applyFilters(List<TradeEntity> trades) {
    return trades.where((trade) {
      return ListFilterUtils.matchesDateRangeOrQuick(
            trade.orderDateTime,
            _selectedDate,
            _customDateRange,
          ) &&
          ListFilterUtils.matchesExact(trade.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(trade.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<TradeEntity> trades) {
    final symbols = trades.map((trade) => trade.symbol).toSet().toList();
    symbols.sort();
    return symbols;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Trade',
            subtitle:
                'Monitor users who exceeded configured trade quantity limits',
            onRefresh: _onRefresh,
            onSettingsTap: widget.onSettingsTap,
            onNotificationTap: widget.onNotificationTap,
            hasFilterBelow: true,
          ),
          Expanded(
            child: BlocBuilder<TradeBloc, TradeState>(
              builder: (context, state) {
                if (state is TradeLoading) {
                  return const SizedBox.shrink();
                }
                if (state is TradeLoaded) {
                  final filteredTrades = _applyFilters(state.trades);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageFiltersBar(
                        itemCount: state.todayTradeCount,
                        countLabel: 'Today trade',
                        selectedDate: _selectedDate,
                        selectedExchange: _selectedExchange,
                        selectedSymbol: _selectedSymbol,
                        symbolItems: _symbolItems(state.trades),
                        onDateChanged: (value) =>
                            setState(() => _selectedDate = value),
                        onExchangeChanged: (value) =>
                            setState(() => _selectedExchange = value),
                        onSymbolChanged: (value) =>
                            setState(() => _selectedSymbol = value),
                        onReset: _resetFilters,
                        onApply: () => setState(() {}),
                        attachedToHeader: true,
                        customDateRange: _customDateRange,
                        onCustomDateRangeChanged: (range) =>
                            setState(() => _customDateRange = range),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TradeTable(
                          trades: filteredTrades,
                          resolvedCityByIp: state.resolvedCityByIp,
                          onNearBottom: _onNearBottom,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      ),
                    ],
                  );
                }
                if (state is TradeError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
