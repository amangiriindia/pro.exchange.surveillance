import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widget/svg_icon.dart' show SvgIcon;
import '../../data/models/dropdown_option_model.dart';

class CustomDropdownField extends StatefulWidget {
  final String hintText;
  final String? value;
  final List<DropdownOption> items;
  final ValueChanged<String?> onChanged;
  final double? width;
  final double? dropdownHeight;
  const CustomDropdownField({
    Key? key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
    this.dropdownHeight,
  }) : super(key: key);
  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  static const double _fieldHeight = 45;
  static const double _defaultDropdownHeight = 125;
  static const double _gap = 5;
  TextStyle get _textStyle => GoogleFonts.openSans(
    fontSize: AppDimensions.fontSizeL,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.15,
    color: AppColors.primaryBlue,
  );
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();
  void _open() {
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

  bool _isSvg(String path) => path.toLowerCase().endsWith('.svg');
  Widget _buildLeftIcon(String? iconPath) {
    if (iconPath == null || iconPath.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(right: AppDimensions.paddingM),
      child: SizedBox(
        width: AppDimensions.iconSizeM,
        height: AppDimensions.iconSizeM,
        child: _isSvg(iconPath)
            ? SvgIcon(
                assetPath: iconPath,
                isActive: true,
                size: AppDimensions.iconSizeM,
              )
            : Image.asset(
                iconPath,
                width: AppDimensions.iconSizeM,
                height: AppDimensions.iconSizeM,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
      ),
    );
  }

  Widget _buildTrailingIcon(String? iconPath) {
    if (iconPath == null || iconPath.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: AppDimensions.iconSizeM,
      height: AppDimensions.iconSizeM,
      child: _isSvg(iconPath)
          ? SvgIcon(
              assetPath: iconPath,
              isActive: true,
              size: AppDimensions.iconSizeM,
            )
          : Image.asset(
              iconPath,
              width: AppDimensions.iconSizeM,
              height: AppDimensions.iconSizeM,
              fit: BoxFit.contain,
              color: AppColors.primaryBlue,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }

  bool get _hasSelection => widget.value != null && widget.value!.isNotEmpty;
  DropdownOption? get _selectedItem {
    if (!_hasSelection) return null;
    try {
      return widget.items.firstWhere((e) => e.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final dropdownWidth = widget.width ?? size.width;
    final dropdownHeight = widget.dropdownHeight ?? _defaultDropdownHeight;
    return OverlayEntry(
      builder: (context) => Stack(
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
            top: offset.dy + size.height + _gap,
            width: dropdownWidth,
            child: FadeTransition(
              opacity: _animation,
              child: Material(
                color: AppColors.transparent,
                child: Container(
                  width: dropdownWidth,
                  height: dropdownHeight,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusL,
                    ),
                    border: Border.all(
                      color: AppColors.primaryBlue,
                      width: AppDimensions.borderWidthMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusL - 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildDropdownItems(dropdownHeight),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDropdownItems(double dropdownHeight) {
    final List<Widget> children = [];
    final itemCount = widget.items.length;
    final availableHeight = dropdownHeight - 4;
    final itemHeight = availableHeight / itemCount;
    for (int i = 0; i < itemCount; i++) {
      final item = widget.items[i];
      final selected = item.value == widget.value;
      children.add(
        SizedBox(
          height: itemHeight,
          child: InkWell(
            onTap: () {
              widget.onChanged(item.value);
              _close();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.tableAlternateRowBackground
                    : AppColors.transparent,
                border: i < itemCount - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          width: AppDimensions.borderWidthThin,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  _buildLeftIcon(item.iconPath),
                  Expanded(child: Text(item.label, style: _textStyle)),
                  _buildTrailingIcon(item.trailingIconPath),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    return SizedBox(
      width: widget.width,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            height: _fieldHeight,
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
              border: Border.all(
                color: AppColors.primaryBlue,
                width: AppDimensions.borderWidthMedium,
              ),
            ),
            child: Row(
              children: [
                if (_hasSelection && selected != null)
                  _buildLeftIcon(selected.iconPath),
                Expanded(
                  child: Text(
                    _hasSelection && selected != null
                        ? selected.label
                        : widget.hintText,
                    style: _textStyle,
                  ),
                ),
                if (widget.items.isNotEmpty &&
                    widget.items.first.trailingIconPath != null)
                  _buildTrailingIcon(widget.items.first.trailingIconPath),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
