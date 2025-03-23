class PackageProductResponse {
  final int? totalItems;
  final int? page;
  final int? pageSize;
  final List<Data>? data;
  final int? pageCount;

  PackageProductResponse({
    this.totalItems,
    this.page,
    this.pageSize,
    this.data,
    this.pageCount,
  });

  factory PackageProductResponse.fromJson(Map<String, dynamic> json) {
    return PackageProductResponse(
      totalItems: json['total_items'],
      page: json['page'],
      pageSize: json['page_size'],
      data: (json['data'] as List?)?.map((e) => Data.fromJson(e)).toList(),
      pageCount: json['page_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'page': page,
      'page_size': pageSize,
      'data': data?.map((e) => e.toJson()).toList(),
      'page_count': pageCount,
    };
  }
}

class Data {
  final int? packageProductId;
  final String? packageProductName;
  final int? price;
  final String? packageKey;
  final List<ListFunctions>? listFunctions;
  final List<ListMonths>? listMonths;
  final int? recordCount;

  Data({
    this.packageProductId,
    this.packageProductName,
    this.price,
    this.packageKey,
    this.listFunctions,
    this.listMonths,
    this.recordCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      packageProductId: json['package_product_id'],
      packageProductName: json['package_product_name'],
      price: json['price'],
      packageKey: json['package_key'],
      listFunctions: (json['list_functions'] as List?)
          ?.map((e) => ListFunctions.fromJson(e))
          .toList(),
      listMonths: (json['list_months'] as List?)
          ?.map((e) => ListMonths.fromJson(e))
          .toList(),
      recordCount: json['RecordCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_product_id': packageProductId,
      'package_product_name': packageProductName,
      'price': price,
      'package_key': packageKey,
      'list_functions': listFunctions?.map((e) => e.toJson()).toList(),
      'list_months': listMonths?.map((e) => e.toJson()).toList(),
      'RecordCount': recordCount,
    };
  }
}

class ListFunctions {
  final int? checked;
  final int? numbersOfBot;
  final int? numbersOfUsers;
  final int? queriesPerMonth;
  final String? packageFunctionId;
  final String? packageFunctionName;

  ListFunctions({
    this.checked,
    this.numbersOfBot,
    this.numbersOfUsers,
    this.queriesPerMonth,
    this.packageFunctionId,
    this.packageFunctionName,
  });

  factory ListFunctions.fromJson(Map<String, dynamic> json) {
    return ListFunctions(
      checked: json['checked'],
      numbersOfBot: json['numbers_of_bot'],
      numbersOfUsers: json['numbers_of_users'],
      queriesPerMonth: json['queries_per_month'],
      packageFunctionId: json['package_function_id'],
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
      'package_function_name': packageFunctionName,
    };
  }
}

class ListMonths {
  final int? unitPrice;
  final int? countMonth;
  final int? packageMonthId;
  final int? packageProductId;

  ListMonths({
    this.unitPrice,
    this.countMonth,
    this.packageMonthId,
    this.packageProductId,
  });

  factory ListMonths.fromJson(Map<String, dynamic> json) {
    return ListMonths(
      unitPrice: json['unit_price'],
      countMonth: json['count_month'],
      packageMonthId: json['package_month_id'],
      packageProductId: json['package_product_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_price': unitPrice,
      'count_month': countMonth,
      'package_month_id': packageMonthId,
      'package_product_id': packageProductId,
    };
  }
}
