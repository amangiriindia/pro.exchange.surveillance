import 'dart:async';

import 'package:surveillance/core/constants/app_colors.dart';
import 'package:surveillance/core/constants/app_images.dart';
import 'package:surveillance/core/widget/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewTableColumn {
  final String id;
  final String label;
  final double width;
  final bool isNumeric;
  final bool sortable;
  final Widget? customHeaderWidget;
  final Alignment? alignment;

  final int headerLines;
  const ViewTableColumn({
    required this.id,
    required this.label,
    required this.width,
    this.isNumeric = false,
    this.sortable = true,
    this.customHeaderWidget,
    this.alignment,
    this.headerLines = 1,
  });
}

class ViewDataTable<T> extends StatefulWidget {
  final List<ViewTableColumn> columns;
  final List<T> data;
  final Widget Function(T item, ViewTableColumn column) cellBuilder;
  final String Function(T item) idExtractor;
  final String? selectedId;
  final Function(T item)? onRowTap;
  final Function(T item)? onRowSecondaryTap;
  final Function(String columnId, bool ascending)? onSort;
  final String? sortColumn;
  final bool sortAscending;
  final bool isDarkMode;
  final String emptyMessage;
  final double? rowHeight;
  final double? headerHeight;
  final Widget Function(List<ViewTableColumn> columns)? footerBuilder;
  final bool autoFit;
  final Color? headerBgColor;
  final bool shrinkWrap;
  final Comparable Function(T item, String columnId)? comparatorBuilder;
  final bool isStart;
  final bool isBorderFit;
  final double? headerTextSize;
  final double? bodyTextSize;
  final Color? Function(T item, int index)? rowBackgroundBuilder;
  final BoxDecoration? tableBoxDecoration;
  final bool showRowBorders;
  final Iterable<String> Function(T item)? keyboardSearchValues;
  final Duration keyboardSearchResetDelay;
  final int keyboardSearchSelectionThreshold;
  final int keyboardSearchMaxLength;
  const ViewDataTable({
    Key? key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    required this.idExtractor,
    this.selectedId,
    this.onRowTap,
    this.onRowSecondaryTap,
    this.onSort,
    this.sortColumn,
    this.sortAscending = true,
    this.isDarkMode = false,
    this.emptyMessage = 'No data found',
    this.rowHeight,
    this.headerHeight,
    this.footerBuilder,
    this.autoFit = false,
    this.headerBgColor,
    this.shrinkWrap = false,
    this.comparatorBuilder,
    this.isStart = false,
    this.isBorderFit = false,
    this.headerTextSize,
    this.bodyTextSize,
    this.rowBackgroundBuilder,
    this.tableBoxDecoration,
    this.showRowBorders = true,
    this.keyboardSearchValues,
    this.keyboardSearchResetDelay = const Duration(seconds: 1),
    this.keyboardSearchSelectionThreshold = 1,
    this.keyboardSearchMaxLength = 5,
  }) : super(key: key);
  @override
  State<ViewDataTable<T>> createState() => _ViewDataTableState<T>();
}

