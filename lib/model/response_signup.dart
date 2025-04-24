class ResponseSignup {
  String? message;
  String? results;

  ResponseSignup({this.message, this.results});

  ResponseSignup.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    results = json['results'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['results'] = results;
    return data;
  }
}
