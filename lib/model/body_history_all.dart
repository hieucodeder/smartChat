class BodyHistoryAll {
  String? chatbotCode;
  String? startDate;
  String? endDate;
  String? platform;
  String? isRead;
  String? isStar;

  BodyHistoryAll(
      {this.chatbotCode,
      this.startDate,
      this.endDate,
      this.platform,
      this.isRead,
      this.isStar});

  BodyHistoryAll.fromJson(Map<String, dynamic> json) {
    chatbotCode = json['chatbot_code'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    platform = json['platform'];
    isRead = json['is_read'];
    isStar = json['is_star'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatbot_code'] = this.chatbotCode;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['platform'] = this.platform;
    data['is_read'] = this.isRead;
    data['is_star'] = this.isStar;
    return data;
  }
}
