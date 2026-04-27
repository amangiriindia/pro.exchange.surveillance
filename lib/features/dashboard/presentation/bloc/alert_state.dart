import 'package:equatable/equatable.dart';
import '../../domain/entities/alert_entity.dart';

abstract class AlertState extends Equatable {
  const AlertState();
  @override
  List<Object?> get props => [];
}

class AlertInitialState extends AlertState {
  const AlertInitialState();
}

class AlertConnectedState extends AlertState {
  const AlertConnectedState();
}

class AlertNewNotificationState extends AlertState {
  final AlertEntity alert;
  const AlertNewNotificationState(this.alert);
  @override
  List<Object?> get props => [alert];
}
