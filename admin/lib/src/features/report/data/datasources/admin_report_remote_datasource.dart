import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_exception.dart';
import '../models/admin_report_model.dart';

abstract class AdminReportRemoteDataSource {
  Future<List<AdminReportModel>> fetchReports();

  Future<void> resolveReport(String reportId);
}

class AdminReportRemoteDataSourceImpl implements AdminReportRemoteDataSource {
  final ApiClient _apiClient;

  const AdminReportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminReportModel>> fetchReports() async {
    try {
      final result = await _apiClient.get(ApiConstants.reports);
      return _extractMaps(result).map(AdminReportModel.fromJson).toList();
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<void> resolveReport(String reportId) async {
    await _apiClient.patch(
      ApiConstants.reportById(reportId),
      data: const {'status': 'resolved'},
    );
  }

  List<Map<String, dynamic>> _extractMaps(dynamic result) {
    if (result is Map) {
      final map = Map<String, dynamic>.from(result);
      final data = map['data'];
      if (data is Map && data['items'] is List) {
        return _mapsFromList(data['items'] as List);
      }
      if (data is List) {
        return _mapsFromList(data);
      }
      if (map['items'] is List) {
        return _mapsFromList(map['items'] as List);
      }
    }

    if (result is List) {
      return _mapsFromList(result);
    }

    return const [];
  }

  List<Map<String, dynamic>> _mapsFromList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
