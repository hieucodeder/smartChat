class ResponseAnswerFalse {
  String? message;
  bool? results;
  Data? data;

  ResponseAnswerFalse({this.message, this.results, this.data});

  ResponseAnswerFalse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    results = json['results'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['results'] = results;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? message;
  List<String>? images;
  bool? isMaxMessage;

  Data({this.message, this.images, this.isMaxMessage});

  Data.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    isMaxMessage = json['isMaxMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (images != null) {
      data['images'] = images;
    }
    data['isMaxMessage'] = isMaxMessage;
    return data;
  }
}
