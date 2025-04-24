class ResponsePackageActive {
  int? id;
  String? packageProductName;
  String? packageKey;
  double? price;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  List<PackageFunction>? listFunctions;

  ResponsePackageActive({
    this.id,
    this.packageProductName,
    this.packageKey,
    this.price,
    this.startDate,
    this.endDate,
    this.status,
    this.listFunctions,
  });

  factory ResponsePackageActive.fromJson(Map<String, dynamic> json) {
    return ResponsePackageActive(
      id: json['id'] as int?,
      packageProductName: json['package_product_name'] as String?,
      packageKey: json['package_key'] as String?,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      status: json['status'] as String?,
      listFunctions: (json['list_functions'] as List<dynamic>?)
          ?.map((e) => PackageFunction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_product_name': packageProductName,
      'package_key': packageKey,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'list_functions': listFunctions?.map((e) => e.toJson()).toList(),
    };
  }
}

class PackageFunction {
  int? checked;
  int? numbersOfBot;
  int? numbersOfUsers;
  int? queriesPerMonth;
  String? packageFunctionId;
  String? packageFunctionCode;
  String? packageFunctionName;

  PackageFunction({
    this.checked,
    this.numbersOfBot,
    this.numbersOfUsers,
    this.queriesPerMonth,
    this.packageFunctionId,
    this.packageFunctionCode,
    this.packageFunctionName,
  });

  factory PackageFunction.fromJson(Map<String, dynamic> json) {
    return PackageFunction(
      checked: json['checked'] as int?,
      numbersOfBot: json['numbers_of_bot'] as int?,
      numbersOfUsers: json['numbers_of_users'] as int?,
      queriesPerMonth: json['queries_per_month'] as int?,
      packageFunctionId: json['package_function_id'] as String?,
      packageFunctionCode: json['package_function_code'] as String?,
      packageFunctionName: json['package_function_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checked': checked,
      'numbers_of_bot': numbersOfBot,
      'numbers_of_users': numbersOfUsers,
      'queries_per_month': queriesPerMonth,
      'package_function_id': packageFunctionId,
      'package_function_code': packageFunctionCode,
      'package_function_name': packageFunctionName,
    };
  }
}
