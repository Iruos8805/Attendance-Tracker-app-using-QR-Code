import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  static Database? _database;
  static const String tableName = 'AuthToken';
  static const String columnKey = 'id';
  static const String columnValue = 'token';

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    print(path);
    return openDatabase(
      join(path, 'authTokens.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE $tableName($columnKey INTEGER PRIMARY KEY, $columnValue TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initializeDB();
    return _database!;
  }

  Future<void> insertOrUpdateRecord(int id, String token) async {
    final Database db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT OR REPLACE INTO $tableName($columnKey, $columnValue) VALUES(?, ?)',
        [id, token],
      );
    });
  }

  Future<String?> getTokenForId(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [columnValue],
      where: '$columnKey = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first[columnValue] : null;
  }
}
