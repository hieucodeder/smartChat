class ResponseTotalQuestion {
  int? totalQuestions;

  ResponseTotalQuestion({this.totalQuestions});

  ResponseTotalQuestion.fromJson(Map<String, dynamic> json) {
    totalQuestions = json['total_questions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['total_questions'] = this.totalQuestions;
    return data;
  }
}
