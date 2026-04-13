import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class DateRangePickerButton extends StatefulWidget {
  final DateTimeRange? selectedDateRange;
  final VoidCallback onTap;
  final ValueChanged<DateTimeRange>? onDateRangeSelected;
  final double? width;
  final double? height;
  final String hintText;
  const DateRangePickerButton({
    super.key,
    required this.selectedDateRange,
    required this.onTap,
    this.onDateRangeSelected,
    this.width,
    this.height,
    this.hintText = 'Select Date Range',
  });
  @override
  State<DateRangePickerButton> createState() => _DateRangePickerButtonState();
}

class _DateRangePickerButtonState extends State<DateRangePickerButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: 240.w,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8.r),
                shadowColor: Colors.black26,
                child: DateRangeCalendarPopup(
                  initialStartDate: widget.selectedDateRange?.start,
                  initialEndDate: widget.selectedDateRange?.end,
                  onApply: (range) {
                    _closeDropdown();
                    widget.onDateRangeSelected?.call(range);
                  },
                  onCancel: _closeDropdown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: widget.onDateRangeSelected != null
            ? _toggleDropdown
            : widget.onTap,
        child: Container(
          width: widget.width ?? 160.w,
          height: widget.height ?? 35.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.primaryBlue, width: 1.4),
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.selectedDateRange != null
                      ? '${DateFormat('dd-MM-yy').format(widget.selectedDateRange!.start)} - ${DateFormat('dd-MM-yy').format(widget.selectedDateRange!.end)}'
                      : widget.hintText,
                  style: GoogleFonts.openSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: 0.15,
                    color: widget.selectedDateRange != null
                        ? AppColors.primaryTextColor
                        : AppColors.primaryBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.calendar_month_outlined,
                size: 16.sp,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateRangeCalendarPopup extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final ValueChanged<DateTimeRange> onApply;
  final VoidCallback onCancel;
  const DateRangeCalendarPopup({
    this.initialStartDate,
    this.initialEndDate,
    required this.onApply,
    required this.onCancel,
  });
  @override
  State<DateRangeCalendarPopup> createState() => DateRangeCalendarPopupState();
}

class DateRangeCalendarPopupState extends State<DateRangeCalendarPopup> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _selectingEndDate = false;
  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _currentMonth = _startDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthNavigation(),
          _buildWeekdayHeaders(),
          _buildCalendarGrid(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final monthFormat = DateFormat('MMMM yy');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
            },
            child: Icon(
              Icons.chevron_left,
              color: AppColors.primaryBlue,
              size: 18.sp,
            ),
          ),
          Text(
            monthFormat.format(_currentMonth),
            style: GoogleFonts.openSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
            },
            child: Icon(
              Icons.chevron_right,
              color: AppColors.primaryBlue,
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.tableHeaderBackground,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 0 || index == 6;
          return SizedBox(
            width: 28.w,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isWeekend ? AppColors.red : AppColors.primaryBlue,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final List<Widget> rows = [];
    List<Widget> currentRow = [];
    for (int i = 0; i < firstWeekday; i++) {
      final prevMonthDay = firstDayOfMonth.subtract(
        Duration(days: firstWeekday - i),
      );
      currentRow.add(_buildDayCell(prevMonthDay, isCurrentMonth: false));
    }
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      currentRow.add(_buildDayCell(date, isCurrentMonth: true));
      if (currentRow.length == 7) {
        rows.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentRow,
            ),
          ),
        );
        currentRow = [];
      }
    }
    if (currentRow.isNotEmpty) {
      int nextMonthDay = 1;
      while (currentRow.length < 7) {
        final nextDate = DateTime(
          _currentMonth.year,
          _currentMonth.month + 1,
          nextMonthDay++,
        );
        currentRow.add(_buildDayCell(nextDate, isCurrentMonth: false));
      }
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentRow,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Column(children: rows),
    );
  }

  Widget _buildDayCell(DateTime date, {required bool isCurrentMonth}) {
    final isStartDate = _startDate != null && _isSameDay(date, _startDate!);
    final isEndDate = _endDate != null && _isSameDay(date, _endDate!);
    final isInRange = _isDateInRange(date);
    final isWeekend =
        date.weekday == DateTime.sunday || date.weekday == DateTime.saturday;
    Color textColor;
    BoxDecoration? decoration;
    if (isStartDate || isEndDate) {
      textColor = AppColors.white;
      decoration = BoxDecoration(
        color: isWeekend ? AppColors.red : AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(8.r),
      );
    } else if (isInRange) {
      textColor = AppColors.primaryTextColor;
      decoration = BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
      );
    } else if (!isCurrentMonth) {
      textColor = AppColors.secondaryTextColor.withValues(alpha: 0.3);
    } else if (isWeekend) {
      textColor = AppColors.red;
    } else {
      textColor = AppColors.primaryTextColor;
    }
    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTap(date) : null,
      child: Container(
        width: 28.w,
        height: 28.h,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: GoogleFonts.openSans(
            fontSize: 10.sp,
            fontWeight: (isStartDate || isEndDate)
                ? FontWeight.w600
                : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  void _onDayTap(DateTime date) {
    setState(() {
      if (_startDate == null || _selectingEndDate == false) {
        _startDate = date;
        _endDate = null;
        _selectingEndDate = true;
      } else {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _selectingEndDate = false;
        if (_startDate != null && _endDate != null) {
          Future.microtask(() {
            widget.onApply(DateTimeRange(start: _startDate!, end: _endDate!));
          });
        }
      }
    });
  }
}