class _ViewDataTableState<T> extends State<ViewDataTable<T>> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  String? _internalSortColumn;
  bool _internalSortAscending = true;
  List<T>? _sortedData;
  String? _selectedId;
  final FocusNode _focusNode = FocusNode();
  List<ViewTableColumn> _activeColumns = [];
  Map<String, double> _columnWidths = {};
  final Set<String> _manuallyResizedColumns = {};
  String? _dragTargetColumnId;
  Timer? _keyboardSearchResetTimer;
  String _keyboardSearchBuffer = '';
  bool get _useInternalSort =>
      widget.comparatorBuilder != null && widget.onSort == null;
  String? get _activeSortColumn =>
      _useInternalSort ? _internalSortColumn : widget.sortColumn;
  bool get _activeSortAscending =>
      _useInternalSort ? _internalSortAscending : widget.sortAscending;
  List<T> get _displayData {
    if (_useInternalSort && _sortedData != null) {
      return _sortedData!;
    }
    return widget.data;
  }

  @override
  void initState() {
    super.initState();
    _activeColumns = List.from(widget.columns);
    for (var col in widget.columns) {
      _columnWidths[col.id] = col.width;
    }
    _selectedId = widget.selectedId;
  }

  void _onColumnReorder(String fromId, String toId) {
    if (fromId == toId) return;
    setState(() {
      final fromIndex = _activeColumns.indexWhere((c) => c.id == fromId);
      final toIndex = _activeColumns.indexWhere((c) => c.id == toId);
      if (fromIndex != -1 && toIndex != -1) {
        final col = _activeColumns.removeAt(fromIndex);
        _activeColumns.insert(toIndex, col);
      }
    });
  }

  void _onColumnResize(
    String columnId,
    double delta,
    double minWidth,
    double scale,
  ) {
    setState(() {
      final currentWidth = (_columnWidths[columnId] ?? minWidth) * scale;
      final newWidth = (currentWidth + delta).clamp(minWidth, double.infinity);
      _columnWidths[columnId] = newWidth / scale;
      _manuallyResizedColumns.add(columnId);
    });
  }

  void _handleSort(String columnId) {
    if (_useInternalSort) {
      setState(() {
        if (_internalSortColumn == columnId) {
          _internalSortAscending = !_internalSortAscending;
        } else {
          _internalSortColumn = columnId;
          _internalSortAscending = true;
        }
        _sortedData = List<T>.from(widget.data);
        _sortedData!.sort((a, b) {
          final aVal = widget.comparatorBuilder!(a, columnId);
          final bVal = widget.comparatorBuilder!(b, columnId);
          final comparison = aVal.compareTo(bVal);
          return _internalSortAscending ? comparison : -comparison;
        });
      });
    } else if (widget.onSort != null) {
      final newAscending = _activeSortColumn == columnId
          ? !_activeSortAscending
          : true;
      widget.onSort!(columnId, newAscending);
    }
  }

  @override
  void didUpdateWidget(covariant ViewDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns != widget.columns) {
      _activeColumns = List.from(widget.columns);
      for (var col in widget.columns) {
        _columnWidths[col.id] = col.width;
      }
    }
    if (_useInternalSort && oldWidget.data != widget.data) {
      if (_internalSortColumn != null) {
        _sortedData = List<T>.from(widget.data);
        _sortedData!.sort((a, b) {
          final aVal = widget.comparatorBuilder!(a, _internalSortColumn!);
          final bVal = widget.comparatorBuilder!(b, _internalSortColumn!);
          final comparison = aVal.compareTo(bVal);
          return _internalSortAscending ? comparison : -comparison;
        });
      } else {
        _sortedData = null;
      }
    }
    if (oldWidget.selectedId != widget.selectedId) {
      _selectedId = widget.selectedId;
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _keyboardSearchResetTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  double get _totalOriginalWidth {
    return _activeColumns.fold<double>(0, (sum, col) => sum + col.width);
  }

  Color get _headerBgColor =>
      widget.headerBgColor ??
      (widget.isDarkMode
          ? DarkThemeColors.tableColumnHeadColor
          : LightThemeColors.tableColumnHeadColor);
  Color get _rowBgColor => widget.isDarkMode
      ? DarkThemeColors.tableRowBackground
      : LightThemeColors.tableRowBackground;
  Color get _selectedRowBgColor => widget.isDarkMode
      ? DarkThemeColors.selectedRowBackground
      : LightThemeColors.selectedRowBackground;
  Color get _dividerColor =>
      widget.isDarkMode ? DarkThemeColors.dividerColor : AppColors.greyBorder;
  Color get _textColor => widget.isDarkMode
      ? DarkThemeColors.textColor
      : LightThemeColors.textColor;

  Color get _headerTextColor {
    final bg = _headerBgColor;
    final luminance = bg.computeLuminance();
    return luminance < 0.4 ? Colors.white : _textColor;
  }

  @override
  Widget build(BuildContext context) {
    final rowHeight = widget.rowHeight ?? 30.h;
    final int maxHeaderLines = widget.columns.fold(1, (max, c) {
      final lines = c.label.split('\n').length;
      final apparent = c.headerLines > lines ? c.headerLines : lines;
      return apparent > max ? apparent : max;
    });
    final headerHeight =
        widget.headerHeight ??
        (maxHeaderLines >= 3
            ? 55.h
            : maxHeaderLines == 2
            ? 40.h
            : 35.h);
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.primaryBlue),
        ),
      ),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) => _handleKeyEvent(event, rowHeight),
        child: GestureDetector(
          onTap: () {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
          },
          child: Align(
            alignment: widget.isStart ? Alignment.topLeft : Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(0.w, 4.h, 0.w, 10.h),
              decoration:
                  widget.tableBoxDecoration ??
                  BoxDecoration(
                    color: _rowBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _dividerColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalOriginalWidth = _totalOriginalWidth;
                  final scale =
                      widget.autoFit &&
                          constraints.maxWidth > totalOriginalWidth
                      ? constraints.maxWidth / totalOriginalWidth
                      : 1.0;
                  double totalWidth = 0;
                  for (var col in _activeColumns) {
                    totalWidth += (_columnWidths[col.id] ?? col.width) * scale;
                  }
                  final bool isScrollableX = totalWidth > constraints.maxWidth;
                  final contentWidth = widget.isBorderFit
                      ? constraints.maxWidth.clamp(totalWidth, double.infinity)
                      : totalWidth;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: widget.shrinkWrap
                        ? _buildShrinkWrapContent(
                            headerHeight,
                            rowHeight,
                            contentWidth,
                            scale,
                            isScrollableX,
                          )
                        : _buildExpandedContent(
                            headerHeight,
                            rowHeight,
                            contentWidth,
                            scale,
                            isScrollableX,
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, double rowHeight) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_handleKeyboardSearch(event, rowHeight)) {
      return KeyEventResult.handled;
    }
    final logicalKey = event.logicalKey;
    if (logicalKey == LogicalKeyboardKey.arrowDown ||
        logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveSelection(logicalKey == LogicalKeyboardKey.arrowDown, rowHeight);
      return KeyEventResult.handled;
    }
    if (logicalKey == LogicalKeyboardKey.arrowLeft ||
        logicalKey == LogicalKeyboardKey.arrowRight) {
      _scrollHorizontal(logicalKey == LogicalKeyboardKey.arrowRight);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _handleKeyboardSearch(KeyEvent event, double rowHeight) {
    if (widget.keyboardSearchValues == null || _displayData.isEmpty) {
      return false;
    }
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return false;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_keyboardSearchBuffer.isEmpty) {
        return false;
      }
      _keyboardSearchBuffer = _keyboardSearchBuffer.substring(
        0,
        _keyboardSearchBuffer.length - 1,
      );
      _selectKeyboardSearchMatch(rowHeight);
      _restartKeyboardSearchResetTimer();
      return true;
    }

    final character = event.character;
    if (character == null || character.trim().isEmpty) {
      return false;
    }

    final normalizedCharacter = character.toUpperCase();
    if (!RegExp(r'[A-Z0-9]').hasMatch(normalizedCharacter)) {
      return false;
    }

    if (_keyboardSearchBuffer.length >= widget.keyboardSearchMaxLength) {
      _restartKeyboardSearchResetTimer();
      return true;
    }

    _keyboardSearchBuffer = '$_keyboardSearchBuffer$normalizedCharacter';
    _selectKeyboardSearchMatch(rowHeight);
    _restartKeyboardSearchResetTimer();
    return true;
  }

  void _selectKeyboardSearchMatch(double rowHeight) {
    final query = _normalizeKeyboardSearchValue(_keyboardSearchBuffer);
    if (query.length < widget.keyboardSearchSelectionThreshold) {
      return;
    }

    T? match;
    for (final item in _displayData) {
      final values = widget.keyboardSearchValues!(item);
      final normalizedValues = values
          .map(_normalizeKeyboardSearchValue)
          .where((value) => value.isNotEmpty)
          .toList();
      if (normalizedValues.any((value) => value.startsWith(query))) {
        match = item;
        break;
      }
    }

    match ??= _displayData.cast<T?>().firstWhere((item) {
      if (item == null) return false;
      final values = widget.keyboardSearchValues!(item);
      final normalizedValues = values
          .map(_normalizeKeyboardSearchValue)
          .where((value) => value.isNotEmpty)
          .toList();
      return normalizedValues.any((value) => value.contains(query));
    }, orElse: () => null);

    if (match == null) {
      return;
    }

    final index = _displayData.indexOf(match);
    setState(() {
      _selectedId = widget.idExtractor(match!);
    });
    if (widget.onRowTap != null) {
      widget.onRowTap!(match);
    }
    _scrollToIndex(index, rowHeight);
  }

  String _normalizeKeyboardSearchValue(String value) {
    return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  void _restartKeyboardSearchResetTimer() {
    _keyboardSearchResetTimer?.cancel();
    _keyboardSearchResetTimer = Timer(widget.keyboardSearchResetDelay, () {
      _keyboardSearchBuffer = '';
    });
  }

  void _moveSelection(bool down, double rowHeight) {
    if (_displayData.isEmpty) return;
    int currentIndex = -1;
    if (_selectedId != null) {
      currentIndex = _displayData.indexWhere(
        (item) => widget.idExtractor(item) == _selectedId,
      );
    }
    int nextIndex;
    if (down) {
      nextIndex = (currentIndex + 1).clamp(0, _displayData.length - 1);
    } else {
      nextIndex = (currentIndex - 1).clamp(0, _displayData.length - 1);
    }
    if (nextIndex != currentIndex) {
      final item = _displayData[nextIndex];
      setState(() {
        _selectedId = widget.idExtractor(item);
      });
      if (widget.onRowTap != null) {
        widget.onRowTap!(item);
      }
      _scrollToIndex(nextIndex, rowHeight);
    }
  }

  void _scrollToIndex(int index, double rowHeight) {
    if (!_verticalScrollController.hasClients) return;
    final offset = index * rowHeight;
    final viewportHeight = _verticalScrollController.position.viewportDimension;
    final currentOffset = _verticalScrollController.offset;
    if (offset < currentOffset) {
      _verticalScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    } else if (offset + rowHeight > currentOffset + viewportHeight) {
      _verticalScrollController.animateTo(
        offset + rowHeight - viewportHeight,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollHorizontal(bool right) {
    if (!_horizontalScrollController.hasClients) return;
    final delta = right ? 100.0 : -100.0;
    final targetOffset = (_horizontalScrollController.offset + delta).clamp(
      0.0,
      _horizontalScrollController.position.maxScrollExtent,
    );
    _horizontalScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildExpandedContent(
    double headerHeight,
    double rowHeight,
    double totalWidth,
    double scale,
    bool isScrollableX,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderRow(headerHeight, scale),
                    Flexible(
                      fit: FlexFit.loose,
                      child: _displayData.isEmpty
                          ? _buildEmptyState()
                          : _buildDataRows(rowHeight, scale),
                    ),
                    if (widget.footerBuilder != null)
                      _buildFooterRow(rowHeight, scale, isScrollableX),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShrinkWrapContent(
    double headerHeight,
    double rowHeight,
    double totalWidth,
    double scale,
    bool isScrollableX,
  ) {
    return SingleChildScrollView(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderRow(headerHeight, scale),
            _displayData.isEmpty
                ? SizedBox(height: 150.h, child: _buildEmptyState())
                : _buildDataRows(rowHeight, scale),
            if (widget.footerBuilder != null)
              _buildFooterRow(rowHeight, scale, isScrollableX),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool darkMode = widget.isDarkMode;
    final Color titleColor = darkMode ? Colors.white38 : Colors.black38;
    final Color iconColor = darkMode
        ? DarkThemeColors.supportiveTextColor
        : const Color(0xFF9EDFEA);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56.sp, color: iconColor),
          SizedBox(height: 14.h),
          Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double headerHeight, double scale) {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: _headerBgColor,
        border: Border(
          bottom: BorderSide(
            color: _headerTextColor.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: _activeColumns.asMap().entries.map((entry) {
          final index = entry.key;
          final column = entry.value;
          final isLast = index == _activeColumns.length - 1;
          return _buildHeaderCell(column, isLast, scale, headerHeight);
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCell(
    ViewTableColumn column,
    bool isLast,
    double scale,
    double headerRowHeight,
  ) {
    final int effectiveLines =
        column.label.split('\n').length > column.headerLines
        ? column.label.split('\n').length
        : column.headerLines;

    final isSorted = _activeSortColumn == column.id;
    final originalWidth = widget.columns
        .firstWhere((c) => c.id == column.id)
        .width;
    final cellWidth = (_columnWidths[column.id] ?? originalWidth) * scale;

    const headerAlignment = Alignment.center;
    Widget content = Align(
      alignment: headerAlignment,
      child: Padding(
        padding: EdgeInsets.only(left: 2.w, right: isLast ? 14.w : 2.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (column.customHeaderWidget != null)
              column.customHeaderWidget!
            else ...[
              Flexible(
                child: Text(
                  column.label,
                  style: GoogleFonts.inter(
                    fontSize: effectiveLines >= 3
                        ? (widget.headerTextSize != null
                              ? widget.headerTextSize! - 2.sp
                              : 10.sp)
                        : effectiveLines == 2
                        ? (widget.headerTextSize != null
                              ? widget.headerTextSize! - 1.sp
                              : 11.sp)
                        : (widget.headerTextSize ?? 11.sp),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    color: _headerTextColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: effectiveLines > 1 ? effectiveLines : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (column.sortable) ...[
                SizedBox(width: 4.w),
                SvgIcon(
                  assetPath: AppImages.sortIcon,
                  isActive: isSorted,
                  size: 12.sp,
                  activeColor: isSorted
                      ? _headerTextColor
                      : _headerTextColor.withOpacity(0.5),
                ),
              ],
            ],
          ],
        ),
      ),
    );
    Widget headerItem = GestureDetector(
      onTap: column.sortable ? () => _handleSort(column.id) : null,
      child: Container(
        width: cellWidth,
        height: headerRowHeight,
        decoration: BoxDecoration(
          border: _dragTargetColumnId == column.id
              ? Border(left: BorderSide(color: AppColors.blue, width: 2.5))
              : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(child: content),
            if (!isLast)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 1.5,
                child: Container(
                  color: widget.isDarkMode
                      ? DarkThemeColors.dividerColor
                      : AppColors.white,
                ),
              ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 20.w,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    _onColumnResize(
                      column.id,
                      details.delta.dx,
                      originalWidth,
                      scale,
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        if (details.data != column.id) {
          setState(() => _dragTargetColumnId = column.id);
          return true;
        }
        return false;
      },
      onLeave: (_) {
        if (_dragTargetColumnId == column.id) {
          setState(() => _dragTargetColumnId = null);
        }
      },
      onAcceptWithDetails: (details) {
        setState(() => _dragTargetColumnId = null);
        _onColumnReorder(details.data, column.id);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<String>(
          data: column.id,
          axis: Axis.horizontal,
          delay: const Duration(milliseconds: 150),
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4.r),
            color: _headerBgColor,
            child: Container(
              width: cellWidth,
              height: 35.h,
              alignment: Alignment.center,
              child: Text(
                column.label,
                style: GoogleFonts.inter(
                  fontSize: (widget.headerTextSize ?? 11.sp) - 1.sp,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: _headerTextColor,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.4, child: headerItem),
          child: headerItem,
        );
      },
    );
  }

  Widget _buildDataRows(double rowHeight, double scale) {
    return Scrollbar(
      controller: widget.shrinkWrap ? null : _verticalScrollController,
      thumbVisibility: !widget.shrinkWrap,
      child: ListView.builder(
        controller: widget.shrinkWrap ? null : _verticalScrollController,
        padding: EdgeInsets.only(
          bottom: widget.footerBuilder != null ? 0 : 14.h,
        ),
        shrinkWrap: true,
        physics: widget.shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        itemCount: _displayData.length,
        itemBuilder: (context, index) {
          final item = _displayData[index];
          final itemId = widget.idExtractor(item);
          final isSelected = itemId == widget.selectedId;
          final isLast = index == _displayData.length - 1;
          return _buildDataRow(
            item,
            index,
            isSelected,
            isLast,
            rowHeight,
            scale,
          );
        },
      ),
    );
  }

  Widget _buildDataRow(
    T item,
    int index,
    bool isSelected,
    bool isLast,
    double rowHeight,
    double scale,
  ) {
    final effectiveIsSelected = widget.idExtractor(item) == _selectedId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedId = widget.idExtractor(item);
        });
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
        if (widget.onRowTap != null) {
          widget.onRowTap!(item);
        }
      },
      onSecondaryTapDown: widget.onRowSecondaryTap != null
          ? (details) => widget.onRowSecondaryTap!(item)
          : null,
      child: Container(
        height: rowHeight,
        decoration: BoxDecoration(
          color:
              widget.rowBackgroundBuilder?.call(item, index) ??
              (effectiveIsSelected ? _selectedRowBgColor : _rowBgColor),
          border: isLast || !widget.showRowBorders
              ? null
              : Border(
                  bottom: BorderSide(
                    color: _dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: _activeColumns.map((column) {
            final isLastColumn = column == _activeColumns.last;
            final colWidth = (_columnWidths[column.id] ?? column.width) * scale;
            final effectiveAlignment =
                column.alignment ??
                (column.isNumeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft);
            return Container(
              width: colWidth,
              alignment: effectiveAlignment,
              padding: EdgeInsets.only(
                left:
                    15.w +
                    (effectiveAlignment == Alignment.centerLeft ? 8.w : 0),
                right:
                    (isLastColumn ? 14.w : 15.w) +
                    (effectiveAlignment == Alignment.centerRight ? 8.w : 0),
              ),
              child: _normalizeEmptyTextCell(widget.cellBuilder(item, column)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _normalizeEmptyTextCell(Widget cell) {
    if (cell is! Text) {
      return cell;
    }

    final rawText = cell.data ?? cell.textSpan?.toPlainText() ?? '';
    if (rawText.trim().isNotEmpty) {
      return cell;
    }

    return Text(
      '-',
      style: cell.style,
      maxLines: cell.maxLines,
      softWrap: cell.softWrap,
      overflow: cell.overflow,
      textAlign: cell.textAlign,
      textWidthBasis: cell.textWidthBasis,
    );
  }

  Widget _buildFooterRow(double rowHeight, double scale, bool isScrollableX) {
    final scaledColumns = _activeColumns
        .map(
          (c) => ViewTableColumn(
            id: c.id,
            label: c.label,
            width: (_columnWidths[c.id] ?? c.width) * scale,
            isNumeric: c.isNumeric,
            sortable: c.sortable,
            customHeaderWidget: c.customHeaderWidget,
            alignment: c.alignment,
            headerLines: c.headerLines,
          ),
        )
        .toList();
    return Container(
      decoration: BoxDecoration(
        color: _headerBgColor,
        border: Border(top: BorderSide(color: _dividerColor, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: isScrollableX ? 12.h : 0),
      child: widget.footerBuilder!(scaledColumns),
    );
  }
}
