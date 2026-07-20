import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/invoice_model.dart';
import '../models/settings_model.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'invoice_generator.db';
  static const String invoicesTable = 'invoices';
  static const String settingsTable = 'settings';

  // Synchronization lock for initialization
  static final _initLock = Object();
  static Completer<Database>? _initCompleter;

  // Private constructor for singleton
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    return await initializeDatabase();
  }

  Future<Database> initializeDatabase() async {
    // 1. Return already initialized database
    if (_database != null) return _database!;

    // 2. If initialization is already in progress, wait for it
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<Database>();

    try {
      String dbPath;
      if (kIsWeb) {
        dbPath = dbName;
      } else {
        // Use path_provider for more reliable paths on Desktop/Mobile
        final Directory appDocDir = await getApplicationSupportDirectory();
        final String dbDir = path.join(appDocDir.path, 'databases');
        
        // Ensure the directory exists
        final directory = Directory(dbDir);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        dbPath = path.join(dbDir, dbName);
      }
      
      print('📁 Opening database at: $dbPath');

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createTables,
      );
      
      print('✅ Database opened successfully');
      _initCompleter!.complete(_database);
      _initCompleter = null; // Clear completer after success
      return _database!;
    } catch (e, stack) {
      log('❌ Database initialization failed: $e', stackTrace: stack);
      _initCompleter?.completeError(e, stack);
      _initCompleter = null; // Clear so we can retry later
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $invoicesTable (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT UNIQUE,
        invoiceDate TEXT,
        dueDate TEXT,
        businessInfo TEXT NOT NULL,
        customerInfo TEXT NOT NULL,
        items TEXT NOT NULL,
        taxPercentage REAL NOT NULL DEFAULT 0.0,
        notes TEXT,
        status TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'USD',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
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
      print('✅ Tables created successfully');
    } catch (e, stack) {
      log('❌ Failed to create tables: $e', stackTrace: stack);
      rethrow;
    }
  }

  // ──────────────── INVOICE CRUD ────────────────

  Future<void> createInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      invoicesTable,
      _invoiceToMap(invoice),
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
    return _parseInvoiceSafe(result.first);
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      orderBy: 'createdAt DESC',
    );
    return _parseInvoiceListSafe(result);
  }

  Future<List<Invoice>> searchInvoices(String query) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      where: 'invoiceNumber LIKE ? OR customerInfo LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return _parseInvoiceListSafe(result);
  }

  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return _parseInvoiceListSafe(result);
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final db = await database;
    final map = _invoiceToMap(invoice);
    map.remove('id');
    await db.update(
      invoicesTable,
      map,
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

  // ──────────────── DASHBOARD STATISTICS ────────────────

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
    return invoices.fold<double>(0.0, (sum, inv) => sum + inv.total);
  }

  Future<List<Invoice>> getRecentInvoices({int limit = 5}) async {
    final db = await database;
    final result = await db.query(
      invoicesTable,
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return _parseInvoiceListSafe(result);
  }

  // ──────────────── SETTINGS ────────────────

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

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(invoicesTable);
    await db.delete(settingsTable);
  }

  // ──────────────── HELPERS ────────────────

  Map<String, dynamic> _invoiceToMap(Invoice invoice) {
    return {
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
    };
  }

  Invoice _parseInvoiceSafe(Map<String, dynamic> row) {
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value as String);
      } catch (_) {
        return DateTime.now();
      }
    }

    dynamic _safeDecode(dynamic value, {dynamic fallback}) {
      if (value == null) return fallback;
      try {
        return jsonDecode(value as String);
      } catch (_) {
        return fallback;
      }
    }

    InvoiceStatus _parseStatus(dynamic value) {
      if (value == null) return InvoiceStatus.unpaid;
      try {
        return InvoiceStatus.values.firstWhere(
          (e) => e.toString().split('.').last == value,
          orElse: () => InvoiceStatus.unpaid,
        );
      } catch (_) {
        return InvoiceStatus.unpaid;
      }
    }

    final businessJson = _safeDecode(row['businessInfo'], fallback: {}) as Map;
    final customerJson = _safeDecode(row['customerInfo'], fallback: {}) as Map;
    final itemsJson = _safeDecode(row['items'], fallback: []) as List;

    return Invoice(
      id: (row['id'] as String?) ?? '',
      invoiceNumber: (row['invoiceNumber'] as String?) ?? 'INV-000',
      invoiceDate: _parseDate(row['invoiceDate']),
      dueDate: _parseDate(row['dueDate']),
      businessInfo: BusinessInfo.fromJson(Map<String, dynamic>.from(businessJson)),
      customerInfo: CustomerInfo.fromJson(Map<String, dynamic>.from(customerJson)),
      items: itemsJson
          .map((item) => InvoiceItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      taxPercentage: (row['taxPercentage'] as num?)?.toDouble() ?? 0.0,
      notes: row['notes'] as String?,
      status: _parseStatus(row['status']),
      currency: (row['currency'] as String?) ?? 'USD',
      createdAt: _parseDate(row['createdAt']),
      updatedAt: _parseDate(row['updatedAt']),
    );
  }

  List<Invoice> _parseInvoiceListSafe(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      try {
        return _parseInvoiceSafe(row);
      } catch (e) {
        log('Skipping corrupted row: $e');
        return null;
      }
    }).whereType<Invoice>().toList();
  }
}
