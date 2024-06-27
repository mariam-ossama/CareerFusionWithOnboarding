import 'package:career_fusion/screens/candidate_screens/edit_user_profile_screen.dart';

class UserProfile {
  String username;
  String fullName;
  String? title;
  String profilePicturePath;
  int followersCount;
  String description;
  String address;
  //List<Projects> projects;
  List<ProjectLink> projectLinks;
  List<Course> courses;
  List<Skill> skills;
  List<SiteLink> siteLinks;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.title,
    required this.profilePicturePath,
    required this.followersCount,
    required this.description,
    required this.address,
    required this.projectLinks,
    required this.courses,
    required this.skills,
    required this.siteLinks,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['userName'] as String? ?? 'No Username',
      fullName: json['fullName'] as String? ?? 'No Fullname',
      title: json['title'] as String? ?? 'No title',
      profilePicturePath:
          json['profilePicturePath'] as String? ?? 'assets/images/111.avif',
      followersCount: json['followersCount'] as int? ?? 0,
      description: json['description'] as String? ?? 'No description provided',
      address: json['address'] as String? ?? 'No address provided',
      projectLinks: (json['projectLinks'] as List<dynamic>?)
              ?.map((x) => ProjectLink.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
      courses: (json['courses'] as List<dynamic>?)
              ?.map((x) => Course.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((x) => Skill.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
      siteLinks: (json['siteLinks'] as List<dynamic>?)
              ?.map((x) => SiteLink.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
