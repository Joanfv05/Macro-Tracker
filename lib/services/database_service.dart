import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'macro_tracker.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            grams REAL NOT NULL,
            date TEXT NOT NULL,
            meal TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE day_logs (
            date TEXT PRIMARY KEY,
            calories REAL DEFAULT 0,
            protein REAL DEFAULT 0,
            carbs REAL DEFAULT 0,
            fat REAL DEFAULT 0,
            water REAL DEFAULT 0,
            steps INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY,
            calories REAL DEFAULT 2000,
            protein REAL DEFAULT 150,
            carbs REAL DEFAULT 200,
            fat REAL DEFAULT 60,
            water REAL DEFAULT 2.5,
            steps INTEGER DEFAULT 8000
          )
        ''');
        await db.execute('''
          CREATE TABLE profile (
            name TEXT,
            age INTEGER,
            weight REAL,
            height REAL,
            gender TEXT,
            goal TEXT
          )
        ''');
        // Insert default goals
        await db.insert('goals', {
          'id': 1,
          'calories': 2000,
          'protein': 150,
          'carbs': 200,
          'fat': 60,
          'water': 2.5,
          'steps': 8000,
        });
        // Insert default profile
        await db.insert('profile', {
          'name': '',
          'age': 25,
          'weight': 70,
          'height': 170,
          'gender': 'Hombre',
          'goal': 'Definición',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE profile (
              name TEXT,
              age INTEGER,
              weight REAL,
              height REAL,
              gender TEXT,
              goal TEXT
            )
          ''');
          await db.insert('profile', {
            'name': '',
            'age': 25,
            'weight': 70,
            'height': 170,
            'gender': 'Hombre',
            'goal': 'Definición',
          });
        }
      },
    );
  }

  // ─── FOOD ENTRIES ────────────────────────────────────────────────────────────

  Future<int> insertFood(FoodEntry entry) async {
    final database = await db;
    final id = await database.insert('food_entries', entry.toMap()..remove('id'));
    await _recalcDayLog(entry.date);
    return id;
  }

  Future<void> deleteFood(int id, String date) async {
    final database = await db;
    await database.delete('food_entries', where: 'id = ?', whereArgs: [id]);
    await _recalcDayLog(date);
  }

  Future<List<FoodEntry>> getFoodsForDay(String date) async {
    final database = await db;
    final maps = await database.query(
      'food_entries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
    return maps.map((m) => FoodEntry.fromMap(m)).toList();
  }

  // ─── DAY LOGS ────────────────────────────────────────────────────────────────

  Future<void> _recalcDayLog(String date) async {
    final database = await db;
    final foods = await getFoodsForDay(date);

    double cal = 0, prot = 0, carb = 0, fat = 0;
    for (final f in foods) {
      cal += f.calories;
      prot += f.protein;
      carb += f.carbs;
      fat += f.fat;
    }

    final existing = await database.query('day_logs', where: 'date = ?', whereArgs: [date]);
    if (existing.isEmpty) {
      await database.insert('day_logs', {
        'date': date,
        'calories': cal,
        'protein': prot,
        'carbs': carb,
        'fat': fat,
        'water': 0,
        'steps': 0,
      });
    } else {
      await database.update(
        'day_logs',
        {'calories': cal, 'protein': prot, 'carbs': carb, 'fat': fat},
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }

  Future<DayLog> getDayLog(String date) async {
    final database = await db;
    final maps = await database.query('day_logs', where: 'date = ?', whereArgs: [date]);
    if (maps.isEmpty) return DayLog(date: date);
    return DayLog.fromMap(maps.first);
  }

  Future<void> updateWater(String date, double water) async {
    final database = await db;
    final existing = await database.query('day_logs', where: 'date = ?', whereArgs: [date]);
    if (existing.isEmpty) {
      await database.insert('day_logs', {'date': date, 'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'water': water, 'steps': 0});
    } else {
      await database.update('day_logs', {'water': water}, where: 'date = ?', whereArgs: [date]);
    }
  }

  Future<void> updateSteps(String date, int steps) async {
    final database = await db;
    final existing = await database.query('day_logs', where: 'date = ?', whereArgs: [date]);
    if (existing.isEmpty) {
      await database.insert('day_logs', {'date': date, 'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0, 'water': 0, 'steps': steps});
    } else {
      await database.update('day_logs', {'steps': steps}, where: 'date = ?', whereArgs: [date]);
    }
  }

  Future<List<DayLog>> getLastNDays(int n) async {
    final database = await db;
    final maps = await database.query(
      'day_logs',
      orderBy: 'date DESC',
      limit: n,
    );
    return maps.map((m) => DayLog.fromMap(m)).toList().reversed.toList();
  }

  // ─── GOALS ───────────────────────────────────────────────────────────────────

  Future<UserGoals> getGoals() async {
    final database = await db;
    final maps = await database.query('goals', where: 'id = ?', whereArgs: [1]);
    if (maps.isEmpty) return UserGoals();
    return UserGoals.fromMap(maps.first);
  }

  Future<void> saveGoals(UserGoals goals) async {
    final database = await db;
    await database.update(
      'goals',
      goals.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ─── PROFILE ────────────────────────────────────────────────────────────────

  Future<void> saveProfile(UserProfile profile) async {
    final database = await db;
    // Primero borramos el perfil existente (solo debe haber uno)
    await database.delete('profile');
    // Insertamos el nuevo
    await database.insert('profile', profile.toMap());
  }

  Future<UserProfile> getProfile() async {
    final database = await db;
    final maps = await database.query('profile');
    if (maps.isEmpty) return const UserProfile();
    return UserProfile.fromMap(maps.first);
  }
}