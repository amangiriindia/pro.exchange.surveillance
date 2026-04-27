import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/profit_cross_entity.dart';
import '../bloc/profit_cross_bloc.dart';
import '../widgets/profit_cross_table.dart';

class ProfitCrossPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const ProfitCrossPage({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfitCrossBloc>()..add(LoadProfitCrossData()),
      child: ProfitCrossView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class ProfitCrossView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const ProfitCrossView({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  State<ProfitCrossView> createState() => _ProfitCrossViewState();
}

class _ProfitCrossViewState extends State<ProfitCrossView> {
  bool _fetchPending = false;
  String? _selectedDate;
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
    context.read<ProfitCrossBloc>().add(LoadProfitCrossData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<ProfitCrossBloc>().state;
    if (state is ProfitCrossLoaded && state.hasMore && !state.isLoadingMore) {
      _fetchPending = true;
      context.read<ProfitCrossBloc>().add(LoadMoreProfitCrossData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<ProfitCrossEntity> _applyFilters(List<ProfitCrossEntity> data) {
    return data.where((item) {
      return ListFilterUtils.matchesQuickDate(item.orderDT, _selectedDate) &&
          ListFilterUtils.matchesExact(item.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<ProfitCrossEntity> data) {
    final symbols = data.map((item) => item.symbol).toSet().toList();
    symbols.sort();
    return symbols;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Profit % Cross',
            subtitle:
                'Monitor users who exceeded configured trade quantity limits',
            onRefresh: _onRefresh,
            onSettingsTap: widget.onSettingsTap,
            onNotificationTap: widget.onNotificationTap,
          ),
          Expanded(
            child: BlocBuilder<ProfitCrossBloc, ProfitCrossState>(
              buildWhen: (previous, current) =>
                  current is ProfitCrossLoading ||
                  current is ProfitCrossLoaded ||
                  current is ProfitCrossError,
              builder: (context, state) {
                if (state is ProfitCrossLoading) {
                  return const SizedBox.shrink();
                } else if (state is ProfitCrossLoaded) {
                  final filteredData = _applyFilters(state.data);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      PageFiltersBar(
                        selectedDate: _selectedDate,
                        selectedExchange: _selectedExchange,
                        selectedSymbol: _selectedSymbol,
                        symbolItems: _symbolItems(state.data),
                        onDateChanged: (value) =>
                            setState(() => _selectedDate = value),
                        onExchangeChanged: (value) =>
                            setState(() => _selectedExchange = value),
                        onSymbolChanged: (value) =>
                            setState(() => _selectedSymbol = value),
                        onReset: _resetFilters,
                        onApply: () => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ProfitCrossTable(
                          data: filteredData,
                          onNearBottom: _onNearBottom,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      ),
                    ],
                  );
                } else if (state is ProfitCrossError) {
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
