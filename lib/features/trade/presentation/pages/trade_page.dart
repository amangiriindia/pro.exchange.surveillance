import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../bloc/trade_bloc.dart';
import '../bloc/trade_event.dart';
import '../bloc/trade_state.dart';
import '../widgets/trade_table.dart';
import '../../../../core/widget/custom_outlined_button.dart';

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
      color: Colors.transparent, // Allow dashboard gradient to show
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
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
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trade',
              style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor users who exceeded configured trade quantity limits',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54, size: 20),
                onPressed: () {
                  context.read<TradeBloc>().add(LoadTrades());
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.black54, size: 20),
                onPressed: onSettingsTap,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black54, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        )
      ],
    );
  }
}
