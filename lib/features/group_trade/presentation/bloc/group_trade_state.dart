import 'package:equatable/equatable.dart';
import '../../domain/entities/group_trade_entity.dart';

abstract class GroupTradeState extends Equatable {
  const GroupTradeState();

  @override
  List<Object?> get props => [];
}

class GroupTradeInitial extends GroupTradeState {}

class GroupTradeLoading extends GroupTradeState {}

class GroupTradeLoaded extends GroupTradeState {
  final List<GroupTradeEntity> items;
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  const GroupTradeLoaded({
    required this.items,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  GroupTradeLoaded copyWith({
    List<GroupTradeEntity>? items,
    int? totalRecords,
    int? totalPages,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return GroupTradeLoaded(
      items: items ?? this.items,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
        items, totalRecords, totalPages, currentPage, isLoadingMore, hasMore,
      ];
}

class GroupTradeError extends GroupTradeState {
  final String message;

  const GroupTradeError({required this.message});

  @override
  List<Object?> get props => [message];
}
