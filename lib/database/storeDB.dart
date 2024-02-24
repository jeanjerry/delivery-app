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
            id TEXT,
            consumer TEXT,
            fee TEXT,
            note TEXT,
            delivery TEXT,
            orderStatus TEXT,
            contract TEXT,
            storeAddress TEXT,
            time TEXT
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
            fee TEXT,
            storeAddress TEXT
          )
        ''');
        // 建立Orders表格
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Orders (
            id TEXT,
            storeName TEXT,
            fee TEXT,
            contract TEXT,
            foodCost TEXT,
            note TEXT,
            time TEXT
          )
        ''');
        // 建立checkorders表格
        await db.execute('''
          CREATE TABLE IF NOT EXISTS checkorders (
            id TEXT,
            contract TEXT,
            storeName TEXT,
            fee TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS wallets (
            orderStatus TEXT,
            storeName TEXT,
            fee TEXT,
            id TEXT
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

  // 在 wallets 表格中插入資料
  Future<void> dbInsertwallet(Map<String, dynamic> wallet) async {
    final db = await database;
    await db.insert('wallets', wallet);
  }

  // 在 Order_content 表格中插入資料
  Future<void> dbInsertOrder_content(Map<String, dynamic> Order_content) async {
    final db = await database;
    await db.insert('Order_contents', Order_content);
  }

  // 在Order_numbers 表格中插入資料
  Future<void> dbInsertOrder(Map<String, dynamic> Order) async {
    final db = await database;
    await db.insert('Orders', Order);
  }

  // checkorders 表格中插入資料
  Future<void> dbInsertcheckorder(Map<String, dynamic> checkorder) async {
    final db = await database;
    await db.insert('checkorders', checkorder);
  }

  // 從 stores 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetStores() async {
    final db = await database;
    return await db.query('stores');
  }

  // 從 wallet 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetwallet() async {
    final db = await database;
    return await db.query('wallets');
  }

  // 從 Order_contents 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetOrder_content() async {
    final db = await database;
    return await db.query('Order_contents');
  }

  // 從 checkorders 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetcheckorder() async {
    final db = await database;
    return await db.query('checkorders');
  }

  // 從 Order_numbers 表格中獲得資料
  Future<List<Map<String, dynamic>>> dbGetOrder() async {
    final db = await database;
    return await db.query('Orders');
  }

  // 在 stores 表格中重置資料
  Future<void> dbResetStores() async {
    final db = await database;
    await db.delete('stores');
  }

  // 在 Order_contents 表格中重置資料
  Future<void> dbResetOrder_content() async {
    final db = await database;
    await db.delete('Order_contents');
  }

  // 在 Order 表格中重置資料
  Future<void> dbResetOrder() async {
    final db = await database;
    await db.delete('Orders');
  }

  // 在 checkorders 表格中重置資料
  Future<void> dbResetcheckorder() async {
    final db = await database;
    await db.delete('checkorders');
  }

  // 在 wallet 表格中重置資料
  Future<void> dbResetwallet() async {
    final db = await database;
    await db.delete('wallets');
  }

}