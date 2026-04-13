import 'package:equatable/equatable.dart';

abstract class BulkOrderDetailsEvent extends Equatable {
  const BulkOrderDetailsEvent();
  @override
  List<Object> get props => [];
}

class LoadBulkOrderDetails extends BulkOrderDetailsEvent {
  final String symbol;

  const LoadBulkOrderDetails({required this.symbol});

  @override
  List<Object> get props => [symbol];
}
