class ResponseTotalInteraction  {
  int? totalInteraction;

  ResponseTotalInteraction ({this.totalInteraction});

  ResponseTotalInteraction .fromJson(Map<String, dynamic> json) {
    totalInteraction = json['total_sessions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_sessions'] = totalInteraction;
    return data;
  }
}
