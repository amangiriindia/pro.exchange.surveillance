import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../../../../injection_container.dart';
import '../bloc/profit_cross_bloc.dart';
import '../widgets/profit_cross_table.dart';
import '../../../../core/widget/custom_action_button.dart';
import '../../../../core/widget/custom_outlined_button.dart';

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
            child: BlocBuilder<ProfitCrossBloc, ProfitCrossState>(
              buildWhen: (previous, current) => 
                  current is ProfitCrossLoading || current is ProfitCrossLoaded || current is ProfitCrossError,
              builder: (context, state) {
                if (state is ProfitCrossLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProfitCrossLoaded) {
                  return ProfitCrossTable(data: state.data);
                } else if (state is ProfitCrossError) {
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
    return Row(
      children: [
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
            items: const [
              'ALL',
              'NSE',
              'MCX',
              'CE/PE',
              'OTHERS',
              'COMEX FUTURE',
              'COMEX SPOT',
              'CRYPTO',
              'GIFT',
              'FOREX',
              'CDS'
            ],
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
            items: const [
              'SGX GIFTNIFTY Oct 28',
              'NSE NIFTY Oct 28',
              'NSE BANKNIFTY Oct 28',
              'MINI GOLDMINI Dec 05',
              'MINI SILVERMINI Dec 05',
              'OTHER DOW Dec 19',
              'OTHER NASDAQ Dec 19',
              'OTHER S & P Dec 19'
            ],
            borderColor: Colors.grey.shade400,
          ),
        ),
        const Spacer(),
        CustomActionButton(
          text: 'Apply Filter',
          onPressed: () {},
          width: 140,
          height: 38,
        ),

]
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
              'Profit % Cross',
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
                  context.read<ProfitCrossBloc>().add(LoadProfitCrossData());
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
