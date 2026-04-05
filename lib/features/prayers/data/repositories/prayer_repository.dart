import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/prayer_models.dart';

class PrayerRepository {
  final Dio _dio;
  PrayerRepository(this._dio);

  Future<List<PrayerDefinitionModel>> getDefinitions() async {
    final res = await _dio.get(ApiConstants.prayerDefinitions);
    final results = res.data['results'] ?? res.data;
    return (results as List).map((e) => PrayerDefinitionModel.fromJson(e)).toList();
  }

  Future<List<PrayerLogModel>> getMyToday() async {
    final res = await _dio.get(ApiConstants.prayerMyToday);
    return (res.data as List).map((e) => PrayerLogModel.fromJson(e)).toList();
  }

  Future<List<PrayerLogModel>> getLogs({String? memberId, String? date, String? status}) async {
    final params = <String, dynamic>{};
    if (memberId != null) params['member'] = memberId;
    if (date != null) params['date'] = date;
    if (status != null) params['status'] = status;
    final res = await _dio.get(ApiConstants.prayerLogs, queryParameters: params);
    final results = res.data['results'] ?? res.data;
    return (results as List).map((e) => PrayerLogModel.fromJson(e)).toList();
  }

  Future<void> updateStatus(String logId, String status) async {
    await _dio.post('${ApiConstants.prayerLogs}$logId/update_status/', data: {'status': status});
  }
}
