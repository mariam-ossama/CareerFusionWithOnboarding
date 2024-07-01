import 'dart:convert';
import 'dart:io';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/models/post.dart';
import 'package:career_fusion/models/timeline_item.dart';
import 'package:career_fusion/screens/HR_screens/hr_post_candidates.dart';
import 'package:career_fusion/screens/HR_screens/open_positions_details_screen.dart';
import 'package:career_fusion/screens/candidate_screens/user_profile_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_open_position_card.dart';
import 'package:career_fusion/widgets/timeline_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/user_profile_model.dart';

class UserDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  UserDetailPage({required this.userData});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  List<TimelineItem> timelineItems = [];
  DateTime? startDate;
  DateTime? endDate;
  List<Post> hrPosts = [];
  List<Position> positions = [];

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

  UserProfile? userProfile;

  // Controllers for the form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _followersCountController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectUrlController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController skillNameController = TextEditingController();
  final TextEditingController skillLevelController = TextEditingController();
  final TextEditingController linkUrlController = TextEditingController();

  List<TextEditingController> _skillNameControllers = [];
  List<TextEditingController> _skillLevelControllers = [];
  List<TextEditingController> _courseControllers = [];
  List<TextEditingController> _projectNameControllers = [];
  List<TextEditingController> _projectUrlControllers = [];
  List<TextEditingController> _siteLinkControllers = [];
  List<TextEditingController> _courseNameControllers = [];
  List<TextEditingController> _siteLinkUrlControllers = [];

  @override
  void initState() {
    super.initState();
    buildUserProfile();
    fetchProfilePicture();
    fetchUserData();
    fetchTimelineData(widget.userData['userId']); // Use userId from userData
    fetchHRPosts();
    fetchPositions();
  }

  void handleCheckboxChange(bool? newValue, int index) async {
    setState(() {
      timelineItems[index].isChecked =
          newValue ?? false; // Update the isChecked property
    });

    int? stageId = timelineItems[index].stageId;

    try {
      final response = await http.put(
        Uri.parse(
            '${baseUrl}/HiringTimeline/UpdateTimelineStage/${widget.userData['userId']}/$stageId'),
        body: jsonEncode({
          'stageId': stageId,
          'status': newValue ?? false, // Update the status field
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Status updated successfully');
      } else {
        throw Exception('Failed to update status: ${response.body}');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> fetchTimelineData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/HiringTimeline/GetTimelinesForUser/$userId'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          timelineItems = responseData.map((itemData) {
            return TimelineItem.fromJson(itemData);
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch timeline data: ${response.body}');
      }
    } catch (e) {
      throw 'Error fetching timeline data: $e';
    }
  }

  void deleteTimelineItem(int stageId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '${baseUrl}/HiringTimeline/DeleteTimelineStage/${widget.userData['userId']}/$stageId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Timeline item deleted successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timeline item deleted successfully')),
        );

        setState(() {
          timelineItems.removeWhere((item) => item.stageId == stageId);
        });
      } else {
        throw Exception('Failed to delete timeline item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting timeline item: $e');
    }
  }

  Future<void> fetchHRPosts() async {
    final apiUrl = '${baseUrl}/Post/HrPost/${widget.userData['userId']}';
    final response = await http.get(Uri.parse(apiUrl));
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      List<Post> loadedPosts = [];
      for (var postJson in responseData) {
        Post post = Post.fromJson(postJson);
        await post.fetchImageUrls();
        await post.fetchFileUrls();
        loadedPosts.add(post);
      }
      setState(() {
        hrPosts = loadedPosts;
      });
    } else {
      throw Exception('Failed to load HR posts');
    }
  }

  Future<void> fetchPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    final url = '${baseUrl}/jobform/OpenPos/${widget.userData['userId']}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received positions data: $data'); // Debug print
        final List<Position> fetchedPositions =
            data.map((item) => Position.fromJson(item)).toList();
        print('Parsed positions: $fetchedPositions'); // Debug print
        setState(() {
          positions = fetchedPositions;
        });
      } catch (e) {
        print('Error parsing positions data: $e');
      }
    } else {
      print('Failed to fetch positions: ${response.statusCode}');
    }
  }

  Future<void> uploadProfilePicture() async {
    try {
      final url =
          '${baseUrl}/UserProfile/upload-profile-picture/${widget.userData['userId']}';
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
    try {
      final url =
          '${baseUrl}/UserProfile/${widget.userData['userId']}/profile-picture';
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);
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
      final url =
          '${baseUrl}/UserProfile/${widget.userData['userId']}';
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
    final url =
        '${baseUrl}/UserProfile/${widget.userData['userId']}/skills/$skillId';
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
        '${baseUrl}/UserProfile/${widget.userData['userId']}/sitelinks/$siteLinkId';
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
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final directory = await getExternalStorageDirectory();
        final downloadsPath = '${directory!.path}/Download';
        final filePath = '$downloadsPath/CV.docx';
        final file = File(filePath);

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

  Widget buildUserProfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
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
                        final url =
                            '${baseUrl}/UserProfile/${widget.userData['userId']}/courses/${course.courseId}';
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
          Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
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
                        final url =
                            '${baseUrl}/UserProfile/${widget.userData['userId']}/projectlinks/${project.projectId}';
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
          Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
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
          Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
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
                        /*try {
      // Make an HTTP GET request to download the CV
      final response = await http.get(Uri.parse('http://10.0.2.2:5266/api/UserProfile/download-file'));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Get the application directory
        final directory = await getApplicationDocumentsDirectory();
        
        // Write the bytes of the downloaded file to a file in the application directory
        final filePath = '${directory.path}/CV.docx';
        final file = File(filePath);
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
    }*/
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
          /*CustomButton(
            text: 'Edit your profile',
            onPressed: () {
              Navigator.pushNamed(context, 'EditUserProfilePage');
            },
          ),*/
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      // Construct the updated data map
      final Map<String, dynamic> updatedData = {
        'userId': userId, // Always include the userId in the update request
        'userName': _usernameController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'skills': _skillNameControllers.asMap().entries.map((entry) {
          int index = entry.key;
          String skillName = entry.value.text;
          String skillLevel = _skillLevelControllers[index].text;
          if (index < userProfile!.skills.length &&
              userProfile!.skills[index].skillId != null) {
            // Check if skillId exists and is not null
            // Update existing skill
            return {
              'skillId': userProfile!.skills[index].skillId,
              'skillName': skillName,
              'skillLevel': skillLevel,
            };
          } else {
            // Add new skill
            return {
              'skillName': skillName,
              'skillLevel': skillLevel,
            };
          }
        }).toList(),

// For courses
        'courses': _courseControllers.asMap().entries.map((entry) {
          int index = entry.key;
          String courseName = entry.value.text;
          if (index < userProfile!.courses.length &&
              userProfile!.courses[index].courseId != null) {
            // Check if courseId exists and is not null
            // Update existing course
            return {
              'courseId': userProfile!.courses[index].courseId,
              'courseName': courseName,
            };
          } else {
            // Add new course
            return {
              'courseName': courseName,
            };
          }
        }).toList(),

// For projects
        'projectLinks': _projectNameControllers.asMap().entries.map((entry) {
          int index = entry.key;
          String projectName = entry.value.text;
          String projectUrl = _projectUrlControllers[index].text;
          if (index < userProfile!.projectLinks.length &&
              userProfile!.projectLinks[index].projectLinkId != null) {
            // Check if projectLinkId exists and is not null
            // Update existing project
            return {
              'projectLinkId': userProfile!.projectLinks[index].projectLinkId,
              'projectName': projectName,
              'projectUrl': projectUrl,
            };
          } else {
            // Add new project
            return {
              'projectName': projectName,
              'projectUrl': projectUrl,
            };
          }
        }).toList(),

// For siteLinks
        'siteLinks': _siteLinkControllers.asMap().entries.map((entry) {
          int index = entry.key;
          String linkUrl = entry.value.text;
          if (index < userProfile!.siteLinks.length &&
              userProfile!.siteLinks[index].siteLinkId != null) {
            // Check if siteLinkId exists and is not null
            // Update existing site link
            return {
              'linkId': userProfile!.siteLinks[index].siteLinkId,
              'linkUrl': linkUrl,
            };
          } else {
            // Add new site link
            return {
              'linkUrl': linkUrl,
            };
          }
        }).toList(),
      };

      // Send the update request
      final response = await http.put(
        Uri.parse(
            '${baseUrl}/UserProfile/${widget.userData['userId']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(updatedData),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('User profile updated successfully.');
      } else {
        print(
            'Failed to update user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  void _addSkillField() {
    setState(() {
      _skillNameControllers.add(TextEditingController());
      _skillLevelControllers.add(TextEditingController());
    });
  }

  void _addProjectField() {
    setState(() {
      _projectNameControllers.add(TextEditingController());
      _projectUrlControllers.add(TextEditingController());
    });
  }

  void _addCourseField() {
    setState(() {
      _courseControllers.add(TextEditingController());
    });
  }

  void _addSiteLinkField() {
    setState(() {
      _siteLinkControllers.add(TextEditingController());
    });
  }

  Widget buildEditUserProfile() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEditableField('Username', _usernameController),
            SizedBox(
              height: 10,
            ),
            _buildEditableField('Title', _titleController),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            _buildEditableField('Description', _descriptionController),
            SizedBox(
              height: 10,
            ),
            _buildEditableField('Address', _addressController),
            SizedBox(
              height: 10,
            ),
            Text('Skills', style: Theme.of(context).textTheme.headline5),
            for (int i = 0; i < _skillNameControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillNameControllers[i],
                      decoration: InputDecoration(labelText: 'Skill Name'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _skillLevelControllers[i],
                      decoration: InputDecoration(labelText: 'Skill Level'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: mainAppColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _skillNameControllers.removeAt(i);
                        _skillLevelControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            TextButton(
              onPressed: _addSkillField,
              child: Text('Add More Skills'),
            ),

            SizedBox(
              height: 10,
            ),
            // Similar for courses, projects, and siteLinks
            Text('Courses', style: Theme.of(context).textTheme.headline5),
            for (int i = 0; i < _courseControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _courseControllers[i],
                      decoration: InputDecoration(labelText: 'Course'),
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: mainAppColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _courseControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            TextButton(
              onPressed: _addCourseField,
              child: Text(
                'Add More Courses',
                style: TextStyle(
                  color: mainAppColor, //fontFamily: appFont
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Text('Projects', style: Theme.of(context).textTheme.headline5),
            for (int i = 0; i < _projectNameControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _projectNameControllers[i],
                      decoration: InputDecoration(labelText: 'Project Name'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _projectUrlControllers[i],
                      decoration: InputDecoration(labelText: 'Project URL'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        _projectNameControllers.removeAt(i);
                        _projectUrlControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            TextButton(
              onPressed: _addProjectField,
              child: Text('Add More Projects'),
            ),
            SizedBox(height: 10),

            Text('Sitelinks', style: Theme.of(context).textTheme.headline5),
            for (int i = 0; i < _siteLinkControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _siteLinkControllers[i],
                      decoration: InputDecoration(labelText: 'Sitelink'),
                    ),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: mainAppColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _siteLinkControllers.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            TextButton(
              onPressed: _addSiteLinkField,
              child: Text(
                'Add More Sitelinks',
                style: TextStyle(
                  color: mainAppColor, //fontFamily: appFont
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            /*ElevatedButton(
                      child: Text('Save Changes'),
                      onPressed: () {
                        _updateUserProfile();
                      },
                    ),*/
            CustomButton(
              text: 'Save Changes',
              onPressed: () {
                _updateUserProfile();
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserTimeline() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: timelineItems.asMap().entries.map((entry) {
          final int index = entry.key;
          final TimelineItem item = entry.value;

          return CustomTimelineTile(
            isFirst: index == 0,
            isLast: index == timelineItems.length - 1,
            isPast: item.isChecked,
            eventCard: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: item.description,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(item.startDate, style: TextStyle(color: Colors.white)),
                Text(item.endDate, style: TextStyle(color: Colors.white)),
              ],
            ),
            onDelete: () {
              deleteTimelineItem(item.stageId!);
            },
            onEdit: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController descriptionController =
                      TextEditingController(text: item.description);

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text('Enter Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: descriptionController,
                              decoration:
                                  InputDecoration(labelText: 'New Description'),
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text(
                                  'Start Date: ${startDate?.toString() ?? 'Select Start Date'}'),
                              onTap: () async {
                                final DateTime? pickedStartDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: startDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedStartDate != null) {
                                  setState(() {
                                    startDate = pickedStartDate;
                                  });
                                }
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text(
                                  'End Date: ${endDate?.toString() ?? 'Select End Date'}'),
                              onTap: () async {
                                final DateTime? pickedEndDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: endDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedEndDate != null) {
                                  setState(() {
                                    endDate = pickedEndDate;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              String newDescription =
                                  descriptionController.text;
                              String newStartDate = startDate != null
                                  ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                      .format(startDate!)
                                  : "";
                              String newEndDate = endDate != null
                                  ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                      .format(endDate!)
                                  : "";

                              try {
                                if (item.stageId != null) {
                                  final response = await http.put(
                                    Uri.parse(
                                        '${baseUrl}/HiringTimeline/UpdateTimelineStage/${widget.userData['userId']}/${item.stageId}'),
                                    body: jsonEncode({
                                      'stageId': item.stageId,
                                      'description': newDescription,
                                      'startTime': newStartDate,
                                      'endTime': newEndDate,
                                      'updatedStage': 'someValue',
                                    }),
                                    headers: <String, String>{
                                      'Content-Type':
                                          'application/json; charset=UTF-8',
                                    },
                                  );
                                  if (response.statusCode == 200) {
                                    print('Timeline item updated successfully');
                                    setState(() {
                                      timelineItems[index] = TimelineItem(
                                        stageId: item.stageId,
                                        description: newDescription,
                                        startDate: newStartDate,
                                        endDate: newEndDate,
                                      );
                                    });
                                    fetchTimelineData(
                                        widget.userData['userId']);
                                  } else {
                                    throw Exception(
                                        'Failed to update timeline item: ${response.body}');
                                  }
                                } else {
                                  throw Exception('stageId is null');
                                }
                              } catch (e) {
                                print('Error updating timeline item: $e');
                              }

                              Navigator.of(context).pop();
                            },
                            child: Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            onCheckboxChanged: (newValue) =>
                handleCheckboxChange(newValue, index),
            item: item,
          );
        }).toList(),
      ),
    );
  }

  Widget buildUserPosts() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: hrPosts.length,
          itemBuilder: (context, index) {
            final post = hrPosts[index];
            return GestureDetector(
              onTap: () {
                ///////////////////
              },
              child: Card(
                shadowColor: Colors.grey[500],
                color: Color.fromARGB(255, 235, 233, 255),
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (post.userProfilePicturePath != null &&
                              post.userProfilePicturePath!.isNotEmpty)
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                'http://10.0.2.2:5266${post.userProfilePicturePath}',
                              ),
                            ),
                          SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            child: Text(
                              post.userFullName,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        post.content,
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 8.0),
                      if (post.imageUrls != null &&
                          post.imageUrls!.isNotEmpty) ...[
                        for (var imageUrl in post.imageUrls!)
                          if (imageUrl != 'Error fetching image URL') ...[
                            SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: Image.network(
                                  imageUrl,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text('Image not available');
                                  },
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                      ],
                      if (post.fileUrls != null &&
                          post.fileUrls!.isNotEmpty) ...[
                        for (var fileUrl in post.fileUrls!)
                          if (fileUrl != 'Error fetching file URL') ...[
                            SizedBox(height: 10),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.description,
                                          color: mainAppColor,
                                        ),
                                        SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            fileUrl,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: appFont,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                      ],
                      Center(
                        child: Text(
                          'Posted on: ${post.createdAt}',
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                              fontFamily: appFont,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      CustomButton(
                        text: 'Applied Candidates',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HRPostCandidatesPage(postId: post.postId),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget buildUserPositions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: positions.length,
        itemBuilder: (context, index) {
          return PositionCard(
            position: positions[index],
            onTap: () {
              final jobId = positions[index].jobId;
              if (jobId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PositionDetailsPage(
                        userId: widget.userData['userId'],
                        jobId: jobId,
                        jobTitle: positions[index].title),
                  ),
                );
              } else {
                // Handle the case where jobId is null
                print('Job ID is null for position at index $index');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDynamicList(String title, List<dynamic> items,
      List<TextEditingController> controllers, Function deleteFunction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: appFont)),
        ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            TextEditingController controller = controllers[index];
            return ListTile(
              title: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Item ${index + 1}',
                  border: OutlineInputBorder(),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: mainAppColor),
                onPressed: () => deleteFunction(items[index].id),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.userData['userName']} Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: mainAppColor,
          bottom: TabBar(
            indicatorColor: secondColor,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.person_2_outlined,
                  color: Colors.white,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                ),
              ),
              Tab(
                  icon: Icon(
                Icons.timeline_outlined,
                color: Colors.white,
              )),
              Tab(
                  icon: Icon(
                Icons.post_add_outlined,
                color: Colors.white,
              )),
              Tab(
                  icon: Icon(
                Icons.announcement_outlined,
                color: Colors.white,
              )),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildUserProfile(),
            buildEditUserProfile(),
            buildUserTimeline(),
            //Center(child: Text('Posts for ${widget.userData['userName']}')),
            buildUserPositions(),
            /*Center(
                child:
                    Text('Announcements for ${widget.userData['userName']}')),*/
            buildUserPosts(),
          ],
        ),
      ),
    );
  }
}

class ProjectLinkA {
  int projectLinkId;
  String projectName;
  String projectUrl;

  ProjectLinkA({
    required this.projectLinkId,
    required this.projectName,
    required this.projectUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectLinkId': projectLinkId,
      'projectName': projectName,
      'projectUrl': projectUrl,
    };
  }

  factory ProjectLinkA.fromJson(Map<String, dynamic> json) {
    return ProjectLinkA(
      projectLinkId: json[
          'projectLinkId'], // Corrected from 'projectLinkId' to 'projectId'
      projectName: json['projectName'],
      projectUrl:
          json['projectUrl'], // Corrected from 'projectUrl' to 'projectURL'
    );
  }
}

class CourseA {
  int courseId;
  String courseName;

  CourseA({
    required this.courseId,
    required this.courseName,
  });

  // Define the toJson method to convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
    };
  }

  factory CourseA.fromJson(Map<String, dynamic> json) {
    return CourseA(
      courseId: json['courseId'],
      courseName: json['courseName'],
    );
  }
}

class SkillA {
  int skillId;
  String? skillName;
  String? skillLevel;

  SkillA({
    required this.skillId,
    this.skillName,
    this.skillLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'skillLevel': skillLevel,
    };
  }

  factory SkillA.fromJson(Map<String, dynamic> json) {
    return SkillA(
      skillId: json['skillId'],
      skillName: json['skillName'],
      skillLevel: json['skillLevel'],
    );
  }
}

class SiteLinkA {
  int siteLinkId;
  String linkUrl;

  SiteLinkA({
    required this.siteLinkId,
    required this.linkUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'linkId': siteLinkId,
      'linkUrl': linkUrl,
    };
  }

  factory SiteLinkA.fromJson(Map<String, dynamic> json) {
    return SiteLinkA(
      siteLinkId: json['linkId'],
      linkUrl: json['linkUrl'],
    );
  }
}
