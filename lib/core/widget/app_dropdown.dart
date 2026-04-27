import 'package:surveillance/core/widget/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

enum AppDropdownType { simple, search, multiSelect, multiSelectRightNoSearch }

class AppDropdown extends StatefulWidget {
  final AppDropdownType type;
  final String hintText;
  final String? value;
  final List<String>? selectedValues;
  final List<String> items;
  final List<String>? subtitles;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<List<String>>? onMultiChanged;
  final double? width;
  final double? height;
  final double? dropdownHeight;
  final String searchHint;
  final bool showAllOption;
  final String allOptionText;
  final Color? borderColor;
  final Color? textColor;
  final bool isDarkMode;
  final String? label;
  final Color? labelColor;
  final bool showSelectAll;
  final FocusNode? focusNode;
  final bool autofocus;
  const AppDropdown({
    Key? key,
    this.type = AppDropdownType.simple,
    required this.hintText,
    this.value,
    this.selectedValues,
    required this.items,
    this.onChanged,
    this.onMultiChanged,
    this.width,
    this.height,
    this.dropdownHeight,
    this.searchHint = 'Search & Add',
    this.showAllOption = false,
    this.allOptionText = 'All',
    this.borderColor,
    this.textColor,
    this.isDarkMode = false,
    this.showSelectAll = true,
    this.label,
    this.labelColor,
    this.subtitles,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);
  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _filteredItems = [];
  Set<String> _selectedSet = {};
  late AnimationController _controller;
  late Animation<double> _animation;
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  int _highlightedIndex = -1;
  FocusScopeNode? _overlayScopeNode;
  FocusNode? _overlayItemsFocusNode;
  FocusNode? _searchFieldFocusNode;
  bool _moveToNextFocusOnClose = false;
  bool _moveToPrevFocusOnClose = false;
  bool _returnFocusOnClose = false;
  bool _suppressAutoOpen = false;
  static bool _keyboardNavigating = false;

  List<String> get _itemsForList {
    if (!widget.showAllOption || widget.type != AppDropdownType.simple) {
      return widget.items;
    }
    final normalizedAll = widget.allOptionText.trim().toLowerCase();
    return widget.items
        .where((item) => item.trim().toLowerCase() != normalizedAll)
        .toList();
  }

  bool get _hasSearchField =>
      widget.type != AppDropdownType.simple &&
      widget.type != AppDropdownType.multiSelectRightNoSearch;
  static const int _maxVisibleItems = 6;
  static double get _itemHeight => 26.h;
  static double get _searchFieldHeight => 32.h;
  static double get _selectAllHeight => 26.h;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _filteredItems = List.from(_itemsForList);
    if (widget.selectedValues != null) {
      _selectedSet = Set.from(widget.selectedValues!);
    }
  }

