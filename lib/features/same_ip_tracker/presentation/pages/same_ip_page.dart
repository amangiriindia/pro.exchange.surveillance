import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../core/widget/common_dilog_box.dart';
import '../../../../injection_container.dart';
import '../bloc/same_ip_tracker_bloc.dart';
import '../widgets/same_ip_table.dart';
import '../widgets/same_ip_details_view.dart';

class SameIPPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const SameIPPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SameIPTrackerBloc>()..add(LoadSameIPData()),
      child: SameIPView(onSettingsTap: onSettingsTap),
    );
  }
}

class SameIPView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const SameIPView({super.key, this.onSettingsTap});

  @override
  State<SameIPView> createState() => _SameIPViewState();
}

class _SameIPViewState extends State<SameIPView> {
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
            subtitle: 'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () => context.read<SameIPTrackerBloc>().add(LoadSameIPData()),
            onSettingsTap: widget.onSettingsTap,
          ),
          const SizedBox(height: 12),
          const PageFiltersBar(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SameIPTrackerBloc, SameIPTrackerState>(
              builder: (context, state) {
                if (state is SameIPTrackerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SameIPTrackerLoaded) {
                  return SameIPTable(
                    data: state.data,
                    onViewSelected: (clusterId) {
                      _showDetailsDialog(context, clusterId);
                    },
                  );
                } else if (state is SameIPTrackerError) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
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

  void _showDetailsDialog(BuildContext context, String clusterId) {
    CommonDialog.show(
      context: context,
      title: 'Same IP Details - $clusterId',
      width: 1200,
      height: 600,
      showButtons: false,
      backgroundColor: Colors.white,
      headerColor: const Color(0xFF424B5A),
      content: SameIPDetailsView(
        clusterId: clusterId,
        onBack: () {}, // Handled by dialog close
      ),
    );
  }
}
