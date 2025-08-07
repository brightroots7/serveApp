import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Appcolors.dart';

class Volunteering extends GetView<ExploreControllers> {
  final String templeId;  // Ensure templeId is defined

  const Volunteering({super.key, required this.templeId});  // Pass templeId in constructor

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text("Volunteering Requests", style: GoogleFonts.rozhaOne(color: Colors.amber)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getVolunteeringRequests(templeId),  // Correct usage of templeId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading events'));
          }

          final volunteeringRequest = _processVolunteeringRequests(snapshot.data?.docs ?? []);

          controller.storeVolunteering(volunteeringRequest);

          _printVolunteeringRequests(volunteeringRequest);

          return VolunteeringCalendar(volunteeringRequest: volunteeringRequest, templeId: templeId,);
        },
      ),
    );
  }

  void _printVolunteeringRequests(Map<DateTime, List<Map<String, dynamic>>> events) {
    print('Request for templeId: $templeId');  // Correct usage of templeId
    events.forEach((date, eventList) {
      print('\nDate: ${DateFormat('yyyy-MM-dd').format(date)}');
      eventList.forEach((event) {
        print('├─ Event Name: ${event['eventName']}');
        print('├─ Festival: ${event['festivalName']}');
        print('├─ Image URL: ${event['img']}');
        print('└─ Timestamp: ${event['date_time']}');
      });
    });
  }

  Map<DateTime, List<Map<String, dynamic>>> _processVolunteeringRequests(List<QueryDocumentSnapshot> docs) {
    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['date_time'] as Timestamp;
      final localDate = timestamp.toDate();
      final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

      print('''
  Processing event:
  - Document ID: ${doc.id}
  - Temple ID: ${data['templeId']}
  - Local Date: ${localDate.toIso8601String()}
  - Date Key: ${dateOnly.toIso8601String()}
  - Status: ${data['status']}
  ''');

      events.update(
        dateOnly,
            (list) => list..add(data),
        ifAbsent: () => [data],
      );
    }

    return events;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class VolunteeringCalendar extends StatefulWidget {
  final String templeId;
  final Map<DateTime, List<Map<String, dynamic>>> volunteeringRequest;

  VolunteeringCalendar({super.key, required this.volunteeringRequest, required this.templeId});

  @override
  _VolunteeringCalendarState createState() => _VolunteeringCalendarState();
}

class _VolunteeringCalendarState extends State<VolunteeringCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedVolunteeringRequests = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedVolunteeringRequests = _getVolunteeringRequestForDay(_selectedDay!);
  }

  DateTime _normalizeDate(DateTime date) {
    // Convert to the same timezone as the event timestamp.
    return DateTime.utc(date.year, date.month, date.day);
  }

  List<Map<String, dynamic>> _getVolunteeringRequestForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    print('Checking requests for: ${normalized.toString()}'); // Debug print
    final requests = widget.volunteeringRequest[normalized] ?? [];
    print('Found ${requests.length} volunteeringRequest'); // Debug print

    return requests.where((request) => request['status'] == 'Accepted').toList();
  }


  void _showRequestDialog(BuildContext context, String templeId) {
    final formKey = GlobalKey<FormState>();
    final eventNameController = TextEditingController();
    final festivalNameController = TextEditingController();

    // Use the selected day from calendar
    final selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Volunteering Request'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: eventNameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter event name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: festivalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Festival Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter festival name' : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selected Date: ${DateFormat.yMMMd().format(selectedDate)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('volunteering requests')
                        .add({
                      'eventName': eventNameController.text,
                      'festivalName': festivalNameController.text,
                      'date_time': Timestamp.fromDate(selectedDate),
                      'templeId': templeId,
                      'userId': user.uid,
                      'username': user.displayName ?? 'Anonymous',
                      'status': 'Requested',
                      'createdAt': Timestamp.now(),
                    });

                    Get.snackbar(
                      'Success',
                      'Request submitted successfully!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to submit request: $e',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Requested':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2000),
          lastDay: DateTime.utc(2050),
          focusedDay: _focusedDay,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          eventLoader: (day) {
            final requests = _getVolunteeringRequestForDay(day);
            print('Loaded events for: ${DateFormat.yMMMd().format(day)} with ${requests.length} requests');
            return requests.isNotEmpty ? [Object()] : [];
          },

          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedVolunteeringRequests = _getVolunteeringRequestForDay(selectedDay);
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    width: 10,
                    height: 10,
                  ),
                );
              }
              return null;
            },
          ),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            markersAlignment: Alignment.bottomCenter,
            markersAutoAligned: true,
            markerSize: 8,
            todayDecoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        Expanded(
          child: _selectedVolunteeringRequests.isEmpty
              ? Center(child: Text('No request on selected date'))
              : ListView.builder(
            itemCount: _selectedVolunteeringRequests.length,
            itemBuilder: (context, index) {
              final volunteeringRequest = _selectedVolunteeringRequests[index];
              final date = (volunteeringRequest['date_time'] as Timestamp).toDate();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(volunteeringRequest['status']),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      volunteeringRequest['eventName'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volunteeringRequest['festivalName'],
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(date),
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () async {
            _showRequestDialog(context, widget.templeId);  // Pass templeId here
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Appcolors.appColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Request Volunteering Opportunity',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

