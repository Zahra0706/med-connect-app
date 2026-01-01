import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/patient_profile_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/doctor.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://192.168.0.159:8000";
  static const String apiPrefix = "$baseUrl/api";

  Future<AuthResponse> registerPatient(RegisterRequest request) async {
    final url = Uri.parse('$apiPrefix/auth/register/patient/');

    print('URL d\'inscription: $url');
    print('Données envoyées: ${request.toJson()}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    print('Statut de réponse: ${response.statusCode}');
    print('Corps de réponse: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
      throw Exception(
        'Erreur inconnue',
      ); // Should be unreachable given _handleError throws
    }
  }

  Future<AuthResponse> registerDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse('$apiPrefix/auth/register/doctor/');

    print('URL d\'inscription Médecin: $url');
    print('Données envoyées: $data');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    print('Statut de réponse: ${response.statusCode}');
    print('Corps de réponse: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
      throw Exception('Erreur inconnue');
    }
  }

  void _handleError(http.Response response) {
    try {
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) {
        if (body.containsKey('error')) {
          throw Exception(body['error']);
        }
        if (body.containsKey('message')) {
          throw Exception(body['message']);
        }
        if (body.containsKey('detail')) {
          throw Exception(body['detail']);
        }

        // Handle DRF validation errors (field: [errors])
        final List<String> errorMessages = [];
        body.forEach((key, value) {
          if (value is List) {
            errorMessages.add("$key: ${value.join(', ')}");
          } else {
            errorMessages.add("$key: $value");
          }
        });

        if (errorMessages.isNotEmpty) {
          throw Exception(errorMessages.join('\n'));
        }
      }
    } catch (e) {
      if (e.toString().startsWith('Exception:')) rethrow;
      // Fallback if parsing failed
    }
    throw Exception('Erreur serveur (${response.statusCode})');
  }

  Future<PatientProfileModel> getPatientProfile(String token) async {
    final url = Uri.parse('$apiPrefix/patient/profile/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Erreur de chargement du profil: ${response.statusCode}');
    }
  }

  Future<PatientProfileModel> updatePatientProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiPrefix/patient/profile/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Erreur de mise à jour: ${response.statusCode}');
    }
  }

  Future<AuthResponse> loginPatient(String email, String password) async {
    final url = Uri.parse('$apiPrefix/auth/login/');
    return _loginStrict(url, email, password);
  }

  Future<AuthResponse> loginDoctor(String email, String password) async {
    final url = Uri.parse('$apiPrefix/auth/login/');
    return _loginStrict(url, email, password);
  }

  Future<AuthResponse> _loginStrict(
    Uri url,
    String email,
    String password,
  ) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Identifiants incorrects (${response.statusCode})');
    }
  }

  // Keeping generic login for backward compatibility if needed, but pointing to patient by default or deprecated?
  // User asked for specific endpoints. I will comment out or remove generic login if not used elsewhere,
  // but to be safe I will leave it or redirect it.
  // Given the user request, I'll just keep the new methods.
  // The generic login might be used by existing code. I'll check usages later or just keep it separate.
  // Actually, I'll replace the existing `login` to avoiding conflict if I use the same name,
  // but I can't overload. I'll just add the new ones and keep `login` for now or remove it if I replace usages.
  // The tool call `replace_file_content` replaces the specific chunk. I will replace the `login` function with `loginPatient` and `loginDoctor` and a private helper.
  // Wait, `ApiAuthService` uses `login`. I should check `ApiAuthService` first.
  // ...

  // MESSAGING

  Future<List<ConversationModel>> getConversations(String token) async {
    final url = Uri.parse('$apiPrefix/conversations/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((e) => ConversationModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Erreur chargement conversations: ${response.statusCode}',
      );
    }
  }

  Future<List<MessageModel>> getMessages(
    String token,
    int conversationId,
  ) async {
    final url = Uri.parse('$apiPrefix/conversations/$conversationId/messages/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((e) => MessageModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement messages: ${response.statusCode}');
    }
  }

  Future<void> sendMessage(
    String token,
    int conversationId,
    String? content,
    File? file,
  ) async {
    final url = Uri.parse('$apiPrefix/messages/');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Token $token';
    request.fields['conversation'] = conversationId.toString();
    if (content != null) {
      request.fields['content'] = content;
    }
    if (file != null) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Erreur envoi message: ${response.statusCode}');
    }
  }

  Future<void> markAsRead(String token, int messageId) async {
    final url = Uri.parse('$apiPrefix/messages/$messageId/read/');
    final response = await http.patch(
      url,
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur markAsRead: ${response.statusCode}');
    }
  }

  Future<List<Doctor>> getDoctors(String token) async {
    final url = Uri.parse('$apiPrefix/doctors/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      // Assuming DoctorModel or similar structure
      return body.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement médecins: ${response.statusCode}');
    }
  }

  Future<ConversationModel> createConversation(
    String token,
    int doctorId,
  ) async {
    final url = Uri.parse('$apiPrefix/conversations/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({'doctor': doctorId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ConversationModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Erreur création conversation: ${response.statusCode}');
    }
  }
}
