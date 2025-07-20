import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String _eventName = '';
  String _description = '';
  String _location = '';
  DateTime? _selectedDateTime;
  double _duration = 1;

  final _firestore = FirebaseFirestore.instance;

  Future<void> _addEventToFirestore() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) return;

    _formKey.currentState!.save();

    try {
      await _firestore.collection('events').add({
        'name': _eventName,
        'description': _description,
        'location': _location,
        'timestamp': _selectedDateTime,
        'duration': _duration,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event added successfully")),
      );

      _formKey.currentState!.reset();
      setState(() => _selectedDateTime = null);
    } catch (e) {
      print("Error adding event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add event")),
      );
    }
  }

  void _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Add Event'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Event Name'),
              validator: (value) => value!.isEmpty ? 'Enter event name' : null,
              onSaved: (value) => _eventName = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Location'),
              onSaved: (value) => _location = value!,
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                _selectedDateTime == null
                    ? 'Pick Date & Time'
                    : DateFormat.yMMMd().add_jm().format(_selectedDateTime!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            SizedBox(height: 10),
            Text("Duration (hours): ${_duration.toStringAsFixed(1)}"),
            Slider(
              value: _duration,
              min: 0.5,
              max: 8,
              divisions: 15,
              label: _duration.toString(),
              onChanged: (value) => setState(() => _duration = value),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Add Event'),
              onPressed: _addEventToFirestore,
            ),
          ],
        ),
      ),
    ),
  );
}
}
