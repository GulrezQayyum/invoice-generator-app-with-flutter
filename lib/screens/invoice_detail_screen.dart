import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _invoice;
  final PDFService _pdfService = PDFService();
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${_invoice.invoiceNumber}'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: const Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 8),
                    Text('Export PDF'),
                  ],
                ),
                onTap: () => _generateAndSharePDF(),
              ),
              PopupMenuItem(
                value: 'share',
                child: const Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
                onTap: () => _shareInvoice(),
              ),
              PopupMenuItem(
                value: 'edit',
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INVOICE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Invoice #: ${_invoice.invoiceNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(_invoice.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo(
                          'Invoice Date',
                          _invoice.invoiceDate,
                        ),
                        _buildDateInfo(
                          'Due Date',
                          _invoice.dueDate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // From and To
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoText(_invoice.businessInfo.companyName),
                          _buildInfoText(_invoice.businessInfo.address),
                          _buildInfoText(_invoice.businessInfo.email),
                          _buildInfoText(_invoice.businessInfo.phoneNumber),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bill To',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoText(_invoice.customerInfo.name),
                          _buildInfoText(_invoice.customerInfo.address),
                          _buildInfoText(_invoice.customerInfo.email),
                          _buildInfoText(_invoice.customerInfo.phoneNumber),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowHeight: 50,
                        columnSpacing: 8,
                        columns: const [
                          DataColumn(label: Text('Item')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Disc%')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: _invoice.items
                            .map((item) => DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text('${item.quantity}')),
                          DataCell(Text(
                            '${_invoice.currency} ${NumberFormat('#,##0.00').format(item.unitPrice)}',
                          )),
                          DataCell(Text('${item.discount ?? 0}%')),
                          DataCell(Text(
                            '${_invoice.currency} ${NumberFormat('#,##0.00').format(item.total)}',
                          )),
                        ]))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Totals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow(
                      'Subtotal',
                      _invoice.subtotal,
                      _invoice.currency,
                    ),
                    const Divider(),
                    _buildTotalRow(
                      'Tax (${_invoice.taxPercentage}%)',
                      _invoice.taxAmount,
                      _invoice.currency,
                      isBold: false,
                    ),
                    const Divider(),
                    _buildTotalRow(
                      'Grand Total',
                      _invoice.total,
                      _invoice.currency,
                      isBold: true,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            if (_invoice.notes != null && _invoice.notes!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _invoice.notes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Update Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _invoice.status != InvoiceStatus.paid
                                ? () => _updateStatus(InvoiceStatus.paid)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                            ),
                            child: const Text('Mark as Paid'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _invoice.status != InvoiceStatus.unpaid
                                ? () => _updateStatus(InvoiceStatus.unpaid)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningColor,
                            ),
                            child: const Text('Mark as Unpaid'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = AppTheme.accentColor;
        textColor = Colors.white;
        break;
      case InvoiceStatus.unpaid:
        bgColor = AppTheme.warningColor;
        textColor = Colors.white;
        break;
      case InvoiceStatus.overdue:
        bgColor = AppTheme.dangerColor;
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTotalRow(
      String label,
      double amount,
      String currency, {
        bool isBold = false,
        double fontSize = 14,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$currency ${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _generateAndSharePDF() async {
    setState(() => _isGeneratingPDF = true);

    try {
      final pdfFile = await _pdfService.generatePDF(_invoice);
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Invoice ${_invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  void _shareInvoice() {
    final text = '''
Invoice #${_invoice.invoiceNumber}
Customer: ${_invoice.customerInfo.name}
Amount: ${_invoice.currency} ${NumberFormat('#,##0.00').format(_invoice.total)}
Due Date: ${DateFormat('MMM dd, yyyy').format(_invoice.dueDate)}
    ''';

    Share.share(text);
  }

  void _updateStatus(InvoiceStatus status) {
    context.read<InvoiceProvider>().updateInvoiceStatus(_invoice.id, status);
    setState(() {
      _invoice = _invoice.copyWith(status: status);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invoice marked as ${status.toString().split('.').last}',
        ),
      ),
    );
  }
}