class ResponseSearch {
  bool? success;
  int? totalRows;
  List<Data>? data;

  ResponseSearch({this.success, this.totalRows, this.data});

  ResponseSearch.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalRows = json['total_rows'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['total_rows'] = totalRows;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? userId;
  String? username;
  String? fullName;
  String? phoneNumber;
  String? email;
  String? picture;
  String? status;
  String? endDate;
  int? packageProductId;
  String? packageProductName;
  String? packageKey;
  int? packageMonth;
  int? isGift;
  String? startDate;
  String? histories;

  Data(
      {this.userId,
      this.username,
      this.fullName,
      this.phoneNumber,
      this.email,
      this.picture,
      this.status,
      this.endDate,
      this.packageProductId,
      this.packageProductName,
      this.packageKey,
      this.packageMonth,
      this.isGift,
      this.startDate,
      this.histories});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    fullName = json['full_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    picture = json['picture'];
    status = json['status'];
    endDate = json['end_date'];
    packageProductId = json['package_product_id'];
    packageProductName = json['package_product_name'];
    packageKey = json['package_key'];
    packageMonth = json['package_month'];
    isGift = json['is_gift'];
    startDate = json['start_date'];
    histories = json['histories'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['full_name'] = fullName;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['picture'] = picture;
    data['status'] = status;
    data['end_date'] = endDate;
    data['package_product_id'] = packageProductId;
    data['package_product_name'] = packageProductName;
    data['package_key'] = packageKey;
    data['package_month'] = packageMonth;
    data['is_gift'] = isGift;
    data['start_date'] = startDate;
    data['histories'] = histories;
    return data;
  }
}
