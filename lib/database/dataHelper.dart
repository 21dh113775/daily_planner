import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal(); // Private constructor for singleton

  // Retrieve database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database with tables and version control
  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'app_database.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Using a batch for multiple table creation
          Batch batch = db.batch();
          batch.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              email TEXT UNIQUE, 
              password TEXT
            );
          ''');
          batch.execute('''
            CREATE TABLE IF NOT EXISTS events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL,
              is_all_day INTEGER NOT NULL,
              color INTEGER NOT NULL
            );
          ''');
          await batch.commit();
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Example of future upgrades
          if (oldVersion < newVersion) {
            // Handle upgrading database schema here
            await db.execute('ALTER TABLE events ADD COLUMN location TEXT');
          }
        },
      );
    } catch (e) {
      throw Exception('Database initialization failed: $e');
    }
  }

  // Insert a new user into the database
  Future<void> insertUser(String email, String password) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        {'email': email, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting user: $e');
    }
  }

  // Retrieve user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
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
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Create a new event
  Future<int> createEvent(Event event) async {
    try {
      final db = await database;
      return await db.insert('events', event.toJson());
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  // Retrieve all events
  Future<List<Event>> getEvents() async {
    try {
      final db = await database;
      final result = await db.query('events');
      return result.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error retrieving events: $e');
    }
  }

  // Update an existing event
  Future<int> updateEvent(Event event) async {
    try {
      final db = await database;
      return await db.update(
        'events',
        event.toJson(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  // Delete an event by its id
  Future<int> deleteEvent(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
}

// Event Model with validation and conversion utilities
class Event {
  final int? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAllDay;
  final int color;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isAllDay,
    required this.color,
  }) {
    // Basic validation
    if (title.isEmpty || description.isEmpty) {
      throw Exception('Event title and description cannot be empty');
    }
    if (startDate.isAfter(endDate)) {
      throw Exception('Event start date cannot be after end date');
    }
  }

  // Convert Event to a map for database insertion
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_all_day': isAllDay ? 1 : 0,
        'color': color,
      };

  // Create Event object from a map retrieved from the database
  static Event fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as int?,
        title: json['title'] as String,
        description: json['description'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        isAllDay: json['is_all_day'] == 1,
        color: json['color'] as int,
      );

  // Method to copy event and update only specific fields (immutable update)
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    int? color,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
    );
  }
}
