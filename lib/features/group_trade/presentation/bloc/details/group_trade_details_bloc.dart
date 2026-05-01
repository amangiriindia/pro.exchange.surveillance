import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/ip_city_lookup.dart';
import '../../../domain/usecases/get_group_trade_details.dart';
import 'group_trade_details_event.dart';
import 'group_trade_details_state.dart';

class GroupTradeDetailsBloc
    extends Bloc<GroupTradeDetailsEvent, GroupTradeDetailsState> {
  final GetGroupTradeDetails getGroupTradeDetails;

  GroupTradeDetailsBloc({required this.getGroupTradeDetails})
    : super(GroupTradeDetailsInitial()) {
    on<LoadGroupTradeDetails>(_onLoadGroupTradeDetails);
  }

  Future<void> _onLoadGroupTradeDetails(
    LoadGroupTradeDetails event,
    Emitter<GroupTradeDetailsState> emit,
  ) async {
    emit(GroupTradeDetailsLoading());
    final result = await getGroupTradeDetails(event.alertId);
    await result.fold(
      (failure) async => emit(GroupTradeDetailsError(message: failure)),
      (data) async {
        emit(
          GroupTradeDetailsLoaded(details: data, resolvedCityByIp: const {}),
        );

        final cityMap = await IpCityLookup.instance.prefetchBatch(
          data.map((t) => (ip: t.ipAddress, backendCity: t.city)),
        );

        final s = state;
        if (s is! GroupTradeDetailsLoaded) return;
        emit(s.copyWith(resolvedCityByIp: cityMap));
      },
    );
  }
}
