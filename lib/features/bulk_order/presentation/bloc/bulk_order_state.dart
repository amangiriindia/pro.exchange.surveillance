import 'package:equatable/equatable.dart';
import '../../domain/entities/bulk_order_entity.dart';

abstract class BulkOrderState extends Equatable {
  const BulkOrderState();
  @override
  List<Object> get props => [];
}

class BulkOrderInitial extends BulkOrderState {}
class BulkOrderLoading extends BulkOrderState {}
class BulkOrderLoaded extends BulkOrderState {
  final List<BulkOrderEntity> trades;
  const BulkOrderLoaded({required this.trades});
  @override
  List<Object> get props => [trades];
}
class BulkOrderError extends BulkOrderState {
  final String message;
  const BulkOrderError({required this.message});
  @override
  List<Object> get props => [message];
}
