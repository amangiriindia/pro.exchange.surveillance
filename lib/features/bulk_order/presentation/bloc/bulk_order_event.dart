import 'package:equatable/equatable.dart';

abstract class BulkOrderEvent extends Equatable {
  const BulkOrderEvent();
  @override
  List<Object> get props => [];
}

class LoadBulkOrders extends BulkOrderEvent {}

class LoadMoreBulkOrders extends BulkOrderEvent {}
