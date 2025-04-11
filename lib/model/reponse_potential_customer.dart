class ResponsePotentialCustomer {
  int? totalItems;
  String? page;
  String? pageSize;
  List<DataPotentialCustomer> data;
  int? pageCount;

  ResponsePotentialCustomer({
    this.totalItems,
    this.page,
    this.pageSize,
    List<DataPotentialCustomer>? data,
    this.pageCount,
  }) : data = data ?? [];

  factory ResponsePotentialCustomer.fromJson(Map<String, dynamic> json) {
    return ResponsePotentialCustomer(
      totalItems: json['total_items'] ?? 0,
      page: json['page']?.toString() ?? "1",
      pageSize: json['page_size']?.toString() ?? "10",
      data: (json['data'] as List?)
              ?.map((e) => DataPotentialCustomer.fromJson(e))
              .toList() ??
          [],
      pageCount: json['page_count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'page': page,
      'page_size': pageSize,
      'data': data.map((e) => e.toJson()).toList(),
      'page_count': pageCount,
    };
  }
}

class DataPotentialCustomer {
  final int rowNumber;
  final int chatHistoryId;
  final String slotId;
  final String intentSlots;
  final Map<String, dynamic> slotDetails;
  final String? slotStatus;
  final int? activity;
  final String? createdAt;
  final String? updatedAt;
  final String? platform;
  final int? recordCount;

  DataPotentialCustomer({
    required this.rowNumber,
    required this.chatHistoryId,
    required this.slotId,
    required this.intentSlots,
    required this.slotDetails,
    required this.slotStatus,
    required this.activity,
    required this.createdAt,
    required this.updatedAt,
    required this.platform,
    this.recordCount,
  });

  factory DataPotentialCustomer.fromJson(Map<String, dynamic> json) {
    return DataPotentialCustomer(
      rowNumber: json["RowNumber"] ?? 0,
      chatHistoryId: json["chat_history_id"] ?? 0,
      slotId: json["slot_id"] ?? "",
      intentSlots: json["intent_slots"] ?? "",
      slotStatus: json["slot_status"] ?? "",
      slotDetails: Map<String, dynamic>.from(json["slot_details"] ?? {}),
      activity: json['active'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      platform: json['platform'],
      recordCount: json["RecordCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "RowNumber": rowNumber,
      "chat_history_id": chatHistoryId,
      "slot_id": slotId,
      "intent_slots": intentSlots,
      "slot_status": slotStatus,
      "slot_details": slotDetails,
      "active": activity,
      "created_at": createdAt,
      "updated_at": updatedAt,
      'platform': platform,
      "RecordCount": recordCount,
    };
  }
}
