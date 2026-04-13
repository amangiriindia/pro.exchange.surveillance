import 'package:equatable/equatable.dart';

abstract class TradeEvent extends Equatable {
  const TradeEvent();

  @override
  List<Object> get props => [];
}

class LoadTrades extends TradeEvent {}
