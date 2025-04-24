class BodySignup {
  String? fullName;
  String? username;
  String? address;
  String? email;
  String? phoneNumber;
  String? passwordHash;
  String? passwordConfirmation;
  String? picture;

  BodySignup(
      {this.fullName,
      this.username,
      this.address,
      this.email,
      this.phoneNumber,
      this.passwordHash,
      this.passwordConfirmation,
      this.picture});

  BodySignup.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    username = json['username'];
    address = json['address'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    passwordHash = json['password_hash'];
    passwordConfirmation = json['password_confirmation'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['username'] = username;
    data['address'] = address;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['password_hash'] = passwordHash;
    data['password_confirmation'] = passwordConfirmation;
    data['picture'] = picture;
    return data;
  }
}
