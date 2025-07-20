import 'package:flutter/material.dart';
import 'add_event_screen.dart';
import 'schedule_screen.dart';
import 'clash_checker_screen.dart';
import 'view_events_screen.dart';
import 'view_schedule.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Campus Event Checker!'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi there 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'What would you like to do today?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  HomeOption(title: '➕ Add Event', screen: AddEventScreen()),
                  HomeOption(title: '📘 Add Class/Schedule', screen: ScheduleScreen()),
                  HomeOption(title: '🔍 Clash Checker', screen: ClashCheckerScreen()),
                  HomeOption(title: '📅 View Events', screen: ViewEventsScreen()),
                  HomeOption(title: '🗓️ Your Schedule', screen: ViewScheduleScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeOption extends StatelessWidget {
  final String title;
  final Widget screen;

  HomeOption({required this.title, required this.screen});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Center(
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}
