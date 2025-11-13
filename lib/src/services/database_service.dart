import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bible_models.dart';

class DatabaseService {
  static const String _databaseName = 'bible.db';
  static const int _databaseVersion = 2;

  static const String booksTable = 'books';
  static const String chaptersTable = 'chapters';
  static const String versesTable = 'verses';

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $versesTable');
    await db.execute('DROP TABLE IF EXISTS $chaptersTable');
    await db.execute('DROP TABLE IF EXISTS $booksTable');
    await _onCreate(db, newVersion);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $booksTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        shortName TEXT NOT NULL,
        bookNumber INTEGER NOT NULL,
        bookType INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $chaptersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT NOT NULL,
        number INTEGER NOT NULL,
        FOREIGN KEY (bookId) REFERENCES $booksTable (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $versesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapterId INTEGER NOT NULL,
        number INTEGER NOT NULL,
        text TEXT NOT NULL,
        notes TEXT,
        cross_references TEXT,
        FOREIGN KEY (chapterId) REFERENCES $chaptersTable (id)
      )
    ''');
  }

  Future<void> insertBible(String translationId, List<BibleBook> books) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      for (final book in books) {
        await txn.insert(booksTable, {
          'id': '${translationId}_${book.id}',
          'name': book.name,
          'shortName': book.shortName,
          'bookNumber': book.bookNumber,
          'bookType': book.bookType.index,
        });

        for (final chapter in book.chapters) {
          final chapterId = await txn.insert(chaptersTable, {
            'bookId': '${translationId}_${book.id}',
            'number': chapter.number,
          });

          for (final verse in chapter.verses) {
            await txn.insert(versesTable, {
              'chapterId': chapterId,
              'number': verse.number,
              'text': verse.text,
              'notes': verse.notes?.join(';'),
              'cross_references': verse.references?.join(';'),
            });
          }
        }
      }
    });
  }

  Future<List<BibleBook>> getBible(String translationId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> bookMaps = await db.query(
      booksTable,
      where: 'id LIKE ?',
      whereArgs: ['${translationId}_%'],
    );

    if (bookMaps.isEmpty) {
      return [];
    }

    final List<BibleBook> books = [];
    for (final bookMap in bookMaps) {
      final bookId = bookMap['id'] as String;
      final List<Map<String, dynamic>> chapterMaps = await db.query(
        chaptersTable,
        where: 'bookId = ?',
        whereArgs: [bookId],
      );

      final List<BibleChapter> chapters = [];
      for (final chapterMap in chapterMaps) {
        final chapterId = chapterMap['id'] as int;
        final List<Map<String, dynamic>> verseMaps = await db.query(
          versesTable,
          where: 'chapterId = ?',
          whereArgs: [chapterId],
        );

        final verses = verseMaps.map((verseMap) {
          final notes = (verseMap['notes'] as String?)?.split(';');
          final references = (verseMap['cross_references'] as String?)?.split(';');
          return BibleVerse(
            number: verseMap['number'] as int,
            text: verseMap['text'] as String,
            notes: notes,
            references: references,
          );
        }).toList();

        chapters.add(BibleChapter(
          number: chapterMap['number'] as int,
          verses: verses,
        ));
      }

      books.add(BibleBook(
        id: (bookMap['id'] as String).split('_').last,
        name: bookMap['name'] as String,
        shortName: bookMap['shortName'] as String,
        bookNumber: bookMap['bookNumber'] as int,
        bookType: BibleBookType.values[bookMap['bookType'] as int],
        chapters: chapters,
      ));
    }

    return books;
  }

  Future<bool> isBibleCached(String translationId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> bookMaps = await db.query(
      booksTable,
      where: 'id LIKE ?',
      whereArgs: ['${translationId}_%'],
      limit: 1,
    );
    return bookMaps.isNotEmpty;
  }

  Future<void> deleteBible(String translationId) async {
    final db = await instance.database;
    await db.delete(
      booksTable,
      where: 'id LIKE ?',
      whereArgs: ['${translationId}_%'],
    );
  }

  Future<void> deleteAllBibles() async {
    final db = await instance.database;
    await db.delete(booksTable);
    await db.delete(chaptersTable);
    await db.delete(versesTable);
  }
}
