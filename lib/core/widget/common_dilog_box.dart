import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveillance/core/widget/custom_action_button.dart';
import 'package:surveillance/core/widget/custom_outlined_button.dart';
import '../../../../core/constants/app_colors.dart';

class CommonDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? headerColor;
  final bool showButtons;
  final bool isDarkMode;
  final String cancelText;
  final String saveText;
  final EdgeInsets? contentPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final bool scrollable;
  final bool autoPop;
  final VoidCallback? onClose;
  final VoidCallback? onBringToFront;
  final List<Widget>? titleActions;
  const CommonDialog({
    Key? key,
    required this.title,
    required this.content,
    this.onCancel,
    this.onSave,
    this.width,
    this.height,
    this.backgroundColor,
    this.headerColor,
    this.showButtons = true,
    this.isDarkMode = false,
    this.cancelText = 'Cancel',
    this.saveText = 'Save',
    this.contentPadding,
    this.buttonWidth,
    this.buttonHeight,
    this.scrollable = true,
    this.autoPop = true,
    this.onClose,
    this.onBringToFront,
    this.titleActions,
  }) : super(key: key);
  static final List<OverlayEntry> _activeDialogs = [];
  static bool closeRecent() {
    if (_activeDialogs.isNotEmpty) {
      final entry = _activeDialogs.removeLast();
      if (entry.mounted) {
        entry.remove();
      }
      return true;
    }
    return false;
  }

  static void closeAll() {
    while (_activeDialogs.isNotEmpty) {
      final entry = _activeDialogs.removeLast();
      if (entry.mounted) {
        entry.remove();
      }
    }
  }

  static void show({
    required BuildContext context,
    required String title,
    Widget? content,
    Widget Function(BuildContext, VoidCallback)? contentBuilder,
    VoidCallback? onCancel,
    VoidCallback? onSave,
    VoidCallback? onClose,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? headerColor,
    bool showButtons = true,
    bool isDarkMode = false,
    String cancelText = 'Cancel',
    String saveText = 'Save',
    EdgeInsets? contentPadding,
    double? buttonWidth,
    double? buttonHeight,
    bool scrollable = true,
    bool autoPop = true,
    List<Widget>? titleActions,
  }) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => CommonDialog(
        title: title,
        content:
            content ??
            (contentBuilder != null
                ? contentBuilder(context, () {
                    if (overlayEntry.mounted) {
                      overlayEntry.remove();
                    }
                  })
                : const SizedBox.shrink()),
        onCancel: onCancel,
        onSave: onSave,
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        headerColor: headerColor,
        showButtons: showButtons,
        isDarkMode: isDarkMode,
        cancelText: cancelText,
        saveText: saveText,
        contentPadding: contentPadding,
        buttonWidth: buttonWidth,
        buttonHeight: buttonHeight,
        scrollable: scrollable,
        autoPop: autoPop,
        titleActions: titleActions,
        onClose: () {
          if (_activeDialogs.contains(overlayEntry)) {
            _activeDialogs.remove(overlayEntry);
          }
          if (onClose != null) onClose();
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
        onBringToFront: () {
          if (_activeDialogs.isNotEmpty &&
              _activeDialogs.last == overlayEntry) {
            return;
          }
          if (_activeDialogs.contains(overlayEntry)) {
            _activeDialogs.remove(overlayEntry);
            _activeDialogs.add(overlayEntry);
          }
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
          final overlay = Overlay.of(context, rootOverlay: true);
          overlay.insert(overlayEntry);
        },
      ),
    );
    _activeDialogs.add(overlayEntry);
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }

  @override
  State<CommonDialog> createState() => _CommonDialogState();
}

class _CommonDialogState extends State<CommonDialog> {
  Offset? _position;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position == null) {
      final screenSize = MediaQuery.of(context).size;
      final dialogWidth = widget.width ?? 400.w;

      _position = Offset(
        (screenSize.width - dialogWidth) / 2,
        (screenSize.height - (widget.height ?? 400.h)) / 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ??
        (widget.isDarkMode
            ? DarkThemeColors.cardBackground
            : LightThemeColors.cardBackground);
    final headerBgColor =
        widget.headerColor ??
        (widget.isDarkMode
            ? LightThemeColors.primaryColor
            : AppColors.primaryBlue);
    return Stack(
      children: [
        Positioned(
          left: _position!.dx,
          top: _position!.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              setState(() {
                _position = Offset(
                  _position!.dx + details.delta.dx,
                  _position!.dy + details.delta.dy,
                );
              });
            },
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: (widget.width ?? 400.w).clamp(
                  200.w,
                  MediaQuery.of(context).size.width * 0.9,
                ),
                height: widget.height,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: widget.height != null
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      _buildHeader(context, headerBgColor),
                      Flexible(
                        child: widget.scrollable
                            ? SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      widget.contentPadding ??
                                      EdgeInsets.all(20.w),
                                  child: widget.content,
                                ),
                              )
                            : Padding(
                                padding:
                                    widget.contentPadding ??
                                    EdgeInsets.all(20.w),
                                child: widget.content,
                              ),
                      ),
                      if (widget.showButtons) ...[
                        _buildButtons(context),
                        SizedBox(height: 10.h),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color headerBgColor) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      ),
      child: Container(
        height: 40.h,
        color: headerBgColor,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: GoogleFonts.openSans(
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            if (widget.titleActions != null) ...[
              ...widget.titleActions!,
              SizedBox(width: 8.w),
            ],
            GestureDetector(
              onTap: () {
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.close, size: 18.sp, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final primaryColor = widget.isDarkMode
        ? const Color(0xFF1F4A66)
        : (widget.headerColor ?? AppColors.primaryBlue);
    final btnHeight = widget.buttonHeight ?? 45.h;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CustomOutlinedActionButton(
              text: widget.cancelText,
              onPressed: () {
                if (widget.onCancel != null) {
                  widget.onCancel!();
                }
                if (widget.autoPop) {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              height: btnHeight,
              borderColor: primaryColor,
              textColor: primaryColor,
              borderRadius: 10.r,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomActionButton(
              text: widget.saveText,
              onPressed: () {
                if (widget.onSave != null) {
                  widget.onSave!();
                }
                if (widget.autoPop) {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
              height: btnHeight,
              backgroundColor: primaryColor,
              borderRadius: 10.r,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
