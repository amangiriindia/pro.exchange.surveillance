import 'dart:async';

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
