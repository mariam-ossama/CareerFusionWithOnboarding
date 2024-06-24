import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/candidate_screens/edit_user_profile_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Define the model class to parse JSON data
class UserProfile {
  String username;
  String fullName;
  String? title;
  String profilePicturePath;
  int? followersCount;
  String description;
  String address;
  List<ProjectLink> projectLinks;
  List<Course> courses;
  List<Skill> skills;
  List<SiteLink> siteLinks;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.title,
    required this.profilePicturePath,
    this.followersCount,
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

// Define other model classes like ProjectLink, Course, Skill, and SiteLink similarly...

// Create a function to fetch profile data from the API
Future<UserProfile> fetchUserProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  final response = await http.get(
    Uri.parse('${baseUrl}/UserProfile/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Include any other necessary headers, such as authorization headers
    },
  );
  print(response.body);

  if (response.statusCode == 200) {
    return UserProfile.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load user profile: ${response.body}');
  }
}

/*Future<void> uploadProfilePicture(String userId) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://careerfus.azurewebsites.net/api/UserProfile/upload-profile-picture/$userId'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'profilePicture',
      pickedFile.path,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Profile picture uploaded successfully.');
      print('${response.statusCode}');
    } else {
      print('Failed to upload profile picture.');
    }
  } else {
    print('No image selected.');
  }
}*/

Future<String?> fetchProfilePictureUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  final response = await http.get(
    Uri.parse(
        '${baseUrl}/UserProfile/$userId/profile-picture'),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // Assuming the response contains a direct URL or a path that you can construct the URL from
    return responseData['profilePictureUrl'];
  } else {
    // Handle error or return a default image URL
    print('Failed to load profile picture: ${response.body}');
    return null;
  }
}

// Now, you can build your Flutter UI using a StatefulWidget

// Your UserProfile class and other model classes remain unchanged...

// UserProfilePage StatefulWidget

class HRProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<HRProfilePage> {
  late Future<UserProfile> futureUserProfile;

  @override
  void initState() {
    super.initState();
    futureUserProfile = fetchUserProfile(); // Replace with your user ID
  }

