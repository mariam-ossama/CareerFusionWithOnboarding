import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserProfilePage> {
  File? _image;
  String? _profilePictureUrl;
  String? _userName;
  String? _fullName;
  String? _title;
  String? _profilePicturePath;
  String? _description;
  String? _address;
  List<Project> _projects = [];
  List<Skill> _skills = [];
  List<Course> _courses = [];
  List<SiteLink> _siteLinks = [];

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
    fetchUserData();
  }

  Future<void> uploadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      final url =
          '${baseUrl}/UserProfile/upload-profile-picture/${userId}';
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            _image!.path,
            //contentType: MediaType('image', 'webp'),
          ),
        );

      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = jsonDecode(responseBody);
        var imagePath = responseData['imagePath'];
        // Handle imagePath as needed, update UI or perform other actions
      } else {
        print('Failed to upload profile picture: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    }
  }

  Future<void> fetchProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      final url =
          '${baseUrl}/UserProfile/${userId}/profile-picture';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _profilePictureUrl = responseBody['profilePictureUrl'];
        });
      } else {
        print('Failed to fetch profile picture: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      final url = '${baseUrl}/UserProfile/${userId}';
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _userName = responseBody['userName'];
          _fullName = responseBody['fullName'];
          _title = responseBody['title'];
          _profilePicturePath = responseBody['profilePicturePath'];
          _description = responseBody['description'];
          _address = responseBody['address'];
          _projects = (responseBody['projectLinks'] as List)
              .map((project) => Project(
                    projectId:
                        project['projectLinkId'], // Include projectId here
                    name: project['projectName'],
                    link: project['projectUrl'],
                  ))
              .toList();
          _courses = (responseBody['courses'] as List)
              .map((course) => Course(
                  courseId: course['courseId'],
                  courseName: course['courseName']))
              .toList();
          _skills = (responseBody['skills'] as List)
              .map((skill) => Skill(
                    skillId: skill['skillId'],
                    name: skill['skillName'],
                    level: skill['skillLevel'],
                  ))
              .toList();
          _siteLinks = (responseBody['siteLinks'] as List)
              .map((siteLink) => SiteLink(
                    linkId: siteLink['linkId'].toString(),
                    linkUrl: siteLink['linkUrl'],
                  ))
              .toList();
        });
      } else {
        print('Failed to fetch user data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> deleteSkill(int skillId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = '${baseUrl}/UserProfile/$userId/skills/$skillId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _skills.removeWhere((skill) => skill.skillId == skillId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Skill deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete skill')),
        );
      }
    } catch (e) {
      print('Error deleting skill: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while deleting the skill')),
      );
    }
  }

  Future<void> deleteSiteLink(String siteLinkId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/UserProfile/$userId/sitelinks/$siteLinkId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _siteLinks.removeWhere((siteLink) => siteLink.linkId == siteLinkId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Site link deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete site link')),
        );
      }
    } catch (e) {
      print('Error deleting site link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while deleting the site link')),
      );
    }
  }

  Future<void> downloadCV() async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl}/UserProfile/download-file'));

      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final downloadsPath = '${directory!.path}/Download';
        final filePath = '$downloadsPath/CV.docx';
        final file = File(filePath);
        print(filePath);

        if (!Directory(downloadsPath).existsSync()) {
          Directory(downloadsPath).createSync(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CV template downloaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download CV')),
        );
      }
    } catch (e) {
      print('Error downloading CV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while downloading CV')),
      );
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
      body: ListView(
        children: [
          SizedBox(
            height: 35,
          ),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey,
                  backgroundImage: _profilePictureUrl != null
                      ? NetworkImage(_profilePictureUrl!)
                      : null,
                  child: _profilePictureUrl == null
                      ? Icon(Icons.person, size: 60)
                      : null,
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
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                          });

                          // Upload the selected image
                          await uploadProfilePicture();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              _userName ?? 'Username',
              style: TextStyle(
                  fontSize: 20,
                  //fontFamily: appFont,
                  color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              _title ?? 'Title',
              style: TextStyle(
                  fontSize: 20,
                  //fontFamily: appFont,
                  color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          /*Container(
            width: 250,
            child: Card(
              borderOnForeground: true,
              color: Colors.grey[300],
              shadowColor: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10,),
                  Text('Description', style: TextStyle(fontSize: 20),),
                  SizedBox(width: 230,),
                  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_rounded)),
                ]),
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: secondColor,
              // Card content here
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Description',
                      style: TextStyle(
                          //fontFamily: appFont,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _description ?? 'No description available',
                          style: TextStyle(//fontFamily: appFont
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Additional content
                ],
              ),
            ),
          ),
          Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: secondColor,
              // Card content here
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Address',
                      style: TextStyle(
                          //fontFamily: appFont,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _address ?? 'No address',
                          style: TextStyle(//fontFamily: appFont
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Additional content
                ],
              ),
            ),
          ),
          Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          if (_courses.isNotEmpty)
            Center(
                child: Text(
              'My Courses',
              style: TextStyle(
                  //fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index]; // Get the course object
                return Card(
                  color: secondColor,
                  child: ListTile(
                    title: Text(
                      course.courseName,
                      style: TextStyle(
                          //fontFamily: appFont,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: mainAppColor),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId = prefs.getString('userId');
                        final url =
                            '${baseUrl}/UserProfile/$userId/courses/${course.courseId}';
                        try {
                          final response = await http.delete(Uri.parse(url));
                          print(response.body);
                          print(response.statusCode);
                          if (response.statusCode == 200) {
                            setState(() {
                              _courses.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Course deleted successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to delete course')),
                            );
                          }
                        } catch (e) {
                          print('Error deleting course: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'An error occurred while deleting the course')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_courses.isNotEmpty)
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          if (_projects.isNotEmpty)
            Center(
                child: Text(
              'My Projects',
              style: TextStyle(
                  //fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index]; // Get the project object
                return Card(
                  color: secondColor,
                  child: ListTile(
                    title: Text(
                      project.name,
                      style: TextStyle(
                          //fontFamily: appFont,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      project.link,
                      style: TextStyle(//fontFamily: appFont
                          ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: mainAppColor,
                      ),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId = prefs.getString('userId');
                        final url =
                            '${baseUrl}/UserProfile/$userId/projectlinks/${project.projectId}';
                        try {
                          final response = await http.delete(Uri.parse(url));
                          print(response.body);
                          print(response.statusCode);
                          if (response.statusCode == 200) {
                            setState(() {
                              _projects.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Project deleted successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to delete project')),
                            );
                          }
                        } catch (e) {
                          print('Error deleting project: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'An error occurred while deleting the project')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_projects.isNotEmpty)
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          if (_skills.isNotEmpty)
            Center(
                child: Text(
              'My Skills',
              style: TextStyle(
                  //fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _skills.length,
              itemBuilder: (context, index) {
                final skill = _skills[index]; // Get the skill object
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: secondColor,
                    child: ListTile(
                      title: Text(
                        skill.name,
                        style: TextStyle(
                            //fontFamily: appFont,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        skill.level,
                        style: TextStyle(//fontFamily: appFont
                            ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: mainAppColor),
                        onPressed: () {
                          // Call deleteSkill method when the delete button is pressed
                          deleteSkill(skill.skillId);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_skills.isNotEmpty)
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          if (_siteLinks.isNotEmpty)
            Center(
                child: Text(
              'My Sitelinks',
              style: TextStyle(
                  //fontFamily: appFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _siteLinks.length,
              itemBuilder: (context, index) {
                final siteLink = _siteLinks[index];
                return Card(
                  color: secondColor,
                  child: ListTile(
                    title: Text(
                      siteLink.linkUrl,
                      style: TextStyle(
                          //fontFamily: appFont,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: mainAppColor),
                      onPressed: () {
                        // Call deleteSiteLink method when the delete button is pressed
                        deleteSiteLink(siteLink.linkId);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_siteLinks.isNotEmpty)
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: secondColor,
              // Card content here
              child: Column(
                children: [
                  ListTile(
                    leading: IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color: mainAppColor,
                      ), // Icon for download
                      onPressed: () async {
                        downloadCV();
                      },
                    ),
                    title: Text('My CV',
                        style: TextStyle(
                            //fontFamily: appFont,
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CV',
                            style: TextStyle(//fontFamily: appFont
                                )),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.file_upload,
                        color: mainAppColor,
                      ), // Icon for upload
                      onPressed: () async {
                        try {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'docx'],
                          );
                          if (result != null) {
                            File file = File(result.files.single.path!);

                            var request = http.MultipartRequest(
                                'POST',
                                Uri.parse(
                                    '${baseUrl}/UserProfile/upload-file'));
                            request.files.add(
                              await http.MultipartFile.fromPath(
                                'file',
                                file.path,
                                //contentType: MediaType('application', 'docx'), // Adjust content type if needed
                              ),
                            );
                            var streamedResponse = await request.send();
                            if (streamedResponse.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('CV uploaded successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to upload CV')),
                              );
                            }
                          }
                        } catch (e) {
                          print('Error uploading CV: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'An error occurred while uploading CV')),
                          );
                        }
                      },
                    ),
                  ),

                  // Additional content
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CustomButton(
            text: 'Edit your profile',
            onPressed: () {
              Navigator.pushNamed(context, 'EditUserProfilePage');
            },
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class Project {
  final int projectId; // Add projectId property
  final String name;
  final String link;

  Project({required this.projectId, required this.name, required this.link});
}

class Skill {
  final int skillId;
  final String name;
  final String level;

  Skill({required this.skillId, required this.name, required this.level});
}

class SiteLink {
  final String linkId;
  final String linkUrl;

  SiteLink({required this.linkId, required this.linkUrl});
}

class Course {
  final int courseId;
  final String courseName;

  Course({required this.courseId, required this.courseName});
}
