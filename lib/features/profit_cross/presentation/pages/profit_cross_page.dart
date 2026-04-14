import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widget/page_filters_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/profit_cross_bloc.dart';
import '../widgets/profit_cross_table.dart';

class ProfitCrossPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const ProfitCrossPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfitCrossBloc>()..add(LoadProfitCrossData()),
      child: ProfitCrossView(onSettingsTap: onSettingsTap),
    );
  }
}

class ProfitCrossView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const ProfitCrossView({super.key, this.onSettingsTap});

  @override
  State<ProfitCrossView> createState() => _ProfitCrossViewState();
}

class _ProfitCrossViewState extends State<ProfitCrossView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Profit % Cross',
            subtitle: 'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () => context.read<ProfitCrossBloc>().add(LoadProfitCrossData()),
            onSettingsTap: widget.onSettingsTap,
          ),
          const SizedBox(height: 12),
          const PageFiltersBar(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ProfitCrossBloc, ProfitCrossState>(
              buildWhen: (previous, current) =>
                  current is ProfitCrossLoading ||
                  current is ProfitCrossLoaded ||
                  current is ProfitCrossError,
              builder: (context, state) {
                if (state is ProfitCrossLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProfitCrossLoaded) {
                  return ProfitCrossTable(data: state.data);
                } else if (state is ProfitCrossError) {
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
