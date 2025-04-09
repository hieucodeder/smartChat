import 'package:flutter/foundation.dart';

class PlatformProvider with ChangeNotifier {
  String _platform = '';

  String get platform => _platform;

  void setPlatform(String platform) {
    _platform = platform;
    notifyListeners();
  }

  // Thêm phương thức reset
  void resetPlatform() {
    _platform = '';
    notifyListeners();
  }
}
