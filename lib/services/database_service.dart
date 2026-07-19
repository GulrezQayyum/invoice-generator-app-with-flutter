import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/invoice_model.dart';
import '../models/settings_model.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'invoice_generator.db';
  static const String invoicesTable = 'invoices';
  static const String settingsTable = 'settings';

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $invoicesTable (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT UNIQUE,
        invoiceDate TEXT,
        dueDate TEXT,
        businessInfo TEXT,
        customerInfo TEXT,
        items TEXT,
        taxPercentage REAL,
        notes TEXT,
        status TEXT,
        currency TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $settingsTable (
        id TEXT PRIMARY KEY,
        currency TEXT,
        defaultTaxPercentage REAL,
        invoicePrefix TEXT,
        nextInvoiceNumber INTEGER,
        companyLogoPath TEXT
      )
    ''');
  }

  // Invoice Operations
  Future<void> createInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      invoicesTable,
      {
        'id': invoice.id,
        'invoiceNumber': invoice.invoiceNumber,
        'invoiceDate': invoice.invoiceDate.toIso8601String(),
        'dueDate': invoice.dueDate.toIso8601String(),
        'businessInfo': jsonEncode(invoice.businessInfo.toJson()),
        'customerInfo': jsonEncode(invoice.customerInfo.toJson()),
        'items': jsonEncode(invoice.items.map((i) => i.toJson()).toList()),
        'taxPercentage': invoice.taxPercentage,
        'notes': invoice.notes,
        'status': invoice.status.toString().split('.').last,
        'currency': invoice.currency,
        'createdAt': invoice.createdAt.toIso8601String(),
        'updatedAt': invoice.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Invoice?> getInvoice(String id) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return _parseInvoice(result.first);
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      orderBy: 'createdAt DESC',
    );

    return result.map((row) => _parseInvoice(row)).toList();
  }

  Future<List<Invoice>> searchInvoices(String query) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      where: 'invoiceNumber LIKE ? OR customerInfo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return result.map((row) => _parseInvoice(row)).toList();
  }

  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );

    return result.map((row) => _parseInvoice(row)).toList();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final db = await database;
    await db.update(
      invoicesTable,
      {
        'invoiceNumber': invoice.invoiceNumber,
        'invoiceDate': invoice.invoiceDate.toIso8601String(),
        'dueDate': invoice.dueDate.toIso8601String(),
        'businessInfo': jsonEncode(invoice.businessInfo.toJson()),
        'customerInfo': jsonEncode(invoice.customerInfo.toJson()),
        'items': jsonEncode(invoice.items.map((i) => i.toJson()).toList()),
        'taxPercentage': invoice.taxPercentage,
        'notes': invoice.notes,
        'status': invoice.status.toString().split('.').last,
        'currency': invoice.currency,
        'updatedAt': invoice.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<void> deleteInvoice(String id) async {
    final db = await database;
    await db.delete(
      invoicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings Operations
  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.insert(
      settingsTable,
      {
        'id': 'app_settings',
        'currency': settings.currency,
        'defaultTaxPercentage': settings.defaultTaxPercentage,
        'invoicePrefix': settings.invoicePrefix,
        'nextInvoiceNumber': settings.nextInvoiceNumber,
        'companyLogoPath': settings.companyLogoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppSettings?> getSettings() async {
    final db = await database;
    final result = await db.query(
      settingsTable,
      where: 'id = ?',
      whereArgs: ['app_settings'],
    );

    if (result.isEmpty) return null;
    return AppSettings.fromJson(result.first);
  }

  // Dashboard Statistics
  Future<int> getTotalInvoices() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $invoicesTable');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getPaidInvoices() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $invoicesTable WHERE status = ?',
      ['paid'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getUnpaidInvoices() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $invoicesTable WHERE status = ?',
      ['unpaid'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<double> getTotalRevenue() async {
    final invoices = await getAllInvoices();
    return invoices.fold<double>(0.0, (double sum, Invoice invoice) => sum + invoice.total);
  }

  Future<List<Invoice>> getRecentInvoices({int limit = 5}) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return result.map((row) => _parseInvoice(row)).toList();
  }

  Invoice _parseInvoice(Map<String, dynamic> row) {
    return Invoice(
      id: row['id'] as String,
      invoiceNumber: row['invoiceNumber'] as String,
      invoiceDate: DateTime.parse(row['invoiceDate'] as String),
      dueDate: DateTime.parse(row['dueDate'] as String),
      businessInfo: BusinessInfo.fromJson(jsonDecode(row['businessInfo'] as String) as Map<String, dynamic>),
      customerInfo: CustomerInfo.fromJson(jsonDecode(row['customerInfo'] as String) as Map<String, dynamic>),
      items: (jsonDecode(row['items'] as String) as List)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      taxPercentage: (row['taxPercentage'] as num).toDouble(),
      notes: row['notes'] as String?,
      status: InvoiceStatus.values
          .firstWhere((e) => e.toString().split('.').last == row['status']),
      currency: row['currency'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(invoicesTable);
    await db.delete(settingsTable);
  }
}
