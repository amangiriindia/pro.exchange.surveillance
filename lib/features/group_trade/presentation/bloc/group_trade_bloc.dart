import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_trade_event.dart';
import 'group_trade_state.dart';
import '../../domain/usecases/get_group_trades.dart';

class GroupTradeBloc extends Bloc<GroupTradeEvent, GroupTradeState> {
  final GetGroupTrades getGroupTrades;

  GroupTradeBloc({required this.getGroupTrades}) : super(GroupTradeInitial()) {
    on<LoadGroupTrades>(_onLoadGroupTrades);
  }

  void _onLoadGroupTrades(LoadGroupTrades event, Emitter<GroupTradeState> emit) async {
    emit(GroupTradeLoading());
    final result = await getGroupTrades();
    result.fold(
      (failure) => emit(const GroupTradeError(message: 'Failed to load group trades')),
      (trades) => emit(GroupTradeLoaded(trades: trades)),
    );
  }
}
