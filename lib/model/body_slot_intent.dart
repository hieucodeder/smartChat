class BodySlotIntent {
  String? chatbotCode;
  String? intentQueue;
  String? pageIndex;
  String? pageSize;
  String? searchContent;
  String? userId;
  String? slotStatus;

  BodySlotIntent(
      {this.chatbotCode,
      this.intentQueue,
      this.pageIndex,
      this.pageSize,
      this.searchContent,
      this.userId,
      this.slotStatus});

  BodySlotIntent.fromJson(Map<String, dynamic> json) {
    chatbotCode = json['chatbot_code'];
    intentQueue = json['intent_queue'];
    pageIndex = json['page_index'];
    pageSize = json['page_size'];
    searchContent = json['search_content'];
    userId = json['user_id'];
    slotStatus = json['slot_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatbot_code'] = this.chatbotCode;
    data['intent_queue'] = this.intentQueue;
    data['page_index'] = this.pageIndex;
    data['page_size'] = this.pageSize;
    data['search_content'] = this.searchContent;
    data['user_id'] = this.userId;
    data['slot_status'] = this.slotStatus;
    return data;
  }
}