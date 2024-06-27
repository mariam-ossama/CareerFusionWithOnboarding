import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_profile_model.dart';

// ... Other imports ...

// Define your UserProfile and related models here...

Future<UserProfile> fetchUserProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  final response = await http.get(
    Uri.parse('http://10.0.2.2:5266/api/UserProfile/$userId'),
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

class EditUserProfilePage extends StatefulWidget {
  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
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

    // Initialize your controllers with empty strings to avoid null errors.
    _usernameController.text;
    _titleController.text;
    _descriptionController.text;
    _addressController.text;

    fetchUserProfile().then((profile) {
      if (!mounted) return; // Check if the widget is still in the tree.

      setState(() {
        userProfile = profile;

        // Initialize controllers with fetched data
        _usernameController.text = userProfile!.username;
        _titleController.text = userProfile!.title ?? '';
        _descriptionController.text = userProfile!.description;
        _addressController.text = userProfile!.address;
        _followersCountController.text = userProfile!.followersCount.toString();

        // Initialize the list of TextEditingControllers for dynamic fields
        _skillNameControllers = userProfile!.skills
            .map((skill) => TextEditingController(text: skill.skillName))
            .toList();
        _skillLevelControllers = userProfile!.skills
            .map((skill) => TextEditingController(text: skill.skillLevel))
            .toList();
        _courseControllers = userProfile!.courses
            .map((course) => TextEditingController(text: course.courseName))
            .toList();

        // Initialize project controllers based on the number of projects
        _projectNameControllers = userProfile!.projectLinks.map((project) {
          return TextEditingController(text: project.projectName);
        }).toList();

        _projectUrlControllers = userProfile!.projectLinks.map((project) {
          return TextEditingController(text: project.projectUrl);
        }).toList();

        _siteLinkControllers = userProfile!.siteLinks
            .map((siteLink) => TextEditingController(text: siteLink.linkUrl))
            .toList();
      });
    }).catchError((error) {
      // Handle any errors here
      print('Failed to load user profile: $error');
    });
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

  // Add your fetchUserProfile function here

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
        Uri.parse('http://10.0.2.2:5266/api/UserProfile/$userId'),
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

  Future<void> _deleteSkill(int skillId) async {
    // TODO: Make API call to delete the skill
  }

  // Similar functions for courses, projects, and siteLinks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
              //fontFamily: appFont,
              color: Colors.white),
        ),
        backgroundColor: mainAppColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () {
              _updateUserProfile();
            },
          ),
        ],
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    Text('Skills',
                        style: Theme.of(context).textTheme.headline5),
                    for (int i = 0; i < _skillNameControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _skillNameControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Skill Name'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _skillLevelControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Skill Level'),
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
                    Text('Courses',
                        style: Theme.of(context).textTheme.headline5),
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
                    Text('Projects',
                        style: Theme.of(context).textTheme.headline5),
                    for (int i = 0; i < _projectNameControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _projectNameControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Project Name'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _projectUrlControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Project URL'),
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

                    Text('Sitelinks',
                        style: Theme.of(context).textTheme.headline5),
                    for (int i = 0; i < _siteLinkControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _siteLinkControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Sitelink'),
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

  // Dispose controllers when the state is disposed
  @override
  void dispose() {
    _skillNameControllers.forEach((controller) => controller.dispose());
    _skillLevelControllers.forEach((controller) => controller.dispose());
    _projectNameControllers.forEach((controller) => controller.dispose());
    _projectUrlControllers.forEach((controller) => controller.dispose());
    _courseNameControllers.forEach((controller) => controller.dispose());
    _siteLinkUrlControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

// Run the app
class ProjectLink {
  int projectLinkId;
  String projectName;
  String projectUrl;

  ProjectLink({
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

  factory ProjectLink.fromJson(Map<String, dynamic> json) {
    return ProjectLink(
      projectLinkId: json[
          'projectLinkId'], // Corrected from 'projectLinkId' to 'projectId'
      projectName: json['projectName'],
      projectUrl:
          json['projectUrl'], // Corrected from 'projectUrl' to 'projectURL'
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

  // Define the toJson method to convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      courseName: json['courseName'],
    );
  }
}

class Skill {
  int skillId;
  String? skillName;
  String? skillLevel;

  Skill({
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

  Map<String, dynamic> toJson() {
    return {
      'linkId': siteLinkId,
      'linkUrl': linkUrl,
    };
  }

  factory SiteLink.fromJson(Map<String, dynamic> json) {
    return SiteLink(
      siteLinkId: json['linkId'],
      linkUrl: json['linkUrl'],
    );
  }
}
