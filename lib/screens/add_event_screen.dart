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
  final _reminderController = TextEditingController();
  late DateTime _date;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  Color _selectedColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  "${_date.day}/${_date.month}/${_date.year}",
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, isStartTime: true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ Bắt Đầu',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, isStartTime: false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Giờ Kết Thúc',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reminderController,
              decoration: InputDecoration(
                labelText: 'Nhắc Nhở',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Chọn Màu', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
              children: [
                _colorButton(Colors.red),
                SizedBox(width: 12), // Add small spacing between buttons
                _colorButton(Colors.yellow),
                SizedBox(width: 12), // Add small spacing between buttons
                _colorButton(Colors.blue),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saveEvent,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 94, 147, 228), // Green background
                  padding:
                      EdgeInsets.symmetric(vertical: 16), // Padding for height
                  side: BorderSide(
                      color: const Color.fromARGB(255, 85, 158, 237),
                      width: 2), // Border style
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text(
                  'Tạo sự kiện',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16), // White text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEvent() {
    if (_titleController.text.isNotEmpty) {
      final startDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _endTime.hour,
        _endTime.minute,
      );

      Event newEvent = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: startDateTime,
        endDate: endDateTime,
        isAllDay: false, // You might want to add an option for all-day events
        color: _selectedColor.value,
      );

      DatabaseHelper().createEvent(newEvent).then((id) {
        newEvent = Event(
          id: id,
          title: newEvent.title,
          description: newEvent.description,
          startDate: newEvent.startDate,
          endDate: newEvent.endDate,
          isAllDay: newEvent.isAllDay,
          color: newEvent.color,
        );
        widget.onEventAdded(newEvent);
        Navigator.pop(context);
      });
    }
  }
}
