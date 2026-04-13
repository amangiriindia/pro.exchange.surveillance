import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class AnimatedPriceBox extends StatefulWidget {
  final String price;
  final bool isDarkMode;
  final double? width;
  final double? height;
  const AnimatedPriceBox({
    Key? key,
    required this.price,
    this.isDarkMode = false,
    this.width,
    this.height,
  }) : super(key: key);
  @override
  State<AnimatedPriceBox> createState() => _AnimatedPriceBoxState();
}

class _AnimatedPriceBoxState extends State<AnimatedPriceBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _bgAnimation;
  late Animation<Color?> _textAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    final Color blue = const Color(0xFF0052FF);
    final Color red = AppColors.red;
    final Color blank = Colors.transparent;
    final Color textWhite = AppColors.white;
    final Color textDark = widget.isDarkMode ? Colors.white : AppColors.black;
    _bgAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: blue, end: blue),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: blue, end: blank),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: blank, end: blank),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: blank, end: red),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: red, end: red),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: red, end: blank),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: blank, end: blank),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: blank, end: blue),
      ),
    ]).animate(_controller);
    _textAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: textWhite, end: textWhite),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: textWhite, end: textDark),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: textDark, end: textDark),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: textDark, end: textWhite),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: textWhite, end: textWhite),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: textWhite, end: textDark),
      ),
      TweenSequenceItem(
        weight: 2,
        tween: ColorTween(begin: textDark, end: textDark),
      ),
      TweenSequenceItem(
        weight: 1,
        tween: ColorTween(begin: textDark, end: textWhite),
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? 110.w,
          height: widget.height ?? 45.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _bgAnimation.value,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            widget.price,
            style: GoogleFonts.openSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _textAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
