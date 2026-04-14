import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/btst_bloc.dart';
import '../widgets/btst_table.dart';
import '../widgets/btst_details_view.dart';

class BTSTPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const BTSTPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BTSTBloc>()..add(LoadBTSTData()),
      child: BTSTView(onSettingsTap: onSettingsTap),
    );
  }
}

class BTSTView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const BTSTView({super.key, this.onSettingsTap});

  @override
  State<BTSTView> createState() => _BTSTViewState();
}

class _BTSTViewState extends State<BTSTView> {
  String? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedUser != null
          ? BTSTDetailsView(
              uName: selectedUser!,
              onBack: () => setState(() => selectedUser = null),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'BTST/STBT',
                  subtitle: 'Monitor users who exceeded configured trade quantity limits',
                  onRefresh: () => context.read<BTSTBloc>().add(LoadBTSTData()),
                  onSettingsTap: widget.onSettingsTap,
                ),
                const SizedBox(height: 12),
                const PageFiltersBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<BTSTBloc, BTSTState>(
                    builder: (context, state) {
                      if (state is BTSTLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is BTSTLoaded) {
                        return BTSTTable(
                          data: state.data,
                          onViewSelected: (uName) {
                            setState(() => selectedUser = uName);
                          },
                        );
                      } else if (state is BTSTError) {
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
}
