import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class ClientProfitLossWidget extends StatefulWidget {
  const ClientProfitLossWidget({Key? key}) : super(key: key);
  @override
  State<ClientProfitLossWidget> createState() => _ClientProfitLossWidgetState();
}

class _ClientProfitLossWidgetState extends State<ClientProfitLossWidget> {
  double _profitLoss = 81400.00;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          final isPositive = (DateTime.now().second % 2 == 0);
          final mockChange = 500.0 + (DateTime.now().millisecond % 2000);
          if (isPositive) {
            _profitLoss = _profitLoss.abs() + mockChange;
          } else {
            _profitLoss = -(_profitLoss.abs() - mockChange);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💰', style: TextStyle(fontSize: 20.sp)),
        SizedBox(width: 8.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            'P/L : ${_profitLoss.toStringAsFixed(2)}',
            key: ValueKey<double>(_profitLoss),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: _profitLoss >= 0
                  ? AppColors.buyColor
                  : AppColors.sellColor,
            ),
          ),
        ),
      ],
    );
  }
}
