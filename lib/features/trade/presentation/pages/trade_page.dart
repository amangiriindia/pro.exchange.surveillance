import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/widget/page_header.dart';
import '../bloc/trade_bloc.dart';
import '../bloc/trade_event.dart';
import '../bloc/trade_state.dart';
import '../widgets/trade_table.dart';

class TradePage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const TradePage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TradeBloc>()..add(LoadTrades()),
      child: TradeView(onSettingsTap: onSettingsTap),
    );
  }
}

class TradeView extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const TradeView({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Trade',
            subtitle: 'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () => context.read<TradeBloc>().add(LoadTrades()),
            onSettingsTap: onSettingsTap,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<TradeBloc, TradeState>(
              builder: (context, state) {
                if (state is TradeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TradeLoaded) {
                  return TradeTable(trades: state.trades);
                } else if (state is TradeError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
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
