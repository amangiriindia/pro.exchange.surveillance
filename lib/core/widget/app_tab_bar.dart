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
  final bool isDarkMode;
  final bool useExpanded;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
    this.style = AppTabBarStyle.underline,
    this.autoFocus = true,
    this.isDarkMode = false,
    this.useExpanded = true,
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
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
      height: 38,
      child: Row(
        mainAxisSize: widget.useExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: List.generate(widget.tabs.length, (i) {
          final selected = widget.activeTab == i;
          final isHovered = _hoveredIndex == i && !selected;

          final tabChild = Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.useExpanded ? 4.w : 0,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hoveredIndex = i),
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: GestureDetector(
                onTap: () {
                  widget.onTabChanged(i);
                  _focusNode.requestFocus();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: selected
                        ? (widget.isDarkMode
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF202D3B))
                        : (isHovered
                              ? (widget.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : const Color(0xFFF1F5F9))
                              : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : (isHovered
                                ? (widget.isDarkMode
                                      ? Colors.white.withOpacity(0.12)
                                      : const Color(0xFFE2E8F0))
                                : Colors.transparent),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.tabs[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : (widget.isDarkMode
                                  ? Colors.white.withOpacity(0.65)
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          if (widget.useExpanded) {
            return Expanded(child: tabChild);
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: tabChild,
          );
        }),
      ),
    );
  }
}
