class ActivityRecord {
  final String id;
  final String type;
  final DateTime timestamp;
  final String? status;

  ActivityRecord({
    required this.id,
    required this.type,
    required this.timestamp,
    this.status,
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(
        (json['timestamp'] as String).endsWith('Z') 
          ? json['timestamp'] as String 
          : '${json['timestamp']}Z'
      ).toLocal(),
      status: json['status'] as String?,
    );
  }
}
