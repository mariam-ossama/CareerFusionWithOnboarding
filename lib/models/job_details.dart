class JobDetails {
  final String jobId;
  final String jobTitle;
  final String jobType;
  final String jobLocation;
  final List<Map<String, dynamic>> jobSkills;
  final List<Map<String, dynamic>> jobDescriptions;
  final List<Map<String, dynamic>> jobResponsibilities;

  JobDetails({
    required this.jobId,
    required this.jobTitle,
    required this.jobType,
    required this.jobLocation,
    required this.jobSkills,
    required this.jobDescriptions,
    required this.jobResponsibilities,
  });

  factory JobDetails.fromJson(Map<String, dynamic> json) {
    return JobDetails(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      jobType: json['jobType'],
      jobLocation: json['jobLocation'],
      jobSkills: List<Map<String, dynamic>>.from(json['jobSkills']),
      jobDescriptions: List<Map<String, dynamic>>.from(json['jobDescriptions']),
      jobResponsibilities: List<Map<String, dynamic>>.from(json['jobResponsibilities']),
    );
  }
}
