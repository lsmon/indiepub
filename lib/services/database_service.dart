import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:indiepub/models/user.dart';
import 'package:indiepub/models/event.dart';
import 'package:indiepub/models/post.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'indiepub.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            location TEXT NOT NULL,
            price REAL NOT NULL,
            capacity INTEGER NOT NULL,
            creator_id TEXT NOT NULL,
            sold INTEGER DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY,
            content TEXT NOT NULL,
            user_id TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertUser(AppUser user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> getUser(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? AppUser.fromJson(result.first) : null;
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final result = await db.query('events');
    return result.map((json) => Event.fromJson(json)).toList();
  }

  Future<void> insertEvents(List<Event> events) async {
    final db = await database;
    final batch = db.batch();
    for (var event in events) {
      batch.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Post>> getPosts() async {
    final db = await database;
    final result = await db.query('posts');
    return result.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> insertPosts(List<Post> posts) async {
    final db = await database;
    final batch = db.batch();
    for (var post in posts) {
      batch.insert('posts', post.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }
}