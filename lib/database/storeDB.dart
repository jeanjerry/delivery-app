import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // 取得資料庫路徑
    String path = join(await getDatabasesPath(), 'consumer_database.db');
    // 開啟資料庫
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 建立 stores 表格
        await db.execute('''
          CREATE TABLE IF NOT EXISTS stores (
            id INTEGER PRIMARY KEY,
            storeName TEXT,
            storeAddress TEXT,
            storePhone TEXT,
            storeWallet TEXT,
            currentID TEXT,
            storeTag TEXT,
            latitudeAndLongitude TEXT,
            menuLink TEXT,
            storeEmail TEXT,
            contract TEXT
          )
        ''');
        // 建立Order_content表格
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Order_contents (
            orderID TEXT,
            num TEXT,
            contract TEXT,
            id TEXT,
            storeName TEXT,
            fee TEXT
          )
        ''');
      },
    );
  }

  // 在 stores 表格中插入資料
  Future<void> dbInsertStore(Map<String, dynamic> store) async {
    final db = await database;
    await db.insert('stores', store);
  }

  // 在 Order_content 表格中插入資料
  Future<void> dbInsertOrder_content(Map<String, dynamic> Order_content) async {
    final db = await database;
    await db.insert('Order_contents', Order_content);
  }

  // 從 stores 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetStores() async {
    final db = await database;
    return await db.query('stores');
  }

  // 從 Order_content 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetOrder_content() async {
    final db = await database;
    return await db.query('Order_contents');
  }

  // 在 stores 表格中重置資料
  Future<void> dbResetStores() async {
    final db = await database;
    await db.delete('stores');
  }

  // 在 Order_content 表格中重置資料
  Future<void> dbResetOrder_content() async {
    final db = await database;
    await db.delete('Order_contents');
  }

}