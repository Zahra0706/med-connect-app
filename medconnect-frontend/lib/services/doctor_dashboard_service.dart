import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_dashboard_data.dart';
import 'api_service.dart';

class DoctorDashboardService {
  Future<DoctorDashboardData> getDashboardData(String token) async {
    final url = Uri.parse('${ApiService.apiPrefix}/doctor/dashboard/');
    print('Calling GET $url');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return DoctorDashboardData.fromJson(decoded);
    } else {
      throw Exception('Erreur chargement dashboard: ${response.statusCode}');
    }
  }
}
