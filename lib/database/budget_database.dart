import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';

class BudgetDatabase {
  /// create a private constructor for Budget Database class
  BudgetDatabase._instance();

  /// Save the instance in a variable for later uses
  static final BudgetDatabase instance = BudgetDatabase._instance();

  /// create a SQFlite object
  static Database? _db;

  // create table name and column names
  static const String expenseTable = 'budget_table';
  static const String colId = 'id';
  static const String colTitle = 'title';
  static const String colDescription = 'description';
  static const String colPrice = 'price';
  static const String colIsIncome = 'isIncome';
  static const String colDate = 'date';
  static const String colImageUrl = 'imageUrl';

  /// create a getter for database object
  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  /// initialize the database
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final path = dir.path + '/budget_manager.db';
    final expenseTrackerDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return expenseTrackerDb;
  }

  /// Create a database for us when you open it.
  void _createDb(Database db, int version) async {
    await db.execute('''CREATE TABLE $expenseTable(
      $colId INTEGER PRIMARY KEY AUTOINCREMENT, 
      $colTitle TEXT, 
      $colDescription TEXT, 
      $colPrice INTEGER, 
      $colIsIncome INTEGER, 
      $colDate TEXT, 
      $colImageUrl TEXT
)''');
  }

  Future<List<Map<String, dynamic>>> getExpenseMapList() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(expenseTable);
    return result;
  }

  // R in CRUD
  Future<List<List<Expense>>> getExpenseList() async {
    final List<Map<String, dynamic>> expenseMapList = await getExpenseMapList();
    final List<Expense> expenseList = [];
    for (var expenseMap in expenseMapList) {
      expenseList.add(Expense.fromMap(expenseMap));
    }
    final groupedList = groupBy(expenseList,
        (Expense expense) => expense.date.toIso8601String().substring(0, 10));
    final result = groupedList.values.toList();
    result.sort((expenseA, expenseB) => expenseB[0]
        .date
        .toString()
        .substring(0, 10)
        .compareTo(expenseA[0].date.toString().substring(0, 10)));
    return result;
  }

  // C in CRUD
  Future<int> insertExpense(Expense expense) async {
    final db = await this.db;
    final int result = await db.insert(expenseTable, expense.toMap());
    return result;
  }

  // U in CRUD
  Future<int> updateExpense(Expense expense) async {
    final db = await this.db;
    final int result = await db.update(
      expenseTable,
      expense.toMap(),
      where: '$colId = ?',
      whereArgs: [expense.id],
    );
    return result;
  }

  // D in CRUD
  Future<int> deleteExpense(int id) async {
    final db = await this.db;
    final int deleteCount = await db.delete(
      expenseTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return deleteCount;
  }
}
