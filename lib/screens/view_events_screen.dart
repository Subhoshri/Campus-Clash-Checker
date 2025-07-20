import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'view_past_events.dart';

class ViewEventsScreen extends StatelessWidget {
  const ViewEventsScreen({super.key});

  Future<void> addToSchedule(Map<String, dynamic> event, BuildContext context) async {
  final eventName = event['name'];
  final eventDay = DateFormat('EEEE').format(event['timestamp'].toDate());
  final eventStartTime = DateFormat('h:mm a').format(event['timestamp'].toDate());

  final scheduleRef = FirebaseFirestore.instance.collection('schedule');

  // Check if event already exists in schedule
  final existing = await scheduleRef
      .where('subject', isEqualTo: eventName)
      .where('day', isEqualTo: eventDay)
      .where('startTime', isEqualTo: eventStartTime)
      .where('type', isEqualTo: 'Event')
      .get();

  if (existing.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event already added to your schedule.")),
    );
    return;
  }

  // Add to schedule
  final scheduleData = {
    'subject': eventName,
    'type': 'Event',
    'day': eventDay,
    'startTime': eventStartTime,
    'endTime': DateFormat('h:mm a').format(
      event['timestamp'].toDate().add(Duration(hours: event['duration'] ?? 1)),
    ),
    'createdAt': Timestamp.now(),
  };

  await scheduleRef.add(scheduleData);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Event added to your schedule!")),
  );
}


  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();

    return Scaffold(
      appBar: AppBar(title: Text('Upcoming Events')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('timestamp', isGreaterThan: now)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final events = snapshot.data!.docs;

                if (events.isEmpty) {
                  return Center(child: Text('No upcoming events.'));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index].data() as Map<String, dynamic>;
                    final timestamp = event['timestamp'].toDate();
                    final formattedDate = DateFormat('EEEE, MMM d • h:mm a').format(timestamp);

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['name'] ?? 'No Name',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(event['description'] ?? ''),
                            SizedBox(height: 4),
                            Text('📍 ${event['location']}'),
                            Text('🕒 $formattedDate • ${event['duration']} hrs'),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => addToSchedule(event, context),
                              icon: Icon(Icons.add),
                              label: Text("Add to Schedule"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ViewPastEventsScreen()));
              },
              icon: Icon(Icons.history),
              label: Text("View Past Events"),
            ),
          ),
        ],
      ),
    );
  }
}
