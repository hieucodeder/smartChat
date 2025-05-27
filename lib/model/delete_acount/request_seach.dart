class RequestSeach {
  int? pageIndex;
  int? pageSize;
  String? searchContent;

  RequestSeach({this.pageIndex, this.pageSize, this.searchContent});

  RequestSeach.fromJson(Map<String, dynamic> json) {
    pageIndex = json['page_index'];
    pageSize = json['page_size'];
    searchContent = json['search_content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_index'] = pageIndex;
    data['page_size'] = pageSize;
    data['search_content'] = searchContent;
    return data;
  }
}
