import 'package:flutter/material.dart';

class SelectedItemProvider with ChangeNotifier {
  int _selectedIndex = -1; // -1 nghĩa là chưa có item nào được chọn

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
