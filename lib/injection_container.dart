import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/usecases/get_profile.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/trade/data/datasources/trade_remote_data_source.dart';
import 'features/trade/data/repositories/trade_repository_impl.dart';
import 'features/trade/domain/repositories/trade_repository.dart';
import 'features/trade/domain/usecases/get_trade_count.dart';
import 'features/trade/domain/usecases/get_trades.dart';
import 'features/trade/presentation/bloc/trade_bloc.dart';
import 'features/group_trade/data/datasources/group_trade_remote_data_source.dart';
import 'features/group_trade/data/repositories/group_trade_repository_impl.dart';
import 'features/group_trade/domain/repositories/group_trade_repository.dart';
import 'features/group_trade/domain/usecases/get_group_trades.dart';
import 'features/group_trade/presentation/bloc/group_trade_bloc.dart';
import 'features/bulk_order/data/datasources/bulk_order_remote_data_source.dart';
import 'features/bulk_order/data/repositories/bulk_order_repository_impl.dart';
import 'features/bulk_order/domain/repositories/bulk_order_repository.dart';
import 'features/bulk_order/domain/usecases/get_bulk_orders.dart';
import 'features/bulk_order/presentation/bloc/bulk_order_bloc.dart';
import 'features/bulk_order/data/datasources/bulk_order_details_remote_data_source.dart';
import 'features/bulk_order/data/repositories/bulk_order_details_repository_impl.dart';
import 'features/bulk_order/domain/repositories/bulk_order_details_repository.dart';
import 'features/bulk_order/domain/usecases/get_bulk_order_details.dart';
import 'features/bulk_order/presentation/bloc/details/bulk_order_details_bloc.dart';
import 'features/profit_cross/data/datasources/profit_cross_remote_data_source.dart';
import 'features/profit_cross/data/repositories/profit_cross_repository_impl.dart';
import 'features/profit_cross/domain/repositories/profit_cross_repository.dart';
import 'features/profit_cross/domain/usecases/get_order_duration_details.dart';
import 'features/profit_cross/domain/usecases/get_profit_cross_data.dart';
import 'features/profit_cross/presentation/bloc/profit_cross_bloc.dart';
import 'features/jobber_tracker/data/datasources/jobber_tracker_remote_data_source.dart';
import 'features/jobber_tracker/data/repositories/jobber_tracker_repository_impl.dart';
import 'features/jobber_tracker/domain/repositories/jobber_tracker_repository.dart';
import 'features/jobber_tracker/domain/usecases/get_jobber_details.dart';
import 'features/jobber_tracker/domain/usecases/get_jobber_tracker_data.dart';
import 'features/jobber_tracker/presentation/bloc/jobber_tracker_bloc.dart';
import 'features/jobber_tracker/presentation/bloc/jobber_details_bloc.dart';
import 'features/btst/data/datasources/btst_remote_data_source.dart';
import 'features/btst/data/repositories/btst_repository_impl.dart';
import 'features/btst/domain/repositories/btst_repository.dart';
import 'features/btst/domain/usecases/get_btst_details.dart';
import 'features/btst/domain/usecases/get_btst_data.dart';
import 'features/btst/presentation/bloc/btst_bloc.dart';
import 'features/btst/presentation/bloc/btst_details_bloc.dart';
import 'features/same_ip_tracker/data/datasources/same_ip_remote_data_source.dart';
import 'features/same_ip_tracker/data/repositories/same_ip_repository_impl.dart';
import 'features/same_ip_tracker/domain/repositories/same_ip_repository.dart';
import 'features/same_ip_tracker/domain/usecases/get_same_ip_details.dart';
import 'features/same_ip_tracker/domain/usecases/get_same_ip_data.dart';
import 'features/same_ip_tracker/presentation/bloc/same_ip_tracker_bloc.dart';
import 'features/same_ip_tracker/presentation/bloc/same_ip_details_bloc.dart';
import 'features/same_device_tracker/data/datasources/same_device_remote_data_source.dart';
import 'features/same_device_tracker/data/repositories/same_device_repository_impl.dart';
import 'features/same_device_tracker/domain/repositories/same_device_repository.dart';
import 'features/same_device_tracker/domain/usecases/get_same_device_details.dart';
import 'features/same_device_tracker/domain/usecases/get_same_device_data.dart';
import 'features/same_device_tracker/presentation/bloc/same_device_tracker_bloc.dart';
import 'features/same_device_tracker/presentation/bloc/same_device_details_bloc.dart';
import 'features/trade_comparison/data/datasources/trade_comparison_remote_data_source.dart';
import 'features/trade_comparison/data/repositories/trade_comparison_repository_impl.dart';
import 'features/trade_comparison/domain/repositories/trade_comparison_repository.dart';
import 'features/trade_comparison/domain/usecases/get_trade_comparison_data.dart';
import 'features/trade_comparison/presentation/bloc/trade_comparison_bloc.dart';
import 'features/dashboard/data/datasources/alert_socket_datasource.dart';
import 'features/dashboard/presentation/bloc/alert_bloc.dart';

