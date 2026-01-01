import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/medical_document_model.dart';
import 'api_service.dart';

class DocumentService {
  final String _baseUrl = ApiService.apiPrefix;

  Future<List<MedicalDocument>> getDocuments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/patient/documents/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => MedicalDocument.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur de chargement des documents (${response.statusCode})',
      );
    }
  }

  Future<MedicalDocument> uploadDocument({
    required String token,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    required String title,
    required String documentType,
    String? description,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/patient/documents/'),
    );

    request.headers['Authorization'] = 'Token $token';
    request.fields['title'] = title;
    request.fields['document_type'] = documentType;
    if (description != null) {
      request.fields['description'] = description;
    }

    if (fileBytes != null) {
      // Web Upload
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName ?? 'document.pdf',
        ),
      );
    } else if (file != null) {
      // Mobile Upload
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    } else {
      throw Exception("Aucun fichier fourni");
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return MedicalDocument.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      print("[Upload Error] Status: ${response.statusCode}");
      print("[Upload Error] Body: ${response.body}");
      try {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Erreur lors de l\'upload');
      } catch (e) {
        // If JSON parse fails (e.g. HTML body), throw the raw body or a generic error with info
        if (response.body.startsWith('<!DOCTYPE html>')) {
          throw Exception(
            "Erreur Serveur (HTML response): ${response.statusCode}",
          );
        }
        throw Exception(
          "Erreur upload (${response.statusCode}): ${response.body}",
        );
      }
    }
  }
}
