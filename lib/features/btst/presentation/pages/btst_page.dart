import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/btst_entity.dart';
import '../bloc/btst_bloc.dart';
import '../widgets/btst_table.dart';
import '../widgets/btst_details_view.dart';

class BTSTPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const BTSTPage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BTSTBloc>()..add(LoadBTSTData()),
      child: BTSTView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class BTSTView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const BTSTView({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<BTSTView> createState() => _BTSTViewState();
}

class _BTSTViewState extends State<BTSTView> {
  BTSTEntity? selectedItem;
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
    context.read<BTSTBloc>().add(LoadBTSTData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<BTSTBloc>().state;
    if (state is BTSTLoaded && state.hasMore && !state.isLoadingMore) {
      _fetchPending = true;
      context.read<BTSTBloc>().add(LoadMoreBTSTData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<BTSTEntity> _applyFilters(List<BTSTEntity> data) {
    return data.where((item) {
      return ListFilterUtils.matchesQuickDate(item.inTime, _selectedDate) &&
          ListFilterUtils.matchesExact(item.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<BTSTEntity> data) {
    final symbols = data.map((item) => item.symbol).toSet().toList();
    symbols.sort();
    return symbols;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedItem != null
          ? BTSTDetailsView(
              alertId: selectedItem!.id,
              uName: selectedItem!.uName,
              onBack: () => setState(() => selectedItem = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'BTST/STBT',
                  subtitle:
                      'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: _onRefresh,
                  onSettingsTap: widget.onSettingsTap,
                  onNotificationTap: widget.onNotificationTap,
                ),
                Expanded(
                  child: BlocBuilder<BTSTBloc, BTSTState>(
                    builder: (context, state) {
                      if (state is BTSTLoading) {
                        return const SizedBox.shrink();
                      } else if (state is BTSTLoaded) {
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
                              child: BTSTTable(
                                data: filteredData,
                                onViewSelected: (item) {
                                  setState(() => selectedItem = item);
                                },
                                onNearBottom: _onNearBottom,
                                isLoadingMore: state.isLoadingMore,
                              ),
                            ),
                          ],
                        );
                      } else if (state is BTSTError) {
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
