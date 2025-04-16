class ResponseLoginGoogle {
  String? userId;
  String? username;
  String? email;
  Null? passwordHash;
  String? fullName;
  String? picture;
  String? createdAt;
  String? updatedAt;
  String? role;
  Null? packageProductId;
  int? active;
  String? token;

  ResponseLoginGoogle(
      {this.userId,
      this.username,
      this.email,
      this.passwordHash,
      this.fullName,
      this.picture,
      this.createdAt,
      this.updatedAt,
      this.role,
      this.packageProductId,
      this.active,
      this.token});

  ResponseLoginGoogle.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    email = json['email'];
    passwordHash = json['password_hash'];
    fullName = json['full_name'];
    picture = json['picture'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    role = json['role'];
    packageProductId = json['package_product_id'];
    active = json['active'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['email'] = email;
    data['password_hash'] = passwordHash;
    data['full_name'] = fullName;
    data['picture'] = picture;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['role'] = role;
    data['package_product_id'] = packageProductId;
    data['active'] = active;
    data['token'] = token;
    return data;
  }
}
