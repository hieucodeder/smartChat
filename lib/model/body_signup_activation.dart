class BodySignupActivation {
  String? email;
  User? user;

  BodySignupActivation({this.email, this.user});

  BodySignupActivation.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? fullName;

  User({this.fullName});

  User.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    return data;
  }
}
