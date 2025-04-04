class ResponseUpdateChatbot {
  String? message;
  bool? results;

  ResponseUpdateChatbot({this.message, this.results});

  ResponseUpdateChatbot.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    results = json['results'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['results'] = this.results;
    return data;
  }
}
