class TrainingRecord {
  final String id;
  final String videoId;
  final String resultSasUrl;
  final String fileName;
  final DateTime createdAt;

  TrainingRecord({
    required this.id,
    required this.videoId,
    required this.resultSasUrl,
    required this.fileName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'resultSasUrl': resultSasUrl,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      resultSasUrl: json['resultSasUrl'] as String,
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

