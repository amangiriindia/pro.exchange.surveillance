import 'package:equatable/equatable.dart';
import '../../../domain/entities/group_trade_details_entity.dart';

abstract class GroupTradeDetailsState extends Equatable {
  const GroupTradeDetailsState();

  @override
  List<Object?> get props => [];
}

class GroupTradeDetailsInitial extends GroupTradeDetailsState {}

class GroupTradeDetailsLoading extends GroupTradeDetailsState {}

class GroupTradeDetailsLoaded extends GroupTradeDetailsState {
  final List<GroupTradeDetailsEntity> details;
  final Map<String, String> resolvedCityByIp;

  const GroupTradeDetailsLoaded({
    required this.details,
    this.resolvedCityByIp = const {},
  });

  GroupTradeDetailsLoaded copyWith({
    List<GroupTradeDetailsEntity>? details,
    Map<String, String>? resolvedCityByIp,
  }) {
    return GroupTradeDetailsLoaded(
      details: details ?? this.details,
      resolvedCityByIp: resolvedCityByIp ?? this.resolvedCityByIp,
    );
  }

  @override
  List<Object?> get props => [details, resolvedCityByIp];
}

class GroupTradeDetailsError extends GroupTradeDetailsState {
  final String message;
  const GroupTradeDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
