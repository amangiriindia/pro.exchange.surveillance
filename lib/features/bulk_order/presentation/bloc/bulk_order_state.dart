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
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  const BulkOrderLoaded({
    required this.trades,
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  BulkOrderLoaded copyWith({
    List<BulkOrderEntity>? trades,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return BulkOrderLoaded(
      trades: trades ?? this.trades,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object> get props => [trades, currentPage, isLoadingMore, hasMore];
}

class BulkOrderError extends BulkOrderState {
  final String message;
  const BulkOrderError({required this.message});
  @override
  List<Object> get props => [message];
}
