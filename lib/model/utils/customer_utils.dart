import 'package:intl/intl.dart';

class CustomerUtils {
  static final platformMapping = {
    'playground': 'Trải Nghiệm Thử',
    'zalo': 'Zalo',
    'facebook': 'Facebook',
  };

  static final statusMapping = {
    'pending': 'Chưa xử lý',
    'completed': 'Đã xử lý',
    'unreachable': 'Chưa liên hệ được',
  };

  static String formatDateTime(String? dateTime) {
    if (dateTime == null) return '-';
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return dateTime;
    }
  }

  static bool isImageUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase().trim();
    final isHttp =
        lowerUrl.startsWith('http://') || lowerUrl.startsWith('https://');
    final hasImageExtension =
        RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)(\?.*)?$').hasMatch(lowerUrl);
    final containsImagePath =
        RegExp(r'(image|img|picture|pic|photo)').hasMatch(lowerUrl);
    return isHttp && (hasImageExtension || containsImagePath);
  }
}
