import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/list_filter_utils.dart';
import '../../../../core/widget/app_dropdown.dart';
import '../../../../core/widget/date_range_picker_dialog.dart';
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
  DateTimeRange? _customDateRange;
  String? _selectedExchange;
  String? _selectedSymbol;
  bool _fetchPending = false;

  void _resetFilters() {
    setState(() {
      _selectedUsers = const [];
      _selectedDate = null;
      _selectedExchange = null;
      _selectedSymbol = null;
      _customDateRange = null;
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
          ListFilterUtils.matchesDateRangeOrQuick(
            item.orderDateTime,
            _selectedDate,
            _customDateRange,
          ) &&
          ListFilterUtils.matchesExact(item.exch, _selectedExchange) &&
          ListFilterUtils.matchesContains(item.symbol, _selectedSymbol);
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
            hasFilterBelow: true,
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
                      _buildFilters(state.data),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TradeComparisonTable(
                          data: filteredData,
                          resolvedCityByIp: state.resolvedCityByIp,
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

  Future<void> _onDateChanged(String? value) async {
    if (value == 'Custom date') {
      final range = await CustomDateRangePickerDialog.show(
        context,
        initialStartDate: _customDateRange?.start,
        initialEndDate: _customDateRange?.end,
        showSimpleUI: true,
      );
      if (range != null && mounted) {
        setState(() {
          _selectedDate = 'Custom date';
          _customDateRange = range;
        });
      }
    } else {
      setState(() {
        _selectedDate = value;
        if (value == null) _customDateRange = null;
      });
    }
  }

  Widget _buildFilters(List<TradeComparisonEntity> data) {
    final isDark = AppColors.isDarkMode(context);
    final borderCol = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE2E8F0);
    final dropBorderCol = isDark
        ? Colors.white.withOpacity(0.15)
        : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C2535).withOpacity(0.85)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border(
          left: BorderSide(color: borderCol, width: 1),
          right: BorderSide(color: borderCol, width: 1),
          bottom: BorderSide(color: borderCol, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF3B30), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: AppDropdown(
              hintText: 'Search & Add',
              height: 30,
              type: AppDropdownType.multiSelect,
              items: _userItems(data),
              selectedValues: _selectedUsers,
              onMultiChanged: (values) =>
                  setState(() => _selectedUsers = values),
              borderColor: dropBorderCol,
              isDarkMode: isDark,
            ),
          ),
          const SizedBox(width: 8),
          if (_selectedDate == 'Custom date' && _customDateRange != null)
            SizedBox(
              width: 160,
              height: 30,
              child: GestureDetector(
                onTap: () => _onDateChanged('Custom date'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3145)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3B82F6).withOpacity(0.5)
                          : const Color(0xFF93C5FD),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${_customDateRange!.start.day.toString().padLeft(2, '0')} ${_monthAbbr(_customDateRange!.start.month)} → ${_customDateRange!.end.day.toString().padLeft(2, '0')} ${_monthAbbr(_customDateRange!.end.month)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF2563EB),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedDate = null;
                          _customDateRange = null;
                        }),
                        child: Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: 160,
              child: AppDropdown(
                hintText: 'Select Date',
                height: 30,
                value: _selectedDate,
                onChanged: _onDateChanged,
                items: const ['Today', 'Yesterday', 'Custom date'],
                borderColor: dropBorderCol,
                isDarkMode: isDark,
              ),
            ),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: AppDropdown(
              hintText: 'Exchange',
              height: 30,
              value: _selectedExchange,
              onChanged: (value) => setState(() => _selectedExchange = value),
              items: const ['ALL', 'NSE', 'MCX', 'CE/PE', 'CDS'],
              showAllOption: true,
              borderColor: dropBorderCol,
              isDarkMode: isDark,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: AppDropdown(
              type: AppDropdownType.search,
              hintText: 'Symbol',
              height: 30,
              value: _selectedSymbol,
              onChanged: (value) => setState(() => _selectedSymbol = value),
              items: _symbolItems(data),
              borderColor: dropBorderCol,
              isDarkMode: isDark,
            ),
          ),
          const SizedBox(width: 8),
          _ResetBtn(onPressed: _resetFilters),
          const SizedBox(width: 8),
          _GradientApplyBtn(onPressed: () => setState(() {})),
          const Spacer(),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

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

class _ResetBtn extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ResetBtn({this.onPressed});

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
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 15,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
