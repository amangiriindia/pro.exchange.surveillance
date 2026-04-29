import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../core/widget/common_dilog_box.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/same_ip_entity.dart';
import '../bloc/same_ip_tracker_bloc.dart';
import '../widgets/same_ip_table.dart';
import '../widgets/same_ip_details_view.dart';

class SameIPPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const SameIPPage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SameIPTrackerBloc>()..add(LoadSameIPData()),
      child: SameIPView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class SameIPView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const SameIPView({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<SameIPView> createState() => _SameIPViewState();
}

class _SameIPViewState extends State<SameIPView> {
  bool _fetchPending = false;
  String? _selectedDate;
  String? _selectedSymbol;

  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      _selectedSymbol = null;
    });
  }

  void _onRefresh() {
    _fetchPending = false;
    context.read<SameIPTrackerBloc>().add(LoadSameIPData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<SameIPTrackerBloc>().state;
    if (state is SameIPTrackerLoaded && state.hasMore && !state.isLoadingMore) {
      _fetchPending = true;
      context.read<SameIPTrackerBloc>().add(LoadMoreSameIPData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<SameIPEntity> _applyFilters(List<SameIPEntity> data) {
    return data.where((item) {
      return ListFilterUtils.matchesQuickDate(item.time, _selectedDate) &&
          ListFilterUtils.matchesContains(item.uName, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<SameIPEntity> data) {
    final users = data.map((item) => item.uName).toSet().toList();
    users.sort();
    return users;
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
            title: 'Same IP Tracker',
            subtitle:
                'Monitor users who exceeded configured trade quantity limits',
            onRefresh: _onRefresh,
            onSettingsTap: widget.onSettingsTap,
            onNotificationTap: widget.onNotificationTap,
          ),
          Expanded(
            child: BlocBuilder<SameIPTrackerBloc, SameIPTrackerState>(
              builder: (context, state) {
                if (state is SameIPTrackerLoading) {
                  return const SizedBox.shrink();
                } else if (state is SameIPTrackerLoaded) {
                  final filteredData = _applyFilters(state.data);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      PageFiltersBar(
                        selectedDate: _selectedDate,
                        selectedSymbol: _selectedSymbol,
                        symbolItems: _symbolItems(state.data),
                        showExchangeFilter: false,
                        onDateChanged: (value) =>
                            setState(() => _selectedDate = value),
                        onSymbolChanged: (value) =>
                            setState(() => _selectedSymbol = value),
                        onReset: _resetFilters,
                        onApply: () => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SameIPTable(
                          data: filteredData,
                          resolvedCityByIp: state.resolvedCityByIp,
                          onViewSelected: (item) {
                            _showDetailsDialog(context, item);
                          },
                          onNearBottom: _onNearBottom,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      ),
                    ],
                  );
                } else if (state is SameIPTrackerError) {
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

  void _showDetailsDialog(BuildContext context, SameIPEntity item) {
    CommonDialog.show(
      context: context,
      title: 'Same IP Details - ${item.uName}',
      width: 1200,
      height: 600,
      showButtons: false,
      scrollable: false,
      backgroundColor: Colors.white,
      headerColor: const Color(0xFF424B5A),
      content: SameIPDetailsView(
        alertId: item.id,
        clusterId: item.uName,
        onBack: () {},
      ),
    );
  }
}
