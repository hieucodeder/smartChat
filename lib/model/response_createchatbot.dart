class ResponseCreatechatbot {
  String? message;
  bool? results;
  String? code;

  ResponseCreatechatbot({this.message, this.results, this.code});

  ResponseCreatechatbot.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    results = json['results'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['results'] = results;
    data['code'] = code;
    return data;
  }
}
