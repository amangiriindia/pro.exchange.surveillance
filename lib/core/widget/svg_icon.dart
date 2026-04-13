import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  const SvgIcon({
    super.key,
    required this.assetPath,
    required this.isActive,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });
  @override
  Widget build(BuildContext context) {
    final Color? iconColor = isActive ? activeColor : inactiveColor;
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    );
  }
}
