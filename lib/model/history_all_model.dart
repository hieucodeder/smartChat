class HistoryAllModel {
  List<Data>? data;

  HistoryAllModel({this.data});

  HistoryAllModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? chatbotHistoryId;
  String? updatedAt;
  String? slots;
  int? is_read;
  int? is_start;
  String? platform;
  String? userName;
  List<Messages>? messages;

  Data({
    this.chatbotHistoryId,
    this.updatedAt,
    this.slots,
    this.is_read,
    this.is_start,
    this.platform,
    this.userName,
    this.messages,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      chatbotHistoryId: json['chatbot_history_id'],
      updatedAt: json['updated_at'],
      slots: json['slots'],
      is_read: json['is_read'],
      is_start: json['is_start'],
      platform: json['platform'],
      userName: json['user_name'],
      messages: json['messages'] != null
          ? (json['messages'] as List).map((v) => Messages.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chatbot_history_id'] = chatbotHistoryId;
    data['updated_at'] = updatedAt;
    data['slots'] = slots;
    data['is_read'] = is_read;
    data['is_start'] = is_start;
    data['platform'] = platform;
    data['user_name']=userName;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  int? likes;
  String? content;
  int? dislikes;
  String? messageType;

  Messages({this.likes, this.content, this.dislikes, this.messageType});

  Messages.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
    content = json['content'];
    dislikes = json['dislikes'];
    messageType = json['message_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['likes'] = likes;
    data['content'] = content;
    data['dislikes'] = dislikes;
    data['message_type'] = messageType;
    return data;
  }
}
