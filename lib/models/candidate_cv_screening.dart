

class CandidateCVScreening {
  final String email;
  final String phoneNumber;
  final String fileName;
  final String filePath;
  final List<String> matchedSkills;

  CandidateCVScreening({
    required this.email,
    required this.phoneNumber,
    required this.fileName,
    required this.filePath,
    required this.matchedSkills,
  });

  factory CandidateCVScreening.fromJson(Map<String, dynamic> json) {
    return CandidateCVScreening(
      email: json['contact_info']['email'],
      phoneNumber: json['contact_info']['phone_number'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      matchedSkills: List<String>.from(json['matched_skills']),
    );
  }
}