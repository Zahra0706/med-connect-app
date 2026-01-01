import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../../view_models/chat_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import 'chat_screen.dart';
import 'doctor_list_screen.dart';

class ConversationListScreen extends StatefulWidget {
  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<ChatViewModel>(context, listen: false).loadConversations(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messagerie")),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (viewModel.error.isNotEmpty) {
            return Center(child: Text("Erreur: ${viewModel.error}"));
          }
          if (viewModel.conversations.isEmpty) {
            return Center(child: Text("Aucune conversation."));
          }
          return ListView.builder(
            itemCount: viewModel.conversations.length,
            itemBuilder: (context, index) {
              final conversation = viewModel.conversations[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(conversation.doctorName),
                subtitle: Text(conversation.lastMessage?.content ?? "Fichier joint"),
                trailing: conversation.unreadCount != null && conversation.unreadCount! > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          "${conversation.unreadCount}", 
                          style: TextStyle(fontSize: 12, color: Colors.white)
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: conversation.id,
                        otherUserName: conversation.doctorName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DoctorListScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
