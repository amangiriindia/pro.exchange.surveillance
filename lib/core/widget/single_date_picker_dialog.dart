import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import 'custom_action_button.dart';
import 'custom_outlined_button.dart';

class SingleDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  const SingleDatePickerDialog({Key? key, this.initialDate}) : super(key: key);
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return await showDialog<DateTime>(
      context: context,
      barrierColor: AppColors.black.withOpacity(0.5),
      builder: (context) => SingleDatePickerDialog(initialDate: initialDate),
    );
  }

  @override
  State<SingleDatePickerDialog> createState() => _SingleDatePickerDialogState();
}

class _SingleDatePickerDialogState extends State<SingleDatePickerDialog> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = _selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildMonthNavigation(),
            _buildWeekdayHeaders(),
            _buildCalendarGrid(),
            if (_selectedDate != null) _buildSelectedDateDisplay(),
            _buildButtons(),
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
            'Select Date',
            style: GoogleFonts.openSans(
              fontSize: 18.sp,
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
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
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
                fontSize: 14.sp,
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
        _selectedDate != null && _isSameDay(date, _selectedDate!);
    final isWeekend =
        date.weekday == DateTime.sunday || date.weekday == DateTime.saturday;
    Color textColor;
    Color? backgroundColor;
    BoxDecoration? decoration;
    if (isSelected) {
      textColor = AppColors.white;
      backgroundColor = AppColors.primaryBlue;
      decoration = BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      );
    } else if (!isCurrentMonth) {
      textColor = AppColors.secondaryTextColor.withOpacity(0.3);
    } else if (isWeekend) {
      textColor = AppColors.red;
    } else {
      textColor = AppColors.primaryTextColor;
    }
    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTap(date) : null,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: GoogleFonts.openSans(
            fontSize: 14.sp,
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

  void _onDayTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Widget _buildSelectedDateDisplay() {
    final dateFormat = DateFormat('dd MMMM yyyy');
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBlue, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primaryBlue),
          SizedBox(width: 8.w),
          Text(
            dateFormat.format(_selectedDate!),
            style: GoogleFonts.openSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
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
              fontSize: 14.sp,
              borderColor: AppColors.primaryBlue,
              textColor: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomActionButton(
              text: 'Select',
              onPressed: _selectedDate != null
                  ? () {
                      Navigator.pop(context, _selectedDate);
                    }
                  : () {},
              height: 48.h,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
