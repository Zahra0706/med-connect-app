
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository(this._appointmentService);

  Future<List<Appointment>> getDoctorAppointments(String token) {
    return _appointmentService.getDoctorAppointments(token);
  }

  Future<Appointment> confirmAppointment(String token, int id) {
    return _appointmentService.confirmAppointment(token, id);
  }

  Future<Appointment> refuseAppointment(String token, int id, String reason) {
    return _appointmentService.refuseAppointment(token, id, reason);
  }

  Future<Appointment> cancelAppointment(String token, int id, String? reason) {
    return _appointmentService.cancelAppointment(token, id, reason);
  }

  Future<Appointment> rescheduleAppointment(String token, int id, DateTime newDate) {
    return _appointmentService.reschedule(token, id, newDate);
  }
}
