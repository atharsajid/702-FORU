/// Tiny formatting helpers so we do not need the `intl` package yet.
class AppFormatters {
  const AppFormatters._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// `4:17 PM`
  static String time(DateTime dt) {
    final hour24 = dt.hour;
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour24 < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// `Oct 1, 2026`
  static String date(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  /// `Oct 1` – handy for compact cards.
  static String shortDate(DateTime dt) => '${_months[dt.month - 1]} ${dt.day}';

  /// `2h ago`, `3d ago`, `just now`.
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return shortDate(dt);
  }

  /// `1.2k`, `15.4k`, `2.1M`.
  static String compact(int value) {
    if (value < 1000) return '$value';
    if (value < 1000000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    final m = value / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }

  /// `4.8` – never shows a trailing `.0`.
  static String rating(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  /// `$12.50` style price.
  static String price(double value) => '\$${value.toStringAsFixed(2)}';

  /// Title-cases a string: `arts & culture` → `Arts & Culture`.
  static String titleCase(String input) => input
      .split(' ')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
