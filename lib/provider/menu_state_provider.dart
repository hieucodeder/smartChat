import 'package:flutter/material.dart';

class MenuStateProvider with ChangeNotifier {
  bool _showPotentialCustomer = false;
  bool _showServicePackage = true;
  bool _showReloadButton = true; // Thêm biến mới chỉ điều khiển IconButton

  bool get showPotentialCustomer => _showPotentialCustomer;
  bool get showServicePackage => _showServicePackage;
  bool get showReloadButton => _showReloadButton;

  // Thêm method mới
  void setReloadButton(bool value) {
    _showReloadButton = value;
    notifyListeners();
  }

  // Thêm hàm này để đồng bộ với selectedIndex
  void updateBasedOnSelectedIndex(int selectedIndex) {
    _showPotentialCustomer = (selectedIndex != -1);
    _showServicePackage = (selectedIndex == -1);
    notifyListeners();
  }

  void updateBase(int selectedIndex) {
    _showPotentialCustomer = (selectedIndex != -1);

    notifyListeners();
  }

  // Toggle chỉ thay đổi PotentialCustomer, KHÔNG ảnh hưởng ServicePackage
  void toggleMenuItems() {
    _showPotentialCustomer = !_showPotentialCustomer;
    notifyListeners(); // Không đảo _showServicePackage
  }

  // Đặt trạng thái riêng cho Khách hàng tiềm năng
  void setPotentialCustomer(bool value) {
    _showPotentialCustomer = value;
    notifyListeners();
  }

  // Đặt trạng thái riêng cho Gói dịch vụ
  void setServicePackage(bool value) {
    _showServicePackage = value;
    notifyListeners();
  }

  // Reset về trạng thái mặc định
  void reset() {
    _showPotentialCustomer = false;
    _showServicePackage = true;
    notifyListeners();
  }
}
