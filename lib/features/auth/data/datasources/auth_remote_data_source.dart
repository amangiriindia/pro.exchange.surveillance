import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/profile_details_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginUserModel> login({
    required String username,
    required String password,
  });

  Future<String> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  });

  Future<ProfileDetailsModel> getProfile({required String token});

  Future<String> logout({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginUserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        AuthConstants.loginEndpoint,
        data: {'username': username, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return LoginUserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Login failed',
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message'] ?? 'Login failed'
          : 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        AuthConstants.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>? ?? {};
        return data['message'] as String? ??
            'Password changed successfully, please login again';
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Change password failed',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message'] ?? 'Change password failed'
          : 'Change password failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ProfileDetailsModel> getProfile({required String token}) async {
    try {
      final response = await dio.get(
        AuthConstants.profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ProfileDetailsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to fetch profile',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message'] ?? 'Failed to fetch profile'
          : 'Failed to fetch profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String> logout({required String token}) async {
    try {
      final response = await dio.post(
        AuthConstants.logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>? ?? {};
        return data['message'] as String? ?? 'Logout successful';
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Logout failed',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? data['message'] ?? 'Logout failed'
          : 'Logout failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
