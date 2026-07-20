import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../providers/invoice_provider.dart';
import '../providers/business_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/invoice_item_form.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoiceToEdit;

  const CreateInvoiceScreen({
    Key? key,
    this.invoiceToEdit,
  }) : super(key: key);

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _invoiceDate;
  late DateTime _dueDate;

  // Customer Fields
  late TextEditingController _customerNameController;
  late TextEditingController _customerAddressController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerPhoneController;

  // Items
  List<InvoiceItem> _items = [];
  late TextEditingController _itemNameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _discountController;

  // Other
  late TextEditingController _notesController;
  late TextEditingController _taxPercentageController;

  @override
  void initState() {
    super.initState();
    _invoiceDate = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 30));

    _customerNameController = TextEditingController();
    _customerAddressController = TextEditingController();
    _customerEmailController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _itemNameController = TextEditingController();
    _quantityController = TextEditingController();
    _unitPriceController = TextEditingController();
    _discountController = TextEditingController();
    _notesController = TextEditingController();

    final businessProvider = context.read<BusinessProvider>();
    _taxPercentageController = TextEditingController(
      text: businessProvider.settings.defaultTaxPercentage.toString(),
    );

    if (widget.invoiceToEdit != null) {
      _populateFormWithInvoice(widget.invoiceToEdit!);
    }
  }

  void _populateFormWithInvoice(Invoice invoice) {
    _invoiceDate = invoice.invoiceDate;
    _dueDate = invoice.dueDate;
    _customerNameController.text = invoice.customerInfo.name;
    _customerAddressController.text = invoice.customerInfo.address;
    _customerEmailController.text = invoice.customerInfo.email;
    _customerPhoneController.text = invoice.customerInfo.phoneNumber;
    _notesController.text = invoice.notes ?? '';
    _taxPercentageController.text = invoice.taxPercentage.toString();
    _items = invoice.items;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    _taxPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoiceToEdit != null
            ? 'Edit Invoice'
            : 'Create Invoice'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dates Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Dates',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Invoice Date',
                                ),
                                child: Text(
                                  '${_invoiceDate.toLocal()}'.split(' ')[0],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                ),
                                child: Text(
                                  '${_dueDate.toLocal()}'.split(' ')[0],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Enter customer name',
                        ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Customer name is required';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter customer address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter customer email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter customer phone',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Invoice Items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Invoice Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddItemDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No items added yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)} = \$${item.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: const Text('Edit'),
                                      onTap: () =>
                                          _editItem(index),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: Colors.red)),
                                      onTap: () {
                                        setState(() {
                                          _items.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tax and Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _taxPercentageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tax Percentage (%)',
                          hintText: 'Enter tax percentage',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tax percentage is required';
                          }

                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter a valid number';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add payment instructions or notes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      widget.invoiceToEdit != null
                          ? 'Update Invoice'
                          : 'Create Invoice',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, bool isInvoiceDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = pickedDate;
        } else {
          _dueDate = pickedDate;
        }
      });
    }
  }

  void _showAddItemDialog() {
    _itemNameController.clear();
    _quantityController.clear();
    _unitPriceController.clear();
    _discountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'Enter item name',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price',
                  hintText: 'Enter unit price',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount (%)',
                  hintText: 'Enter discount (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _unitPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    final newItem = InvoiceItem(
      id: const Uuid().v4(),
      name: _itemNameController.text,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      unitPrice: double.tryParse(_unitPriceController.text.trim()) ?? 0.0,
      discount: _discountController.text.trim().isEmpty
          ? null
          : double.tryParse(_discountController.text.trim()),
    );

    setState(() {
      _items.add(newItem);
    });

    Navigator.pop(context);
  }

  void _editItem(int index) {
    final item = _items[index];
    _itemNameController.text = item.name;
    _quantityController.text = item.quantity.toString();
    _unitPriceController.text = item.unitPrice.toString();
    _discountController.text = (item.discount ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount (%)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItem = InvoiceItem(
                id: item.id,
                name: _itemNameController.text,
                quantity: int.parse(_quantityController.text),
                unitPrice: double.parse(_unitPriceController.text),
                discount: _discountController.text.isNotEmpty
                    ? double.parse(_discountController.text)
                    : null,
              );

              setState(() {
                _items[index] = updatedItem;
              });

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
        ),
      );
      return;
    }

    final businessProvider = context.read<BusinessProvider>();
    final invoiceProvider = context.read<InvoiceProvider>();

    final customerInfo = CustomerInfo(
      name: _customerNameController.text,
      address: _customerAddressController.text,
      email: _customerEmailController.text,
      phoneNumber: _customerPhoneController.text,
    );

    final invoice = Invoice(
      id: widget.invoiceToEdit?.id ?? const Uuid().v4(),
      invoiceNumber: widget.invoiceToEdit?.invoiceNumber ??
          businessProvider.generateInvoiceNumber(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      businessInfo: businessProvider.businessInfo,
      customerInfo: customerInfo,
      items: _items,
      taxPercentage: double.parse(_taxPercentageController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      status: widget.invoiceToEdit?.status ?? InvoiceStatus.unpaid,
      currency: businessProvider.settings.currency,
      createdAt: widget.invoiceToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.invoiceToEdit == null) {
      invoiceProvider.createInvoice(invoice);
      businessProvider.incrementInvoiceNumber();
    } else {
      invoiceProvider.updateInvoice(invoice);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.invoiceToEdit == null
              ? 'Invoice created successfully'
              : 'Invoice updated successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }
}