import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class AppCalendar extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? selectedDate;
  final Color Function(DateTime)? selectedDayColorBuilder;
  const AppCalendar({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.selectedDate,
    this.selectedDayColorBuilder,
  }) : super(key: key);
  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _currentMonth;
  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMonthNavigation(),
        _buildWeekdayHeaders(),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    final monthFormat = DateFormat('MMMM yyyy');
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
              fontSize: 16.sp,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.tableHeaderBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index == 0 || index == 6;
          return SizedBox(
            width: 40.w,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 12.sp,
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
    final isSelected =
        widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);
    final isWeekend =
        date.weekday == DateTime.sunday || date.weekday == DateTime.saturday;
    Color textColor;
    Color? backgroundColor;
    BoxDecoration? decoration;
    if (isSelected) {
      textColor = AppColors.white;
      backgroundColor =
          widget.selectedDayColorBuilder?.call(date) ?? AppColors.primaryBlue;
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      );
    } else if (!isCurrentMonth) {
      textColor = AppColors.secondaryTextColor.withOpacity(0.3);
    } else if (isWeekend) {
      textColor = AppColors.red;
    } else {
      textColor = AppColors.primaryTextColor;
    }
    return GestureDetector(
      onTap: isCurrentMonth ? () => widget.onDateSelected(date) : null,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: GoogleFonts.openSans(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
