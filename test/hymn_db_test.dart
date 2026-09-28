import 'package:flutter_test/flutter_test.dart';
import 'package:hymn_book/model/db_helper.dart';
import 'package:hymn_book/model/hymn.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite ffi for desktop/test runner
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Hymns Model Tests', () {
    test('Hymns toJson and fromJson work accurately', () {
      final hymn = Hymns(
        id: 1,
        title: "Praise, my soul",
        lyric: "Praise, my soul, the King of heaven",
        author: "Henry Francis Lyte",
        tune: "a0001.mid",
        favorite: 1,
        isCustom: 0,
        version: 2,
      );

      final jsonMap = hymn.toJson();
      expect(jsonMap['id'], 1);
      expect(jsonMap['title'], "Praise, my soul");
      expect(jsonMap['favorite'], 1);
      expect(jsonMap['version'], 2);

      final reconstructed = Hymns.fromJson(jsonMap);
      expect(reconstructed.id, 1);
      expect(reconstructed.title, "Praise, my soul");
      expect(reconstructed.isFav, isTrue);
      expect(reconstructed.isUserComposed, isFalse);
      expect(reconstructed.version, 2);
    });

    test('Hymns toMap and fromMap for SQLite work accurately', () {
      final hymn = Hymns(
        id: 10001,
        title: "My Custom Song",
        lyric: "Lord, I lift your name on high",
        author: "Church Choir",
        tune: "Antioch",
        favorite: 0,
        isCustom: 1,
        version: 1,
      );

      final dbMap = hymn.toMap();
      expect(dbMap['id'], 10001);
      expect(dbMap['is_favorite'], 0);
      expect(dbMap['is_custom'], 1);

      final fromDb = Hymns.fromMap(dbMap);
      expect(fromDb.id, 10001);
      expect(fromDb.title, "My Custom Song");
      expect(fromDb.isFav, isFalse);
      expect(fromDb.isUserComposed, isTrue);
    });

    test('Hymns copyWith produces accurate clones with updated fields', () {
      final original = Hymns(
        id: 5,
        title: "Original Title",
        lyric: "Original Lyrics",
        favorite: 0,
      );

      final updated = original.copyWith(
        title: "Updated Title",
        favorite: 1,
      );

      expect(updated.id, 5);
      expect(updated.title, "Updated Title");
      expect(updated.lyric, "Original Lyrics");
      expect(updated.favorite, 1);
      expect(updated.isFav, isTrue);
    });
  });

  group('DatabaseHelper Unified Storage Tests', () {
    late Database testDb;

    setUp(() async {
      // Use an in-memory SQLite database for clean, isolated tests
      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE ${DatabaseHelper.tableHymns} (
                ${DatabaseHelper.colId} INTEGER PRIMARY KEY,
                ${DatabaseHelper.colTitle} TEXT NOT NULL,
                ${DatabaseHelper.colAuthor} TEXT,
                ${DatabaseHelper.colLyrics} TEXT NOT NULL,
                ${DatabaseHelper.colTune} TEXT,
                ${DatabaseHelper.colIsFavorite} INTEGER DEFAULT 0,
                ${DatabaseHelper.colIsCustom} INTEGER DEFAULT 0,
                ${DatabaseHelper.colVersion} INTEGER DEFAULT 1,
                ${DatabaseHelper.colCreatedAt} INTEGER,
                ${DatabaseHelper.colUpdatedAt} INTEGER
              )
            ''');
          },
        ),
      );

      // Initialize DatabaseHelper singleton
      DatabaseHelper.internal();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Seed official hymns and query list', () async {
      // Insert initial sample hymns
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 1,
        DatabaseHelper.colTitle: "Praise, my soul, the King of heaven",
        DatabaseHelper.colAuthor: "H. F. Lyte",
        DatabaseHelper.colLyrics: "Praise, my soul, the King of heaven",
        DatabaseHelper.colTune: "a0001.mid",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 0,
        DatabaseHelper.colVersion: 1,
      });

      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 2,
        DatabaseHelper.colTitle: "A mighty fortress is our God",
        DatabaseHelper.colAuthor: "Martin Luther",
        DatabaseHelper.colLyrics: "A mighty fortress is our God, A bulwark never failing",
        DatabaseHelper.colTune: "a0002.mid",
        DatabaseHelper.colIsFavorite: 1,
        DatabaseHelper.colIsCustom: 0,
        DatabaseHelper.colVersion: 1,
      });

      final allHymns = await testDb.query(DatabaseHelper.tableHymns);
      expect(allHymns.length, 2);

      // Verify favorites query
      final favHymns = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colIsFavorite} = 1",
      );
      expect(favHymns.length, 1);
      expect(favHymns.first[DatabaseHelper.colId], 2);
    });

    test('Atomic favorite toggle on/off', () async {
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 10,
        DatabaseHelper.colTitle: "Day by day the manna fell",
        DatabaseHelper.colLyrics: "Day by day the manna fell",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 0,
        DatabaseHelper.colVersion: 1,
      });

      // Toggle favorite ON (0 -> 1)
      await testDb.update(
        DatabaseHelper.tableHymns,
        {DatabaseHelper.colIsFavorite: 1},
        where: "${DatabaseHelper.colId} = ?",
        whereArgs: [10],
      );

      var hymn = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = ?",
        whereArgs: [10],
      )).first;
      expect(hymn[DatabaseHelper.colIsFavorite], 1);

      // Toggle favorite OFF (1 -> 0)
      await testDb.update(
        DatabaseHelper.tableHymns,
        {DatabaseHelper.colIsFavorite: 0},
        where: "${DatabaseHelper.colId} = ?",
        whereArgs: [10],
      );

      hymn = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = ?",
        whereArgs: [10],
      )).first;
      expect(hymn[DatabaseHelper.colIsFavorite], 0);
    });

    test('User composed hymn CRUD lifecycle', () async {
      // 1. Create user composed hymn (ID >= 10001)
      const customId = 10001;
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: customId,
        DatabaseHelper.colTitle: "My Personal Testimony",
        DatabaseHelper.colAuthor: "John Doe",
        DatabaseHelper.colLyrics: "I once was lost, but now I'm found",
        DatabaseHelper.colTune: "Grace",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 1,
        DatabaseHelper.colVersion: 1,
      });

      // 2. Query custom songs
      var customSongs = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colIsCustom} = 1",
      );
      expect(customSongs.length, 1);
      expect(customSongs.first[DatabaseHelper.colTitle], "My Personal Testimony");

      // 3. Update custom song
      await testDb.update(
        DatabaseHelper.tableHymns,
        {
          DatabaseHelper.colTitle: "My Personal Testimony (Revised)",
          DatabaseHelper.colLyrics: "I once was lost, but now am found, was blind but now I see",
        },
        where: "${DatabaseHelper.colId} = ? AND ${DatabaseHelper.colIsCustom} = 1",
        whereArgs: [customId],
      );

      var updated = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = ?",
        whereArgs: [customId],
      )).first;
      expect(updated[DatabaseHelper.colTitle], "My Personal Testimony (Revised)");
      expect(updated[DatabaseHelper.colLyrics], contains("was blind but now I see"));

      // 4. Delete custom song
      final deletedCount = await testDb.delete(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = ? AND ${DatabaseHelper.colIsCustom} = 1",
        whereArgs: [customId],
      );
      expect(deletedCount, 1);

      customSongs = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colIsCustom} = 1",
      );
      expect(customSongs.isEmpty, isTrue);
    });

    test('Search hymns across title, author, and lyrics', () async {
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 1,
        DatabaseHelper.colTitle: "The God of Abraham praise",
        DatabaseHelper.colAuthor: "Thomas Olivers",
        DatabaseHelper.colLyrics: "Ancient of everlasting days",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 0,
      });

      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 10001,
        DatabaseHelper.colTitle: "Youth Praise Medley",
        DatabaseHelper.colAuthor: "Youth Fellowship",
        DatabaseHelper.colLyrics: "Great is thy faithfulness, morning by morning",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 1,
      });

      // Search by title keyword
      var results = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colTitle} LIKE ? OR ${DatabaseHelper.colLyrics} LIKE ?",
        whereArgs: ['%Abraham%', '%Abraham%'],
      );
      expect(results.length, 1);
      expect(results.first[DatabaseHelper.colId], 1);

      // Search by lyric keyword in custom song
      results = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colTitle} LIKE ? OR ${DatabaseHelper.colLyrics} LIKE ?",
        whereArgs: ['%faithfulness%', '%faithfulness%'],
      );
      expect(results.length, 1);
      expect(results.first[DatabaseHelper.colId], 10001);

      // Global search matching both official and custom songs with "Praise"
      results = await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colTitle} LIKE ? OR ${DatabaseHelper.colLyrics} LIKE ?",
        whereArgs: ['%Praise%', '%Praise%'],
      );
      expect(results.length, 2);
    });

    test('Remote sync upsert: updates lyrics and adds new hymns WITHOUT overwriting user favorites', () async {
      // User has hymn 1 marked as FAVORITE (is_favorite = 1)
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 1,
        DatabaseHelper.colTitle: "Praise, my soul, the King of heaven",
        DatabaseHelper.colAuthor: "Lyte",
        DatabaseHelper.colLyrics: "Old lyrics with a typo",
        DatabaseHelper.colIsFavorite: 1, // User favorited this!
        DatabaseHelper.colIsCustom: 0,
        DatabaseHelper.colVersion: 1,
      });

      // User also has their own custom composed song
      await testDb.insert(DatabaseHelper.tableHymns, {
        DatabaseHelper.colId: 10001,
        DatabaseHelper.colTitle: "My Song",
        DatabaseHelper.colLyrics: "Do not touch my song",
        DatabaseHelper.colIsFavorite: 0,
        DatabaseHelper.colIsCustom: 1,
        DatabaseHelper.colVersion: 1,
      });

      // Incoming remote sync payload:
      // 1. Correction to hymn 1 (version 2)
      // 2. Brand new official hymn 1201 (version 1)
      final incoming = [
        Hymns(
          id: 1,
          title: "Praise, my soul, the King of heaven",
          author: "Henry Francis Lyte",
          lyric: "Corrected lyrics with fixed stanza",
          version: 2,
        ),
        Hymns(
          id: 1201,
          title: "A Newly Added Supplementary Hymn",
          author: "Contemporary Writer",
          lyric: "Blessed assurance, Jesus is mine",
          version: 1,
        ),
      ];

      // Simulate remote sync logic
      await testDb.transaction((txn) async {
        for (var hymn in incoming) {
          if (hymn.isCustom == 1) continue;

          final existing = await txn.query(
            DatabaseHelper.tableHymns,
            columns: [DatabaseHelper.colId, DatabaseHelper.colIsFavorite, DatabaseHelper.colVersion],
            where: "${DatabaseHelper.colId} = ?",
            whereArgs: [hymn.id],
          );

          if (existing.isNotEmpty) {
            final localRow = existing.first;
            int localVersion = (localRow[DatabaseHelper.colVersion] as int?) ?? 1;
            if (hymn.version >= localVersion) {
              await txn.update(
                DatabaseHelper.tableHymns,
                {
                  DatabaseHelper.colTitle: hymn.title,
                  DatabaseHelper.colAuthor: hymn.author,
                  DatabaseHelper.colLyrics: hymn.lyric,
                  DatabaseHelper.colTune: hymn.tune,
                  DatabaseHelper.colVersion: hymn.version,
                  // NOTE: colIsFavorite is NOT updated!
                },
                where: "${DatabaseHelper.colId} = ?",
                whereArgs: [hymn.id],
              );
            }
          } else {
            await txn.insert(
              DatabaseHelper.tableHymns,
              {
                DatabaseHelper.colId: hymn.id,
                DatabaseHelper.colTitle: hymn.title,
                DatabaseHelper.colAuthor: hymn.author,
                DatabaseHelper.colLyrics: hymn.lyric,
                DatabaseHelper.colTune: hymn.tune,
                DatabaseHelper.colIsFavorite: 0,
                DatabaseHelper.colIsCustom: 0,
                DatabaseHelper.colVersion: hymn.version,
              },
            );
          }
        }
      });

      // Verify Hymn 1: Lyrics are updated, BUT is_favorite is STILL 1!
      final hymn1 = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = 1",
      )).first;
      expect(hymn1[DatabaseHelper.colLyrics], "Corrected lyrics with fixed stanza");
      expect(hymn1[DatabaseHelper.colIsFavorite], 1); // Favorite preserved!
      expect(hymn1[DatabaseHelper.colVersion], 2);

      // Verify Hymn 1201: Successfully added
      final hymn1201 = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = 1201",
      )).first;
      expect(hymn1201[DatabaseHelper.colTitle], "A Newly Added Supplementary Hymn");
      expect(hymn1201[DatabaseHelper.colIsFavorite], 0);

      // Verify User Custom Song: Completely untouched!
      final custom = (await testDb.query(
        DatabaseHelper.tableHymns,
        where: "${DatabaseHelper.colId} = 10001",
      )).first;
      expect(custom[DatabaseHelper.colTitle], "My Song");
    });
  });
}
