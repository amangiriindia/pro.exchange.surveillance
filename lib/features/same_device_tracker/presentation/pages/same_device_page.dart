import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/same_device_entity.dart';
import '../bloc/same_device_tracker_bloc.dart';
import '../widgets/same_device_table.dart';
import '../widgets/same_device_details_view.dart';

class SameDevicePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const SameDevicePage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SameDeviceTrackerBloc>()..add(LoadSameDeviceData()),
      child: SameDeviceView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class SameDeviceView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const SameDeviceView({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<SameDeviceView> createState() => _SameDeviceViewState();
}

class _SameDeviceViewState extends State<SameDeviceView> {
  SameDeviceEntity? selectedItem;
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
    context.read<SameDeviceTrackerBloc>().add(LoadSameDeviceData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<SameDeviceTrackerBloc>().state;
    if (state is SameDeviceTrackerLoaded &&
        state.hasMore &&
        !state.isLoadingMore) {
      _fetchPending = true;
      context.read<SameDeviceTrackerBloc>().add(LoadMoreSameDeviceData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<SameDeviceEntity> _applyFilters(List<SameDeviceEntity> data) {
    return data.where((item) {
      return ListFilterUtils.matchesQuickDate(item.time, _selectedDate) &&
          ListFilterUtils.matchesContains(item.uName, _selectedSymbol);
    }).toList();
  }

  List<String> _symbolItems(List<SameDeviceEntity> data) {
    final users = data.map((item) => item.uName).toSet().toList();
    users.sort();
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedItem != null
          ? SameDeviceDetailsView(
              alertId: selectedItem!.id,
              clusterId: selectedItem!.uName,
              onBack: () => setState(() => selectedItem = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Same Device Tracker',
                  subtitle:
                      'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: _onRefresh,
                  onSettingsTap: widget.onSettingsTap,
                  onNotificationTap: widget.onNotificationTap,
                ),
                Expanded(
                  child:
                      BlocBuilder<
                        SameDeviceTrackerBloc,
                        SameDeviceTrackerState
                      >(
                        builder: (context, state) {
                          if (state is SameDeviceTrackerLoading) {
                            return const SizedBox.shrink();
                          } else if (state is SameDeviceTrackerLoaded) {
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
                                  child: SameDeviceTable(
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
                          } else if (state is SameDeviceTrackerError) {
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