  Future<void> uploadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${baseUrl}/UserProfile/upload-profile-picture/$userId'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'profilePicture',
        pickedFile.path,
      ));

      var streamedResponse = await request.send();

      // Convert the streamed response to a http.Response to read the body
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Profile picture uploaded successfully.');

        // Trigger a UI update by fetching the latest profile picture URL
        setState(() {
          // Invalidate the current profile picture URL to force a refresh
          futureUserProfile =
              fetchUserProfile(); // This will re-fetch the user profile, including the new profile picture
        });
      } else {
        print(
            'Failed to upload profile picture. Status code: ${response.statusCode}');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> deleteSkill(String userId, int skillId) async {
    final http.Response response = await http.delete(
      Uri.parse(
          '${baseUrl}/UserProfile/$userId/skills/$skillId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Skill deleted successfully.');
    } else {
      throw Exception(
          'Failed to delete skill. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteCourse(String userId, int courseId) async {
    final http.Response response = await http.delete(
      Uri.parse(
          '${baseUrl}/UserProfile/$userId/courses/$courseId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Course deleted successfully.');
    } else {
      throw Exception(
          'Failed to delete course. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteProject(String userId, int projectId) async {
    final http.Response response = await http.delete(
      Uri.parse(
          '${baseUrl}/UserProfile/$userId/projectlinks/$projectId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Project deleted successfully.');
    } else {
      throw Exception(
          'Failed to delete Project. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteSitelinks(String userId, int sitelinktId) async {
    final http.Response response = await http.delete(
      Uri.parse(
          '${baseUrl}/UserProfile/$userId/sitelinks/$sitelinktId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Sitelink deleted successfully.');
    } else {
      throw Exception(
          'Failed to delete Sitelink. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: FutureBuilder<UserProfile>(
        future: futureUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return buildUserProfile(snapshot.data!);
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildUserProfile(UserProfile userProfile) {
    // Assuming 'userId' is available in your class. If not, make sure to pass it appropriately.
    //String userId = '0f8ecacb-abe9-4922-8bc9-5bebb0db743d';

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              FutureBuilder<String?>(
                future: fetchProfilePictureUrl(),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 60),
                    );
                  } else {
                    return CircleAvatar(
                      radius: 90,
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  }
                },
              ),
              Container(
                padding: EdgeInsets.all(2), // White border width
                decoration: BoxDecoration(
                  color: Colors.white, // White border color
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mainAppColor, // Edit icon background color
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      await uploadProfilePicture();
                      setState(() {
                        // Trigger a rebuild to refresh the profile picture
                        futureUserProfile =
                            fetchUserProfile(); // Refetch user profile or specifically the profile picture
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            userProfile.username ?? 'No Username',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            userProfile.title ?? 'No title', // Use actual role or description
            style: TextStyle(color: Colors.black),
          ),
          Text(
            userProfile.followersCount
                .toString(), // Use actual role or description
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          ),

          Divider(
            height: 40,
            thickness: 2,
            indent: 8,
            endIndent: 8,
          ),

          ListTile(
            title: Text(
              userProfile.description ?? 'No Description',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            ),
          ),

          // Add other user details like address, followers count etc.
          Divider(
            height: 40,
            thickness: 2,
            indent: 8,
            endIndent: 8,
          ),
          ListTile(
            title: Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,//fontFamily: appFont
              ),
            ),
            subtitle: Text(userProfile.address,style: TextStyle(//fontFamily: appFont
            ),),
            /*trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Implement CV viewing or downloading
            },*/
          ),
          Divider(
            height: 40,
            thickness: 2,
            indent: 8,
            endIndent: 8,
          ),
          // _buildSectionTitle(context, 'My Skills'),
          // ...userProfile.skills.map((skill) => ListTile(
          //       title: Text(skill.skillName),
          //       subtitle: Text(skill.skillLevel),
          //       trailing: IconButton(
          //         icon: Icon(Icons.delete),
          //         onPressed: () async {
          //           // Retrieve the user ID from shared preferences or your state management solution
          //           SharedPreferences prefs =
          //               await SharedPreferences.getInstance();
          //           String? userId = prefs.getString('userId');
          //           if (userId != null) {
          //             await deleteSkill(userId, skill.skillId);
          //             // Update your state to remove the skill from the list
          //             setState(() {
          //               userProfile.skills
          //                   .removeWhere((s) => s.skillId == skill.skillId);
          //             });
          //           }
          //         },
          //       ),
          //     )),
          // Divider(
          //   height: 40,
          //   thickness: 2,
          //   indent: 8,
          //   endIndent: 8,
          // ),
          // _buildSectionTitle(context, 'My Projects'),
          // ...userProfile.projectLinks.map((project) => ListTile(
          //       title: Text(project.projectName),
          //       subtitle: Text(project.projectUrl),
          //       trailing: IconButton(
          //         icon: Icon(Icons.delete),
          //         onPressed: () async {
          //           // Retrieve the user ID from shared preferences or your state management solution
          //           SharedPreferences prefs =
          //               await SharedPreferences.getInstance();
          //           String? userId = prefs.getString('userId');
          //           if (userId != null) {
          //             await deleteProject(userId, project.projectLinkId);
          //             // Update your state to remove the skill from the list
          //             setState(() {
          //               userProfile.projectLinks.removeWhere(
          //                   (s) => s.projectLinkId == project.projectLinkId);
          //             });
          //           }
          //         },
          //       ),
          //       onTap: () => _launchURL(project.projectUrl),
          //     )),
          // Divider(
          //   height: 40,
          //   thickness: 2,
          //   indent: 8,
          //   endIndent: 8,
          // ),
          // _buildSectionTitle(context, 'My Courses'),
          // ...userProfile.courses.map((course) => ListTile(
          //       title: Text(course.courseName),
          //       trailing: IconButton(
          //         icon: Icon(Icons.delete),
          //         onPressed: () async {
          //           // Retrieve the user ID from shared preferences or your state management solution
          //           SharedPreferences prefs =
          //               await SharedPreferences.getInstance();
          //           String? userId = prefs.getString('userId');
          //           if (userId != null) {
          //             await deleteCourse(userId, course.courseId);
          //             // Update your state to remove the skill from the list
          //             setState(() {
          //               userProfile.courses
          //                   .removeWhere((s) => s.courseId == course.courseId);
          //             });
          //           }
          //         },
          //       ),
          //     )),
          // Divider(
          //   height: 40,
          //   thickness: 2,
          //   indent: 8,
          //   endIndent: 8,
          // ),
          // _buildSectionTitle(context, 'My Site Links'),
          // ...userProfile.siteLinks.map((siteLink) => ListTile(
          //       title: Text(siteLink.linkUrl),
          //       trailing: IconButton(
          //         icon: Icon(Icons.delete),
          //         onPressed: () async {
          //           // Retrieve the user ID from shared preferences or your state management solution
          //           SharedPreferences prefs =
          //               await SharedPreferences.getInstance();
          //           String? userId = prefs.getString('userId');
          //           if (userId != null) {
          //             await deleteSitelinks(userId, siteLink.siteLinkId);
          //             // Update your state to remove the skill from the list
          //             setState(() {
          //               userProfile.siteLinks.removeWhere(
          //                   (s) => s.siteLinkId == siteLink.siteLinkId);
          //             });
          //           }
          //         },
          //       ),
          //     )),
          // Divider(
          //   height: 40,
          //   thickness: 2,
          //   indent: 8,
          //   endIndent: 8,
          // ),
          // ListTile(
          //   title: Text(
          //     'CV',
          //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, //fontFamily: appFont
          //     ),
          //   ),
          //   trailing: Icon(Icons.arrow_forward),
          //   onTap: () {
          //     // Implement CV viewing or downloading
          //   },
          // ),
          SizedBox(height: 20),
          CustomButton(
            text: 'Edit Profile Info',
            onPressed: () {
              Navigator.pushNamed(context, 'EditHRProfilePage');
            },
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,//fontFamily: appFont
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

class ProjectLink {
  int projectLinkId;
  String projectName;
  String projectUrl;

  ProjectLink({
    required this.projectLinkId,
    required this.projectName,
    required this.projectUrl,
  });

  factory ProjectLink.fromJson(Map<String, dynamic> json) {
    return ProjectLink(
      projectLinkId: json['projectLinkId'],
      projectName: json['projectName'],
      projectUrl: json['projectUrl'],
    );
  }
}

class Course {
  int courseId;
  String courseName;

  Course({
    required this.courseId,
    required this.courseName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      courseName: json['courseName'],
    );
  }
}

class Skill {
  int skillId;
  String skillName;
  String skillLevel;

  Skill({
    required this.skillId,
    required this.skillName,
    required this.skillLevel,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      skillId: json['skillId'],
      skillName: json['skillName'],
      skillLevel: json['skillLevel'],
    );
  }
}

class SiteLink {
  int siteLinkId;
  String linkUrl;

  SiteLink({
    required this.siteLinkId,
    required this.linkUrl,
  });

  factory SiteLink.fromJson(Map<String, dynamic> json) {
    return SiteLink(
      siteLinkId: json['linkId'],
      linkUrl: json['linkUrl'],
    );
  }
}
