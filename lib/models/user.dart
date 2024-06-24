class User {
  String id; // User ID
  String image;
  String name;
  List<String> courses;
  String phone;
  List<String> projects;
  List<String> skills;
  List<String> siteLinks;

  User(
      {required this.id,
      required this.image,
      required this.name,
      required this.courses,
      required this.phone,
      required this.projects,
      required this.skills,
      required this.siteLinks});

  User copy({
    String? id,
    String? imagePath,
    String? name,
    String? phone,
    List<String>? courses,
    List<String>? projects,
    List<String>? skills,
    List<String>? siteLinks, // Corrected to List<String>?
  }) =>
      User(
        id: id ?? this.id,
        image: imagePath ?? this.image,
        name: name ?? this.name,
        courses: courses ?? this.courses,
        phone: phone ?? this.phone,
        projects: projects ?? this.projects,
        skills: skills ?? this.skills,
        siteLinks: siteLinks ?? this.siteLinks,
      );

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'], // Assuming 'id' is the key for user ID in JSON
        image: json['imagePath'],
        name: json['name'],
        courses: List<String>.from(json['courses']),
        projects: List<String>.from(json['projects']),
        phone: json['phone'],
        skills: List<String>.from(json['skills']),
        siteLinks:
            List<String>.from(json['siteLinks']), // Ensure this is a list
      );

  Map<String, dynamic> toJson() => {
        'id': id, // Serialize user ID
        'imagePath': image,
        'name': name,
        'courses': courses,
        'projects': projects,
        'phone': phone,
        'skills': skills,
        'siteLinks': siteLinks,
      };
}
