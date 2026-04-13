import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum AppTabBarStyle { underline, pill }

class AppTabBar extends StatefulWidget {
  final List<String> tabs;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final AppTabBarStyle style;
  final bool autoFocus;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
    this.style = AppTabBarStyle.underline,
    this.autoFocus = true,
  });

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  late FocusNode _focusNode;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        final newIndex = (widget.activeTab + 1) % widget.tabs.length;
        widget.onTabChanged(newIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        final newIndex =
            (widget.activeTab - 1 + widget.tabs.length) % widget.tabs.length;
        widget.onTabChanged(newIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.style == AppTabBarStyle.underline
          ? _buildUnderlineTabBar()
          : _buildPillTabBar(),
    );
  }

  Widget _buildUnderlineTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: List.generate(widget.tabs.length, (i) {
            final selected = widget.activeTab == i;
            return GestureDetector(
              onTap: () {
                widget.onTabChanged(i);
                _focusNode.requestFocus();
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = i),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 6.h),
                    decoration: BoxDecoration(
                      border: selected
                          ? Border(
                              bottom: BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      widget.tabs[i],
                      style: GoogleFonts.openSans(
                        fontSize: 13.sp,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.primaryBlue
                            : _hoveredIndex == i
                            ? AppColors.primaryBlue.withOpacity(0.8)
                            : AppColors.primaryBlue.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPillTabBar() {
    return SizedBox(
      height: 40.h,
      child: Row(
        children: List.generate(widget.tabs.length, (i) {
          final selected = widget.activeTab == i;
          final isHovered = _hoveredIndex == i && !selected;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredIndex = i),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: GestureDetector(
                  onTap: () {
                    widget.onTabChanged(i);
                    _focusNode.requestFocus();
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: isHovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryBlue.withOpacity(0.0),
                                  AppColors.primaryBlue.withOpacity(0.5),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: selected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: GoogleFonts.openSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            letterSpacing: 0.15,
                            color: selected
                                ? AppColors.white
                                : AppColors.textDark,
                          ),
                          child: Text(
                            widget.tabs[i],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
