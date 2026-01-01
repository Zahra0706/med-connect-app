import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import 'api_service.dart';

class AppointmentService {
  Future<List<Appointment>> getAppointments(String token) async {
    try {
      final url = Uri.parse('${ApiService.apiPrefix}/appointments/');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        
        if (body is List) {
          return body.map((e) => Appointment.fromJson(e)).toList();
        } else if (body is Map<String, dynamic> && body.containsKey('results')) {
          final List<dynamic> results = body['results'];
          return results.map((e) => Appointment.fromJson(e)).toList();
        } else {
           throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Erreur de chargement des rendez-vous: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de chargement des rendez-vous: $e');
    }
  }

  Future<List<Appointment>> getDoctorAppointments(String token) async {
    try {
      final url = Uri.parse('${ApiService.apiPrefix}/appointments/doctor/my/');
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
        final dynamic body = json.decode(utf8.decode(response.bodyBytes));
        
        if (body is List) {
          return body.map((e) => Appointment.fromJson(e)).toList();
        } else if (body is Map<String, dynamic> && body.containsKey('results')) {
          final List<dynamic> results = body['results'];
          return results.map((e) => Appointment.fromJson(e)).toList();
        } else {
           throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Erreur de chargement des rendez-vous doc: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detail: $e');
      throw Exception('Erreur de chargement des rendez-vous: $e');
    }
  }

  Future<Appointment> createAppointment(
    String token,
    int doctorId,
    DateTime date,
    String reason,
  ) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'doctor': doctorId,
        'date': date.toIso8601String(),
        'reason': reason,
      }),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['non_field_errors']?[0] ??
            'Erreur lors de la prise de rendez-vous',
      );
    }
  }
  Future<Appointment> confirmAppointment(String token, int id) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/confirm/');
    print('Calling PATCH $url');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.headers['content-type']?.contains('text/html') == true ||
        response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      throw Exception('Erreur Backend: Réponse HTML reçue au lieu de JSON. URL: $url');
    }

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      dynamic error;
      try {
        error = json.decode(response.body);
      } catch (_) {
        error = response.body;
      }
      throw Exception(error is Map ? (error['error'] ?? 'Erreur inconnue') : error.toString());
    }
  }


  Future<Appointment> refuseAppointment(String token, int id, String reason) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/refuse/');
    print('Calling PATCH $url');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({'reason': reason}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.headers['content-type']?.contains('text/html') == true ||
        response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      throw Exception('Erreur Backend: Réponse HTML reçue au lieu de JSON. URL: $url');
    }

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      dynamic error;
      try {
        error = json.decode(response.body);
      } catch (_) {
        error = response.body;
      }
      throw Exception(error is Map ? (error['error'] ?? 'Erreur inconnue') : error.toString());
    }
  }


  Future<Appointment> cancelAppointment(String token, int id, String? reason) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/cancel/');
    print('Calling PATCH $url');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({'reason': reason}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.headers['content-type']?.contains('text/html') == true ||
        response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      throw Exception('Erreur Backend: Réponse HTML reçue au lieu de JSON. URL: $url');
    }

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      dynamic error;
      try {
        error = json.decode(response.body);
      } catch (_) {
        error = response.body;
      }
      throw Exception(error is Map ? (error['error'] ?? 'Erreur inconnue') : error.toString());
    }
  }


  Future<Appointment> updateStatus(String token, int id, String status) async {
    // Deprecated generic update
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/');
    print('Calling PATCH $url');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'status': status,
      }),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour du rendez-vous');
    }
  }

  Future<Appointment> reschedule(String token, int id, DateTime newDate) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'date': newDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la modification du rendez-vous');
    }
  }
}
