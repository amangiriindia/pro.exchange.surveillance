import 'package:equatable/equatable.dart';
import '../../../domain/entities/bulk_order_details_entity.dart';

abstract class BulkOrderDetailsState extends Equatable {
  const BulkOrderDetailsState();
  @override
  List<Object> get props => [];
}

class BulkOrderDetailsInitial extends BulkOrderDetailsState {}

class BulkOrderDetailsLoading extends BulkOrderDetailsState {}

class BulkOrderDetailsLoaded extends BulkOrderDetailsState {
  final List<BulkOrderDetailsEntity> details;
  const BulkOrderDetailsLoaded({required this.details});
  @override
  List<Object> get props => [details];
}

class BulkOrderDetailsError extends BulkOrderDetailsState {
  final String message;
  const BulkOrderDetailsError({required this.message});
  @override
  List<Object> get props => [message];
}
