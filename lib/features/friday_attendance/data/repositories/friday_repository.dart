import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class FridayRepository {
  final Dio _dio;
  FridayRepository(this._dio);

  Future<List<Map<String, dynamic>>> getSessions() async {
    final res = await _dio.get(ApiConstants.fridaySessions);
    return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
  }

  Future<List<Map<String, dynamic>>> getRecords(String sessionId) async {
    final res = await _dio.get(ApiConstants.fridayRecords, queryParameters: {'session': sessionId});
    return List<Map<String, dynamic>>.from(res.data['results'] ?? res.data);
  }

  Future<void> bulkMark(String sessionId, List<Map<String, String>> records) async {
    await _dio.post(ApiConstants.fridayBulkMark, data: {'session_id': sessionId, 'records': records});
  }

  Future<Map<String, dynamic>> createSession(String date, {String? title, String? stageId}) async {
    final res = await _dio.post(ApiConstants.fridaySessions, data: {
      'date': date, 'title': title, 'service_stage': stageId,
    });
    return res.data;
  }
}
