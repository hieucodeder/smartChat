class ServicePackageResponse {
  int? id;
  String? packageProductName;
  int? price;
  String? startDate;
  Null? endDate;
  String? status;
  List<ListFunctions>? listFunctions;

  ServicePackageResponse(
      {this.id,
      this.packageProductName,
      this.price,
      this.startDate,
      this.endDate,
      this.status,
      this.listFunctions});

  ServicePackageResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageProductName = json['package_product_name'];
    price = json['price'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    if (json['list_functions'] != null) {
      listFunctions = <ListFunctions>[];
      json['list_functions'].forEach((v) {
        listFunctions!.add(new ListFunctions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['package_product_name'] = this.packageProductName;
    data['price'] = this.price;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['status'] = this.status;
    if (this.listFunctions != null) {
      data['list_functions'] =
          this.listFunctions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListFunctions {
  int? checked;
  int? numbersOfBot;
  Null? numbersOfUsers;
  int? queriesPerMonth;
  String? packageFunctionId;
  String? packageFunctionCode;
  String? packageFunctionName;

  ListFunctions(
      {this.checked,
      this.numbersOfBot,
      this.numbersOfUsers,
      this.queriesPerMonth,
      this.packageFunctionId,
      this.packageFunctionCode,
      this.packageFunctionName});

  ListFunctions.fromJson(Map<String, dynamic> json) {
    checked = json['checked'];
    numbersOfBot = json['numbers_of_bot'];
    numbersOfUsers = json['numbers_of_users'];
    queriesPerMonth = json['queries_per_month'];
    packageFunctionId = json['package_function_id'];
    packageFunctionCode = json['package_function_code'];
    packageFunctionName = json['package_function_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checked'] = this.checked;
    data['numbers_of_bot'] = this.numbersOfBot;
    data['numbers_of_users'] = this.numbersOfUsers;
    data['queries_per_month'] = this.queriesPerMonth;
    data['package_function_id'] = this.packageFunctionId;
    data['package_function_code'] = this.packageFunctionCode;
    data['package_function_name'] = this.packageFunctionName;
    return data;
  }
}
