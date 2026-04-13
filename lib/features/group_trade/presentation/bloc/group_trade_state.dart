import 'package:equatable/equatable.dart';
import '../../domain/entities/group_trade_entity.dart';

abstract class GroupTradeState extends Equatable {
  const GroupTradeState();

  @override
  List<Object> get props => [];
}

class GroupTradeInitial extends GroupTradeState {}

class GroupTradeLoading extends GroupTradeState {}

class GroupTradeLoaded extends GroupTradeState {
  final List<GroupTradeEntity> trades;

  const GroupTradeLoaded({required this.trades});

  @override
  List<Object> get props => [trades];
}

class GroupTradeError extends GroupTradeState {
  final String message;

  const GroupTradeError({required this.message});

  @override
  List<Object> get props => [message];
}
