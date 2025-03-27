class GetPackageProductResponse {
  int? id;
  String? packageProductName;
  int? price;
  String? startDate;
  String? endDate;
  String? status;
  List<ListFunctions>? listFunctions;

  GetPackageProductResponse({
    this.id,
    this.packageProductName,
    this.price,
    this.startDate,
    this.endDate,
    this.status,
    this.listFunctions,
  });

  factory GetPackageProductResponse.fromJson(Map<String, dynamic> json) {
    return GetPackageProductResponse(
      id: json['id'],
      packageProductName: json['package_product_name'],
      price: json['price'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      listFunctions: (json['list_functions'] as List?)
              ?.map((e) => ListFunctions.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_product_name': packageProductName,
      'price': price,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'list_functions': listFunctions?.map((e) => e.toJson()).toList(),
    };
  }
}

class ListFunctions {
  int? checked;
  int? numbersOfBot;
  int? numbersOfUsers;
  int? queriesPerMonth;
  String? packageFunctionId;
  String? packageFunctionCode;
  String? packageFunctionName;

  ListFunctions({
    this.checked,
    this.numbersOfBot,
    this.numbersOfUsers,
    this.queriesPerMonth,
    this.packageFunctionId,
    this.packageFunctionCode,
    this.packageFunctionName,
  });

  factory ListFunctions.fromJson(Map<String, dynamic> json) {
    return ListFunctions(
      checked: json['checked'],
      numbersOfBot: json['numbers_of_bot'],
      numbersOfUsers: json['numbers_of_users'],
      queriesPerMonth: json['queries_per_month'],
      packageFunctionId: json['package_function_id'],
      packageFunctionCode: json['package_function_code'],
      packageFunctionName: json['package_function_name'],
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
