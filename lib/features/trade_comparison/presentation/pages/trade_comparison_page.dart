import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../../../../injection_container.dart';
import '../bloc/trade_comparison_bloc.dart';
import '../widgets/trade_comparison_table.dart';
import '../widgets/multi_select_dropdown.dart';
import '../../../../core/widget/custom_action_button.dart';

class TradeComparisonPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  const TradeComparisonPage({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TradeComparisonBloc>()..add(LoadTradeComparisonData()),
      child: TradeComparisonView(onSettingsTap: onSettingsTap),
    );
  }
}

class TradeComparisonView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const TradeComparisonView({super.key, this.onSettingsTap});

  @override
  State<TradeComparisonView> createState() => _TradeComparisonViewState();
}

class _TradeComparisonViewState extends State<TradeComparisonView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          Text(
            'Filters',
            style: GoogleFonts.openSans(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 12),
          _buildFilters(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TradeComparisonBloc, TradeComparisonState>(
              builder: (context, state) {
                if (state is TradeComparisonLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TradeComparisonLoaded) {
                  return TradeComparisonTable(data: state.data);
                } else if (state is TradeComparisonError) {
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

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MultiSelectSearchAdd(
              hintText: 'Search & Add',
              items: ['Client 1', 'Client 2', 'Client 3', 'Client 4', 'Client 5'],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: AppDropdown(
              hintText: 'Select Date',
              height: 38,
              items: const ['Today', 'Yesterday', 'Custom Date Range'],
              borderColor: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: AppDropdown(
              hintText: 'Exchange',
              height: 38,
              items: const ['ALL', 'NSE', 'MCX', 'CE/PE', 'CDS'],
              showAllOption: true,
              borderColor: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: AppDropdown(
              type: AppDropdownType.search,
              hintText: 'Symbol',
              height: 38,
              items: const ['RELIANCE', 'TATASTEEL', 'INFY', 'HDFCBANK'],
              borderColor: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: AppDropdown(
              hintText: 'Type',
              height: 38,
              items: const ['All', 'Buy', 'Sell', 'Buy Limit', 'Buy Stop', 'Sell Limit', 'Sell Stop'],
              borderColor: Colors.grey.shade400,
            ),
          ),
          CustomActionButton(
            text: 'Apply Filter',
            width: 120,
            height: 38,
            onPressed: () {},
          ),
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
              'Trade comparison',
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
                  context.read<TradeComparisonBloc>().add(LoadTradeComparisonData());
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
