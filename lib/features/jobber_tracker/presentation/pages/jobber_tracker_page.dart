import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/jobber_tracker_bloc.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../widgets/jobber_tracker_table.dart';
import '../widgets/jobber_details_view.dart';

class JobberTrackerPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const JobberTrackerPage({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobberTrackerBloc>()..add(LoadJobberTrackerData()),
      child: JobberTrackerView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class JobberTrackerView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const JobberTrackerView({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  State<JobberTrackerView> createState() => _JobberTrackerViewState();
}

class _JobberTrackerViewState extends State<JobberTrackerView> {
  JobberTrackerEntity? selectedItem;
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
    context.read<JobberTrackerBloc>().add(LoadJobberTrackerData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<JobberTrackerBloc>().state;
    if (state is JobberTrackerLoaded && state.hasMore && !state.isLoadingMore) {
      _fetchPending = true;
      context.read<JobberTrackerBloc>().add(LoadMoreJobberTrackerData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<JobberTrackerEntity> _applyFilters(List<JobberTrackerEntity> data) {
    return data.where((item) {
      return ListFilterUtils.matchesQuickDate(item.time, _selectedDate) &&
          ListFilterUtils.matchesExact(item.exchange, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<JobberTrackerEntity> data) {
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
          ? JobberDetailsView(
              alertId: selectedItem!.id,
              uName: selectedItem!.uName,
              onBack: () => setState(() => selectedItem = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Jobber Tracker',
                  subtitle:
                      'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: _onRefresh,
                  onSettingsTap: widget.onSettingsTap,
                  onNotificationTap: widget.onNotificationTap,
                ),
                Expanded(
                  child: BlocBuilder<JobberTrackerBloc, JobberTrackerState>(
                    builder: (context, state) {
                      if (state is JobberTrackerLoading) {
                        return const SizedBox.shrink();
                      } else if (state is JobberTrackerLoaded) {
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
                              child: JobberTrackerTable(
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
                      } else if (state is JobberTrackerError) {
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
