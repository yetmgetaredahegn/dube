import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _fmt      = NumberFormat('#,##0.00', 'en_US');
  static final _fmtShort = NumberFormat('#,##0',    'en_US');

  /// "ETB 1,250.00"
  static String format(double amount, {bool showDecimal = true}) {
    final f = showDecimal ? _fmt.format(amount) : _fmtShort.format(amount);
    return 'ETB $f';
  }

  /// "1,250"  (used inside cards where ETB is already labelled)
  static String short(double amount) => _fmtShort.format(amount);

  /// "+ETB 500" / "-ETB 200"
  static String withSign(double amount) {
    final sign = amount >= 0 ? '+' : '-';
    return '$sign ETB ${_fmt.format(amount.abs())}';
  }

  /// Parses user input like "1,250.50" → 1250.50
  static double? parse(String text) {
    try {
      return double.parse(text.replaceAll(',', '').replaceAll('ETB', '').trim());
    } catch (_) {
      return null;
    }
  }
}

class DateFormatter {
  DateFormatter._();

  static final _date  = DateFormat('MMM d, yyyy');
  static final _time  = DateFormat('h:mm a');
  static final _full  = DateFormat('MMM d, yyyy · h:mm a');
  static final _short = DateFormat('MMM d');

  static String date(DateTime dt)  => _date.format(dt);
  static String time(DateTime dt)  => _time.format(dt);
  static String full(DateTime dt)  => _full.format(dt);
  static String short(DateTime dt) => _short.format(dt);

  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1)  return 'Yesterday';
    if (diff.inDays < 7)   return '${diff.inDays}d ago';
    if (diff.inDays < 30)  return '${(diff.inDays / 7).floor()}w ago';
    return _short.format(dt);
  }
}
