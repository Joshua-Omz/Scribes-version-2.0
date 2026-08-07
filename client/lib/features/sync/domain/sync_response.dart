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
  final String localId;
  final String type;
  final int serverSequence;
  final DateTime updatedAt;
  final Map<String, dynamic> content;

  SyncRecord({
    required this.localId,
    required this.type,
    required this.serverSequence,
    required this.updatedAt,
    required this.content,
  });

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      localId: json['local_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      serverSequence: json['server_sequence'] ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      content: json['content'] ?? {},
    );
  }
}

class SyncPushResponse {
  final List<SyncConfirmation> confirmed;
  final int maxSequence;

  SyncPushResponse({required this.confirmed, required this.maxSequence});

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) {
    return SyncPushResponse(
      maxSequence: json['max_sequence'] ?? 0,
      confirmed: (json['confirmed'] as List?)
              ?.map((e) => SyncConfirmation.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SyncConfirmation {
  final String localId;
  final String type;
  final int serverSequence;

  SyncConfirmation({
    required this.localId,
    required this.type,
    required this.serverSequence,
  });

  factory SyncConfirmation.fromJson(Map<String, dynamic> json) {
    return SyncConfirmation(
      localId: json['local_id'] ?? '',
      type: json['type'] ?? '',
      serverSequence: json['server_sequence'] ?? 0,
    );
  }
}
