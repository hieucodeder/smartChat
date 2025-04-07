import 'package:flutter/material.dart';

class MenuStateProvider with ChangeNotifier {
  bool _showPotentialCustomer = false;
  bool _showServicePackage = true; // Mặc định hiển thị

  bool get showPotentialCustomer => _showPotentialCustomer;
  bool get showServicePackage => _showServicePackage;

  void setShowPotentialCustomer(bool value) {
    _showPotentialCustomer = value;
    // Khi hiển thị "Khách hàng tiềm năng" thì ẩn "Gói dịch vụ" và ngược lại
    _showServicePackage = !value;
    notifyListeners();
  }

  void setShowServicePackage(bool value) {
    _showServicePackage = value;
    _showPotentialCustomer = !value;
    notifyListeners();
  }
}
