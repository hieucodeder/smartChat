class ResponsePotentialCustomer {
  String? interactionDate;
  int? totalSlot;

  ResponsePotentialCustomer({this.interactionDate, this.totalSlot});

  ResponsePotentialCustomer.fromJson(Map<String, dynamic> json) {
    interactionDate = json['interaction_date'];
    totalSlot = json['total_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['interaction_date'] = this.interactionDate;
    data['total_slots'] = this.totalSlot;
    return data;
  }
}
