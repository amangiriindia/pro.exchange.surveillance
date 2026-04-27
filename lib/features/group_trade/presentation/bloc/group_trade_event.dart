import 'package:equatable/equatable.dart';

abstract class GroupTradeEvent extends Equatable {
  const GroupTradeEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupTrades extends GroupTradeEvent {
  final int page;
  final int sizePerPage;
  const LoadGroupTrades({this.page = 1, this.sizePerPage = 100});

  @override
  List<Object> get props => [page, sizePerPage];
}

class LoadMoreGroupTrades extends GroupTradeEvent {
  const LoadMoreGroupTrades();
}
