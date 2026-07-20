# Invoice Generator - Flutter App

A professional Flutter Invoice Generator application that enables users to create, manage, and export invoices with local storage, PDF generation, and comprehensive invoice management features.

## 📋 Project Overview

This is a full-featured invoicing application built with Flutter that demonstrates modern app development practices including clean architecture, state management, local database operations, and PDF generation. The app is designed for small businesses, freelancers, and consultants who need to create and manage professional invoices.

## ✨ Core Features

### 1. **Invoice Creation**
- Create new invoices with automatic invoice number generation
- Select invoice date and due date with date pickers
- Add customer information (name, address, email, phone)
- Add multiple products/services with quantity, unit price, and discount
- Automatic calculation of:
    - Subtotal
    - Discount amount
    - Tax
    - Grand total
- Add optional notes and payment instructions
- All invoices saved locally with SQLite

### 2. **Invoice Management**
- View all invoices in a list with search functionality
- Search invoices by invoice number or customer name
- Filter invoices by status (Paid, Unpaid, Overdue)
- Edit existing invoices
- Delete invoices with confirmation dialog
- Duplicate an invoice
- Mark invoices as Paid, Unpaid, or Overdue
- Automatic overdue detection based on due date

### 3. **Export & Sharing**
- Generate professional PDF invoices
- Download PDF to device storage
- Share invoices via WhatsApp, Email, and other apps
- Share invoice details as text

### 4. **Dashboard**
Displays comprehensive statistics:
- Total number of invoices
- Number of paid invoices
- Number of unpaid invoices
- Number of overdue invoices
- Total revenue generated
- List of recent invoices with quick access

### 5. **Settings**
- Configure business information (company name, address, email, phone)
- Select preferred currency (USD, EUR, GBP, PKR, INR)
- Set default tax percentage
- Customize invoice prefix (e.g., INV-)
- View app information
- Reset settings to defaults

## 📦 Packages Used

```yaml
# State Management
provider: ^6.0.0

# Local Database
sqflite: ^2.3.0

# PDF Generation
pdf: ^3.10.0
printing: ^5.11.0

# File Operations
path_provider: ^2.1.0

# Sharing
share_plus: ^7.1.0

# Image Picker
image_picker: ^1.0.0

# Date/Time
intl: ^0.19.0

# UUID Generation
uuid: ^4.0.0

# UI
google_fonts: ^6.1.0
```

## 🏗️ Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/
│   ├── invoice_model.dart             # Invoice, InvoiceItem, BusinessInfo, CustomerInfo models
│   └── settings_model.dart            # AppSettings model
├── services/
│   ├── database_service.dart          # SQLite database operations
│   └── pdf_service.dart               # PDF generation service
├── providers/
│   ├── invoice_provider.dart          # Invoice state management
│   └── business_provider.dart         # Business settings state management
├── screens/
│   ├── home_screen.dart               # Main navigation screen
│   ├── dashboard_screen.dart          # Dashboard with statistics
│   ├── invoice_list_screen.dart       # List of invoices
│   ├── invoice_detail_screen.dart     # Invoice details and actions
│   ├── create_invoice_screen.dart     # Create/Edit invoice form
│   └── settings_screen.dart           # App settings
├── widgets/
│   ├── stat_card.dart                 # Dashboard stat card widget
│   └── invoice_item_form.dart         # Invoice item form widget
├── theme/
│   └── app_theme.dart                 # Material Design theme
└── assets/                            # Images and icons
```

## 🚀 Setup Instructions

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android Studio/Xcode for emulator/device

### Installation Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/invoice_generator.git
cd invoice_generator
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Build and run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d iphone
```

