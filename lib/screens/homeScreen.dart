import 'package:flutter/material.dart';
import 'NavigationBar/customBottomNavigationBar.dart';
import 'calendar_screen.dart';
import 'package:daily_planner/database/dataHelper.dart';
import 'package:daily_planner/screens/add_event_screen.dart';

import 'event_management_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late DatabaseHelper _databaseHelper;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _widgetOptions = <Widget>[
      CalendarScreen(),
      EventManagementScreen(),
      Text('Thử thách'),
      Text('Cài đặt'),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddEventScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(
          selectedDate: DateTime.now(),
          onEventAdded: (Event newEvent) {
            _databaseHelper.createEvent(newEvent);
            // Refresh the calendar if it's currently displayed
            if (_selectedIndex == 0) {
              setState(() {
                _widgetOptions[0] = CalendarScreen();
              });
            }
          },
        ),
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
        onPressed: _showAddEventScreen,
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
