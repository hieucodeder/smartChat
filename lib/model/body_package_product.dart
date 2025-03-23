class BodyPackageProduct {
  int? pageIndex;
  int? pageSize;
  String? searchContent;
  String? packageProductName;

  BodyPackageProduct(
      {this.pageIndex,
      this.pageSize,
      this.searchContent,
      this.packageProductName});

  BodyPackageProduct.fromJson(Map<String, dynamic> json) {
    pageIndex = json['page_index'];
    pageSize = json['page_size'];
    searchContent = json['search_content'];
    packageProductName = json['package_product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page_index'] = this.pageIndex;
    data['page_size'] = this.pageSize;
    data['search_content'] = this.searchContent;
    data['package_product_name'] = this.packageProductName;
    return data;
  }
}
