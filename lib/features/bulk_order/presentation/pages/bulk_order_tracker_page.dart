import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widget/custom_action_button.dart';
import '../../../../../core/widget/page_filters_bar.dart';
import '../../../../../core/widget/page_header.dart';
import '../../../../../injection_container.dart';
import '../bloc/bulk_order_bloc.dart';
import '../bloc/bulk_order_event.dart';
import '../bloc/bulk_order_state.dart';
import '../widgets/bulk_order_table.dart';
import '../widgets/bulk_order_details_view.dart';

class BulkOrderTrackerPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const BulkOrderTrackerPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BulkOrderBloc>()..add(LoadBulkOrders()),
      child: BulkOrderTrackerView(onSettingsTap: onSettingsTap),
    );
  }
}

class BulkOrderTrackerView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const BulkOrderTrackerView({super.key, this.onSettingsTap});

  @override
  State<BulkOrderTrackerView> createState() => _BulkOrderTrackerViewState();
}

class _BulkOrderTrackerViewState extends State<BulkOrderTrackerView> {
  String? selectedSymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: selectedSymbol != null ? _buildDetailsView() : _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Bulk Order Tracker',
          subtitle: 'Monitor users who exceeded configured trade quantity limits',
          onRefresh: () => context.read<BulkOrderBloc>().add(LoadBulkOrders()),
          onSettingsTap: widget.onSettingsTap,
          extraActions: [
            CustomActionButton(
              text: 'Export Report',
              onPressed: () {},
              width: 130,
              height: 48,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const PageFiltersBar(),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<BulkOrderBloc, BulkOrderState>(
            builder: (context, state) {
              if (state is BulkOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BulkOrderLoaded) {
                return BulkOrderTable(
                  trades: state.trades,
                  onViewSelected: (symbol) {
                    setState(() => selectedSymbol = symbol);
                  },
                );
              } else if (state is BulkOrderError) {
                return Center(
                  child: Text(state.message, style: const TextStyle(color: Colors.red)),
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
          title: 'Bulk Order Tracker',
          subtitle: 'Monitor users who exceeded configured trade quantity limits',
          onRefresh: () => context.read<BulkOrderBloc>().add(LoadBulkOrders()),
          onSettingsTap: widget.onSettingsTap,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: BulkOrderDetailsView(
            symbol: selectedSymbol!,
            onBack: () => setState(() => selectedSymbol = null),
          ),
        ),
      ],
    );
  }
}
