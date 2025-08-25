import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:vibe_loader/loaders/quantum_orbital_loader.dart';
class Events extends GetView<ExploreControllers> {
  final String templeId;
  Events({super.key, required this.templeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temple Events",
            style: GoogleFonts.rozhaOne(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getEvents(templeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: QuantumOrbitalLoader(
              orbitColor: Colors.amber,
              particleColor: Colors.amber,
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading events'));
          }

          final events = _processEvents(snapshot.data?.docs ?? []);

          // Store events in controller
          controller.storeEvents(events);

          // Print events to console
          _printEvents(events);

          return EventCalendar(events: events);
        },
      ),
    );
  }

  void _printEvents(Map<DateTime, List<Map<String, dynamic>>> events) {
    print('Events for templeId: $templeId');
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

  Map<DateTime, List<Map<String, dynamic>>> _processEvents(List<QueryDocumentSnapshot> docs) {
    final events = <DateTime, List<Map<String, dynamic>>>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['date_time'] as Timestamp;
      final utcDate = timestamp.toDate();
      final localDate = utcDate.toLocal();
      final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

      // Debug print for each event
      print('''
      Processing event:
      - Document ID: ${doc.id}
      - Temple ID: ${data['templeId']}
      - UTC Date: ${utcDate.toIso8601String()}
      - Local Date: ${localDate.toIso8601String()}
      - Date Key: ${dateOnly.toIso8601String()}
      ''');

      events.update(dateOnly, (list) => list..add(data), ifAbsent: () => [data]);
    }

    return events;
  }
}

class EventCalendar extends StatefulWidget {
  final Map<DateTime, List<Map<String, dynamic>>> events;

  const EventCalendar({super.key, required this.events});

  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedEvents = _getEventsForDay(_selectedDay!);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalized = _normalizeDate(day);
    print('Checking events for: ${normalized.toString()}'); // Debug print
    final events = widget.events[normalized] ?? [];
    print('Found ${events.length} events'); // Debug print
    return events;
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
          eventLoader: (day) => _getEventsForDay(day),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents = _getEventsForDay(selectedDay);
            });
          },calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
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
          child: _selectedEvents.isEmpty
              ? Center(child: Text('No events on selected date'))
              : ListView.builder(
            itemCount: _selectedEvents.length,
            itemBuilder: (context, index) {
              final event = _selectedEvents[index];
              final date = (event['date_time'] as Timestamp).toDate();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: ListTile(
                    leading: event['img']?.isNotEmpty == true
                        ? Image.network(event['img'], width: 70, height: 70)
                        : Icon(Icons.event),
                    title: Text(event['eventName'],style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 18),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['festivalName'],style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w400),),
                        Text(DateFormat.yMMMd().add_jm().format(date),style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w400),),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['img'] != null && event['img'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event['img'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 12),
            Text(
              event['eventName'] ?? 'Event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              event['festivalName'] ?? 'Festival',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(
                (event['date_time'] as Timestamp).toDate(),
              ),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}