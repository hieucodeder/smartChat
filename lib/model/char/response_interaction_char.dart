class ResponseInteractionChar {
  String? interactionDate;
  int? totalSessions;

  ResponseInteractionChar({this.interactionDate, this.totalSessions});

  ResponseInteractionChar.fromJson(Map<String, dynamic> json) {
    interactionDate = json['interaction_date'];
    totalSessions = json['total_sessions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['interaction_date'] = this.interactionDate;
    data['total_sessions'] = this.totalSessions;
    return data;
  }
}
