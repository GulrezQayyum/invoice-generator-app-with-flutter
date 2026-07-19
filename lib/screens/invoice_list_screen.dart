import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice_model.dart';
import '../theme/app_theme.dart';
import 'invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  InvoiceStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<InvoiceProvider>().loadInvoices();
    } else {
      context.read<InvoiceProvider>().searchInvoices(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        elevation: 0,
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          return Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedStatus == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = null;
                              });
                              invoiceProvider.loadInvoices();
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Paid'),
                            selected: _selectedStatus == InvoiceStatus.paid,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus =
                                selected ? InvoiceStatus.paid : null;
                              });
                              if (selected) {
                                invoiceProvider
                                    .filterByStatus(InvoiceStatus.paid);
                              } else {
                                invoiceProvider.loadInvoices();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Unpaid'),
                            selected: _selectedStatus == InvoiceStatus.unpaid,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus =
                                selected ? InvoiceStatus.unpaid : null;
                              });
                              if (selected) {
                                invoiceProvider
                                    .filterByStatus(InvoiceStatus.unpaid);
                              } else {
                                invoiceProvider.loadInvoices();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Overdue'),
                            selected: _selectedStatus == InvoiceStatus.overdue,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus =
                                selected ? InvoiceStatus.overdue : null;
                              });
                              if (selected) {
                                invoiceProvider
                                    .filterByStatus(InvoiceStatus.overdue);
                              } else {
                                invoiceProvider.loadInvoices();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Invoices List
              Expanded(
                child: invoiceProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : invoiceProvider.invoices.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No invoices found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () =>
                      invoiceProvider.loadInvoices(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: invoiceProvider.invoices.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final invoice =
                      invoiceProvider.invoices[index];
                      return _buildInvoiceCard(
                        context,
                        invoice,
                        invoiceProvider,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard(
      BuildContext context,
      Invoice invoice,
      InvoiceProvider provider,
      ) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailScreen(invoice: invoice),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.customerInfo.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${invoice.currency} ${NumberFormat('#,##0.00').format(invoice.total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(invoice.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
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
                      PopupMenuItem(
                        value: 'duplicate',
                        child: const Row(
                          children: [
                            Icon(Icons.content_copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                        onTap: () async {
                          await provider.duplicateInvoice(invoice);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invoice duplicated successfully',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          _showDeleteDialog(context, invoice.id, provider);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = AppTheme.accentColor.withOpacity(0.2);
        textColor = AppTheme.accentColor;
        break;
      case InvoiceStatus.unpaid:
        bgColor = AppTheme.warningColor.withOpacity(0.2);
        textColor = AppTheme.warningColor;
        break;
      case InvoiceStatus.overdue:
        bgColor = AppTheme.dangerColor.withOpacity(0.2);
        textColor = AppTheme.dangerColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      String invoiceId,
      InvoiceProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteInvoice(invoiceId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice deleted successfully'),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}