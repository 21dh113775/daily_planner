import 'package:flutter/material.dart';
import 'package:daily_planner/database/dataHelper.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final Function(Event) onEventUpdated;
  final Function() onEventDeleted;

  EventDetailsScreen({
    required this.event,
    required this.onEventUpdated,
    required this.onEventDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết sự kiện'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editEvent(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteEvent(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Mô tả:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(event.description),
            SizedBox(height: 16),
            Text(
              'Thời gian bắt đầu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(event.startDate.toString()),
            SizedBox(height: 8),
            Text(
              'Thời gian kết thúc:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(event.endDate.toString()),
            SizedBox(height: 16),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(event.color),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editEvent(BuildContext context) {
    // Navigate to edit event screen
    // After editing, call onEventUpdated with the updated event
  }

  void _deleteEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa sự kiện'),
          content: Text('Bạn có chắc chắn muốn xóa sự kiện này?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () {
                DatabaseHelper().deleteEvent(event.id!).then((_) {
                  onEventDeleted();
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to calendar screen
                });
              },
            ),
          ],
        );
      },
    );
  }
}
