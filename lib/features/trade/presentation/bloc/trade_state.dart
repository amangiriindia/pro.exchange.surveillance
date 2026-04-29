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
  final int todayTradeCount;
  final int totalPages;
  final int currentPage;
  final bool isLoadingMore;
  final bool hasMore;

  final Map<String, String> resolvedCityByIp;

  const TradeLoaded({
    required this.trades,
    required this.totalRecords,
    required this.todayTradeCount,
    required this.totalPages,
    required this.currentPage,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.resolvedCityByIp = const {},
  });

  TradeLoaded copyWith({
    List<TradeEntity>? trades,
    int? totalRecords,
    int? todayTradeCount,
    int? totalPages,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasMore,
    Map<String, String>? resolvedCityByIp,
  }) {
    return TradeLoaded(
      trades: trades ?? this.trades,
      totalRecords: totalRecords ?? this.totalRecords,
      todayTradeCount: todayTradeCount ?? this.todayTradeCount,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      resolvedCityByIp: resolvedCityByIp ?? this.resolvedCityByIp,
    );
  }

  @override
  List<Object> get props => [
    trades,
    totalRecords,
    todayTradeCount,
    totalPages,
    currentPage,
    isLoadingMore,
    hasMore,
    resolvedCityByIp,
  ];
}

class TradeError extends TradeState {
  final String message;

  const TradeError({required this.message});

  @override
  List<Object> get props => [message];
}
