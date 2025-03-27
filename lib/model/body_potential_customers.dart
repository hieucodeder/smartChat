class BodyPotentialCustomers {
  String? startDate;
  String? endDate;
  String? chatbotCode;
  String? intentQueue;
  int? pageIndex;
  String? pageSize;
  String? searchContent;
  String? userId;

  BodyPotentialCustomers(
      {this.startDate,
      this.endDate,
      this.chatbotCode,
      this.intentQueue,
      this.pageIndex,
      this.pageSize,
      this.searchContent,
      this.userId});

  BodyPotentialCustomers.fromJson(Map<String, dynamic> json) {
    startDate = json['start_date'];
    endDate = json['end_date'];
    chatbotCode = json['chatbot_code'];
    intentQueue = json['intent_queue'];
    pageIndex = json['page_index'];
    pageSize = json['page_size'];
    searchContent = json['search_content'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['chatbot_code'] = this.chatbotCode;
    data['intent_queue'] = this.intentQueue;
    data['page_index'] = this.pageIndex;
    data['page_size'] = this.pageSize;
    data['search_content'] = this.searchContent;
    data['user_id'] = this.userId;
    return data;
  }
}
