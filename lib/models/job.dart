class Job {
  final String companyName;
  final String jobTitle;
  final String location;
  final String type;
  final String logoUrl;
  List<String>? responsibilities;
  List<String>? skills;
  List<String>? descriptions;

  Job({
    required this.companyName,
    required this.jobTitle,
    required this.location,
    required this.type,
    required this.logoUrl,
    this.responsibilities,
    this.skills,
    this.descriptions,
  });
}
