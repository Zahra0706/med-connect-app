import 'package:flutter/foundation.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';

class AppointmentViewModel with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    final list = _appointments
        .where(
          (a) =>
              a.rawStatus != 'CANCELLED' &&
              a.rawStatus != 'REJECTED' &&
              a.dateTime.isAfter(now),
        )
        .toList();
    // Tri croissant (plus proche au plus lointain)
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    final list = _appointments
        .where(
          (a) =>
              a.rawStatus == 'COMPLETED' ||
              (a.rawStatus != 'CANCELLED' &&
                  a.rawStatus !=
                      'REJECTED' && // Also exclude rejected from past active logic
                  a.dateTime.isBefore(now)),
        )
        .toList();
    // Tri décroissant (plus récent au plus ancien)
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<Appointment> get cancelledAppointments {
    final list = _appointments
        .where((a) => a.rawStatus == 'CANCELLED' || a.rawStatus == 'REJECTED')
        .toList();
    // Tri par date d'annulation (si disponible) ou date de RDV
    list.sort((a, b) {
      if (a.date.isNotEmpty && b.date.isNotEmpty) {
        return b.dateTime.compareTo(a.dateTime);
      }
      return 0;
    });
    return list;
  }

  Future<void> fetchAppointments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _appointmentService.getAppointments(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment(
    String token,
    int doctorId,
    DateTime date,
    String reason,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.createAppointment(
        token,
        doctorId,
        date,
        reason,
      );
      await fetchAppointments(token); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(
    String token,
    int appointmentId, {
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.cancelAppointment(token, appointmentId, reason);
      await fetchAppointments(token); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
