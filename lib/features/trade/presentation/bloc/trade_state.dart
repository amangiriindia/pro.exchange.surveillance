import 'package:equatable/equatable.dart';
import '../../domain/entities/trade_entity.dart';

abstract class TradeState extends Equatable {
  const TradeState();

  @override
  List<Object> get props => [];
}

class TradeInitial extends TradeState {}

class TradeLoading extends TradeState {}

class TradeLoaded extends TradeState {
  final List<TradeEntity> trades;
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  const TradeLoaded({
    required this.trades,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  TradeLoaded copyWith({
    List<TradeEntity>? trades,
    int? totalRecords,
    int? totalPages,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return TradeLoaded(
      trades: trades ?? this.trades,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object> get props => [
    trades,
    totalRecords,
    totalPages,
    currentPage,
    isLoadingMore,
    hasMore,
  ];
}

class TradeError extends TradeState {
  final String message;

  const TradeError({required this.message});

  @override
  List<Object> get props => [message];
}
