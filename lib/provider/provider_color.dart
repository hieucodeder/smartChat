import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Providercolor with ChangeNotifier {
  // Khởi tạo mặc định là màu trắng
  Color _selectedColor = Colors.white;

  Color get selectedColor => _selectedColor;

  Providercolor() {
    _loadColorFromPrefs();
  }

  void changeColor(Color color) {
    _selectedColor = color;
    notifyListeners();
    _saveColorToPrefs();
  }

  Future<void> _loadColorFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt('selectedColor');

      // Nếu không có giá trị lưu trữ, giữ nguyên màu trắng mặc định
      if (colorValue != null) {
        _selectedColor = Color(colorValue);
      }
      notifyListeners();
    } catch (e) {
      // Nếu có lỗi khi đọc, vẫn giữ màu trắng mặc định
      _selectedColor = Colors.white;
      notifyListeners();
    }
  }

  Future<void> _saveColorToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedColor', _selectedColor.value);
    } catch (e) {
      // Xử lý lỗi nếu cần
      debugPrint('Lỗi khi lưu màu: $e');
    }
  }
}
