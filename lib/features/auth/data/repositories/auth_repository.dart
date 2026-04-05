import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<UserModel> login(String phone, String password) async {
    final response = await _dio.post(ApiConstants.login, data: {
      'phone': phone,
      'password': password,
    });
    final data = response.data;
    await TokenStorage.write('access_token', data['access']);
    await TokenStorage.write('refresh_token', data['refresh']);
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateFCMToken(String token, String deviceType) async {
    await _dio.post(ApiConstants.fcmToken, data: {
      'fcm_token': token,
      'device_type': deviceType,
    });
  }

  Future<void> logout() async {
    await TokenStorage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.read('access_token');
    return token != null;
  }
}
