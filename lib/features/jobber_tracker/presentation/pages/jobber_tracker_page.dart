import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/jobber_tracker_bloc.dart';
import '../widgets/jobber_tracker_table.dart';
import '../widgets/jobber_details_view.dart';

class JobberTrackerPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const JobberTrackerPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobberTrackerBloc>()..add(LoadJobberTrackerData()),
      child: JobberTrackerView(onSettingsTap: onSettingsTap),
    );
  }
}

class JobberTrackerView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const JobberTrackerView({super.key, this.onSettingsTap});

  @override
  State<JobberTrackerView> createState() => _JobberTrackerViewState();
}

class _JobberTrackerViewState extends State<JobberTrackerView> {
  String? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedUser != null
          ? JobberDetailsView(
              uName: selectedUser!,
              onBack: () => setState(() => selectedUser = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Jobber Tracker',
                  subtitle: 'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: () =>
                      context.read<JobberTrackerBloc>().add(LoadJobberTrackerData()),
                  onSettingsTap: widget.onSettingsTap,
                ),
                const SizedBox(height: 12),
                const PageFiltersBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<JobberTrackerBloc, JobberTrackerState>(
                    builder: (context, state) {
                      if (state is JobberTrackerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is JobberTrackerLoaded) {
                        return JobberTrackerTable(
                          data: state.data,
                          onViewSelected: (uName) {
                            setState(() => selectedUser = uName);
                          },
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
