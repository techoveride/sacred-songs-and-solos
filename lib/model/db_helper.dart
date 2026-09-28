import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hymn_book/model/globals.dart' as globals;
import 'package:hymn_book/model/hymn.dart';
import 'package:hymn_book/model/hymn_composer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String dbName = "Hymn_Lyrics.db";
  static const int dbVersion = 2;

  // Unified table name
  static const String tableHymns = "Hymns";

  // Column definitions
  static const String colId = "id";
  static const String colTitle = "title";
  static const String colAuthor = "author";
  static const String colLyrics = "lyric";
  static const String colTune = "tune";
  static const String colIsFavorite = "is_favorite";
  static const String colIsCustom = "is_custom";
  static const String colVersion = "version";
  static const String colCreatedAt = "created_at";
  static const String colUpdatedAt = "updated_at";

  // Legacy table for migration
  static const String legacyTable = "HymnLyrics";

  static final DatabaseHelper _databaseHelper = DatabaseHelper.internal();
  factory DatabaseHelper() => _databaseHelper;
  DatabaseHelper.internal();

  static Database? _db;

  Future<Database> get getDB async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHymns (
        $colId INTEGER PRIMARY KEY,
        $colTitle TEXT NOT NULL,
        $colAuthor TEXT,
        $colLyrics TEXT NOT NULL,
        $colTune TEXT,
        $colIsFavorite INTEGER DEFAULT 0,
        $colIsCustom INTEGER DEFAULT 0,
        $colVersion INTEGER DEFAULT 1,
        $colCreatedAt INTEGER,
        $colUpdatedAt INTEGER
      )
    ''');

    await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_fav ON $tableHymns($colIsFavorite)");
    await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_custom ON $tableHymns($colIsCustom)");
    await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_title ON $tableHymns($colTitle)");

    // Seed official hymns
    await _seedOfficialHymns(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create new unified table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableHymns (
          $colId INTEGER PRIMARY KEY,
          $colTitle TEXT NOT NULL,
          $colAuthor TEXT,
          $colLyrics TEXT NOT NULL,
          $colTune TEXT,
          $colIsFavorite INTEGER DEFAULT 0,
          $colIsCustom INTEGER DEFAULT 0,
          $colVersion INTEGER DEFAULT 1,
          $colCreatedAt INTEGER,
          $colUpdatedAt INTEGER
        )
      ''');

      await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_fav ON $tableHymns($colIsFavorite)");
      await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_custom ON $tableHymns($colIsCustom)");
      await db.execute("CREATE INDEX IF NOT EXISTS idx_hymns_title ON $tableHymns($colTitle)");

      // Check if official hymns are seeded
      final countResult = await db.rawQuery("SELECT COUNT(*) as count FROM $tableHymns WHERE $colIsCustom = 0");
      int count = Sqflite.firstIntValue(countResult) ?? 0;
      if (count == 0) {
        await _seedOfficialHymns(db);
      }

      // Migrate existing composed hymns from legacy table
      try {
        final legacySongs = await db.rawQuery("SELECT * FROM $legacyTable");
        for (var row in legacySongs) {
          int legacyId = (row['id'] as int?) ?? 10001;
          if (legacyId < 10000) legacyId += 10000;
          await db.insert(
            tableHymns,
            {
              colId: legacyId,
              colTitle: row['title'] ?? 'Untitled',
              colAuthor: row['author'] ?? '',
              colLyrics: row['lyric'] ?? '',
              colTune: row['tune'] ?? '',
              colIsFavorite: 0,
              colIsCustom: 1,
              colVersion: 1,
              colCreatedAt: DateTime.now().millisecondsSinceEpoch,
              colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      } catch (e) {
        debugPrint("Note: Legacy table migration skipped or finished: $e");
      }
    }
  }

  /// Seeds official hymns into the database using a high-performance batch insert
  Future<void> _seedOfficialHymns(Database db) async {
    // Check if user already had favorites stored in the legacy JSON file
    Set<int> favoriteHymnIds = {};
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final legacyFile = File(join(docDir.path, globals.fileName));
      if (legacyFile.existsSync()) {
        final decoded = json.decode(legacyFile.readAsStringSync());
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map && (item['favorite'] == 1 || item['favorite'] == true)) {
              int? id = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString());
              if (id != null) favoriteHymnIds.add(id);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Legacy JSON favorite migration check skipped: $e");
    }

    final batch = db.batch();
    for (var hymn in listHymns) {
      int isFav = favoriteHymnIds.contains(hymn.id) || hymn.favorite == 1 ? 1 : 0;
      batch.insert(
        tableHymns,
        {
          colId: hymn.id,
          colTitle: hymn.title,
          colAuthor: hymn.author,
          colLyrics: hymn.lyric,
          colTune: hymn.tune,
          colIsFavorite: isFav,
          colIsCustom: 0,
          colVersion: 1,
          colCreatedAt: DateTime.now().millisecondsSinceEpoch,
          colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    debugPrint("Seeded ${listHymns.length} official hymns into SQLite.");
  }

  // -------------------------------------------------------------
  // QUERY METHODS
  // -------------------------------------------------------------

  /// Retrieves hymns with optional filters and sorting
  Future<List<Hymns>> getHymnsList({
    bool? favoritesOnly,
    bool? customOnly,
    String? sortBy, // 'number', 'title'
  }) async {
    final db = await getDB;
    String whereClause = "";
    List<dynamic> whereArgs = [];

    if (favoritesOnly == true) {
      whereClause = "$colIsFavorite = 1";
    }

    if (customOnly == true) {
      if (whereClause.isNotEmpty) whereClause += " AND ";
      whereClause += "$colIsCustom = 1";
    }

    String orderBy = "$colId ASC";
    if (sortBy == 'title') {
      orderBy = "$colTitle COLLATE NOCASE ASC";
    } else if (sortBy == 'number') {
      orderBy = "$colId ASC";
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableHymns,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) => Hymns.fromMap(maps[i]));
  }

  /// Searches hymns across title, author, and lyrics
  Future<List<Hymns>> searchHymns(
    String query, {
    bool favoritesOnly = false,
    bool customOnly = false,
  }) async {
    final db = await getDB;
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return getHymnsList(favoritesOnly: favoritesOnly, customOnly: customOnly);
    }

    String whereSql = "($colTitle LIKE ? OR $colLyrics LIKE ? OR $colAuthor LIKE ? OR CAST($colId AS TEXT) LIKE ?)";
    List<dynamic> args = ['%$cleanQuery%', '%$cleanQuery%', '%$cleanQuery%', '%$cleanQuery%'];

    if (favoritesOnly) {
      whereSql += " AND $colIsFavorite = 1";
    }
    if (customOnly) {
      whereSql += " AND $colIsCustom = 1";
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableHymns,
      where: whereSql,
      whereArgs: args,
      orderBy: "$colId ASC",
    );

    return List.generate(maps.length, (i) => Hymns.fromMap(maps[i]));
  }

  /// Get a single hymn by ID
  Future<Hymns?> getHymnById(int id) async {
    final db = await getDB;
    final List<Map<String, dynamic>> maps = await db.query(
      tableHymns,
      where: "$colId = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Hymns.fromMap(maps.first);
  }

  /// Toggles favorite status atomically
  Future<int> toggleFavorite(int id) async {
    final db = await getDB;
    final current = await getHymnById(id);
    if (current == null) return -1;
    final newFav = current.favorite == 1 ? 0 : 1;
    await db.update(
      tableHymns,
      {
        colIsFavorite: newFav,
        colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: "$colId = ?",
      whereArgs: [id],
    );
    return newFav;
  }

  /// Sets favorite explicitly
  Future<void> setFavorite(int id, bool isFav) async {
    final db = await getDB;
    await db.update(
      tableHymns,
      {
        colIsFavorite: isFav ? 1 : 0,
        colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: "$colId = ?",
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------
  // USER COMPOSED HYMNS
  // -------------------------------------------------------------

  /// Calculates the next available ID for user composed hymns (starting at 10001)
  Future<int> getNextCustomHymnId() async {
    final db = await getDB;
    final res = await db.rawQuery("SELECT MAX($colId) as max_id FROM $tableHymns WHERE $colIsCustom = 1");
    int? maxId = Sqflite.firstIntValue(res);
    if (maxId == null || maxId < 10000) {
      return 10001;
    }
    return maxId + 1;
  }

  /// Saves a user-composed hymn
  Future<int> saveCustomHymn(Hymns hymn) async {
    final db = await getDB;
    int hymnId = hymn.id;
    if (hymnId <= 0 || hymnId < 10000) {
      hymnId = await getNextCustomHymnId();
    }

    final data = hymn.toMap();
    data[colId] = hymnId;
    data[colIsCustom] = 1;
    data[colCreatedAt] = hymn.createdAt ?? DateTime.now().millisecondsSinceEpoch;
    data[colUpdatedAt] = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      tableHymns,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return hymnId;
  }

  /// Updates an existing user-composed hymn
  Future<int> updateCustomHymn(Hymns hymn) async {
    final db = await getDB;
    final data = hymn.toMap();
    data[colUpdatedAt] = DateTime.now().millisecondsSinceEpoch;

    return await db.update(
      tableHymns,
      data,
      where: "$colId = ? AND $colIsCustom = 1",
      whereArgs: [hymn.id],
    );
  }

  /// Deletes a user-composed hymn (official hymns cannot be deleted)
  Future<int> deleteCustomHymn(int id) async {
    final db = await getDB;
    return await db.delete(
      tableHymns,
      where: "$colId = ? AND $colIsCustom = 1",
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------------
  // REMOTE SYNC / ONLINE PUSH
  // -------------------------------------------------------------

  /// Safely upserts official hymns received from online push / remote sync.
  /// Crucially: This DOES NOT overwrite local `is_favorite` state or any custom hymns!
  Future<int> batchUpsertOfficialHymns(List<Hymns> incomingHymns) async {
    final db = await getDB;
    int updatedCount = 0;

    await db.transaction((txn) async {
      for (var hymn in incomingHymns) {
        if (hymn.isCustom == 1) continue; // Remote updates do not touch custom hymns

        // Check if hymn exists locally
        final existing = await txn.query(
          tableHymns,
          columns: [colId, colIsFavorite, colVersion],
          where: "$colId = ?",
          whereArgs: [hymn.id],
        );

        if (existing.isNotEmpty) {
          final localRow = existing.first;
          int localVersion = (localRow[colVersion] as int?) ?? 1;

          // Only update if incoming version is newer
          if (hymn.version >= localVersion) {
            await txn.update(
              tableHymns,
              {
                colTitle: hymn.title,
                colAuthor: hymn.author,
                colLyrics: hymn.lyric,
                colTune: hymn.tune,
                colVersion: hymn.version,
                colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
                // Notice: colIsFavorite is intentionally NOT modified!
              },
              where: "$colId = ?",
              whereArgs: [hymn.id],
            );
            updatedCount++;
          }
        } else {
          // Brand new official hymn pushed online
          await txn.insert(
            tableHymns,
            {
              colId: hymn.id,
              colTitle: hymn.title,
              colAuthor: hymn.author,
              colLyrics: hymn.lyric,
              colTune: hymn.tune,
              colIsFavorite: 0,
              colIsCustom: 0,
              colVersion: hymn.version,
              colCreatedAt: DateTime.now().millisecondsSinceEpoch,
              colUpdatedAt: DateTime.now().millisecondsSinceEpoch,
            },
          );
          updatedCount++;
        }
      }
    });

    debugPrint("Remote sync batch applied: $updatedCount hymns added/updated.");
    return updatedCount;
  }

  // -------------------------------------------------------------
  // BACKWARD COMPATIBILITY ADAPTERS
  // -------------------------------------------------------------

  Future<int> saveHymns(ComposeHymns hymn) async {
    return await saveCustomHymn(
      Hymns(
        id: hymn.id ?? 0,
        title: hymn.title ?? 'Untitled',
        author: hymn.author,
        lyric: hymn.lyric ?? '',
        tune: hymn.tune,
        isCustom: 1,
      ),
    );
  }

  Future<List> getAllHymns() async {
    final list = await getHymnsList(customOnly: true);
    return list.map((h) => h.toJson()).toList();
  }

  Future<ComposeHymns?> getHymns(int id) async {
    final hymn = await getHymnById(id);
    if (hymn == null) return null;
    return ComposeHymns(
      id: hymn.id,
      title: hymn.title,
      author: hymn.author,
      lyric: hymn.lyric,
      tune: hymn.tune,
    );
  }

  Future<int> deleteHymns(int id) async {
    return await deleteCustomHymn(id);
  }

  Future closeDb() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
    }
  }
}
