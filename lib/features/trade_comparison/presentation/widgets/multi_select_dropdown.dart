import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MultiSelectSearchAdd extends StatefulWidget {
  final List<String> items;
  final String hintText;
  
  const MultiSelectSearchAdd({
    super.key, 
    required this.items,
    required this.hintText,
  });

  @override
  State<MultiSelectSearchAdd> createState() => _MultiSelectSearchAddState();
}

class _MultiSelectSearchAddState extends State<MultiSelectSearchAdd> {
  bool isExpanded = false;
  final List<String> selectedItems = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (isExpanded) {
      _overlayEntry?.remove();
      setState(() => isExpanded = false);
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => isExpanded = true);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 250,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  return CheckboxListTile(
                    title: Text(item, style: GoogleFonts.openSans(fontSize: 13)),
                    value: selectedItems.contains(item),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedItems.add(item);
                        } else {
                          selectedItems.remove(item);
                        }
                      });
                      _overlayEntry?.markNeedsBuild();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleOverlay,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedItems.isEmpty 
                    ? widget.hintText 
                    : selectedItems.join(', '),
                  style: GoogleFonts.openSans(
                    fontSize: 13, 
                    color: selectedItems.isEmpty ? Colors.black54 : Colors.black87
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
