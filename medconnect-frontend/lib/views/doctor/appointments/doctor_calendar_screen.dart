import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medconnect_app/view_models/doctor_appointment_view_model.dart';
import 'package:medconnect_app/models/appointment.dart';

class DoctorCalendarScreen extends StatefulWidget {
  const DoctorCalendarScreen({Key? key}) : super(key: key);

  @override
  State<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends State<DoctorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    /// ✅ Initialise le format FR
    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) {
        setState(() {
          _localeInitialized = true;
        });
      }
    });
  }

  /// ✅ Récupérer les RDV du jour
  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final viewModel =
    Provider.of<DoctorAppointmentViewModel>(context, listen: false);

    return viewModel.appointments.where((appointment) {
      final aDate = appointment.dateTime;

      return aDate.year == day.year &&
          aDate.month == day.month &&
          aDate.day == day.day &&
          appointment.status != Appointment.statusCancelled &&
          appointment.status != Appointment.statusRefused;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: !_localeInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildHeader(),
          _buildDaysOfWeek(),

          /// ✅ IMPORTANT: Calendar dans Expanded pour éviter overflow
          Expanded(
            flex: 2,
            child: _buildCalendarGrid(),
          ),

          const Divider(),

          /// ✅ IMPORTANT: Liste des RDV aussi dans Expanded
          Expanded(
            flex: 3,
            child: _buildAppointmentList(),
          ),
        ],
      ),
    );
  }

  /// ✅ Header mois + boutons
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
              });
            },
          ),
          Text(
            DateFormat.yMMMM('fr_FR').format(_focusedDay).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Days in week
  Widget _buildDaysOfWeek() {
    final days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((day) => Text(day,
            style: const TextStyle(fontWeight: FontWeight.bold)))
            .toList(),
      ),
    );
  }

  /// ✅ Calendar grid
  Widget _buildCalendarGrid() {
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // 1=Mon .. 7=Sun

    final int totalSlots = daysInMonth + (firstWeekday - 1);

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox.shrink();
        }

        final day = index - (firstWeekday - 1) + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = _selectedDay != null && isSameDay(_selectedDay!, date);
        final appointments = _getAppointmentsForDay(date);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF567991) : null,
              shape: BoxShape.circle,
              border: isToday(date) && !isSelected
                  ? Border.all(color: const Color(0xFF567991))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                if (appointments.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ List of appointments
  Widget _buildAppointmentList() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final appointments = _getAppointmentsForDay(_selectedDay!);

    if (appointments.isEmpty) {
      return Center(
        child: Text(
          'Aucun rendez-vous pour le ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final timeStr = DateFormat('HH:mm').format(appt.dateTime);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Icon(
              Icons.access_time,
              color: _getStatusColor(appt.status),
            ),
            title: Text(appt.patientName),
            subtitle: Text('$timeStr - ${appt.status}'),
          ),
        );
      },
    );
  }

  /// ✅ Color status
  Color _getStatusColor(String status) {
    switch (status) {
      case Appointment.statusConfirmed:
        return Colors.green;
      case Appointment.statusPending:
        return Colors.orange;
      case Appointment.statusCancelled:
        return Colors.red;
      case Appointment.statusRefused:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }
}
