import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/group_trade_entity.dart';
import '../bloc/group_trade_bloc.dart';
import '../bloc/group_trade_event.dart';
import '../bloc/group_trade_state.dart';
import '../widgets/group_trade_table.dart';
import '../widgets/group_trade_details_view.dart';

class GroupTradePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const GroupTradePage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupTradeBloc>()..add(const LoadGroupTrades()),
      child: GroupTradeView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class GroupTradeView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const GroupTradeView({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<GroupTradeView> createState() => _GroupTradeViewState();
}

class _GroupTradeViewState extends State<GroupTradeView> {
  GroupTradeEntity? selectedItem;
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
    context.read<GroupTradeBloc>().add(const LoadGroupTrades());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final s = context.read<GroupTradeBloc>().state;
    if (s is GroupTradeLoaded && s.hasMore && !s.isLoadingMore) {
      _fetchPending = true;
      context.read<GroupTradeBloc>().add(const LoadMoreGroupTrades());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<GroupTradeEntity> _applyFilters(List<GroupTradeEntity> items) {
    return items.where((item) {
      return ListFilterUtils.matchesQuickDate(item.time, _selectedDate) &&
          ListFilterUtils.matchesExact(item.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<GroupTradeEntity> items) {
    final symbols = items.map((item) => item.symbol).toSet().toList();
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
          title: 'Group Trade',
          subtitle:
              'Monitor users who exceeded configured trade quantity limits',
          onRefresh: _onRefresh,
          onSettingsTap: widget.onSettingsTap,
          onNotificationTap: widget.onNotificationTap,
        ),
        Expanded(
          child: BlocBuilder<GroupTradeBloc, GroupTradeState>(
            builder: (context, state) {
              if (state is GroupTradeLoading) {
                return const SizedBox.shrink();
              }
              if (state is GroupTradeLoaded) {
                final filteredItems = _applyFilters(state.items);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    PageFiltersBar(
                      selectedDate: _selectedDate,
                      selectedExchange: _selectedExchange,
                      selectedSymbol: _selectedSymbol,
                      symbolItems: _symbolItems(state.items),
                      onDateChanged: (value) =>
                          setState(() => _selectedDate = value),
                      onExchangeChanged: (value) =>
                          setState(() => _selectedExchange = value),
                      onSymbolChanged: (value) =>
                          setState(() => _selectedSymbol = value),
                      onReset: _resetFilters,
                      onApply: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _RecordCounter(
                      loaded: filteredItems.length,
                      total: state.totalRecords,
                      hasMore: state.hasMore,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GroupTradeTable(
                        trades: filteredItems,
                        onViewSelected: (item) {
                          setState(() => selectedItem = item);
                        },
                        onNearBottom: _onNearBottom,
                        isLoadingMore: state.isLoadingMore,
                      ),
                    ),
                  ],
                );
              }
              if (state is GroupTradeError) {
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
          title: 'Group Trade',
          subtitle:
              'Monitor users who exceeded configured trade quantity limits',
          onRefresh: _onRefresh,
          onSettingsTap: widget.onSettingsTap,
          onNotificationTap: widget.onNotificationTap,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GroupTradeDetailsView(
            alertId: selectedItem!.id,
            symbol: selectedItem!.symbol,
            onBack: () => setState(() => selectedItem = null),
          ),
        ),
      ],
    );
  }
}

class _RecordCounter extends StatelessWidget {
  final int loaded;
  final int total;
  final bool hasMore;

  const _RecordCounter({
    required this.loaded,
    required this.total,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    return Text(
      hasMore
          ? 'Showing $loaded of $total records  •  Scroll down to load more'
          : 'Showing all $loaded records',
      style: GoogleFonts.openSans(
        fontSize: 12,
        color: isDark
            ? DarkThemeColors.supportiveTextColor
            : LightThemeColors.supportiveTextColor,
      ),
    );
  }
}
