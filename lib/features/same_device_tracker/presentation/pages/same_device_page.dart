import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/same_device_tracker_bloc.dart';
import '../widgets/same_device_table.dart';
import '../widgets/same_device_details_view.dart';

class SameDevicePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const SameDevicePage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SameDeviceTrackerBloc>()..add(LoadSameDeviceData()),
      child: SameDeviceView(onSettingsTap: onSettingsTap),
    );
  }
}

class SameDeviceView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const SameDeviceView({super.key, this.onSettingsTap});

  @override
  State<SameDeviceView> createState() => _SameDeviceViewState();
}

class _SameDeviceViewState extends State<SameDeviceView> {
  String? selectedCluster;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedCluster != null
          ? SameDeviceDetailsView(
              clusterId: selectedCluster!,
              onBack: () => setState(() => selectedCluster = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Same Device Tracker',
                  subtitle: 'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: () =>
                      context.read<SameDeviceTrackerBloc>().add(LoadSameDeviceData()),
                  onSettingsTap: widget.onSettingsTap,
                ),
                const SizedBox(height: 12),
                const PageFiltersBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<SameDeviceTrackerBloc, SameDeviceTrackerState>(
                    builder: (context, state) {
                      if (state is SameDeviceTrackerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SameDeviceTrackerLoaded) {
                        return SameDeviceTable(
                          data: state.data,
                          onViewSelected: (clusterId) {
                            setState(() => selectedCluster = clusterId);
                          },
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
