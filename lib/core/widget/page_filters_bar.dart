import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'app_dropdown.dart';
import 'date_range_picker_dialog.dart';

const kExchangeItems = [
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
  'CDS',
];

const kSymbolItems = [
  'SGX GIFTNIFTY Oct 28',
  'NSE NIFTY Oct 28',
  'NSE BANKNIFTY Oct 28',
  'MINI GOLDMINI Dec 05',
  'MINI SILVERMINI Dec 05',
  'OTHER DOW Dec 19',
  'OTHER NASDAQ Dec 19',
  'OTHER S & P Dec 19',
];

class PageFiltersBar extends StatefulWidget {
  final VoidCallback? onApply;
  final VoidCallback? onReset;
  final List<Widget> extraFilters;
  final String? selectedDate;
  final String? selectedExchange;
  final String? selectedSymbol;
  final ValueChanged<String?>? onDateChanged;
  final ValueChanged<String?>? onExchangeChanged;
  final ValueChanged<String?>? onSymbolChanged;
  final List<String> dateItems;
  final List<String> exchangeItems;
  final List<String> symbolItems;
  final bool showDateFilter;
  final bool showExchangeFilter;
  final bool showSymbolFilter;
  final int? itemCount;
  final String countLabel;
  final bool attachedToHeader;
  final DateTimeRange? customDateRange;
  final ValueChanged<DateTimeRange?>? onCustomDateRangeChanged;

  const PageFiltersBar({
    super.key,
    this.onApply,
    this.onReset,
    this.extraFilters = const [],
    this.selectedDate,
    this.selectedExchange,
    this.selectedSymbol,
    this.onDateChanged,
    this.onExchangeChanged,
    this.onSymbolChanged,
    this.dateItems = const ['Today', 'Yesterday', 'Custom date'],
    this.exchangeItems = kExchangeItems,
    this.symbolItems = kSymbolItems,
    this.showDateFilter = true,
    this.showExchangeFilter = true,
    this.showSymbolFilter = true,
    this.itemCount,
    this.countLabel = 'Total records',
    this.attachedToHeader = false,
    this.customDateRange,
    this.onCustomDateRangeChanged,
  });

  @override
  State<PageFiltersBar> createState() => _PageFiltersBarState();
}

class _PageFiltersBarState extends State<PageFiltersBar> {
  Future<void> _handleDateChanged(String? value) async {
    if (value == 'Custom date') {
      final range = await CustomDateRangePickerDialog.show(
        context,
        initialStartDate: widget.customDateRange?.start,
        initialEndDate: widget.customDateRange?.end,
        showSimpleUI: true,
      );
      if (range != null && mounted) {
        widget.onDateChanged?.call('Custom date');
        widget.onCustomDateRangeChanged?.call(range);
      }
    } else {
      widget.onDateChanged?.call(value);
      if (value == null) widget.onCustomDateRangeChanged?.call(null);
    }
  }

  void _handleReset() {
    widget.onReset?.call();
    widget.onCustomDateRangeChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
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
        borderRadius: widget.attachedToHeader
            ? const BorderRadius.vertical(bottom: Radius.circular(10))
            : BorderRadius.circular(10),
        border: widget.attachedToHeader
            ? Border(
                left: BorderSide(color: borderCol, width: 1),
                right: BorderSide(color: borderCol, width: 1),
                bottom: BorderSide(color: borderCol, width: 1),
              )
            : Border.all(color: borderCol, width: 1),
        boxShadow: widget.attachedToHeader
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  spreadRadius: -1,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar
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

          // Dropdowns
          if (widget.showDateFilter) ...[
            if (widget.selectedDate == 'Custom date' &&
                widget.customDateRange != null)
              _CustomDateChip(
                range: widget.customDateRange!,
                isDark: isDark,
                onTap: () => _handleDateChanged('Custom date'),
                onClear: () {
                  widget.onDateChanged?.call(null);
                  widget.onCustomDateRangeChanged?.call(null);
                },
              )
            else
              _FilterDropdownSlot(
                child: AppDropdown(
                  hintText: 'Select Date',
                  height: 30,
                  value: widget.selectedDate,
                  onChanged: _handleDateChanged,
                  items: widget.dateItems,
                  borderColor: dropBorderCol,
                  isDarkMode: isDark,
                ),
              ),
            const SizedBox(width: 8),
          ],
          if (widget.showExchangeFilter) ...[
            _FilterDropdownSlot(
              child: AppDropdown(
                hintText: 'Exchange',
                height: 30,
                value: widget.selectedExchange,
                onChanged: widget.onExchangeChanged,
                items: widget.exchangeItems,
                showAllOption: true,
                borderColor: dropBorderCol,
                isDarkMode: isDark,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.showSymbolFilter) ...[
            _FilterDropdownSlot(
              child: AppDropdown(
                type: AppDropdownType.search,
                hintText: 'Symbol',
                height: 30,
                value: widget.selectedSymbol,
                onChanged: widget.onSymbolChanged,
                items: widget.symbolItems,
                borderColor: dropBorderCol,
                isDarkMode: isDark,
              ),
            ),
          ],
          for (final extra in widget.extraFilters) ...[
            const SizedBox(width: 8),
            extra,
          ],

          const SizedBox(width: 8),
          _ResetFiltersButton(onPressed: _handleReset),
          const SizedBox(width: 8),
          _GradientApplyButton(onPressed: widget.onApply ?? () {}),

          const Spacer(),

          if (widget.itemCount != null)
            Text(
              '${widget.countLabel}: ${widget.itemCount}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.35)
                    : const Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResetFiltersButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ResetFiltersButton({this.onPressed});

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

class _FilterDropdownSlot extends StatelessWidget {
  final Widget child;
  const _FilterDropdownSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 160, child: child);
  }
}

class _CustomDateChip extends StatelessWidget {
  final DateTimeRange range;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _CustomDateChip({
    required this.range,
    required this.isDark,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM');
    final text = '${fmt.format(range.start)} → ${fmt.format(range.end)}';
    return SizedBox(
      width: 160,
      height: 30,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3145) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF3B82F6).withOpacity(0.5)
                  : const Color(0xFF93C5FD),
              width: 1,
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
                  text,
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
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientApplyButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _GradientApplyButton({required this.onPressed});

  @override
  State<_GradientApplyButton> createState() => _GradientApplyButtonState();
}

class _GradientApplyButtonState extends State<_GradientApplyButton> {
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
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                fontSize: 12,
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
