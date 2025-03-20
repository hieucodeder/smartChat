class ResquestTotal {
  String? chatbotCode;
  String? startDate;
  String? endDate;
  String? userId;

  ResquestTotal(
      {this.chatbotCode, this.startDate, this.endDate, this.userId});

  ResquestTotal.fromJson(Map<String, dynamic> json) {
    chatbotCode = json['chatbot_code'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatbot_code'] = chatbotCode;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['user_id'] = userId;
    return data;
  }
}
