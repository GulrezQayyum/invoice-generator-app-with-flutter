import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _companyNameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _currencyController;
  late TextEditingController _taxPercentageController;
  late TextEditingController _invoicePrefixController;

  @override
  void initState() {
    super.initState();
    final businessProvider = context.read<BusinessProvider>();

    _companyNameController = TextEditingController(
      text: businessProvider.businessInfo.companyName,
    );
    _addressController = TextEditingController(
      text: businessProvider.businessInfo.address,
    );
    _emailController = TextEditingController(
      text: businessProvider.businessInfo.email,
    );
    _phoneController = TextEditingController(
      text: businessProvider.businessInfo.phoneNumber,
    );
    _currencyController = TextEditingController(
      text: businessProvider.settings.currency,
    );
    _taxPercentageController = TextEditingController(
      text: businessProvider.settings.defaultTaxPercentage.toString(),
    );
    _invoicePrefixController = TextEditingController(
      text: businessProvider.settings.invoicePrefix,
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    _taxPercentageController.dispose();
    _invoicePrefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Information Section
                _buildSectionHeader('Business Information'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Company Name',
                            hintText: 'Enter your company name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter company address',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter company email',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter company phone',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveBusinessInfo(
                              businessProvider,
                            ),
                            child: const Text('Save Business Info'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Invoice Settings Section
                _buildSectionHeader('Invoice Settings'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _currencyController.text,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'USD',
                              child: Text('USD (\$)'),
                            ),
                            DropdownMenuItem(
                              value: 'EUR',
                              child: Text('EUR (€)'),
                            ),
                            DropdownMenuItem(
                              value: 'GBP',
                              child: Text('GBP (£)'),
                            ),
                            DropdownMenuItem(
                              value: 'PKR',
                              child: Text('PKR (Rs)'),
                            ),
                            DropdownMenuItem(
                              value: 'INR',
                              child: Text('INR (₹)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _currencyController.text = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _taxPercentageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Default Tax Percentage (%)',
                            hintText: 'Enter default tax percentage',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _invoicePrefixController,
                          decoration: const InputDecoration(
                            labelText: 'Invoice Prefix',
                            hintText: 'e.g., INV, INV-',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Next Invoice Number:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${businessProvider.settings.nextInvoiceNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveInvoiceSettings(
                              businessProvider,
                            ),
                            child: const Text('Save Invoice Settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Danger Zone
                _buildSectionHeader('Danger Zone'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.dangerColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reset all settings to their default values.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showResetDialog(
                              context,
                              businessProvider,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.dangerColor,
                            ),
                            child: const Text('Reset All Settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAboutRow('App Version', '1.0.0'),
                        _buildAboutRow('Build Number', '1'),
                        _buildAboutRow('Developer', 'Your Company'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _saveBusinessInfo(BusinessProvider businessProvider) async {
    try {
      await businessProvider.updateBusinessInfo(
        companyName: _companyNameController.text,
        address: _addressController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business information saved successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveInvoiceSettings(BusinessProvider businessProvider) async {
    try {
      await businessProvider.updateSettings(
        currency: _currencyController.text,
        defaultTaxPercentage:
        double.parse(_taxPercentageController.text),
        invoicePrefix: _invoicePrefixController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice settings saved successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResetDialog(
      BuildContext context,
      BusinessProvider businessProvider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await businessProvider.resetSettings();
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _currencyController.text = 'USD';
                  _taxPercentageController.text = '10.0';
                  _invoicePrefixController.text = 'INV';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset successfully'),
                  ),
                );
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}