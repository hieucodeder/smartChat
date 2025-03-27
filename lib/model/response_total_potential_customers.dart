class ResponseTotalPotentialCustomers {
  int? totalPotentialCustomer;

  ResponseTotalPotentialCustomers({this.totalPotentialCustomer});

  ResponseTotalPotentialCustomers.fromJson(Map<String, dynamic> json) {
    totalPotentialCustomer = json['total_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_slots'] = totalPotentialCustomer;
    return data;
  }
}
