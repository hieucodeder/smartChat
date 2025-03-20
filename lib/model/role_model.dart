class RoleModel {
  int? totalItems;
  String? page;
  String? pageSize;
  List<Data>? data;
  int? pageCount;

  RoleModel(
      {this.totalItems, this.page, this.pageSize, this.data, this.pageCount});

  RoleModel.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    page = json['page']?.toString();
    pageSize = json['page_size'];
    pageCount = json['pageCount'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_items'] = totalItems;
    data['page'] = page;
    data['page_size'] = pageSize;
    data['pageCount'] = pageCount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? chatbotCode;
  String? userId;
  String? chatbotName;
  String? createdAt;
  String? updatedAt;
  int? totalCount;
  String? picture;
  int? isActive;
  int? totalMessages;
  int? isRemoved;
  String? description;
  int? recordCount;

  Data({
    this.id,
    this.chatbotCode,
    this.userId,
    this.chatbotName,
    this.createdAt,
    this.updatedAt,
    this.totalCount,
    this.picture,
    this.isActive,
    this.totalMessages,
    this.isRemoved,
    this.description,
    this.recordCount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatbotCode = json['chatbot_code'];
    userId = json['user_id'];
    chatbotName = json['chatbot_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalCount = json['total_count'];
    picture = json['picture'];
    isActive = json['is_active'];
    totalMessages = json['total_messages'];
    isRemoved = json['is_removed'];
    description = json['description'];
    recordCount = json['RecordCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chatbot_code'] = chatbotCode;
    data['user_id'] = userId;
    data['chatbot_name'] = chatbotName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['total_count'] = totalCount;
    data['picture'] = picture;
    data['is_active'] = isActive;
    data['total_messages'] = totalMessages;
    data['is_removed'] = isRemoved;
    data['description'] = description;
    data['RecordCount'] = recordCount;
    return data;
  }
}
