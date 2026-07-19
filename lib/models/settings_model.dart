class AppSettings {
  final String currency;
  final double defaultTaxPercentage;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String? companyLogoPath;

  AppSettings({
    this.currency = 'USD',
    this.defaultTaxPercentage = 10.0,
    this.invoicePrefix = 'INV',
    this.nextInvoiceNumber = 1,
    this.companyLogoPath,
  });

  String generateInvoiceNumber() {
    return '$invoicePrefix-${nextInvoiceNumber.toString().padLeft(3, '0')}';
  }

  AppSettings copyWith({
    String? currency,
    double? defaultTaxPercentage,
    String? invoicePrefix,
    int? nextInvoiceNumber,
    String? companyLogoPath,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      defaultTaxPercentage: defaultTaxPercentage ?? this.defaultTaxPercentage,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'defaultTaxPercentage': defaultTaxPercentage,
      'invoicePrefix': invoicePrefix,
      'nextInvoiceNumber': nextInvoiceNumber,
      'companyLogoPath': companyLogoPath,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currency: json['currency'] ?? 'USD',
      defaultTaxPercentage: (json['defaultTaxPercentage'] as num?)?.toDouble() ?? 10.0,
      invoicePrefix: json['invoicePrefix'] ?? 'INV',
      nextInvoiceNumber: json['nextInvoiceNumber'] ?? 1,
      companyLogoPath: json['companyLogoPath'],
    );
  }
}
