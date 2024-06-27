class CandidateTechnicatInterview {
  final int id;
  final int jobFormId;
  final String userId;
  final String userEmail;
  final String userFullName;
  final String filePath;
  DateTime? technicalInterviewDate;
  DateTime? physicalInterviewDate;

  CandidateTechnicatInterview({
    required this.id,
    required this.jobFormId,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.filePath,
    this.technicalInterviewDate,
    this.physicalInterviewDate,
  });

  factory CandidateTechnicatInterview.fromJson(Map<String, dynamic> json) {
    return CandidateTechnicatInterview(
      id: json['id'],
      jobFormId: json['jobFormId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      userFullName: json['userFullName'],
      filePath: json['filePath'],
      technicalInterviewDate: json['technicalInterviewDate'] != null
          ? DateTime.parse(json['technicalInterviewDate'])
          : null,
      physicalInterviewDate: json['physicalInterviewDate'] != null
          ? DateTime.parse(json['physicalInterviewDate'])
          : null,
    );
  }
}
