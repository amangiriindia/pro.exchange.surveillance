import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppFilePicker extends StatefulWidget {
  final List<String>? allowedExtensions;
  final String hintText;
  final double? height;
  final ValueChanged<PlatformFile?>? onFilePicked;

  const AppFilePicker({
    super.key,
    this.allowedExtensions,
    this.hintText = 'Browse File',
    this.height,
    this.onFilePicked,
  });

  @override
  State<AppFilePicker> createState() => AppFilePickerState();
}

class AppFilePickerState extends State<AppFilePicker> {
  PlatformFile? _pickedFile;

  PlatformFile? get pickedFile => _pickedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
      widget.onFilePicked?.call(_pickedFile);
    }
  }

  void clear() {
    setState(() {
      _pickedFile = null;
    });
    widget.onFilePicked?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height ?? 36.h;
    return GestureDetector(
      onTap: pickFile,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBlue, width: 1.4),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _pickedFile?.name ?? widget.hintText,
                style: GoogleFonts.openSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: _pickedFile != null
                      ? AppColors.textDark
                      : AppColors.primaryBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_pickedFile != null)
              GestureDetector(
                onTap: clear,
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: AppColors.primaryBlue.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
