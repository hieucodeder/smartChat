class BodyCreateChatbot {
  String? chatbotName;
  String? userIndustry;
  String? systemPrompt;
  String? userId;
  int? groupId;
  int? totalCount;
  List<String>? files;
  String? text; // Đổi từ TextWidget? thành String?
  List<String>? websites;
  List<String>? qa;
  String? picture;
  String? lang;
  String? chatModel;
  String? fallbackResponse;

  BodyCreateChatbot({
    this.chatbotName,
    this.userIndustry,
    this.systemPrompt,
    this.userId,
    this.groupId,
    this.totalCount,
    this.files,
    this.text, // Kiểu String?
    this.websites,
    this.qa,
    this.picture,
    this.lang,
    this.chatModel,
    this.fallbackResponse,
  });

  factory BodyCreateChatbot.fromJson(Map<String, dynamic> json) {
    return BodyCreateChatbot(
      chatbotName: json['chatbot_name'],
      userIndustry: json['user_industry'],
      systemPrompt: json['system_prompt'],
      userId: json['user_id'],
      groupId: json['group_id'],
      totalCount: json['total_count'],
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      text: json['text'] as String?, // Đổi cách parse JSON
      websites: (json['websites'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      qa: (json['qa'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      picture: json['picture'],
      lang: json['lang'],
      chatModel: json['chat_model'],
      fallbackResponse: json['fallback_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatbot_name': chatbotName,
      'user_industry': userIndustry,
      'system_prompt': systemPrompt,
      'user_id': userId,
      'group_id': groupId,
      'total_count': totalCount,
      'files': files,
      'text': text ?? "", // Nếu null thì thành chuỗi rỗng ""
      'websites': websites,
      'qa': qa,
      'picture': picture,
      'lang': lang,
      'chat_model': chatModel,
      'fallback_response': fallbackResponse,
    };
  }
}
