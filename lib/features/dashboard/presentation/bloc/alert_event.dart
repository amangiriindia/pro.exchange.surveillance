import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();
  @override
  List<Object?> get props => [];
}

class AlertConnectEvent extends AlertEvent {
  const AlertConnectEvent();
}

class AlertDisconnectEvent extends AlertEvent {
  const AlertDisconnectEvent();
}

class AlertServerConnectedEvent extends AlertEvent {
  const AlertServerConnectedEvent();
}

class AlertReceivedEvent extends AlertEvent {
  final AlertEntity alert;
  const AlertReceivedEvent(this.alert);
  @override
  List<Object?> get props => [alert];
}

class AlertDismissedEvent extends AlertEvent {
  final AlertEntity alert;
  const AlertDismissedEvent(this.alert);
  @override
  List<Object?> get props => [alert];
}
