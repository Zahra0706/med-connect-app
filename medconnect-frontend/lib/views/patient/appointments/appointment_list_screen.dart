import 'package:flutter/material.dart';
import 'package:medconnect_app/views/patient/appointments/book_appointment_screen.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';
import '../../../models/appointment.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authViewModel = Provider.of<PatientAuthViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.authResponse?.token;
    if (token != null) {
      Provider.of<AppointmentViewModel>(
        context,
        listen: false,
      ).fetchAppointments(token);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
            Tab(text: 'Annulés'),
          ],
        ),
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text("Erreur: ${viewModel.error}"));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(viewModel.upcomingAppointments),
              _buildList(viewModel.pastAppointments),
              _buildList(viewModel.cancelledAppointments),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
          );
        },
        backgroundColor: const Color(0xFF567991),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text("Aucun rendez-vous trouvé"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF567991).withOpacity(0.1),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF567991),
              ),
            ),
            title: Text(
              appt.doctorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.specialty),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(appt.date.replaceAll('T', ' ').substring(0, 16)),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(appt.rawStatus), // Use rawStatus for logic
                _buildCancelButton(context, appt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context, Appointment appt) {
    final now = DateTime.now();
    // Check if cancellation is allowed (> 24h before)
    final bool isFarEnough = appt.dateTime.difference(now).inHours > 24;
    // Only show for active appointments
    if (appt.rawStatus != 'PENDING' && appt.rawStatus != 'CONFIRMED') {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        if (!isFarEnough) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Impossible d'annuler : le rendez-vous est dans moins de 24h.",
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _confirmCancellation(context, appt.id);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          "Annuler",
          style: TextStyle(
            color: isFarEnough ? Colors.red : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    int appointmentId,
  ) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Annuler le rendez-vous ?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Êtes-vous sûr de vouloir annuler ce rendez-vous ?\n(Possible uniquement si + de 24h avant)",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Raison (optionnel)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Oui", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final viewModel = Provider.of<AppointmentViewModel>(
        context,
        listen: false,
      );
      final authViewModel = Provider.of<PatientAuthViewModel>(
        context,
        listen: false,
      );

      final token = authViewModel.authResponse?.token;
      if (token != null) {
        final success = await viewModel.cancelAppointment(
          token,
          appointmentId,
          reason: reasonController.text.isNotEmpty
              ? reasonController.text
              : null,
        );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.error ?? "Erreur d'annulation")),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Rendez-vous annulé")));
        }
      }
    }
  }

  Widget _buildStatusBadge(String rawStatus) {
    Color color;
    String text;
    switch (rawStatus) {
      case 'PENDING':
        color = Colors.orange;
        text = 'En attente';
        break;
      case 'CONFIRMED':
        color = Colors.green;
        text = 'Confirmé';
        break;
      case 'CANCELLED':
        color = Colors.red;
        text = 'Annulé';
        break;
      case 'REJECTED':
        color = Colors.red;
        text = 'Refusé';
        break;
      case 'COMPLETED':
        color = Colors.blue;
        text = 'Terminé';
        break;
      default:
        color = Colors.grey;
        text = rawStatus;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
