import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/alert_socket_datasource.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertSocketDatasource datasource;
  StreamSubscription? _subscription;
  StreamSubscription? _connectedSubscription;

  void _log(String message) {
    debugPrint('[AlertBloc] $message');
  }

  AlertBloc({required this.datasource}) : super(const AlertInitialState()) {
    on<AlertConnectEvent>(_onConnect);
    on<AlertDisconnectEvent>(_onDisconnect);
    on<AlertServerConnectedEvent>(_onServerConnected);
    on<AlertReceivedEvent>(_onReceived);
    on<AlertDismissedEvent>(_onDismissed);
  }

  Future<void> _onConnect(
    AlertConnectEvent event,
    Emitter<AlertState> emit,
  ) async {
    _log('AlertConnectEvent received');

    if (_subscription == null) {
      _log('Subscribing to datasource.alertStream');
      _subscription = datasource.alertStream.listen((alert) {
        _log('Stream listener received alert: type=${alert.alertType.name}');
        add(AlertReceivedEvent(alert));
      });
    } else {
      _log('alertStream already subscribed');
    }

    if (_connectedSubscription == null) {
      _log('Subscribing to datasource.connectedStream');
      _connectedSubscription = datasource.connectedStream.listen((_) {
        _log('connectedStream fired -> emitting AlertConnectedState');
        add(const AlertServerConnectedEvent());
      });
    } else {
      _log('connectedStream already subscribed');
    }

    _log('Subscriptions ready. Calling datasource.connect()...');
    await datasource.connect();
    _log('Datasource connect() returned.');
  }

  void _onServerConnected(
    AlertServerConnectedEvent event,
    Emitter<AlertState> emit,
  ) {
    emit(const AlertConnectedState());
    _log('State emitted: AlertConnectedState');
  }

  void _onDisconnect(AlertDisconnectEvent event, Emitter<AlertState> emit) {
    _log('AlertDisconnectEvent received');
    _subscription?.cancel();
    _subscription = null;
    _connectedSubscription?.cancel();
    _connectedSubscription = null;
    datasource.disconnect();
    emit(const AlertInitialState());
    _log('State emitted: AlertInitialState');
  }

  void _onReceived(AlertReceivedEvent event, Emitter<AlertState> emit) {
    _log('AlertReceivedEvent received. Emitting toast state.');
    emit(AlertNewNotificationState(event.alert));
  }

  void _onDismissed(AlertDismissedEvent event, Emitter<AlertState> emit) {
    emit(const AlertConnectedState());
  }

  @override
  Future<void> close() {
    _log('close() called');
    _subscription?.cancel();
    _subscription = null;
    _connectedSubscription?.cancel();
    _connectedSubscription = null;
    datasource.disconnect();
    return super.close();
  }
}
