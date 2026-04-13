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

  const TradeLoaded({required this.trades});

  @override
  List<Object> get props => [trades];
}

class TradeError extends TradeState {
  final String message;

  const TradeError({required this.message});

  @override
  List<Object> get props => [message];
}
