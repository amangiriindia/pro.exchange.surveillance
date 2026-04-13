import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveillance/core/widget/custom_action_button.dart';
import 'package:surveillance/core/widget/custom_outlined_button.dart';
import '../../../../../core/widget/app_dropdown.dart';
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
      child: selectedSymbol != null 
          ? _buildDetailsView()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
          const SizedBox(height: 12),
          Text(
            'Filters',
            style: GoogleFonts.openSans(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 12),
          Row(
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
                    'ALL', 'NSE', 'MCX', 'CE/PE', 'OTHERS', 'COMEX FUTURE',
                    'COMEX SPOT', 'CRYPTO', 'GIFT', 'FOREX', 'CDS'
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
            ],
          ),
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
                      setState(() {
                        selectedSymbol = symbol;
                      });
                    },
                  );
                } else if (state is BulkOrderError) {
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
  
  Widget _buildDetailsView() {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        Expanded(
          child: BulkOrderDetailsView(
            symbol: selectedSymbol!,
            onBack: () {
              setState(() {
                selectedSymbol = null;
              });
            },
          ),
        ),
      ],
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
              'Bulk Order Tracker',
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
            CustomActionButton(
              text: 'Export Report',
              onPressed: () {},
              width: 130,
              height: 48,
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black54, size: 20),
                onPressed: () {
                  context.read<BulkOrderBloc>().add(LoadBulkOrders());
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
                onPressed: widget.onSettingsTap,
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
