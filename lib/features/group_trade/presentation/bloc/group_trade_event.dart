import 'package:equatable/equatable.dart';

abstract class GroupTradeEvent extends Equatable {
  const GroupTradeEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupTrades extends GroupTradeEvent {}
