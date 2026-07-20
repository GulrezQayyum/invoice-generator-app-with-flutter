import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'services/database_service.dart';
import 'providers/invoice_provider.dart';
import 'providers/business_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }


  try {
    await DatabaseService.instance.initializeDatabase();
    print('✅ Database ready');
    runApp(const MyApp());
  } catch (e, stack) {
    print('❌ Database init failed: $e\n$stack');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SelectableText('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    ));
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BusinessProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Invoice Generator',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}