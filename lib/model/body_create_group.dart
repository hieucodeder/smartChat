class BodyCreateGroup {
  String? groupName;
  String? groupUrl;
  String? userId;
  String? role;

  BodyCreateGroup({this.groupName, this.groupUrl, this.userId, this.role});

  BodyCreateGroup.fromJson(Map<String, dynamic> json) {
    groupName = json['group_name'];
    groupUrl = json['group_url'];
    userId = json['user_id'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_name'] = groupName;
    data['group_url'] = groupUrl;
    data['user_id'] = userId;
    data['role'] = role;
    return data;
  }
}
