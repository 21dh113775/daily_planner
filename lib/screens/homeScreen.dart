import 'package:flutter/material.dart';
import 'NavigationBar/customBottomNavigationBar.dart';
import 'calendar_screen.dart';
import 'package:daily_planner/database/dataHelper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late DatabaseHelper _databaseHelper;

  static List<Widget> _widgetOptions = <Widget>[
    CalendarScreen(),
    Text('Quản lý'),
    Text('Thử thách'),
    Text('Cài đặt'),
  ];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddEventDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _startDate = DateTime.now();
    DateTime _endDate = _startDate.add(Duration(hours: 1));
    bool _isAllDay = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm Sự Kiện'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      child: Text(
                        'Ngày bắt đầu: ${_startDate.toLocal()}'.split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
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
                        'Ngày kết thúc: ${_endDate.toLocal()}'.split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
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
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
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
                _databaseHelper.createEvent(newEvent);
                Navigator.of(context).pop();
                // Refresh the calendar if it's currently displayed
                if (_selectedIndex == 0) {
                  setState(() {
                    _widgetOptions[0] = CalendarScreen();
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 63, 133, 217),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
