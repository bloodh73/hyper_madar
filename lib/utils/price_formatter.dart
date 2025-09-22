import 'package:intl/intl.dart';

class PriceFormatter {
  // Format price with thousands separators and Rial currency
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return '${formatter.format(price)} ریال';
  }

  // Format price without currency symbol (just numbers with separators)
  static String formatPriceNumber(double price) {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return formatter.format(price);
  }

  // Format price with custom currency symbol
  static String formatPriceWithCurrency(double price, String currency) {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return '${formatter.format(price)} $currency';
  }

  // Parse price string back to double (remove separators and currency)
  static double parsePrice(String priceString) {
    // Remove currency symbols and spaces
    String cleanPrice = priceString
        .replaceAll('ریال', '')
        .replaceAll('تومان', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    return double.tryParse(cleanPrice) ?? 0.0;
  }
}
