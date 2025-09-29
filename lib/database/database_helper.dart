import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'safeher.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users_table (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        profile_photo_path TEXT,
        emergency_pin TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Emergency contacts table
    await db.execute('''
      CREATE TABLE emergency_contacts_table (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT NOT NULL,
        priority_level INTEGER DEFAULT 1,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users_table (id) ON DELETE CASCADE
      )
    ''');

    // Journey history table
    await db.execute('''
      CREATE TABLE journey_history_table (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT,
        start_latitude REAL NOT NULL,
        start_longitude REAL NOT NULL,
        start_address TEXT,
        end_latitude REAL,
        end_longitude REAL,
        end_address TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        estimated_arrival TEXT,
        status TEXT NOT NULL,
        route_coordinates TEXT,
        shared_with TEXT,
        is_public INTEGER DEFAULT 0,
        notes TEXT,
        settings TEXT,
        FOREIGN KEY (user_id) REFERENCES users_table (id) ON DELETE CASCADE
      )
    ''');

    // Emergency alerts table
    await db.execute('''
      CREATE TABLE emergency_alerts_table (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        alert_type TEXT NOT NULL,
        status TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        message TEXT,
        contacts_notified TEXT,
        timestamp TEXT NOT NULL,
        resolved_at TEXT,
        additional_data TEXT,
        FOREIGN KEY (user_id) REFERENCES users_table (id) ON DELETE CASCADE
      )
    ''');

    // Safe places table
    await db.execute('''
      CREATE TABLE safe_places_table (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        place_name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        place_type TEXT NOT NULL,
        phone_number TEXT,
        website TEXT,
        opening_hours TEXT,
        rating REAL,
        review_count INTEGER DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        is_public INTEGER DEFAULT 0,
        saved_at TEXT NOT NULL,
        updated_at TEXT,
        notes TEXT,
        additional_info TEXT,
        FOREIGN KEY (user_id) REFERENCES users_table (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings_table (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users_table (id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      )
    ''');

    // Offline sync queue table
    await db.execute('''
      CREATE TABLE sync_queue_table (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts_table(user_id)');
    await db.execute(
        'CREATE INDEX idx_journey_history_user_id ON journey_history_table(user_id)');
    await db.execute(
        'CREATE INDEX idx_emergency_alerts_user_id ON emergency_alerts_table(user_id)');
    await db.execute(
        'CREATE INDEX idx_emergency_alerts_timestamp ON emergency_alerts_table(timestamp)');
    await db.execute(
        'CREATE INDEX idx_safe_places_location ON safe_places_table(latitude, longitude)');
    await db.execute(
        'CREATE INDEX idx_safe_places_type ON safe_places_table(place_type)');
    await db.execute(
        'CREATE INDEX idx_settings_user_key ON settings_table(user_id, setting_key)');
    await db.execute(
        'CREATE INDEX idx_sync_queue_synced ON sync_queue_table(synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Generic CRUD operations
  Future<String> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    return data['id'] ?? '';
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> queryFirst(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final results =
        await query(table, where: where, whereArgs: whereArgs, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Raw query support
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Batch operations
  Future<void> batch(List<String> queries,
      [List<List<dynamic>>? arguments]) async {
    final db = await database;
    final batch = db.batch();

    for (int i = 0; i < queries.length; i++) {
      if (arguments != null && i < arguments.length) {
        batch.rawQuery(queries[i], arguments[i]);
      } else {
        batch.rawQuery(queries[i]);
      }
    }

    await batch.commit();
  }

  // Database maintenance
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Get database size
  Future<int> getDatabaseSize() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'safeher.db');
    final File file = File(path);

    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('settings_table');
      await txn.delete('sync_queue_table');
      await txn.delete('safe_places_table');
      await txn.delete('emergency_alerts_table');
      await txn.delete('journey_history_table');
      await txn.delete('emergency_contacts_table');
      await txn.delete('users_table');
    });
  }

  // Export database (for backup)
  Future<String> exportDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String sourcePath = join(documentsDirectory.path, 'safeher.db');
    final String backupPath = join(documentsDirectory.path,
        'safeher_backup_${DateTime.now().millisecondsSinceEpoch}.db');

    final File sourceFile = File(sourcePath);
    final File backupFile = File(backupPath);

    if (await sourceFile.exists()) {
      await sourceFile.copy(backupPath);
      return backupPath;
    }

    throw Exception('Database file not found');
  }

  // Check database integrity
  Future<bool> checkIntegrity() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first.values.first == 'ok';
    } catch (e) {
      return false;
    }
  }
}