  @override
  void didUpdateWidget(AppDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = List.from(_itemsForList);
    }
    if (widget.selectedValues != null) {
      _selectedSet = Set.from(widget.selectedValues!);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _internalFocusNode?.dispose();
    _overlayScopeNode?.dispose();
    _overlayItemsFocusNode?.dispose();
    _searchFieldFocusNode?.dispose();
    super.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();
  void _open() {
    _searchController.clear();
    _filteredItems = List.from(_itemsForList);
    _highlightedIndex = _getCurrentValueIndex();
    _overlayScopeNode?.dispose();
    _overlayScopeNode = FocusScopeNode(debugLabel: 'AppDropdown-overlay');
    _overlayItemsFocusNode?.dispose();
    _overlayItemsFocusNode = FocusNode(debugLabel: 'AppDropdown-items');
    _searchFieldFocusNode?.dispose();
    _searchFieldFocusNode = FocusNode(debugLabel: 'AppDropdown-search');
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasSearchField) {
        _searchFieldFocusNode?.requestFocus();
      } else {
        _overlayItemsFocusNode?.requestFocus();
      }
    });
  }

  void _close() {
    final shouldMoveNext = _moveToNextFocusOnClose;
    final shouldMovePrev = _moveToPrevFocusOnClose;
    final shouldReturnFocus = _returnFocusOnClose;
    _moveToNextFocusOnClose = false;
    _moveToPrevFocusOnClose = false;
    _returnFocusOnClose = false;
    _controller.reverse().then((_) {
      _removeOverlay();
      if (mounted) {
        setState(() => _isOpen = false);
        if (shouldMoveNext) {
          _keyboardNavigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _effectiveFocusNode.requestFocus();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _effectiveFocusNode.nextFocus();
              }
            });
          });
        } else if (shouldMovePrev) {
          _keyboardNavigating = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _effectiveFocusNode.requestFocus();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _effectiveFocusNode.previousFocus();
              }
            });
          });
        } else if (shouldReturnFocus) {
          _suppressAutoOpen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _effectiveFocusNode.requestFocus();
          });
        }
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_itemsForList);
      } else {
        _filteredItems = _itemsForList
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onItemSelected(String item) {
    if (widget.type == AppDropdownType.multiSelect ||
        widget.type == AppDropdownType.multiSelectRightNoSearch) {
      setState(() {
        if (_selectedSet.contains(item)) {
          _selectedSet.remove(item);
        } else {
          _selectedSet.add(item);
        }
      });
      widget.onMultiChanged?.call(_selectedSet.toList());
      _overlayEntry?.markNeedsBuild();
    } else {
      widget.onChanged?.call(item);
      _close();
    }
  }

  void _onSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedSet = Set.from(widget.items);
      } else {
        _selectedSet.clear();
      }
    });
    widget.onMultiChanged?.call(_selectedSet.toList());
    _overlayEntry?.markNeedsBuild();
  }

  Color get _borderColor =>
      widget.borderColor ??
      (widget.isDarkMode
          ? Colors.white.withOpacity(0.15)
          : const Color(0xFFCBD5E1));

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_isOpen) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _open();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _keyboardNavigating = true;
        _effectiveFocusNode.nextFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _keyboardNavigating = true;
        _effectiveFocusNode.previousFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleNavigationKey(KeyEvent event) {
    final itemCount = _getItemCount();
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_highlightedIndex < itemCount - 1) {
        _highlightedIndex++;
        _overlayEntry?.markNeedsBuild();
        _ensureHighlightedVisible();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_highlightedIndex > 0) {
        _highlightedIndex--;
        _overlayEntry?.markNeedsBuild();
        _ensureHighlightedVisible();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < itemCount) {
        _returnFocusOnClose = true;
        _selectHighlightedItem();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_searchFieldFocusNode?.hasFocus == true) {
        return KeyEventResult.ignored;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveToNextFocusOnClose = true;
      } else {
        _moveToPrevFocusOnClose = true;
      }
      _close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _returnFocusOnClose = true;
      _close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _moveToNextFocusOnClose = true;
      if (_highlightedIndex >= 0 && _highlightedIndex < itemCount) {
        if (widget.type != AppDropdownType.multiSelect &&
            widget.type != AppDropdownType.multiSelectRightNoSearch) {
          _selectHighlightedItem();
        } else {
          _close();
        }
      } else {
        _close();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _selectHighlightedItem() {
    int effectiveIndex = _highlightedIndex;
    if (widget.showAllOption && widget.type == AppDropdownType.simple) {
      if (effectiveIndex == 0) {
        _onItemSelected('');
        return;
      }
      effectiveIndex -= 1;
    }
    if (effectiveIndex >= 0 && effectiveIndex < _filteredItems.length) {
      _onItemSelected(_filteredItems[effectiveIndex]);
    }
  }

  void _ensureHighlightedVisible() {
    if (!_scrollController.hasClients) return;
    final effectiveItemHeight = widget.subtitles != null
        ? (_itemHeight + 10.h)
        : _itemHeight;
    final targetOffset = _highlightedIndex * effectiveItemHeight;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final viewportHeight = _scrollController.position.viewportDimension;
    final currentScroll = _scrollController.offset;
    if (targetOffset < currentScroll) {
      _scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
    } else if (targetOffset + effectiveItemHeight >
        currentScroll + viewportHeight) {
      _scrollController.jumpTo(
        (targetOffset + effectiveItemHeight - viewportHeight).clamp(
          0.0,
          maxScroll,
        ),
      );
    }
  }

  int _getCurrentValueIndex() {
    if (widget.value != null && widget.value!.isNotEmpty) {
      final offset =
          (widget.showAllOption && widget.type == AppDropdownType.simple)
          ? 1
          : 0;
      final idx = _filteredItems.indexOf(widget.value!);
      return idx >= 0 ? idx + offset : 0;
    }
    return 0;
  }

  Color get _textColor =>
      widget.textColor ??
      (widget.isDarkMode
          ? DarkThemeColors.textColor
          : LightThemeColors.textColor);
  Color get _bgColor => widget.isDarkMode
      ? DarkThemeColors.cardBackground
      : LightThemeColors.cardBackground;
  Color get _dropdownBgColor =>
      widget.isDarkMode ? DarkThemeColors.cardBackground : AppColors.white;
  String get _displayText {
    if (widget.type == AppDropdownType.multiSelect ||
        widget.type == AppDropdownType.multiSelectRightNoSearch) {
      if (_selectedSet.isEmpty) return widget.hintText;
      if (_selectedSet.length == widget.items.length) return 'All Selected';
      if (_selectedSet.length == 1) return _selectedSet.first;
      return '${_selectedSet.length} Selected';
    }
    if (widget.value != null && widget.value!.isNotEmpty) {
      return widget.value!;
    }
    return widget.hintText;
  }

  double _calculateDropdownHeight(int filteredCount) {
    int totalItems = filteredCount;
    if (widget.showAllOption && widget.type == AppDropdownType.simple) {
      totalItems += 1;
    }
    final visibleItems = totalItems > _maxVisibleItems
        ? _maxVisibleItems
        : totalItems;
    double listHeight = visibleItems * _itemHeight;
    double searchHeight = 0;
    if (widget.type != AppDropdownType.simple &&
        widget.type != AppDropdownType.multiSelectRightNoSearch) {
      searchHeight = _searchFieldHeight;
    }
    double selectAllHeight = 0;
    if (widget.type == AppDropdownType.multiSelect && widget.showSelectAll) {
      selectAllHeight = _selectAllHeight;
    }
    if (widget.subtitles != null) {
      listHeight = visibleItems * (_itemHeight + 10.h);
    }
    return listHeight + searchHeight + selectAllHeight + 4.h;
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final targetOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    return OverlayEntry(
      builder: (context) {
        final desiredHeight =
            widget.dropdownHeight ??
            _calculateDropdownHeight(_filteredItems.length);
        final availableBelow = math.max(
          0.0,
          overlayBox.size.height - targetOffset.dy - size.height - 6.h,
        );
        final availableAbove = math.max(0.0, targetOffset.dy - 6.h);
        final openUpward =
            availableBelow < desiredHeight && availableAbove > availableBelow;
        final constrainedHeight = math.max(
          _itemHeight + 4.h,
          math.min(desiredHeight, openUpward ? availableAbove : availableBelow),
        );
        return FocusScope(
          node: _overlayScopeNode!,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
              return KeyEventResult.ignored;
            }
            return _handleNavigationKey(event);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: AppColors.transparent),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                  0,
                  openUpward ? -(constrainedHeight + 3.h) : size.height + 3.h,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width:
                        (widget.width == null ||
                            widget.width == double.infinity)
                        ? size.width
                        : widget.width,
                    child: Focus(
                      focusNode: _overlayItemsFocusNode,
                      child: FadeTransition(
                        opacity: _animation,
                        child: Material(
                          color: AppColors.transparent,
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: constrainedHeight,
                            ),
                            decoration: BoxDecoration(
                              color: _dropdownBgColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: _borderColor,
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.type != AppDropdownType.simple &&
                                    widget.type !=
                                        AppDropdownType
                                            .multiSelectRightNoSearch)
                                  _buildSearchField(),
                                if (widget.type ==
                                        AppDropdownType.multiSelect &&
                                    widget.showSelectAll)
                                  _buildSelectAllOption(),
                                Flexible(
                                  child: RawScrollbar(
                                    controller: _scrollController,
                                    thumbVisibility:
                                        _getItemCount() > _maxVisibleItems,
                                    thickness: 6.w,
                                    radius: Radius.circular(3.r),
                                    thumbColor: _borderColor.withOpacity(0.5),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: _getItemCount(),
                                      itemBuilder: (context, index) {
                                        return _buildListItem(index);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getItemCount() {
    if (widget.showAllOption && widget.type == AppDropdownType.simple) {
      return _filteredItems.length + 1;
    }
    return _filteredItems.length;
  }

  Widget _buildListItem(int index) {
    final isHighlighted = index == _highlightedIndex;
    if (widget.showAllOption &&
        widget.type == AppDropdownType.simple &&
        index == 0) {
      return _buildSimpleItem(
        widget.allOptionText,
        isAllOption: true,
        isHighlighted: isHighlighted,
      );
    }
    final itemIndex =
        (widget.showAllOption && widget.type == AppDropdownType.simple)
        ? index - 1
        : index;
    if (itemIndex < 0 || itemIndex >= _filteredItems.length) {
      return const SizedBox.shrink();
    }
    final item = _filteredItems[itemIndex];
    if (widget.type == AppDropdownType.multiSelect ||
        widget.type == AppDropdownType.multiSelectRightNoSearch) {
      return _buildCheckboxItem(item, isHighlighted: isHighlighted);
    }
    return _buildSimpleItem(
      item,
      index: itemIndex,
      isHighlighted: isHighlighted,
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      height: 26.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.primaryBlue, width: 1.0),
      ),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          SvgIcon(
            assetPath: "",
            isActive: _searchController.text.isNotEmpty,
            size: 16.w,
            activeColor: _borderColor,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFieldFocusNode,
              onChanged: _onSearch,
              style: GoogleFonts.openSans(fontSize: 12.sp, color: _textColor),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: GoogleFonts.openSans(
                  fontSize: 12.sp,
                  color: AppColors.supportiveTextColor(context),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllOption() {
    final isAllSelected =
        _selectedSet.length == widget.items.length && widget.items.isNotEmpty;
    return InkWell(
      onTap: () => _onSelectAll(!isAllSelected),
      child: Container(
        height: _selectAllHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: [
            _buildCheckbox(isAllSelected),
            SizedBox(width: 8.w),
            Text(
              'Select All',
              style: GoogleFonts.openSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String item, {bool isHighlighted = false}) {
    final isSelected = _selectedSet.contains(item);
    final isRightAlign =
        widget.type == AppDropdownType.multiSelectRightNoSearch;
    return InkWell(
      onTap: () => _onItemSelected(item),
      child: Container(
        height: _itemHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: isHighlighted
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _borderColor.withOpacity(0.0),
                    _borderColor.withOpacity(0.5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4.r),
              )
            : null,
        child: Row(
          children: [
            if (!isRightAlign) ...[
              _buildCheckbox(isSelected),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.openSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _borderColor : _textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRightAlign) ...[
              SizedBox(width: 8.w),
              _buildCheckbox(isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isChecked) {
    return Container(
      width: 14.w,
      height: 14.h,
      decoration: BoxDecoration(
        color: isChecked ? _borderColor : AppColors.transparent,
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(
          color: isChecked ? _borderColor : AppColors.secondaryTextColor,
          width: 1.0,
        ),
      ),
      child: isChecked
          ? Icon(Icons.check, size: 10.sp, color: AppColors.white)
          : null,
    );
  }

  Widget _buildSimpleItem(
    String item, {
    bool isAllOption = false,
    int index = -1,
    bool isHighlighted = false,
  }) {
    final isSelected =
        widget.value == item || (isAllOption && widget.value == null);
    final subtitle =
        (widget.subtitles != null &&
            !isAllOption &&
            index != -1 &&
            index < widget.subtitles!.length)
        ? widget.subtitles![index]
        : null;
    return InkWell(
      onTap: () => _onItemSelected(isAllOption ? '' : item),
      child: Container(
        height: subtitle != null ? _itemHeight + 10.h : _itemHeight,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: isHighlighted
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _borderColor.withOpacity(0.0),
                    _borderColor.withOpacity(0.5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4.r),
              )
            : BoxDecoration(
                color: isSelected
                    ? _borderColor.withOpacity(0.1)
                    : AppColors.transparent,
              ),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item,
              style: GoogleFonts.openSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.openSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue =
        (widget.value != null && widget.value!.isNotEmpty) ||
        _selectedSet.isNotEmpty;
    return Focus(
      focusNode: _effectiveFocusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      onFocusChange: (hasFocus) {
        if (hasFocus && !_isOpen) {
          if (_suppressAutoOpen) {
            _suppressAutoOpen = false;
            return;
          }
          if (_keyboardNavigating) {
            _keyboardNavigating = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isOpen) _open();
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: GoogleFonts.openSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: widget.labelColor ?? AppColors.white,
              ),
            ),
            SizedBox(height: 5.h),
          ],
          SizedBox(
            width: (widget.width == null || widget.width == double.infinity)
                ? null
                : widget.width,
            height: widget.height ?? 35.h,
            child: CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: _borderColor, width: 1.4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayText,
                          style: GoogleFonts.openSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            letterSpacing: 0.15,
                            color: hasValue
                                ? _textColor
                                : AppColors.primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryBlue,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
