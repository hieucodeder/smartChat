class ResponseInteractionpie {
  String? platform;
  int? totalMessages;

  ResponseInteractionpie({this.platform, this.totalMessages});

  ResponseInteractionpie.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    totalMessages = json['total_messages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['platform'] = this.platform;
    data['total_messages'] = this.totalMessages;
    return data;
  }
}
