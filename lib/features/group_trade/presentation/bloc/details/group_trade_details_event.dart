import 'package:equatable/equatable.dart';

abstract class GroupTradeDetailsEvent extends Equatable {
  const GroupTradeDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupTradeDetails extends GroupTradeDetailsEvent {
  final int alertId;
  const LoadGroupTradeDetails({required this.alertId});

  @override
  List<Object> get props => [alertId];
}
