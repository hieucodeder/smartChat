import 'package:flutter/material.dart';

class DrawSelectedColorProvider with ChangeNotifier {
  int _selectedIndex = -1; // -1 nghĩa là không có mục nào được chọn ban đầu

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // Thông báo cho các widget lắng nghe khi trạng thái thay đổi
  }
}
