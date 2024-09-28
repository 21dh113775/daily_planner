import 'package:flutter/material.dart';
import 'package:daily_planner/database/dataHelper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EventManagementScreen extends StatefulWidget {
  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  late DatabaseHelper _databaseHelper;
  late List<Event> _expiredEvents;
  late List<Event> _upcomingEvents;
  late List<Event> _ongoingEvents;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadEvents();
  }

  void _loadEvents() async {
    List<Event> events = await _databaseHelper.getEvents();
    DateTime now = DateTime.now();

    setState(() {
      _expiredEvents =
          events.where((event) => event.startDate.isBefore(now)).toList();
      _upcomingEvents =
          events.where((event) => event.startDate.isAfter(now)).toList();
      _ongoingEvents = events
          .where((event) =>
              event.startDate.isBefore(now) && event.endDate.isAfter(now))
          .toList();
    });
  }

  Widget _buildEventList(List<Event> events, String title) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Không có sự kiện $title',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) {
          Event event = events[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.event,
                        color: Theme.of(context).primaryColor),
                    title: Text(event.title),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(event.startDate)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sự kiện'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Sự kiện đã hết hạn'),
              _buildEventList(_expiredEvents, 'hết hạn'),
              SizedBox(height: 20),
              _buildSectionTitle('Sự kiện đang diễn ra'),
              _buildEventList(_ongoingEvents, 'đang diễn ra'),
              SizedBox(height: 20),
              _buildSectionTitle('Sự kiện sắp tới'),
              _buildEventList(_upcomingEvents, 'sắp tới'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor),
    );
  }
}
