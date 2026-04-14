import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/page_filters_bar.dart';
import '../../../../../core/widget/page_header.dart';
import '../../../../../injection_container.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../bloc/group_trade_bloc.dart';
import '../bloc/group_trade_event.dart';
import '../bloc/group_trade_state.dart';
import '../widgets/group_trade_table.dart';

class GroupTradePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const GroupTradePage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupTradeBloc>()..add(LoadGroupTrades()),
      child: GroupTradeView(onSettingsTap: onSettingsTap),
    );
  }
}

class GroupTradeView extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const GroupTradeView({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Group Trade',
            subtitle: 'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () => context.read<GroupTradeBloc>().add(LoadGroupTrades()),
            onSettingsTap: onSettingsTap,
          ),
          const SizedBox(height: 12),
          PageFiltersBar(
            extraFilters: [
                   SizedBox(
                        width: 180,
                        child: AppDropdown(
                          hintText: 'Search & Add',
                          height: 36,
                          type: AppDropdownType.multiSelect,
                          items: const ['clent1', 'clent2', 'clent3'],
                        ),
                      ),

                     
         
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<GroupTradeBloc, GroupTradeState>(
              builder: (context, state) {
                if (state is GroupTradeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupTradeLoaded) {
                  return GroupTradeTable(trades: state.trades);
                } else if (state is GroupTradeError) {
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
