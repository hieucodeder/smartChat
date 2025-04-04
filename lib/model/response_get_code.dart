class ResponseGetCode {
  int? id;
  String? chatbotCode;
  String? userId;
  int? groupId;
  String? chatbotName;
  String? createdAt;
  String? updatedAt;
  int? totalCount;
  String? picture;
  String? initialMessages;
  String? suggestedMessages;
  String? messagePlaceholder;
  String? footer;
  String? theme;
  String? displayName;
  String? profilePicture;
  String? chatIcon;
  String? userMessageColor;
  int? isSyncHeader;
  int? totalMessages;
  int? isActive;
  int? isRemoved;
  String? description;
  int? isEmbed;
  String? progress;

  ResponseGetCode(
      {this.id,
      this.chatbotCode,
      this.userId,
      this.groupId,
      this.chatbotName,
      this.createdAt,
      this.updatedAt,
      this.totalCount,
      this.picture,
      this.initialMessages,
      this.suggestedMessages,
      this.messagePlaceholder,
      this.footer,
      this.theme,
      this.displayName,
      this.profilePicture,
      this.chatIcon,
      this.userMessageColor,
      this.isSyncHeader,
      this.totalMessages,
      this.isActive,
      this.isRemoved,
      this.description,
      this.isEmbed,
      this.progress});

  ResponseGetCode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatbotCode = json['chatbot_code'];
    userId = json['user_id'];
    groupId = json['group_id'];
    chatbotName = json['chatbot_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalCount = json['total_count'];
    picture = json['picture'];
    initialMessages = json['initial_messages'];
    suggestedMessages = json['suggested_messages'];
    messagePlaceholder = json['message_placeholder'];
    footer = json['footer'];
    theme = json['theme'];
    displayName = json['display_name'];
    profilePicture = json['profile_picture'];
    chatIcon = json['chat_icon'];
    userMessageColor = json['user_message_color'];
    isSyncHeader = json['is_sync_header'];
    totalMessages = json['total_messages'];
    isActive = json['is_active'];
    isRemoved = json['is_removed'];
    description = json['description'];
    isEmbed = json['is_embed'];
    progress = json['progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chatbot_code'] = this.chatbotCode;
    data['user_id'] = this.userId;
    data['group_id'] = this.groupId;
    data['chatbot_name'] = this.chatbotName;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['total_count'] = this.totalCount;
    data['picture'] = this.picture;
    data['initial_messages'] = this.initialMessages;
    data['suggested_messages'] = this.suggestedMessages;
    data['message_placeholder'] = this.messagePlaceholder;
    data['footer'] = this.footer;
    data['theme'] = this.theme;
    data['display_name'] = this.displayName;
    data['profile_picture'] = this.profilePicture;
    data['chat_icon'] = this.chatIcon;
    data['user_message_color'] = this.userMessageColor;
    data['is_sync_header'] = this.isSyncHeader;
    data['total_messages'] = this.totalMessages;
    data['is_active'] = this.isActive;
    data['is_removed'] = this.isRemoved;
    data['description'] = this.description;
    data['is_embed'] = this.isEmbed;
    data['progress'] = this.progress;
    return data;
  }
}
