import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../services/database_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;

  // Dashboard stats
  int _totalInvoices = 0;
  int _paidInvoices = 0;
  int _unpaidInvoices = 0;
  double _totalRevenue = 0.0;
  List<Invoice> _recentInvoices = [];

  int get totalInvoices => _totalInvoices;
  int get paidInvoices => _paidInvoices;
  int get unpaidInvoices => _unpaidInvoices;
  double get totalRevenue => _totalRevenue;
  List<Invoice> get recentInvoices => _recentInvoices;

  InvoiceProvider() {
    loadInvoices();
    loadDashboardStats();
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoices = await _dbService.getAllInvoices();
      notifyListeners();
    } catch (e) {
      print('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      _totalInvoices = await _dbService.getTotalInvoices();
      _paidInvoices = await _dbService.getPaidInvoices();
      _unpaidInvoices = await _dbService.getUnpaidInvoices();
      _totalRevenue = await _dbService.getTotalRevenue();
      _recentInvoices = await _dbService.getRecentInvoices();
      notifyListeners();
    } catch (e) {
      print('Error loading dashboard stats: $e');
    }
  }

  Future<void> createInvoice(Invoice invoice) async {
    try {
      await _dbService.createInvoice(invoice);
      await loadInvoices();
      await loadDashboardStats();
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      await _dbService.updateInvoice(invoice);
      await loadInvoices();
      await loadDashboardStats();
    } catch (e) {
      print('Error updating invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _dbService.deleteInvoice(id);
      await loadInvoices();
      await loadDashboardStats();
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  Future<void> searchInvoices(String query) async {
    if (query.isEmpty) {
      await loadInvoices();
      return;
    }

    try {
      _invoices = await _dbService.searchInvoices(query);
      notifyListeners();
    } catch (e) {
      print('Error searching invoices: $e');
    }
  }

  Future<void> filterByStatus(InvoiceStatus status) async {
    try {
      _invoices = await _dbService.getInvoicesByStatus(
        status.toString().split('.').last,
      );
      notifyListeners();
    } catch (e) {
      print('Error filtering invoices: $e');
    }
  }

  void selectInvoice(Invoice invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Invoice> duplicateInvoice(Invoice invoice) async {
    final newInvoice = invoice.copyWith(
      id: const Uuid().v4(),
      invoiceNumber: '', // Will be set by business provider
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: InvoiceStatus.unpaid,
    );

    await createInvoice(newInvoice);
    return newInvoice;
  }

  Future<void> updateInvoiceStatus(String invoiceId, InvoiceStatus status) async {
    try {
      final invoice = getInvoiceById(invoiceId);
      if (invoice != null) {
        final updatedInvoice = invoice.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await updateInvoice(updatedInvoice);
      }
    } catch (e) {
      print('Error updating invoice status: $e');
      rethrow;
    }
  }

  Future<void> clearAllInvoices() async {
    try {
      await _dbService.clearDatabase();
      await loadInvoices();
      await loadDashboardStats();
    } catch (e) {
      print('Error clearing invoices: $e');
      rethrow;
    }
  }

  int getOverdueCount() {
    return _invoices.where((inv) => inv.isOverdue).length;
  }
}