4. **Generate APK**
```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## 🎨 UI/UX Features

- **Clean Material Design UI** with modern color scheme
- **Responsive layout** that adapts to different screen sizes
- **Smooth navigation** between screens
- **Attractive cards and tables** for data display
- **Comprehensive input validation** for all forms
- **Empty state messages** when no data exists
- **Loading indicators** for async operations
- **Snackbar notifications** for user feedback
- **Dialog confirmations** for destructive actions

## 💾 Local Storage

The app uses **SQLite** for persistent local storage:
- All invoices are saved locally on the device
- Settings are persisted across app sessions
- No internet connection required
- Data is encrypted at rest (standard SQLite encryption can be added)

### Database Tables
1. **invoices** - Stores all invoice data
2. **settings** - Stores app configuration

## 📄 PDF Generation

Professional PDF invoices include:
- Invoice header with company information
- Invoice number and dates
- Business and customer details
- Itemized invoice line items
- Automatic calculations (subtotal, tax, total)
- Professional layout and formatting
- Invoice status

## 🔄 Data Models

### Invoice Model
```dart
Invoice {
  id,
  invoiceNumber,
  invoiceDate,
  dueDate,
  businessInfo,
  customerInfo,
  items,
  taxPercentage,
  notes,
  status,
  currency,
  createdAt,
  updatedAt
}
```

### InvoiceItem Model
```dart
InvoiceItem {
  id,
  name,
  quantity,
  unitPrice,
  discount
}
```

### BusinessInfo Model
```dart
BusinessInfo {
  companyName,
  address,
  email,
  phoneNumber,
  logoPath
}
```

### CustomerInfo Model
```dart
CustomerInfo {
  name,
  address,
  email,
  phoneNumber
}
```

## 📊 State Management

The app uses **Provider** for state management:
- **InvoiceProvider** - Manages invoice CRUD operations and dashboard data
- **BusinessProvider** - Manages business settings and configuration

This ensures:
- Separation of concerns
- Easy testing
- Efficient state updates
- Clean widget rebuilding

## 🔐 Features Breakdown

### Dashboard Screen
- Displays key statistics in stat cards
- Shows total revenue
- Lists recent invoices
- Pull-to-refresh functionality
- Quick navigation to invoice details

### Invoice List Screen
- Searchable invoice list
- Filter by status (Paid/Unpaid/Overdue)
- Swipe actions (edit, duplicate, delete)
- Invoice status badges
- Quick access to invoice details
- Pull-to-refresh

### Invoice Detail Screen
- Full invoice information display
- Professional formatting
- Export to PDF
- Share functionality
- Status management
- Edit capabilities

### Create/Edit Invoice Screen
- Multi-step form with validation
- Date pickers for invoice dates
- Dynamic item management
- Automatic calculations
- Tax configuration
- Notes section

### Settings Screen
- Business information configuration
- Currency selection
- Default tax percentage
- Invoice prefix customization
- Reset to defaults option
- About section

## 🚦 Invoice Status

Invoices can have three statuses:
1. **Paid** - Invoice has been paid (Green badge)
2. **Unpaid** - Invoice is pending payment (Orange badge)
3. **Overdue** - Invoice is past due date and not paid (Red badge)

Status is automatically set to "Overdue" if:
- Due date is in the past
- Invoice status is "Unpaid"

## 🎯 Key Features Implementation

### Auto-generate Invoice Numbers
- Format: `[PREFIX]-[NUMBER]` (e.g., INV-001)
- Customizable prefix in settings
- Auto-incremented for each new invoice

### Real-time Calculations
- Subtotal = Sum of (Quantity × Unit Price - Discount)
- Tax = Subtotal × Tax Percentage
- Grand Total = Subtotal + Tax

### Search & Filter
- Search by invoice number or customer name
- Filter by invoice status
- Case-insensitive search
- Real-time results

### PDF Generation
- High-quality PDF output
- Professional formatting
- Automatic layout
- Portable across devices

## 🔄 Data Flow

1. User creates invoice → Stored in SQLite
2. Invoice appears in list and dashboard
3. User can edit/delete/duplicate invoice
4. User can generate PDF or share invoice
5. User can update invoice status
6. Statistics auto-update on dashboard

## 🛠️ Development Guidelines

### Adding New Features
1. Update relevant models if needed
2. Add database operations in `DatabaseService`
3. Update providers for state management
4. Create UI screens
5. Add navigation routes
6. Test thoroughly

### Code Organization
- Separate UI, business logic, and data layers
- Use providers for state management
- Follow Flutter best practices
- Maintain clean code standards
- Add meaningful comments

### Testing
- Test form validation
- Test CRUD operations
- Test calculations
- Test PDF generation
- Test sharing functionality

## 📱 Supported Currencies

- USD (US Dollar)
- EUR (Euro)
- GBP (British Pound)
- PKR (Pakistani Rupee)
- INR (Indian Rupee)

Can be easily extended in `settings_screen.dart`

## 🔮 Future Enhancement Possibilities

### Bonus Features (Optional)
- 🌙 Dark mode support
- 📷 Company logo upload
- 📱 QR code for payment
- 👥 Customer history tracking
- 📦 Product catalog
- 📊 Monthly income summary
- 📈 Revenue charts
- 🎨 Multiple invoice templates
- 💾 Backup & restore data
- ⭐ Favorite customers
- 🔔 Due date reminders
- 📤 Export invoice list as CSV

## 🐛 Known Issues & Limitations

- Currently supports single business profile
- No multi-user support
- No cloud sync (can be added)
- Invoices not encrypted (can be added)
- No invoice numbering backup recovery (can be added)

## 📄 License

This project is provided as-is for educational and commercial use.

## 👨‍💻 Developer

Built as a comprehensive Flutter learning project demonstrating:
- Clean architecture
- State management with Provider
- Local database with SQLite
- PDF generation
- Form handling and validation
- UI/UX best practices

## 🤝 Contributing

Feel free to fork, modify, and improve this project. Contributions are welcome!

## 📞 Support

For issues, questions, or suggestions, please open an issue in the GitHub repository.

---

**Last Updated:** January 2024  
**Flutter Version:** 3.0+  
**Dart Version:** 3.0+