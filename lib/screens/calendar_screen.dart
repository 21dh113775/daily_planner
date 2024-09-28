import 'package:daily_planner/screens/add_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:daily_planner/database/dataHelper.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarView _calendarView = CalendarView.month;
  late DatabaseHelper _databaseHelper;
  _EventDataSource? _events;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<Event> events = await _databaseHelper.getEvents();
    setState(() {
      _events = _EventDataSource(events);
      _isLoading = false;
    });
  }

  Future<void> _addEvent(Event event) async {
    await _databaseHelper.createEvent(event);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Lịch'),
        actions: [
          IconButton(
            icon: Icon(Icons.view_module),
            onPressed: _showViewSelector,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.all(20.0), // Add padding for better spacing
              child: SfCalendar(
                view: _calendarView,
                dataSource: _events,
                cellEndPadding: 10, // Adjust padding between cells
                monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  monthCellStyle: MonthCellStyle(
                    textStyle: TextStyle(fontSize: 16), // Increase font size
                  ),
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 7,
                  endHour: 20,
                  timeTextStyle:
                      TextStyle(fontSize: 16), // Increase time text size
                ),
                firstDayOfWeek: 1, // Monday
                showWeekNumber: true,
                allowedViews: [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.workWeek,
                  CalendarView.month,
                  CalendarView.schedule,
                ],
              ),
            ),
    );
  }

  void _showViewSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn chế độ xem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _viewSelectorButton('Ngày', CalendarView.day),
              _viewSelectorButton('Tuần', CalendarView.week),
              _viewSelectorButton('Tuần làm việc', CalendarView.workWeek),
              _viewSelectorButton('Tháng', CalendarView.month),
              _viewSelectorButton('Lịch trình', CalendarView.schedule),
            ],
          ),
        );
      },
    );
  }

  Widget _viewSelectorButton(String title, CalendarView view) {
    return ElevatedButton(
      child: Text(title),
      onPressed: () {
        setState(() {
          _calendarView = view;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAddEventDialog(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(
          selectedDate: selectedDate,
          onEventAdded: (event) {
            _addEvent(event);
          },
        ),
      ),
    );
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endDate;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return Color(appointments![index].color);
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
