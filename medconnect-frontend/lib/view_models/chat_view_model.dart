import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/doctor.dart';
import '../services/api_service.dart';

class ChatViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String _error = '';
  Timer? _refreshTimer;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Load Conversations
  Future<void> loadConversations(String token) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _conversations = await _apiService.getConversations(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Messages for a conversation
  Future<void> loadMessages(String token, int conversationId) async {
    _isLoading = true;
    _messages = [];
    _error = '';
    notifyListeners();

    try {
      _messages = await _apiService.getMessages(token, conversationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send Message
  Future<bool> sendMessage(String token, int conversationId, String? content, File? file) async {
    try {
      await _apiService.sendMessage(token, conversationId, content, file);
      await loadMessages(token, conversationId); // Refresh after send
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String token, int messageId) async {
    try {
      await _apiService.markAsRead(token, messageId);
      // Update local state
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
         // Assuming MessageModel is mutable or we replace it
         // _messages[index].isRead = true; // Check Model
         // If immutable, we might strictly rely on reload/polling
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  // Pick PDF
  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }
  
  // Polling
  void startPolling(String token, int conversationId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        _apiService.getMessages(token, conversationId).then((newMessages) {
             // Simple check if length changed, or just replace
             // Ideally we should merge or only update if changed
             if (newMessages.length != _messages.length) {
                 _messages = newMessages;
                 notifyListeners();
             }
        }).catchError((e) {
          print("Polling error: $e");
        });
    });
  }

  void stopPolling() {
    _refreshTimer?.cancel();
  }

  // Load Doctors
  Future<void> loadDoctors(String token) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _doctors = await _apiService.getDoctors(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Conversation
  Future<int?> createConversation(String token, int doctorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final conversation = await _apiService.createConversation(token, doctorId);
      // Refresh list
      await loadConversations(token);
      return conversation.id;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
