import 'package:flutter/material.dart';
import '../../domain/entities/alert_entity.dart';
import 'alert_toast_card.dart';

class AlertOverlayManager {
  AlertOverlayManager._();

  static final AlertOverlayManager _instance = AlertOverlayManager._();
  static AlertOverlayManager get instance => _instance;

  OverlayState? _overlayState;
  OverlayEntry? _containerEntry;

  final List<_ToastItem> _toasts = [];
  final Set<String> _dismissedSignatures = <String>{};
  final GlobalKey<_AlertOverlayContainerState> _containerKey =
      GlobalKey<_AlertOverlayContainerState>();

  void attach(OverlayState overlayState) {
    if (_overlayState == overlayState) return;
    _overlayState = overlayState;
    _containerEntry?.remove();
    _containerEntry = OverlayEntry(
      builder: (_) => _AlertOverlayContainer(key: _containerKey),
    );
    _overlayState!.insert(_containerEntry!);
  }

  void show(AlertEntity alert) {
    final signature = _alertSignature(alert);

    if (_dismissedSignatures.contains(signature)) {
      return;
    }

    if (_toasts.any((item) => item.signature == signature)) {
      return;
    }

    final item = _ToastItem(alert: alert);
    _toasts.add(item);
    _containerKey.currentState?._addToast(item);
  }

  void markDismissed(_ToastItem item) {
    _dismissedSignatures.add(item.signature);
    _toasts.remove(item);
  }

  String _alertSignature(AlertEntity alert) {
    return [
      alert.alertType.name,
      alert.script ?? '',
      alert.exchange ?? '',
      alert.clientIds.join(','),
      alert.tradeIds.join(','),
      alert.message,
      alert.investigateStatus,
    ].join('|');
  }
}

class _ToastItem {
  final AlertEntity alert;
  final Key key = UniqueKey();
  late final String signature;

  _ToastItem({required this.alert}) {
    signature = [
      alert.alertType.name,
      alert.script ?? '',
      alert.exchange ?? '',
      alert.clientIds.join(','),
      alert.tradeIds.join(','),
      alert.message,
      alert.investigateStatus,
    ].join('|');
  }
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
      _active.add(item);
    });
  }

  void _removeToast(_ToastItem item) {
    if (mounted) setState(() => _active.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final maxPanelHeight = MediaQuery.of(context).size.height * 0.78;

    return Positioned(
      bottom: 16,
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
                    AlertOverlayManager.instance.markDismissed(item);
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
