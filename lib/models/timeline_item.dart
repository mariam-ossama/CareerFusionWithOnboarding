class TimelineItem {
  final String description;
  final String startDate;
  final String endDate;
  bool isChecked; // Define isChecked property
  int? stageId;
  bool status;

  TimelineItem({
    required this.description,
    required this.startDate,
    required this.endDate,
    this.isChecked = false,
    this.stageId, // Initialize isChecked with false by default
    this.status = false,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      description: json['description'] ?? '',
      startDate: json['startTime'] ?? '',
      endDate: json['endTime'] ?? '',
      stageId: json['stageId'] ?? 0,
      isChecked: json['status'] ?? false, // Use status for isChecked
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'startTime': startDate,
      'endTime': endDate,
      'stageId': stageId,
      'status': isChecked, // Ensure status reflects isChecked
    };
  }
}
