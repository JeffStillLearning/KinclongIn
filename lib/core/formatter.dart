import 'package:intl/intl.dart';

String formatCurrency(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatCurrencyWithoutSymbol(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );
  return formatter.format(amount).trim();
}

String formatNumber(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(amount);
}
