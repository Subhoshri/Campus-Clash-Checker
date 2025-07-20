import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/gemini_service.dart';

class ClashCheckerScreen extends StatefulWidget {
  const ClashCheckerScreen({Key? key}) : super(key: key);

  @override
  State<ClashCheckerScreen> createState() => _ClashCheckerScreenState();
}

class _ClashCheckerScreenState extends State<ClashCheckerScreen> {
  String buildClashPrompt(String eventName, String eventDay, String eventTime, int duration) {
  final buffer = StringBuffer();
  buffer.writeln("Event: $eventName");
  buffer.writeln("Scheduled for: $eventDay at $eventTime for $duration minutes.");
  buffer.writeln("This clashes with my academic schedule:");
  for (var s in _schedule.where((s) => s['day'] == eventDay)) {
    buffer.writeln("- ${s['subject']} (${s['type']}) from ${s['startTime']} to ${s['endTime']}");
  }
  buffer.writeln("Can you suggest a smart way to handle this clash or alternatives?");
  return buffer.toString();
}

  List<Map<String, dynamic>> _schedule = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    final snap = await FirebaseFirestore.instance.collection('schedule').get();
    setState(() {
      _schedule = snap.docs.map((doc) => doc.data()).toList();
    });
  }

  bool isClashing(String eventDay, TimeOfDay eventStart, int durationMinutes) {
  final eStart = eventStart.hour * 60 + eventStart.minute;
  final eEnd = eStart + durationMinutes;

  for (var item in _schedule) {
    if (item['day'] != eventDay) continue;

    final classStart = _parseTime(item['startTime']);
    final classEnd = _parseTime(item['endTime']);
    final cStart = classStart.hour * 60 + classStart.minute;
    final cEnd = classEnd.hour * 60 + classEnd.minute;

    debugPrint("Checking clash for $eventDay:");
    debugPrint("Event: $eStart - $eEnd, Class: $cStart - $cEnd");

    if (eStart < cEnd && eEnd > cStart) {
      debugPrint("⚠️ Clash detected!");
      return true;
    }
  }
  return false;
}


  TimeOfDay _parseTime(String t) {
  try {
    // Try parsing 12-hour format first
    return TimeOfDay.fromDateTime(DateFormat.jm().parse(t));
  } catch (_) {
    try {
      // Fallback to 24-hour format if 12-hour parsing fails
      return TimeOfDay.fromDateTime(DateFormat.Hm().parse(t));
    } catch (_) {
      print("Time parsing failed for '$t'");
      return TimeOfDay(hour: 0, minute: 0);
    }
  }
}


  String _getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clash Checker")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("📚 Class/Lab Schedule"),
            _buildScheduleList(),
            Divider(thickness: 2),
            _buildSectionTitle("🎉 Events & Clash Status"),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _schedule.length,
      itemBuilder: (context, index) {
        final s = _schedule[index];
        return ListTile(
          leading: Icon(Icons.class_),
          title: Text("${s['subject']} (${s['type']})"),
          subtitle: Text("${s['day']} | ${s['startTime']} - ${s['endTime']}"),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final events = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final data = events[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Unnamed Event';
            final Timestamp? ts = data['timestamp'];
            if (ts == null) {
              return ListTile(
                leading: Icon(Icons.error, color: Colors.grey),
                title: Text(name),
                subtitle: Text('❗ Missing timestamp'),
                trailing: Icon(Icons.warning, color: Colors.orange),
              );
            }
            final date = ts.toDate();

            final duration = data['duration'] ?? 0;
            final startTime = TimeOfDay(hour: date.hour, minute: date.minute);
            final day = _getDayOfWeek(date);
            final isClash = isClashing(day, startTime, duration);

            return ListTile(
  leading: Icon(Icons.event),
  title: Text(name),
  subtitle: Text('$day, ${DateFormat.jm().format(date)} | Duration: $duration min'),
  trailing: isClash
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.red),
            IconButton(
              icon: Icon(Icons.lightbulb_outline),
              tooltip: "Suggest Solution",
              onPressed: () async {
                final prompt = buildClashPrompt(
                  name,
                  day,
                  DateFormat.jm().format(date),
                            duration,
                          );
                          final suggestion = await GeminiService().getClashFreeSuggestions(prompt);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("AI Suggestion"),
                              content: Text(suggestion),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close"),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  )
                : Icon(Icons.check_circle, color: Colors.green),
          );

          },
        );
      },
    );
  }
}
