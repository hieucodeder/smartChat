import 'package:flutter/material.dart';

class MenuStateProvider with ChangeNotifier {
  bool _showPotentialCustomer = false;
  bool _showServicePackage = true;

  bool get showPotentialCustomer => _showPotentialCustomer;
  bool get showServicePackage => _showServicePackage;

  // Toggle đồng thời cả 2 trạng thái (một cái hiện thì cái kia ẩn)
  void toggleMenuItems() {
    _showPotentialCustomer = !_showPotentialCustomer;
    _showServicePackage = !_showServicePackage;
    notifyListeners();
  }

  // Đặt trạng thái riêng cho Khách hàng tiềm năng
  void setPotentialCustomer(bool value) {
    _showPotentialCustomer = value;
    _showServicePackage = !value; // Luôn đảo ngược với Gói dịch vụ
    notifyListeners();
  }

  // Đặt trạng thái riêng cho Gói dịch vụ
  void setServicePackage(bool value) {
    _showServicePackage = value;
    _showPotentialCustomer = !value; // Luôn đảo ngược với Khách hàng
    notifyListeners();
  }

  // Reset về trạng thái mặc định
  void reset() {
    _showPotentialCustomer = false;
    _showServicePackage = true;
    notifyListeners();
  }
}
