import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class DoctorAppointmentViewModel with ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  DoctorAppointmentViewModel(this._appointmentRepository);

  bool _isLoading = false;
  String? _error;
  List<Appointment> _appointments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Appointment> get appointments => _appointments;

  // ✅ Getters filtered lists
  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.status == Appointment.statusPending).toList();

  List<Appointment> get upcomingAppointments => _appointments
      .where((a) =>
  a.status == Appointment.statusConfirmed &&
      a.dateTime.isAfter(DateTime.now()))
      .toList();

  List<Appointment> get pastAppointments => _appointments
      .where((a) =>
  a.status == Appointment.statusCompleted ||
      a.status == Appointment.statusCancelled ||
      (a.status == Appointment.statusConfirmed &&
          a.dateTime.isBefore(DateTime.now())))
      .toList();

  List<Appointment> get todayAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) =>
    a.status == Appointment.statusConfirmed &&
        a.dateTime.year == now.year &&
        a.dateTime.month == now.month &&
        a.dateTime.day == now.day)
        .toList();
  }

  // ✅ Fetch
  Future<void> fetchAppointments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _appointmentRepository.getDoctorAppointments(token);
    } catch (e) {
      _error = e.toString();
      print("❌ Fetch appointments error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Loading state per appointment
  final Set<int> _loadingAppointmentIds = {};

  bool isAppointmentLoading(int id) => _loadingAppointmentIds.contains(id);

  void _setAppointmentLoading(int id, bool loading) {
    if (loading) {
      _loadingAppointmentIds.add(id);
    } else {
      _loadingAppointmentIds.remove(id);
    }
    notifyListeners();
  }

  // ✅ CONFIRM
  Future<bool> acceptAppointment(String token, int id) async {
    _setAppointmentLoading(id, true);
    _error = null;

    try {
      final updated = await _appointmentRepository.confirmAppointment(token, id);
      _updateLocalAppointment(updated);

      // ✅ Refresh from backend
      await fetchAppointments(token);

      print("✅ Appointment $id confirmed successfully");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error accepting appointment: $e");
      notifyListeners();
      return false;
    } finally {
      _setAppointmentLoading(id, false);
    }
  }

  // ✅ REFUSE
  Future<bool> refuseAppointment(String token, int id, String reason) async {
    _setAppointmentLoading(id, true);
    _error = null;

    try {
      final updated =
      await _appointmentRepository.refuseAppointment(token, id, reason);

      _updateLocalAppointment(updated);
      await fetchAppointments(token);

      print("✅ Appointment $id refused successfully");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error refusing appointment: $e");
      notifyListeners();
      return false;
    } finally {
      _setAppointmentLoading(id, false);
    }
  }

  // ✅ CANCEL
  Future<bool> cancelAppointment(String token, int id, {String? reason}) async {
    _setAppointmentLoading(id, true);
    _error = null;

    try {
      final updated =
      await _appointmentRepository.cancelAppointment(token, id, reason);

      _updateLocalAppointment(updated);
      await fetchAppointments(token);

      print("✅ Appointment $id canceled successfully");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Error canceling appointment: $e");
      notifyListeners();
      return false;
    } finally {
      _setAppointmentLoading(id, false);
    }
  }

  // ✅ RESCHEDULE (si endpoint backend existe)
  Future<void> rescheduleAppointment(String token, int id, DateTime newDate) async {
    _setAppointmentLoading(id, true);
    _error = null;

    try {
      final updated =
      await _appointmentRepository.rescheduleAppointment(token, id, newDate);

      _updateLocalAppointment(updated);
      await fetchAppointments(token);

      print("✅ Appointment $id rescheduled successfully");
    } catch (e) {
      _error = e.toString();
      print("❌ Error rescheduling appointment: $e");
      notifyListeners();
      rethrow;
    } finally {
      _setAppointmentLoading(id, false);
    }
  }

  // ✅ Update local appointment
  void _updateLocalAppointment(Appointment updated) {
    print("🔄 Updating appointment ${updated.id} to status ${updated.status}");

    final index = _appointments.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _appointments[index] = updated;
    }
    notifyListeners();
  }
}
