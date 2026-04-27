import 'package:flutter/material.dart';
import '../../domain/entities/alert_entity.dart';
import 'alert_toast_card.dart';

/// Manages a global top-right overlay queue of alert toasts.
/// Call [AlertOverlayManager.show] from anywhere after the app has navigated.
class AlertOverlayManager {
  AlertOverlayManager._();

  static final AlertOverlayManager _instance = AlertOverlayManager._();
  static AlertOverlayManager get instance => _instance;

  OverlayState? _overlayState;
  OverlayEntry? _containerEntry;

  // Queue of active toasts
  final List<_ToastItem> _toasts = [];
  final GlobalKey<_AlertOverlayContainerState> _containerKey =
      GlobalKey<_AlertOverlayContainerState>();

  /// Attach to the navigator's overlay (call once from [MaterialApp]).
  void attach(OverlayState overlayState) {
    if (_overlayState == overlayState) return;
    _overlayState = overlayState;
    _containerEntry?.remove();
    _containerEntry = OverlayEntry(
      builder: (_) => _AlertOverlayContainer(key: _containerKey),
    );
    _overlayState!.insert(_containerEntry!);
  }

  /// Show a new alert toast and keep it visible until user dismisses it.
  void show(AlertEntity alert) {
    final item = _ToastItem(alert: alert);
    _toasts.add(item);
    _containerKey.currentState?._addToast(item);
  }
}

class _ToastItem {
  final AlertEntity alert;
  final Key key = UniqueKey();
  _ToastItem({required this.alert});
}

class _AlertOverlayContainer extends StatefulWidget {
  const _AlertOverlayContainer({super.key});

  @override
  State<_AlertOverlayContainer> createState() => _AlertOverlayContainerState();
}

class _AlertOverlayContainerState extends State<_AlertOverlayContainer> {
  final List<_ToastItem> _active = [];

  void _addToast(_ToastItem item) {
    if (!mounted) return;
    setState(() {
      _active.insert(0, item);
    });
  }

  void _removeToast(_ToastItem item) {
    if (mounted) setState(() => _active.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final maxPanelHeight = MediaQuery.of(context).size.height * 0.78;

    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxPanelHeight),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: _active.map((item) {
                return AlertToastCard(
                  key: item.key,
                  alert: item.alert,
                  onDismiss: () {
                    _removeToast(item);
                    AlertOverlayManager.instance._toasts.remove(item);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
