import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../injection_container.dart';
import '../bloc/trade_comparison_bloc.dart';
import '../../domain/entities/trade_comparison_entity.dart';
import '../widgets/trade_comparison_table.dart';

class TradeComparisonPage extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const TradeComparisonPage({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TradeComparisonBloc>()..add(LoadTradeComparisonData()),
      child: TradeComparisonView(
        onSettingsTap: onSettingsTap,
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}

class TradeComparisonView extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  const TradeComparisonView({
    super.key,
    this.onSettingsTap,
    this.onNotificationTap,
  });

  @override
  State<TradeComparisonView> createState() => _TradeComparisonViewState();
}

class _TradeComparisonViewState extends State<TradeComparisonView> {
  List<String> _selectedUsers = const [];
  String? _selectedDate;
  String? _selectedExchange;
  String? _selectedSymbol;
  String? _selectedType;
  bool _fetchPending = false;

  void _resetFilters() {
    setState(() {
      _selectedUsers = const [];
      _selectedDate = null;
      _selectedExchange = null;
      _selectedSymbol = null;
      _selectedType = null;
    });
  }

  void _onRefresh() {
    _fetchPending = false;
    context.read<TradeComparisonBloc>().add(LoadTradeComparisonData());
  }

  void _onNearBottom() {
    if (_fetchPending) return;
    final state = context.read<TradeComparisonBloc>().state;
    if (state is TradeComparisonLoaded &&
        state.hasMore &&
        !state.isLoadingMore) {
      _fetchPending = true;
      context.read<TradeComparisonBloc>().add(LoadMoreTradeComparisonData());
      Future.delayed(const Duration(milliseconds: 500), () {
        _fetchPending = false;
      });
    }
  }

  List<TradeComparisonEntity> _applyFilters(List<TradeComparisonEntity> data) {
    return data.where((item) {
      final combinedUser = '${item.uName} ${item.pUser}';
      return ListFilterUtils.matchesAnyContains(combinedUser, _selectedUsers) &&
          ListFilterUtils.matchesQuickDate(item.orderDateTime, _selectedDate) &&
          ListFilterUtils.matchesExact(item.exch, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol) &&
          ListFilterUtils.matchesContains(item.type, _selectedType);
    }).toList();
  }

  List<String> _userItems(List<TradeComparisonEntity> data) {
    final users = <String>{};
    for (final item in data) {
      users.add(item.uName);
      users.add(item.pUser);
    }
    final list = users.toList();
    list.sort();
    return list;
  }

  List<String> _symbolItems(List<TradeComparisonEntity> data) {
    final symbols = data.map((item) => item.symbol).toSet().toList();
    symbols.sort();
    return symbols;
  }

  List<String> _typeItems(List<TradeComparisonEntity> data) {
    final types = data.map((item) => item.type).toSet().toList();
    types.sort();
    return types;
  }

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
            subtitle:
                'Monitor users who exceeded configured trade quantity limits',
            onRefresh: _onRefresh,
            onSettingsTap: widget.onSettingsTap,
            onNotificationTap: widget.onNotificationTap,
          ),
          Expanded(
            child: BlocBuilder<TradeComparisonBloc, TradeComparisonState>(
              builder: (context, state) {
                if (state is TradeComparisonLoading) {
                  return const SizedBox.shrink();
                } else if (state is TradeComparisonLoaded) {
                  final filteredData = _applyFilters(state.data);
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildFilters(state.data),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TradeComparisonTable(
                          data: filteredData,
                          onNearBottom: _onNearBottom,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      ),
                    ],
                  );
                } else if (state is TradeComparisonError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
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

  Widget _buildFilters(List<TradeComparisonEntity> data) {
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
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
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
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(width: 8),
              _ResetFiltersButton(onPressed: _resetFilters),
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
                          items: _userItems(data),
                          selectedValues: _selectedUsers,
                          onMultiChanged: (values) =>
                              setState(() => _selectedUsers = values),
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
                          value: _selectedDate,
                          onChanged: (value) =>
                              setState(() => _selectedDate = value),
                          items: const ['Today', 'Yesterday'],
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
                          value: _selectedExchange,
                          onChanged: (value) =>
                              setState(() => _selectedExchange = value),
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
                          value: _selectedSymbol,
                          onChanged: (value) =>
                              setState(() => _selectedSymbol = value),
                          items: _symbolItems(data),
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
                          value: _selectedType,
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                          items: _typeItems(data),
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
              _GradientApplyBtn(onPressed: () => setState(() {})),
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

class _ResetFiltersButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ResetFiltersButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Tooltip(
      message: 'Reset filters',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 18,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
