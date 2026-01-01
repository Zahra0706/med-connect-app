import 'package:flutter/material.dart';
import '../../../models/doctor.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.fullName),
        backgroundColor: const Color(0xFF567991),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF567991),
                child: Text(
                  doctor.firstName.isNotEmpty ? doctor.firstName[0] : 'D',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                doctor.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                doctor.speciality,
                style: const TextStyle(fontSize: 18, color: Color(0xFF567991)),
              ),
            ),
            const SizedBox(height: 30),

            _buildDetailRow(
              Icons.location_on,
              "Ville",
              doctor.city ?? "Non spécifiée",
            ),
            const Divider(),
            _buildDetailRow(
              Icons.map,
              "Adresse",
              doctor.location ?? "Non spécifiée",
            ),
            const Divider(),
            _buildDetailRow(
              Icons.attach_money,
              "Tarif Consultation",
              "${doctor.consultationFee.toStringAsFixed(0)} DH",
            ),
            const Divider(),
            _buildDetailRow(
              Icons.work,
              "Expérience",
              "${doctor.yearsOfExperience} ans",
            ),
            const Divider(),

            const SizedBox(height: 20),
            const Text(
              "Bio",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              doctor.bio ?? "Aucune information supplémentaire.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true); // Return true to select logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF567991),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Choisir ce médecin"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF567991)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
