import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppDatePicker extends StatefulWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final double? width;
  final double? height;
  final DateTime? firstDate;
  final DateTime? lastDate;
  const AppDatePicker({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.width,
    this.height,
    this.firstDate,
    this.lastDate,
  });
  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _controller;
  late Animation<double> _animation;
  DateTime _viewMonth = DateTime.now();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.value != null) {
      _viewMonth = DateTime(widget.value!.year, widget.value!.month);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();
  void _open() {
    if (widget.value != null) {
      _viewMonth = DateTime(widget.value!.year, widget.value!.month);
    } else {
      _viewMonth = DateTime.now();
    }
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _controller.forward();
  }

  void _close() {
    _controller.reverse().then((_) {
      _removeOverlay();
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  Color get _borderColor => AppColors.primaryBlue;
  String get _displayText {
    if (widget.value == null) return 'Select Date';
    final d = widget.value!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString()}';
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: Container(color: AppColors.transparent),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 3.h,
              child: FadeTransition(
                opacity: _animation,
                child: Material(
                  color: AppColors.transparent,
                  child: StatefulBuilder(
                    builder: (ctx, setCalState) {
                      return _buildCalendar(setCalState);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar(StateSetter setCalState) {
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final prevMonthDays = DateTime(_viewMonth.year, _viewMonth.month, 0).day;
    final totalCells = firstWeekday + daysInMonth;
    final totalRows = ((totalCells + 6) ~/ 7);
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.12),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setCalState(() {
                    _viewMonth = DateTime(
                      _viewMonth.year,
                      _viewMonth.month - 1,
                    );
                  });
                  _overlayEntry?.markNeedsBuild();
                },
                child: Icon(
                  Icons.chevron_left,
                  size: 20.sp,
                  color: _borderColor,
                ),
              ),
              Text(
                '${monthNames[_viewMonth.month - 1]} ${_viewMonth.year.toString().substring(2)}',
                style: GoogleFonts.openSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _borderColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setCalState(() {
                    _viewMonth = DateTime(
                      _viewMonth.year,
                      _viewMonth.month + 1,
                    );
                  });
                  _overlayEntry?.markNeedsBuild();
                },
                child: Icon(
                  Icons.chevron_right,
                  size: 20.sp,
                  color: _borderColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.tableHeaderBackground,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayLabels.map((l) {
                return SizedBox(
                  width: 32.w,
                  child: Center(
                    child: Text(
                      l,
                      style: GoogleFonts.openSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _borderColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 6.h),
          ...List.generate(totalRows, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - firstWeekday + 1;
                final isSunday = col == 0;
                final isSaturday = col == 6;
                if (dayNum < 1) {
                  final prevDay = prevMonthDays + dayNum;
                  return _buildDayCell(
                    prevDay.toString(),
                    isOtherMonth: true,
                    isSunSat: isSunday || isSaturday,
                  );
                } else if (dayNum > daysInMonth) {
                  final nextDay = dayNum - daysInMonth;
                  return _buildDayCell(
                    nextDay.toString(),
                    isOtherMonth: true,
                    isSunSat: isSunday || isSaturday,
                  );
                } else {
                  final thisDate = DateTime(
                    _viewMonth.year,
                    _viewMonth.month,
                    dayNum,
                  );
                  final isSelected =
                      widget.value != null &&
                      widget.value!.year == thisDate.year &&
                      widget.value!.month == thisDate.month &&
                      widget.value!.day == thisDate.day;
                  return GestureDetector(
                    onTap: () {
                      widget.onChanged(thisDate);
                      _close();
                    },
                    child: _buildDayCell(
                      dayNum.toString(),
                      isSelected: isSelected,
                      isSunSat: isSunday || isSaturday,
                    ),
                  );
                }
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    String text, {
    bool isSelected = false,
    bool isOtherMonth = false,
    bool isSunSat = false,
  }) {
    return Container(
      width: 32.w,
      height: 32.h,
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(8.r),
            )
          : null,
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? AppColors.white
              : isOtherMonth
              ? AppColors.primaryBlue.withOpacity(0.3)
              : isSunSat
              ? AppColors.red
              : _borderColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: GoogleFonts.openSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 5.h),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              width: widget.width ?? 180.w,
              height: widget.height ?? 35.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _borderColor, width: 1.4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _displayText,
                      style: GoogleFonts.openSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: 0.15,
                        color: widget.value != null
                            ? AppColors.primaryBlue
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.calendar_today,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
