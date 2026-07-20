import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'services/database_service.dart';
import 'providers/invoice_provider.dart';
import 'providers/business_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ⬇️ CRITICAL: Initialize the web worker
    await databaseFactoryFfiWeb.initWorker();
    // Then set the factory
    databaseFactory = databaseFactoryFfiWeb;
    print('✅ Web database factory initialized');
  } else {
    // For desktop/mobile, no worker needed.
    // Optionally, you can set desktop factory if needed:
    // databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseService.instance.initializeDatabase();
    print('✅ Database opened successfully');
    runApp(const InvoiceGeneratorApp());
  } catch (e, stack) {
    print('❌ Database init failed: $e');
    print(stack);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Database init failed: $e', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Check console for details', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    ));
  }
}