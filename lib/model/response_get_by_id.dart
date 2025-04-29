class ResponseGetById {
  String? userId;
  String? username;
  String? email;
  String? phoneNumber;
  String? address;
  String? passwordHash;
  String? fullName;
  String? picture;
  String? createdAt;
  String? updatedAt;
  String? role;
  String? packageProductId;
  int? active;
  String? emailSubscribes;

  ResponseGetById({
    this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.address,
    this.passwordHash,
    this.fullName,
    this.picture,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.packageProductId,
    this.active,
    this.emailSubscribes,
  });

  factory ResponseGetById.fromJson(Map<String, dynamic> json) {
    return ResponseGetById(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      passwordHash: json['password_hash'],
      fullName: json['full_name'],
      picture: json['picture'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'],
      packageProductId: json['package_product_id']?.toString(),
      active: json['active'],
      emailSubscribes: json['email_subscribes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'password_hash': passwordHash,
      'full_name': fullName,
      'picture': picture,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'package_product_id': packageProductId,
      'active': active,
      'email_subscribes': emailSubscribes,
    };
  }
}
