import 'package:flutter/foundation.dart';
import '../models/invoice_model.dart';
import '../models/settings_model.dart';
import '../services/database_service.dart';

class BusinessProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  // Initialized with default values to prevent LateInitializationError
  AppSettings _settings = AppSettings(
    currency: 'USD',
    defaultTaxPercentage: 10.0,
    invoicePrefix: 'INV',
    nextInvoiceNumber: 1,
    companyLogoPath: null,
  );
  
  BusinessInfo _businessInfo = BusinessInfo(
    companyName: 'Your Company',
    address: '123 Business St, City',
    email: 'info@company.com',
    phoneNumber: '+1-XXX-XXX-XXXX',
    logoPath: null,
  );

  BusinessInfo get businessInfo => _businessInfo;
  AppSettings get settings => _settings;

  BusinessProvider() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final savedSettings = await _dbService.getSettings();
      if (savedSettings != null) {
        _settings = savedSettings;
      }

      _businessInfo = BusinessInfo(
        companyName: 'Your Company',
        address: '123 Business St, City',
        email: 'info@company.com',
        phoneNumber: '+1-XXX-XXX-XXXX',
        logoPath: _settings.companyLogoPath,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      // If initialization fails, we already have default values set
    }
  }

  Future<void> updateBusinessInfo({
    required String companyName,
    required String address,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      _businessInfo = BusinessInfo(
        companyName: companyName,
        address: address,
        email: email,
        phoneNumber: phoneNumber,
        logoPath: _businessInfo.logoPath,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating business info: $e');
      rethrow;
    }
  }

  Future<void> updateSettings({
    String? currency,
    double? defaultTaxPercentage,
    String? invoicePrefix,
    String? logoPath,
  }) async {
    try {
      _settings = _settings.copyWith(
        currency: currency,
        defaultTaxPercentage: defaultTaxPercentage,
        invoicePrefix: invoicePrefix,
        companyLogoPath: logoPath,
      );

      await _dbService.saveSettings(_settings);

      // Update business info logo path
      if (logoPath != null) {
        _businessInfo = _businessInfo.copyWith(logoPath: logoPath);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }

  Future<void> incrementInvoiceNumber() async {
    try {
      _settings = _settings.copyWith(
        nextInvoiceNumber: _settings.nextInvoiceNumber + 1,
      );
      await _dbService.saveSettings(_settings);
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing invoice number: $e');
      rethrow;
    }
  }

  String generateInvoiceNumber() {
    return _settings.generateInvoiceNumber();
  }

  Future<void> resetSettings() async {
    try {
      _settings = AppSettings(
        currency: 'USD',
        defaultTaxPercentage: 10.0,
        invoicePrefix: 'INV',
        nextInvoiceNumber: 1,
        companyLogoPath: null,
      );
      await _dbService.saveSettings(_settings);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      rethrow;
    }
  }
}

extension BusinessInfoExtension on BusinessInfo {
  BusinessInfo copyWith({
    String? companyName,
    String? address,
    String? email,
    String? phoneNumber,
    String? logoPath,
  }) {
    return BusinessInfo(
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
