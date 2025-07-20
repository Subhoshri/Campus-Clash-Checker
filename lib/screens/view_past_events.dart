import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewPastEventsScreen extends StatelessWidget {
  const ViewPastEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();

    return Scaffold(
      appBar: AppBar(title: Text('Past Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('timestamp', isLessThan: now)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final events = snapshot.data!.docs;

          if (events.isEmpty) {
            return Center(child: Text('No past events found.'));
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
