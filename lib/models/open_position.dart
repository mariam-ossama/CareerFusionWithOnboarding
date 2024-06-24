class Position {
  final String id; // Assuming each position has an ID
  final String title;
  final String type;
  final String location;
  final String? description;
  final String? userId;
  int? jobId;

  Position({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    this.description,
    this.userId,
    this.jobId,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['UserId'] ?? '', // Provide default value for better null safety
      title: json['jobTitle'] ?? '',
      type: json['jobType'] ?? '',
      location: json['jobLocation'] ?? '',
      jobId: json['jobId'],
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}