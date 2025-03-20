class ResponseTotalCount {
  int? totalChatbots;

  ResponseTotalCount({this.totalChatbots});

  ResponseTotalCount.fromJson(Map<String, dynamic> json) {
    totalChatbots = json['total_chatbots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_chatbots'] = totalChatbots;
    return data;
  }
}
