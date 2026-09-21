import 'package:intl/intl.dart';

/// Formatting used across every admin screen so numbers, money and dates
/// read the same everywhere.
class AdminFormat {
  AdminFormat._();

  static String symbolFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'PKR':
        return 'Rs ';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'AED ';
      case 'ZAR':
        return 'R ';
      default:
        return '$currency ';
    }
  }

  /// `$81.47` — full precision, for order totals and line items.
  static String money(num value, {String currency = 'USD'}) {
    return NumberFormat.currency(
      symbol: symbolFor(currency),
      decimalDigits: 2,
    ).format(value);
  }

  /// `$85,420` — no cents, for KPI tiles and chart axes.
  static String moneyShort(num value, {String currency = 'USD'}) {
    return NumberFormat.currency(
      symbol: symbolFor(currency),
      decimalDigits: 0,
    ).format(value);
  }

  /// `12.4K` — for tight chart axis labels.
  static String compact(num value) => NumberFormat.compact().format(value);

  static String number(num value) =>
      NumberFormat.decimalPattern().format(value);

  /// `+12.4%` / `-3.1%` / `—`
  static String percentDelta(double? value) {
    if (value == null) return '—';
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  static String dateShort(DateTime? date) =>
      date == null ? '—' : DateFormat('MMM d, y').format(date);

  static String dateTimeShort(DateTime? date) =>
      date == null ? '—' : DateFormat('MMM d, y · h:mm a').format(date);

  /// `2h ago`, `3d ago` — used in recent-activity lists.
  static String relative(DateTime? date) {
    if (date == null) return '—';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  /// `#A1B2C3D4` — RTDB push keys are long, so orders show a short handle.
  static String orderRef(String id) {
    if (id.isEmpty) return '#—';
    final tail = id.length <= 8 ? id : id.substring(id.length - 8);
    return '#${tail.toUpperCase()}';
  }
}
