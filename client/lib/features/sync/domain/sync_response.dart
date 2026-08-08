class SyncDeltaResponse {
  final List<SyncRecord> records;

  SyncDeltaResponse({required this.records});

  factory SyncDeltaResponse.fromJson(dynamic json) {
    if (json is List) {
      return SyncDeltaResponse(
        records: json.map((e) => SyncRecord.fromJson(e)).toList(),
      );
    }
    return SyncDeltaResponse(records: []);
  }
}

class SyncRecord {
  final String localId; // mapped from 'id'
  final String type;
  final int serverSequence;
  final DateTime updatedAt;
  final Map<String, dynamic> content;
  
  // Extra fields from backend Pull response
  final String? titleOrCaption;
  final String? parentId;

  SyncRecord({
    required this.localId,
    required this.type,
    required this.serverSequence,
    required this.updatedAt,
    required this.content,
    this.titleOrCaption,
    this.parentId,
  });

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      localId: json['id'] ?? '',
      type: json['type'] ?? '',
      serverSequence: json['server_sequence'] ?? 0,
      updatedAt: json['ts'] != null 
          ? DateTime.parse(json['ts']) 
          : DateTime.now(),
      content: json['content'] ?? {},
      titleOrCaption: json['title_or_caption'],
      parentId: json['parent_id'],
    );
  }
}

class SyncPushResponse {
  final int applied;
  final int maxSequence;

  SyncPushResponse({required this.applied, required this.maxSequence});

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) {
    return SyncPushResponse(
      applied: json['applied'] ?? 0,
      maxSequence: json['max_sequence'] ?? 0,
    );
  }
}
