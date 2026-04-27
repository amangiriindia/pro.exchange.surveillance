import 'package:equatable/equatable.dart';

abstract class BulkOrderDetailsEvent extends Equatable {
  const BulkOrderDetailsEvent();
  @override
  List<Object> get props => [];
}

class LoadBulkOrderDetails extends BulkOrderDetailsEvent {
  final int alertId;

  const LoadBulkOrderDetails({required this.alertId});

  @override
  List<Object> get props => [alertId];
}
