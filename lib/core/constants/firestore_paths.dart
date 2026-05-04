class FirestorePaths {
  FirestorePaths._();

  static String users() => 'users';
  static String user(String uid) => 'users/$uid';

  static String customers(String uid) => 'users/$uid/customers';
  static String customer(String uid, String customerId) =>
      'users/$uid/customers/$customerId';

  static String transactions(String uid) => 'users/$uid/transactions';
  static String transaction(String uid, String txId) =>
      'users/$uid/transactions/$txId';
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Dube';
  static const String currencySymbol = 'ETB';

  static const int agingWarningDays  = 30;
  static const int agingCriticalDays = 60;
  static const int agingOverdueDays  = 90;
}

class TransactionType {
  TransactionType._();
  static const String credit  = 'CREDIT';
  static const String payment = 'PAYMENT';
}
