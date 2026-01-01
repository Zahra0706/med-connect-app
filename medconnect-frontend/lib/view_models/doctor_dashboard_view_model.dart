import 'package:flutter/material.dart';
import '../models/doctor_dashboard_data.dart';
import '../services/doctor_dashboard_service.dart';

class DoctorDashboardViewModel extends ChangeNotifier {
  final DoctorDashboardService _service = DoctorDashboardService();
  
  DoctorDashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DoctorDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData(token);
    } catch (e) {
      _error = e.toString();
      print("Error fetching doctor dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
