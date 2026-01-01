
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/chat_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import 'chat_screen.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<ChatViewModel>(context, listen: false).loadDoctors(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacter un médecin")),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (viewModel.doctors.isEmpty) {
            return Center(child: Text("Aucun médecin disponible"));
          }
          return ListView.builder(
            itemCount: viewModel.doctors.length,
            itemBuilder: (context, index) {
              final doctor = viewModel.doctors[index];
              return ListTile(
                leading: CircleAvatar(child: Text(doctor.firstName.isNotEmpty ? doctor.firstName[0] : (doctor.lastName.isNotEmpty ? doctor.lastName[0] : "?"))),
                title: Text(doctor.fullName),
                subtitle: Text(doctor.speciality),
                onTap: () async {
                  final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
                  if (token != null) {
                    final conversationId = await viewModel.createConversation(token, doctor.userId);
                    if (!mounted) return;
                    if (conversationId != null) {
                       Navigator.pushReplacement(
                         context,
                         MaterialPageRoute(
                           builder: (_) => ChatScreen(
                             conversationId: conversationId,
                             otherUserName: doctor.fullName,
                           ),
                         ),
                       );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la création de la conversation")));
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
