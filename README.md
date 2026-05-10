# dube

[![License](https://img.shields.io/github/license/yetmgetaredahegn/dube)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/yetmgetaredahegn/dube)](https://github.com/yetmgetaredahegn/dube/issues)
[![GitHub stars](https://img.shields.io/github/stars/yetmgetaredahegn/dube)](https://github.com/yetmgetaredahegn/dube/stargazers)

## Overview

**dube** is a credit management app for local shops and mini-markets in Ethiopia. Shop owners who currently track customer debt using notebooks, memory, and verbal agreements can replace that with a real-time digital ledger. The core idea is that a shop owner extends credit to regular customers ("buy now, pay later"), and **dube** tracks exactly who owes how much, how old the debt is, and sends reminders when people are overdue.

The app has two interfaces in one:
- **Shop owner dashboard:** A full management dashboard to record credits, payments, and customer records.
- **Customer balance check:** Customers can view their own balance using a 6-digit PIN the owner shares with them—no customer account required.

## Features

- Real-time credit and payment tracking
- Overdue reminders to customers
- Two-in-one experience (owner + customer view)
- Ledger-style accounting for full auditability
- Mobile-first UX for local shops

## Powered by Firebase

**Used:**
- **Firebase Authentication** — email and password login for shop owners
- **Cloud Firestore** — main database storing shop owner profiles, customer records, and individual credit/payment transactions as separate documents
- **Firebase Cloud Messaging (FCM)** — push notifications for payment reminders

**Deliberately avoided:**
- **Firebase Storage** (no file uploads needed)
- **Firebase Hosting** (mobile-only app)
- **Paid third-party services** — SMS and email reminders use WhatsApp deep links and clipboard copy instead of services like Twilio or SendGrid

## Ledger Architecture (No Stored Balances)

**dube** never stores a customer’s balance as a database field. Balances are calculated live by summing all credit transactions and subtracting all payment transactions—exactly like a proper accounting ledger. This prevents data corruption and keeps the full history auditable.

## Screenshots

<!-- 
Add screenshots here:
![Shop Dashboard](screenshots/dashboard.png)
![Customer PIN Screen](screenshots/customer_pin.png)
-->

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio or Xcode
- A device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yetmgetaredahegn/dube.git
   cd dube
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

### Building for Release

- **Android:**  
  ```sh
  flutter build apk --release
  ```
- **iOS:**  
  ```sh
  flutter build ios --release
  ```

Refer to the official [Flutter documentation](https://docs.flutter.dev/) for deployment guidance.

## Project Structure

- `lib/` — Flutter/Dart source code
- `android/`, `ios/` — Native platform code
- `assets/` — Images, fonts, and static assets
- `test/` — Unit and widget tests

## Technology Stack

- **Dart / Flutter**
- **Firebase Auth, Firestore, FCM**
- **C++ / C / Swift** (native integrations as needed)
- **CMake**

## Contributing

Contributions are welcome. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a pull request

## License

This project is licensed under the [MIT License](LICENSE).

---

For questions or support, please [open an issue](https://github.com/yetmgetaredahegn/dube/issues).
