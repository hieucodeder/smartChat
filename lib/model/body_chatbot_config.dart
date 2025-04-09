class BodyChatbotConfig {
  String? chatbotCode;
  String? isForm;

  BodyChatbotConfig({this.chatbotCode, this.isForm});

  BodyChatbotConfig.fromJson(Map<String, dynamic> json) {
    chatbotCode = json['chatbot_code'];
    isForm = json['is_form'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatbot_code'] = chatbotCode;
    data['is_form'] = isForm;

    return data;
  }
}
