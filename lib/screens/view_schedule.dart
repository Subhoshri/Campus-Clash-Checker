import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewScheduleScreen extends StatefulWidget {
  const ViewScheduleScreen({super.key});

  @override
  State<ViewScheduleScreen> createState() => _ViewScheduleScreenState();
}

class FilterChips extends StatelessWidget {
  final String selectedType;
  final Function(String) onChanged;

  const FilterChips({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = ['All', 'Class', 'Lab', 'Event'];

    return Wrap(
      spacing: 10,
      children: types.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
          selectedColor: Colors.deepPurple,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        );
      }).toList(),
    );
  }
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  String selectedType = 'All';

  final dayOrder = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Schedule')),
      body: Column(
        children: [
          SizedBox(height: 10),
          FilterChips(
            selectedType: selectedType,
            onChanged: (type) => setState(() => selectedType = type),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('schedule').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // Filtering
                if (selectedType != 'All') {
                  docs = docs.where((doc) => doc['type'] == selectedType).toList();
                }

                // Sorting by day + startTime
                docs.sort((a, b) {
                  final dayA = a['day'] ?? '';
                  final dayB = b['day'] ?? '';
                  final orderA = dayOrder[dayA] ?? 8;
                  final orderB = dayOrder[dayB] ?? 8;
                  if (orderA != orderB) return orderA.compareTo(orderB);

                  final timeA = a['startTime'] ?? '';
                  final timeB = b['startTime'] ?? '';
                  return timeA.compareTo(timeB);
                });

                if (docs.isEmpty) return Center(child: Text('No schedule found.'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String id = doc.id;
                    final String type = data['type'] ?? 'Class';
                    final String title = data['type'] == 'Event' ? (data['subject'] ?? data['name'] ?? 'Event') : (data['subject'] ?? 'Class');
                    final String day = data['day'] ?? 'N/A';
                    final String startTime = data['startTime'] ?? '';
                    final String endTime = data['endTime'] ?? '';
                    final String location = data['location'] ?? '';
                    final String description = data['description'] ?? '';

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 3,
                      child: ListTile(
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🗓 $day, $startTime – $endTime'),
                            if (location.isNotEmpty) Text('📍 $location'),
                            if (description.isNotEmpty) Text('📝 $description'),
                            Text('Type: $type'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(id),
                        ),
                        onTap: () {
                          // TODO: Navigate to Modify Screen with `doc.id`
                          _showModifyDialog(context, doc);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(String docId) {
    FirebaseFirestore.instance.collection('schedule').doc(docId).delete();
  }

  void _showModifyDialog(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final controller = TextEditingController(
      text: data['subject'] ?? data['name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Schedule Title'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('schedule')
                  .doc(doc.id)
                  .update(data['type'] == 'Event'
                      ? {'name': controller.text}
                      : {'subject': controller.text});
              Navigator.pop(context);
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}
