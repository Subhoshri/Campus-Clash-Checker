import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String _subject = '';
  String _type = 'Class';
  String _day = 'Monday';
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _addScheduleEntry() async {
  if (!_formKey.currentState!.validate() || _startTime == null || _endTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❗Please fill all fields')),
    );
    return;
  }

  final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
  final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

  if (startMinutes >= endMinutes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❗Start time must be before end time')),
    );
    return;
  }

  _formKey.currentState!.save();

  final scheduleData = {
  'subject': _subject,
  'type': _type,
  'day': _day,
  'startHour': _startTime!.hour,
  'startMinute': _startTime!.minute,
  'endHour': _endTime!.hour,
  'endMinute': _endTime!.minute,
  'createdAt': Timestamp.now(),
  };

  try {
    await FirebaseFirestore.instance.collection('schedule').add(scheduleData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule added')),
    );

    _formKey.currentState!.reset();
    setState(() {
      _startTime = null;
      _endTime = null;
      _type = 'Class';
      _day = 'Monday';
    });
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save')),
    );
  }
}


  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) _startTime = picked;
      else _endTime = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Class / Lab")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
                onSaved: (val) => _subject = val!,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Class', 'Lab'].map((val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(() => _type = val!),
                decoration: InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: _day,
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() => _day = val!),
                decoration: InputDecoration(labelText: 'Day'),
              ),
              ListTile(
                title: Text(_startTime == null
                    ? 'Pick Start Time'
                    : 'Start: ${_startTime!.format(context)}'),
                trailing: Icon(Icons.schedule),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Pick End Time'
                    : 'End: ${_endTime!.format(context)}'),
                trailing: Icon(Icons.schedule_outlined),
                onTap: () => _pickTime(false),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add Schedule"),
                onPressed: _addScheduleEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
