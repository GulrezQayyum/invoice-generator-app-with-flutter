import 'package:flutter/material.dart';
import '../models/invoice_model.dart';

class InvoiceItemForm extends StatefulWidget {
  final InvoiceItem? initialItem;
  final Function(InvoiceItem) onSave;

  const InvoiceItemForm({
    Key? key,
    this.initialItem,
    required this.onSave,
  }) : super(key: key);

  @override
  State<InvoiceItemForm> createState() => _InvoiceItemFormState();
}

class _InvoiceItemFormState extends State<InvoiceItemForm> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController unitPriceController;
  late TextEditingController discountController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.initialItem?.name ?? '',
    );
    quantityController = TextEditingController(
      text: widget.initialItem?.quantity.toString() ?? '',
    );
    unitPriceController = TextEditingController(
      text: widget.initialItem?.unitPrice.toString() ?? '',
    );
    discountController = TextEditingController(
      text: (widget.initialItem?.discount ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              hintText: 'Enter item or service name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Item name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: unitPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Discount (%)',
              hintText: 'Optional',
            ),
          ),
        ],
      ),
    );
  }

  void save() {
    if (formKey.currentState!.validate()) {
      final item = InvoiceItem(
        id: widget.initialItem?.id ?? '',
        name: nameController.text,
        quantity: int.parse(quantityController.text),
        unitPrice: double.parse(unitPriceController.text),
        discount:
        discountController.text.isEmpty ||
            discountController.text == '0'
            ? null
            : double.parse(discountController.text),
      );
      widget.onSave(item);
    }
  }
}