import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum TableActionVariant { view, investigate, filled }

class TableActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final TableActionVariant variant;
  final IconData? icon;
  final Color? color;

  const TableActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TableActionVariant.filled,
    this.icon,
    this.color,
  });

  const TableActionButton.view({super.key, required this.onPressed})
    : label = 'View',
      variant = TableActionVariant.view,
      icon = null,
      color = null;

  const TableActionButton.investigate({super.key, required this.onPressed})
    : label = 'Investigate',
      variant = TableActionVariant.investigate,
      icon = null,
      color = null;

  @override
  State<TableActionButton> createState() => _TableActionButtonState();
}

class _TableActionButtonState extends State<TableActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    final Color accent;
    final IconData iconData;
    switch (widget.variant) {
      case TableActionVariant.view:
        accent = const Color(0xFF0066FF);
        iconData = Icons.remove_red_eye_outlined;
        break;
      case TableActionVariant.investigate:
        accent = const Color(0xFFFF8C00);
        iconData = Icons.manage_search_rounded;
        break;
      case TableActionVariant.filled:
        accent = widget.color ?? const Color(0xFF202D3B);
        iconData = widget.icon ?? Icons.arrow_forward_rounded;
        break;
    }

    final bgHover = accent.withOpacity(isDark ? 0.18 : 0.1);
    final borderColor = _hovered
        ? accent.withOpacity(0.85)
        : accent.withOpacity(isDark ? 0.35 : 0.3);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered ? bgHover : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 12,
                color: _hovered
                    ? accent
                    : accent.withOpacity(isDark ? 0.75 : 0.7),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _hovered
                      ? accent
                      : accent.withOpacity(isDark ? 0.85 : 0.8),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableActionRow extends StatelessWidget {
  final VoidCallback onView;

  const TableActionRow({super.key, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [TableActionButton.view(onPressed: onView)],
    );
  }
}
