class ResponsePotentialCustomerpie {
  String? platform;
  int? totalSlot;

  ResponsePotentialCustomerpie({this.platform, this.totalSlot});

  ResponsePotentialCustomerpie.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    totalSlot = json['total_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['platform'] = this.platform;
    data['total_slots'] = this.totalSlot;
    return data;
  }
}
