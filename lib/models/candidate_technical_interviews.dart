

class CandidateTechnicatInterview {
  final int id;
  final int jobFormId;
  final String userId;
  final String userEmail;
  final String userFullName;
  final String filePath;

  CandidateTechnicatInterview({
    required this.id,
    required this.jobFormId,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.filePath,
  });

  factory CandidateTechnicatInterview.fromJson(Map<String, dynamic> json) {
    return CandidateTechnicatInterview(
      id: json['id'],
      jobFormId: json['jobFormId'],
      userId: json['userId'],
      userEmail: json['userEmail'],
      userFullName: json['userFullName'],
      filePath: json['filePath'],
    );
  }
}