import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/constants/auth_constants.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/alert_model.dart';

abstract class AlertSocketDatasource {
  Stream<AlertModel> get alertStream;

  /// Emits once each time the server confirms successful auth (event: 'connected').
  Stream<void> get connectedStream;
  bool get isConnected;
  Future<void> connect();
  void disconnect();
}

class AlertSocketDatasourceImpl implements AlertSocketDatasource {
  io.Socket? _socket;
  final StreamController<AlertModel> _controller =
      StreamController<AlertModel>.broadcast();
  final StreamController<void> _connectedController =
      StreamController<void>.broadcast();

  void _log(String message) {
    debugPrint('[AlertSocket] $message');
  }

  @override
  Stream<AlertModel> get alertStream => _controller.stream;

  @override
  Stream<void> get connectedStream => _connectedController.stream;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  Future<void> connect() async {
    _log('connect() called');
    final token = await AuthLocalDataSource.instance.getAuthToken();
    _log(
      'getAuthToken() returned: ${token == null ? 'NULL' : 'length=${token.length} prefix=${token.substring(0, token.length < 12 ? token.length : 12)}...'}',
    );
    if (token == null || token.isEmpty) {
      _log('No auth token found. Socket connect skipped.');
      return;
    }
    _log('Token valid. Proceeding to connect.');

    _log('Disconnecting previous socket instance (if any)');
    disconnect();

    final socketUrl = AuthConstants.socketUrl
        .replaceFirst('ws://', 'http://')
        .replaceFirst('wss://', 'https://');
    _log('Socket URL prepared: $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'authorization': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(2000)
          .build(),
    );
    _log('Socket created, registering event handlers');

    _socket!.onConnect((_) {
      _log('onConnect: connected=true id=${_socket?.id}');
    });

    _socket!.onAny((event, data) {
      _log('onAny event=$event');
    });

    _socket!.on('connected', (data) {
      _log('Server confirmed auth: $data');
      if (!_connectedController.isClosed) _connectedController.add(null);
    });

    _socket!.onConnectError((error) {
      _log('onConnectError: $error');
    });

    _socket!.onReconnectAttempt((attempt) {
      _log('onReconnectAttempt: attempt=$attempt');
    });

    _socket!.onReconnect((attempt) {
      _log('onReconnect: attempt=$attempt');
    });

    _socket!.onReconnectError((error) {
      _log('onReconnectError: $error');
    });

    _socket!.onReconnectFailed((_) {
      _log('onReconnectFailed');
    });

    _socket!.on(AuthConstants.socketAlertEvent, (data) {
      _log(
        'Event received: ${AuthConstants.socketAlertEvent} payloadType=${data.runtimeType}',
      );
      try {
        Map<String, dynamic> json;
        if (data is String) {
          json = jsonDecode(data) as Map<String, dynamic>;
        } else if (data is Map) {
          json = Map<String, dynamic>.from(data);
        } else {
          _log('Unsupported payload type: ${data.runtimeType}');
          return;
        }
        final alert = AlertModel.fromJson(json);
        _log(
          'Parsed alert: type=${alert.alertType.name} message=${alert.message} createdAt=${alert.createdAt}',
        );
        if (!_controller.isClosed) {
          _controller.add(alert);
          _log('Alert pushed to stream');
        } else {
          _log('Stream is closed. Alert dropped.');
        }
      } catch (e, s) {
        _log('Payload parse failed: $e');
        _log('Stack: $s');
      }
    });

    _socket!.onDisconnect((reason) {
      _log('onDisconnect: reason=$reason');
    });

    _socket!.onError((error) {
      _log('onError: $error');
    });

    _log('Calling socket.connect()');
    _socket!.connect();
  }

  @override
  void disconnect() {
    _log(
      'disconnect() called. connected=${_socket?.connected} id=${_socket?.id}',
    );
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _log('Socket disposed.');
  }

  void dispose() {
    disconnect();
    _controller.close();
    _connectedController.close();
  }
}
