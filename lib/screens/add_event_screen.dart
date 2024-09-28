import 'package:flutter/material.dart';
import 'package:daily_planner/database/dataHelper.dart';

class AddEventScreen extends StatefulWidget {
  final Function(Event) onEventAdded;
  final DateTime selectedDate;

  AddEventScreen({required this.onEventAdded, required this.selectedDate});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
    _endDate = widget.selectedDate.add(Duration(hours: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Sự Kiện'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('Ngày bắt đầu: ${_startDate.toLocal()}'
                          .split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _startDate) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text(
                          'Ngày kết thúc: ${_endDate.toLocal()}'.split(' ')[0]),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _endDate) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: Text("Cả ngày"),
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                child: Text('Lưu'),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    Event newEvent = Event(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      startDate: _startDate,
                      endDate: _endDate,
                      isAllDay: _isAllDay,
                      color: Colors.blue.value,
                    );
                    widget.onEventAdded(newEvent);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
