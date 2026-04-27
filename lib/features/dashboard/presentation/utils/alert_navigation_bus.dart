import 'dart:async';

/// Global event bus: when a toast is tapped, emits the alert-type string
/// (e.g. 'GROUP_TRADE') so the dashboard can navigate to the right tab.
class AlertNavigationBus {
  AlertNavigationBus._();
  static final AlertNavigationBus instance = AlertNavigationBus._();

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void navigateTo(String alertType) {
    _controller.add(alertType);
  }
}
