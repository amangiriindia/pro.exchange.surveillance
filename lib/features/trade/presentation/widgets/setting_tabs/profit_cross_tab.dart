import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widget/app_dropdown.dart';
import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/table/view_data_table.dart';
import '../../../../../core/widget/custom_action_button.dart';

class ProfitCrossTab extends StatelessWidget {
  const ProfitCrossTab({super.key});

  final List<String> items = const [
    'NSE_0', 'NSE_1', 'NSE_2', 'NSE_3', 'NSE_4', 'NSE_5', 'NSE_6', 'NSE_7', 'NSE_8', 'NSE_9'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: AppDropdown(
                    hintText: 'Exchange',
                    height: 38,
                    items: const [
                      'NSE', 'MCX', 'CE/PE', 'OTHERS', 'COMEX FUTURE',
                      'COMEX SPOT', 'CRYPTO', 'GIFT', 'FOREX', 'CDS'
                    ],
                    showAllOption: true,
                    borderColor: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 16),
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
              ],
            ),
            CustomActionButton(
              text: 'Import File',
              onPressed: () {},
              width: 120,
              height: 38,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ViewDataTable<String>(
            columns: const [
              ViewTableColumn(id: 'exchange', label: 'EXCHANGE', width: 250),
              ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 250),
              ViewTableColumn(id: 'percentage', label: 'PERCENTAGE (%)', width: 350),
            ],
            data: items,
            idExtractor: (item) => item,
            autoFit: true,
            isDarkMode: false,
            cellBuilder: _buildCell,
          ),
        ),
      ],
    );
  }

  Widget _buildCell(String item, ViewTableColumn col) {
    if (col.id == 'exchange') {
      return Text(
        'NSE',
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    } else if (col.id == 'symbol') {
      return Text(
        'RELIANCE',
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    } else if (col.id == 'percentage') {
      return CustomInputField(
        hintText: 'Type here',
        height: 30,
        width: double.infinity,
        borderColor: Colors.grey.shade400,
      );
    }
    
    return const SizedBox.shrink();
  }
}
