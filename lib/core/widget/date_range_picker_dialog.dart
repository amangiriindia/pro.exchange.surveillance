import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'custom_action_button.dart';
import 'custom_outlined_button.dart';

class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool showSimpleUI;
  const CustomDateRangePickerDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.showSimpleUI = false,
  });
  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    bool showSimpleUI = false,
  }) async {
    return await showDialog<DateTimeRange>(
      context: context,
      barrierColor: AppColors.black.withOpacity(0.5),
      builder: (context) => CustomDateRangePickerDialog(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        showSimpleUI: showSimpleUI,
      ),
    );
  }

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: widget.showSimpleUI ? 330.w : 350.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.showSimpleUI) _buildHeader(),
            _buildMonthNavigation(),
            _buildWeekdayHeaders(),
            _buildCalendarGrid(),
            if (!widget.showSimpleUI && _startDate != null && _endDate != null)
              _buildSelectedDateDisplay(),
            if (!widget.showSimpleUI) _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Market Timing',
            style: GoogleFonts.openSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, size: 24.sp, color: AppColors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final monthFormat = DateFormat('MMMM yy');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
              });
            },
            icon: Icon(
              Icons.chevron_left,
              color: AppColors.primaryBlue,
              size: 28.sp,
            ),
          ),
          Text(
            monthFormat.format(_currentMonth),
            style: GoogleFonts.openSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
              });
            },
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.primaryBlue,
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.tableHeaderBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) {
            return Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            );
          }).toList(),
        ),
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
            padding: EdgeInsets.symmetric(vertical: 2.h),
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
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentRow,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    Color? backgroundColor;
    BoxDecoration? decoration;
    if (isStartDate || isEndDate) {
      textColor = AppColors.white;
      backgroundColor = (date.weekday == DateTime.sunday)
          ? AppColors.red
          : AppColors.primaryBlue;
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      );
    } else if (isInRange) {
      textColor = AppColors.primaryTextColor;
      backgroundColor = (date.weekday == DateTime.sunday)
          ? AppColors.red.withOpacity(0.1)
          : AppColors.primaryBlue.withOpacity(0.1);
      decoration = BoxDecoration(color: backgroundColor);
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
        width: 38.w,
        height: 38.w,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: GoogleFonts.openSans(
            fontSize: 12.sp,
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
        if (widget.showSimpleUI) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.pop(
                context,
                DateTimeRange(start: _startDate!, end: _endDate!),
              );
            }
          });
        }
      }
    });
  }

  Widget _buildSelectedDateDisplay() {
    final dayFormat = DateFormat('dd MMM');
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  dayFormat.format(_startDate!).toUpperCase(),
                  style: GoogleFonts.openSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'to',
                style: GoogleFonts.openSans(
                  fontSize: 12.sp,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  dayFormat.format(_endDate!).toUpperCase(),
                  style: GoogleFonts.openSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'WEEKEND',
            style: GoogleFonts.openSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlinedActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              height: 48.h,
              fontSize: 12.sp,
              borderColor: AppColors.primaryBlue,
              textColor: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomActionButton(
              text: 'Apply',
              onPressed: (_startDate != null && _endDate != null)
                  ? () {
                      Navigator.pop(
                        context,
                        DateTimeRange(start: _startDate!, end: _endDate!),
                      );
                    }
                  : () {},
              height: 48.h,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
