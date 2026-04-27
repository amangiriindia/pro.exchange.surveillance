import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/list_filter_utils.dart';
import '../../../../../core/widget/custom_action_button.dart';
import '../../../../../core/widget/page_filters_bar.dart';
import '../../../../../core/widget/page_header.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/bulk_order_entity.dart';
import '../bloc/bulk_order_bloc.dart';
import '../bloc/bulk_order_event.dart';
import '../bloc/bulk_order_state.dart';
import '../widgets/bulk_order_table.dart';
import '../widgets/bulk_order_details_view.dart';

class BulkOrderTrackerPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const BulkOrderTrackerPage({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BulkOrderBloc>()..add(LoadBulkOrders()),
      child: BulkOrderTrackerView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class BulkOrderTrackerView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const BulkOrderTrackerView({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  State<BulkOrderTrackerView> createState() => _BulkOrderTrackerViewState();
}

class _BulkOrderTrackerViewState extends State<BulkOrderTrackerView> {
  BulkOrderEntity? selectedItem;
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
    context.read<BulkOrderBloc>().add(LoadBulkOrders());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<BulkOrderBloc>().state;
    if (state is BulkOrderLoaded && state.hasMore && !state.isLoadingMore) {
      _fetchPending = true;
      context.read<BulkOrderBloc>().add(LoadMoreBulkOrders());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<BulkOrderEntity> _applyFilters(List<BulkOrderEntity> trades) {
    return trades.where((trade) {
      return ListFilterUtils.matchesQuickDate(trade.time, _selectedDate) &&
          ListFilterUtils.matchesExact(trade.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(trade.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<BulkOrderEntity> trades) {
    final symbols = trades.map((trade) => trade.symbol).toSet().toList();
    symbols.sort();
    return symbols;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedItem != null
          ? _buildDetailsView()
          : _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Bulk Order Tracker',
          subtitle:
              'Monitor users who exceeded configured trade quantity limits',
          onRefresh: _onRefresh,
          onSettingsTap: widget.onSettingsTap,
          onNotificationTap: widget.onNotificationTap,
          extraActions: [
            CustomActionButton(
              text: 'Export Report',
              onPressed: () {},
              width: 130,
              height: 48,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<BulkOrderBloc, BulkOrderState>(
            builder: (context, state) {
              if (state is BulkOrderLoading) {
                return const SizedBox.shrink();
              } else if (state is BulkOrderLoaded) {
                final filteredTrades = _applyFilters(state.trades);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    PageFiltersBar(
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
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BulkOrderTable(
                        trades: filteredTrades,
                        onViewSelected: (item) {
                          setState(() => selectedItem = item);
                        },
                        onNearBottom: _onNearBottom,
                        isLoadingMore: state.isLoadingMore,
                      ),
                    ),
                  ],
                );
              } else if (state is BulkOrderError) {
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
    );
  }

  Widget _buildDetailsView() {
    return Column(
      children: [
        PageHeader(
          title: 'Bulk Order Tracker',
          subtitle:
              'Monitor users who exceeded configured trade quantity limits',
          onRefresh: _onRefresh,
          onSettingsTap: widget.onSettingsTap,
          onNotificationTap: widget.onNotificationTap,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: BulkOrderDetailsView(
            alertId: selectedItem!.id,
            symbol: selectedItem!.symbol,
            onBack: () => setState(() => selectedItem = null),
          ),
        ),
      ],
    );
  }
}