final sl = GetIt.instance;
Future<void> init() async {
  sl.registerLazySingleton(() => ApiClient());
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      changePassword: sl(),
      getProfile: sl(),
      logoutUser: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUser(repository: sl()));
  sl.registerLazySingleton(() => ChangePassword(repository: sl()));
  sl.registerLazySingleton(() => GetProfile(repository: sl()));
  sl.registerLazySingleton(() => LogoutUser(repository: sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => TradeBloc(getTrades: sl(), getTradeCount: sl()));
  sl.registerLazySingleton(() => GetTradeCount(sl()));
  sl.registerLazySingleton(() => GetTrades(sl()));
  sl.registerLazySingleton<TradeRepository>(
    () => TradeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TradeRemoteDataSource>(
    () => TradeRemoteDataSourceImpl(),
  );

  sl.registerFactory(() => GroupTradeBloc(getGroupTrades: sl()));
  sl.registerLazySingleton(() => GetGroupTrades(sl()));
  sl.registerLazySingleton<GroupTradeRepository>(
    () => GroupTradeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GroupTradeRemoteDataSource>(
    () => GroupTradeRemoteDataSourceImpl(),
  );

  sl.registerFactory(() => BulkOrderBloc(getBulkOrders: sl()));
  sl.registerLazySingleton(() => GetBulkOrders(sl()));
  sl.registerLazySingleton<BulkOrderRepository>(
    () => BulkOrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BulkOrderRemoteDataSource>(
    () => BulkOrderRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => BulkOrderDetailsBloc(getBulkOrderDetails: sl()));
  sl.registerLazySingleton(() => GetBulkOrderDetails(sl()));
  sl.registerLazySingleton<BulkOrderDetailsRepository>(
    () => BulkOrderDetailsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BulkOrderDetailsRemoteDataSource>(
    () => BulkOrderDetailsRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(
    () => ProfitCrossBloc(
      getProfitCrossData: sl(),
      getOrderDurationDetails: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetProfitCrossData(sl()));
  sl.registerLazySingleton(() => GetOrderDurationDetails(sl()));
  sl.registerLazySingleton<ProfitCrossRepository>(
    () => ProfitCrossRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfitCrossRemoteDataSource>(
    () => ProfitCrossRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => JobberTrackerBloc(getJobberTrackerData: sl()));
  sl.registerFactory(() => JobberDetailsBloc(getJobberDetails: sl()));
  sl.registerLazySingleton(() => GetJobberTrackerData(sl()));
  sl.registerLazySingleton(() => GetJobberDetails(sl()));
  sl.registerLazySingleton<JobberTrackerRepository>(
    () => JobberTrackerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<JobberTrackerRemoteDataSource>(
    () => JobberTrackerRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => BTSTBloc(getBTSTData: sl()));
  sl.registerFactory(() => BTSTDetailsBloc(getBTSTDetails: sl()));
  sl.registerLazySingleton(() => GetBTSTData(sl()));
  sl.registerLazySingleton(() => GetBTSTDetails(sl()));
  sl.registerLazySingleton<BTSTRepository>(
    () => BTSTRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BTSTRemoteDataSource>(
    () => BTSTRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => SameIPTrackerBloc(getSameIPData: sl()));
  sl.registerFactory(() => SameIPDetailsBloc(getSameIPDetails: sl()));
  sl.registerLazySingleton(() => GetSameIPData(sl()));
  sl.registerLazySingleton(() => GetSameIPDetails(sl()));
  sl.registerLazySingleton<SameIPRepository>(
    () => SameIPRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SameIPRemoteDataSource>(
    () => SameIPRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => SameDeviceTrackerBloc(getSameDeviceData: sl()));
  sl.registerFactory(() => SameDeviceDetailsBloc(getSameDeviceDetails: sl()));
  sl.registerLazySingleton(() => GetSameDeviceData(sl()));
  sl.registerLazySingleton(() => GetSameDeviceDetails(sl()));
  sl.registerLazySingleton<SameDeviceRepository>(
    () => SameDeviceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SameDeviceRemoteDataSource>(
    () => SameDeviceRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerFactory(() => TradeComparisonBloc(getTradeComparisonData: sl()));
  sl.registerLazySingleton(() => GetTradeComparisonData(sl()));
  sl.registerLazySingleton<TradeComparisonRepository>(
    () => TradeComparisonRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TradeComparisonRemoteDataSource>(
    () => TradeComparisonRemoteDataSourceImpl(dio: sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<AlertSocketDatasource>(
    () => AlertSocketDatasourceImpl(),
  );
  sl.registerFactory(() => AlertBloc(datasource: sl<AlertSocketDatasource>()));
}
