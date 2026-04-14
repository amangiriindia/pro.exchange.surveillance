import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../../../../core/widget/custom_input_box.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/trade_comparison_bloc.dart';
import '../widgets/trade_comparison_table.dart';

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
          PageHeader(
            title: 'Trade Comparison',
            subtitle: 'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () =>
                context.read<TradeComparisonBloc>().add(LoadTradeComparisonData()),
            onSettingsTap: widget.onSettingsTap,
          ),
          const SizedBox(height: 12),
          // Trade Comparison has a custom filter layout (horizontal scroll + extra fields)
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TradeComparisonBloc, TradeComparisonState>(
              builder: (context, state) {
                if (state is TradeComparisonLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TradeComparisonLoaded) {
                  return TradeComparisonTable(data: state.data);
                } else if (state is TradeComparisonError) {
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

  Widget _buildFilters() {
    final isDark = AppColors.isDarkMode(context);
    final borderCol = isDark
        ? Colors.white.withOpacity(0.15)
        : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C2535).withOpacity(0.85)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Section label ──
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF3B30), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FILTERS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Scrollable filter row + pinned Apply button ──
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Search & Add – Using CustomInputBox for a search field that matches dropdown styling

                       SizedBox(
                        width: 150,
                        child: AppDropdown(
                          hintText: 'Search & Add',
                          height: 36,
                          type: AppDropdownType.multiSelect,
                          items: const ['clent1', 'clent2', 'clent3'],
                          borderColor: borderCol,
                          isDarkMode: isDark,
                        ),
                      ),

                     
                      const SizedBox(width: 10),
                      // Date
                      SizedBox(
                        width: 150,
                        child: AppDropdown(
                          hintText: 'Select Date',
                          height: 36,
                          items: const ['Today', 'Yesterday', 'Custom Date Range'],
                          borderColor: borderCol,
                          isDarkMode: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Exchange
                      SizedBox(
                        width: 150,
                        child: AppDropdown(
                          hintText: 'Exchange',
                          height: 36,
                          items: const ['ALL', 'NSE', 'MCX', 'CE/PE', 'CDS'],
                          showAllOption: true,
                          borderColor: borderCol,
                          isDarkMode: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Symbol
                      SizedBox(
                        width: 150,
                        child: AppDropdown(
                          type: AppDropdownType.search,
                          hintText: 'Symbol',
                          height: 36,
                          items: const ['RELIANCE', 'TATASTEEL', 'INFY', 'HDFCBANK'],
                          borderColor: borderCol,
                          isDarkMode: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Type
                      SizedBox(
                        width: 150,
                        child: AppDropdown(
                          hintText: 'Type',
                          height: 36,
                          items: const ['All', 'Buy', 'Sell', 'Buy Limit', 'Buy Stop', 'Sell Limit', 'Sell Stop'],
                          borderColor: borderCol,
                          isDarkMode: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply button always pinned to the right
              _GradientApplyBtn(onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gradient Apply Filter button ──────────────────────────────────────────────
class _GradientApplyBtn extends StatefulWidget {
  final VoidCallback onPressed;
  const _GradientApplyBtn({required this.onPressed});

  @override
  State<_GradientApplyBtn> createState() => _GradientApplyBtnState();
}

class _GradientApplyBtnState extends State<_GradientApplyBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFF263547), const Color(0xFF0066CC)]
                  : [const Color(0xFF202D3B), const Color(0xFF005CBB)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF0066FF).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              'Apply Filter',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
