class BlockedSlot {
  BlockedSlot({
    required this.id,
    required this.date,
    this.timeLabel,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final String? timeLabel;
  final DateTime createdAt;

  Map<String, dynamic> toInsertMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'time_label': timeLabel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static BlockedSlot fromMap(Map<String, dynamic> json) {
    return BlockedSlot(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      timeLabel: json['time_label'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
