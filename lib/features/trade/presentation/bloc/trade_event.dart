import 'package:equatable/equatable.dart';

abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object> get props => [];
}

class LoadTrades extends TradeEvent {
  final int page;
  final int sizePerPage;

  const LoadTrades({this.page = 1, this.sizePerPage = 100});

  @override
  List<Object> get props => [page, sizePerPage];
}

class LoadMoreTrades extends TradeEvent {
  const LoadMoreTrades();
}
