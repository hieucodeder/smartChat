class RequestCustomerCreate {
  String? userId;
  int? packageProductId;
  String? startDate;
  String? status;
  int? isGift;
  String? title;
  String? packageProductName;
  String? luUser;

  RequestCustomerCreate(
      {this.userId,
      this.packageProductId,
      this.startDate,
      this.status,
      this.isGift,
      this.title,
      this.packageProductName,
      this.luUser});

  RequestCustomerCreate.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    packageProductId = json['package_product_id'];
    startDate = json['start_date'];
    status = json['status'];
    isGift = json['is_gift'];
    title = json['title'];
    packageProductName = json['package_product_name'];
    luUser = json['lu_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['package_product_id'] = packageProductId;
    data['start_date'] = startDate;
    data['status'] = status;
    data['is_gift'] = isGift;
    data['title'] = title;
    data['package_product_name'] = packageProductName;
    data['lu_user'] = luUser;
    return data;
  }
}
