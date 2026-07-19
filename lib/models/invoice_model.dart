import 'package:intl/intl.dart';

enum InvoiceStatus{paid, unpaid, overdue}

class InvoiceItem{
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double? discount;

  InvoiceItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.discount
});
  double get subtotal => quantity * unitPrice;
  double get discountAmount => subtotal * ((discount ?? 0) / 100);
  double get total => subtotal - discountAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      discount: json['discount'],
  );
  }
}

class BusinessInfo {
  final String companyName;
  final String address;
  final String phoneNumber;
  final String email;
  final String? logoPath;

  BusinessInfo({
    required this.companyName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.logoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'logoPath': logoPath,
    };
  }
  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      companyName: json['companyName'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      logoPath: json['logoPath'],
    );
  }
}

class CustomerInfo{
  final String name;
  final String address;
  final String phoneNumber;
  final String email;

  CustomerInfo({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final BusinessInfo businessInfo;
  final CustomerInfo customerInfo;
  final List<InvoiceItem> items;
  final double taxPercentage;
  final String? notes;
  final InvoiceStatus status;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.businessInfo,
    required this.customerInfo,
    required this.items,
    required this.taxPercentage,
    this.notes,
    required this.status,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  double get taxAmount => subtotal * (taxPercentage / 100);

  double get total => subtotal + taxAmount;

  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status != InvoiceStatus.paid;
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    BusinessInfo? businessInfo,
    CustomerInfo? customerInfo,
    List<InvoiceItem>? items,
    double? taxPercentage,
    String? notes,
    InvoiceStatus? status,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      businessInfo: businessInfo ?? this.businessInfo,
      customerInfo: customerInfo ?? this.customerInfo,
      items: items ?? this.items,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'businessInfo': businessInfo.toJson(),
      'customerInfo': customerInfo.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'taxPercentage': taxPercentage,
      'notes': notes,
      'status': status
          .toString()
          .split('.')
          .last,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
      businessInfo: BusinessInfo.fromJson(json['businessInfo']),
      customerInfo: CustomerInfo.fromJson(json['customerInfo']),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      taxPercentage: json['taxPercentage'],
      notes: json['notes'],
      status: InvoiceStatus.values
          .firstWhere((e) =>
      e
          .toString()
          .split('.')
          .last == json['status']),
      currency: json['currency'] ?? 'USD',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}


