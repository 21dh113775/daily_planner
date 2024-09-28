import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2, // Tăng version khi thay đổi cấu trúc database
      onCreate: (db, version) async {
        // Creating users table
        await db.execute(
          '''CREATE TABLE users(
            id INTEGER PRIMARY KEY,
            email TEXT UNIQUE,
            password TEXT
          )''',
        );
        // Creating events table
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            is_all_day INTEGER NOT NULL,
            color INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0
          )''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Cập nhật database nếu phiên bản cũ chưa có trường is_completed
          await db.execute('''
            ALTER TABLE events ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );
  }

  // User-related methods

  // Insert a new user into the database
  Future<void> insertUser(String email, String password) async {
    final db = await database;

    await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;

    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Calendar-related methods

  Future<void> initializeCalendarTable() async {
    final db = await database;
    await db.execute('''CREATE TABLE IF NOT EXISTS events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          is_all_day INTEGER NOT NULL,
          color INTEGER NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0
        )''');
  }

  // Create a new event
  Future<int> createEvent(Event event) async {
    await initializeCalendarTable();
    final db = await database;
    return await db.insert('events', event.toJson(excludeId: true));
  }

  // Retrieve all events
  Future<List<Event>> getEvents() async {
    await initializeCalendarTable();
    final db = await database;
    final result = await db.query('events');
    return result.map((json) => Event.fromJson(json)).toList();
  }

  // Retrieve events by status
  Future<List<Event>> getEventsByCompletion(bool isCompleted) async {
    final db = await database;
    final result = await db.query(
      'events',
      where: 'is_completed = ?',
      whereArgs: [isCompleted ? 1 : 0],
    );
    return result.map((json) => Event.fromJson(json)).toList();
  }

  // Update an existing event
  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // Mark event as completed
  Future<int> markEventCompleted(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'events',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete an event
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Event model
class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAllDay;
  final bool isCompleted;
  final int color;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isAllDay,
    this.isCompleted = false,
    required this.color,
  });

  Map<String, dynamic> toJson({bool excludeId = false}) {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_all_day': isAllDay ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'color': color,
    };

    if (!excludeId && id != null) {
      data['id'] = id;
    }

    return data;
  }

  static Event fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as int?,
        title: json['title'] as String,
        description: json['description'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        isAllDay: json['is_all_day'] == 1,
        isCompleted: json['is_completed'] == 1,
        color: json['color'] as int,
      );
}
