import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('client_radar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. LEADS TABLE
    await db.execute('''
      CREATE TABLE leads (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        source TEXT,
        source_type TEXT,
        url TEXT,
        date_found TEXT,
        published_date TEXT,
        language TEXT,
        country TEXT,
        service_type TEXT,
        client_temperature TEXT,
        score INTEGER,
        risk_score INTEGER,
        budget_detected TEXT,
        recommended_price TEXT,
        recommended_action TEXT,
        keywords_detected TEXT,
        score_reasons TEXT,
        questions_to_ask TEXT,
        reply_short TEXT,
        reply_professional TEXT,
        offer_page TEXT,
        proposal_path TEXT,
        status TEXT,
        notes TEXT,
        created_at TEXT,
        updated_at TEXT,
        replies TEXT
      )
    ''');

    // 2. USER ACTIONS QUEUE
    await db.execute('''
      CREATE TABLE user_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lead_id TEXT NOT NULL,
        action TEXT NOT NULL,
        value TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // 3. STATS CACHE TABLE
    await db.execute('''
      CREATE TABLE stats_cache (
        id INTEGER PRIMARY KEY,
        stats_json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // --- LEADS OPERATIONS ---
  Future<int> insertLead(Map<String, dynamic> lead) async {
    final db = await database;
    return await db.insert('leads', lead, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLead(String id, Map<String, dynamic> lead) async {
    final db = await database;
    return await db.update('leads', lead, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getLead(String id) async {
    final db = await database;
    final maps = await db.query('leads', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllLeads() async {
    final db = await database;
    return await db.query('leads', orderBy: 'score DESC');
  }

  Future<void> replaceAllLeads(List<Map<String, dynamic>> leads) async {
    final db = await database;
    final batch = db.batch();
    
    // We do not want to wipe out user notes of matching leads!
    // So we fetch existing lead notes and statuses first
    final existing = await getAllLeads();
    final Map<String, Map<String, dynamic>> existingMap = {
      for (var l in existing) l['id'] as String: l
    };

    batch.delete('leads');
    for (var lead in leads) {
      final id = lead['id'] as String;
      final mutableLead = Map<String, dynamic>.from(lead);
      
      // Preserve local updates if we already have the lead locally
      if (existingMap.containsKey(id)) {
        final old = existingMap[id]!;
        mutableLead['notes'] = old['notes'] ?? '';
        mutableLead['status'] = old['status'] ?? 'new';
        mutableLead['updated_at'] = old['updated_at'] ?? mutableLead['updated_at'];
      }
      batch.insert('leads', mutableLead);
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateLeadStatus(String id, String status) async {
    final db = await database;
    return await db.update(
      'leads',
      {
        'status': status,
        'updated_at': DateTime.now().toIsoformatString(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateLeadNotes(String id, String notes) async {
    final db = await database;
    return await db.update(
      'leads',
      {
        'notes': notes,
        'updated_at': DateTime.now().toIsoformatString(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- USER ACTIONS OPERATIONS ---
  Future<int> insertAction(String leadId, String action, String value) async {
    final db = await database;
    return await db.insert('user_actions', {
      'lead_id': leadId,
      'action': action,
      'value': value,
      'timestamp': DateTime.now().toIsoformatString(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final db = await database;
    return await db.query('user_actions', orderBy: 'id ASC');
  }

  Future<int> deleteActions(List<int> ids) async {
    final db = await database;
    if (ids.isEmpty) return 0;
    final idList = ids.join(',');
    return await db.delete('user_actions', where: 'id IN ($idList)');
  }

  Future<int> clearActions() async {
    final db = await database;
    return await db.delete('user_actions');
  }

  // --- STATS OPERATIONS ---
  Future<void> cacheStats(String statsJson) async {
    final db = await database;
    await db.insert('stats_cache', {
      'id': 1,
      'stats_json': statsJson,
      'updated_at': DateTime.now().toIsoformatString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getCachedStats() async {
    final db = await database;
    final results = await db.query('stats_cache', where: 'id = 1');
    if (results.isNotEmpty) {
      return results.first['stats_json'] as String;
    }
    return null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('leads');
    await db.delete('user_actions');
    await db.delete('stats_cache');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

extension on DateTime {
  String toIsoformatString() => toIso8601String();
}
