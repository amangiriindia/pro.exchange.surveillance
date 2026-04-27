import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A modern text input box designed to match the [AppDropdown] style.
/// Used for "Search & Add" or other filter inputs where consistency with
/// dropdown triggers is required.
class CustomInputBox extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final double height;
  final double? width;
  final bool isDarkMode;
  final Color? borderColor;
  final IconData? prefixIcon;

  const CustomInputBox({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.height = 36,
    this.width,
    this.isDarkMode = false,
    this.borderColor,
    this.prefixIcon = Icons.search,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol =
        borderColor ??
        (isDarkMode ? Colors.white.withOpacity(0.15) : const Color(0xFFCBD5E1));

    final textColor = isDarkMode ? Colors.white : const Color(0xFF202D3B);
    final hintColor = isDarkMode
        ? Colors.white.withOpacity(0.3)
        : const Color(0xFF94A3B8);
    final bgColor = isDarkMode
        ? const Color(0xFF1E293B).withOpacity(0.5)
        : Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 16, color: hintColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
