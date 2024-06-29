import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/HR_screens/hr_profile_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// ... Other imports ...

// Define your UserProfile and related models here...

class UserProfile {
  String username;
  String fullName;
  String? title;
  String profilePicturePath;
  int followersCount;
  String description;
  String address;
  List<Projects> projects;
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
    required this.projects,
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
      projects: (json['projects'] as List<dynamic>?)
              ?.map((x) => Projects.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
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

class EditHRProfilePage extends StatefulWidget {
  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditHRProfilePage> {
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

  List<TextEditingController> _skillControllers = [];
  List<TextEditingController> _courseControllers = [];
  List<TextEditingController> _projectControllers = [];
  List<TextEditingController> _siteLinkControllers = [];
  List<TextEditingController> _projectNameControllers = [];
  List<TextEditingController> _projectUrlControllers = [];
  List<TextEditingController> _skillNameControllers = [];
  List<TextEditingController> _skillLevelControllers = [];
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
    // Initialize lists if necessary
    _skillControllers;
    _courseControllers;
    _projectControllers;
    _siteLinkControllers;

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
        _skillControllers = userProfile!.skills
            .map((skill) => TextEditingController(text: skill.skillName))
            .toList();
        _courseControllers = userProfile!.courses
            .map((course) => TextEditingController(text: course.courseName))
            .toList();
        _projectControllers = userProfile!.projects
            .map((project) => TextEditingController(text: project.projectName))
            .toList();
        _siteLinkControllers = userProfile!.siteLinks
            .map((siteLink) => TextEditingController(text: siteLink.linkUrl))
            .toList();
        _projectControllers = userProfile!.projectLinks
            .map((projectLink) =>
                TextEditingController(text: projectLink.projectName))
            .toList();
      });
    }).catchError((error) {
      // Handle any errors here
      print('Failed to load user profile: $error');
    });
  }

  void _addSkillField() {
    //var newSkillId = userProfile.skills.length + 1;
    setState(() {
      var newSkillId = userProfile!.skills.length + 1;
      _skillNameControllers.add(skillNameController);
      _skillLevelControllers.add(skillLevelController);
      userProfile!.skills.add(Skill(
        skillId: newSkillId,
        skillName: skillNameController.text,
        skillLevel: skillLevelController.text,
      ));
      _skillNameControllers.add(TextEditingController());
      _skillLevelControllers.add(TextEditingController());
    });
  }

  void _addProjectField() {
    setState(() {
      var newProjectId = userProfile!.projects.length + 1;
      userProfile!.projects.add(Projects(
        projectId: newProjectId,
        projectName: projectNameController.text,
        projectURL: projectUrlController.text,
      ));
      _projectNameControllers.add(TextEditingController());
      _projectUrlControllers.add(TextEditingController());
    });
  }

  void _addCourseField() {
    setState(() {
      var newCourseId = userProfile!.courses.length + 1;
      userProfile!.courses.add(Course(
        courseId: newCourseId,
        courseName: courseNameController.text,
      ));
      _courseNameControllers.add(TextEditingController());
    });
  }

  void _addSiteLinkField() {
    setState(() {
      // Add a new SiteLink object
      userProfile!.siteLinks.add(SiteLink(
        siteLinkId: userProfile!.siteLinks.length +
            1, // Assuming siteLinkId is the index+1
        linkUrl: '',
      ));
      // Add a new TextEditingController for the site link URL
      _siteLinkControllers.add(TextEditingController());
    });
  }

  // Add your fetchUserProfile function here

  Future<void> _updateUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    // This map will be populated with the current state of your form.
    final Map<String, dynamic> updatedData = {
      'title': _titleController.text,
      /*'profilePicturePath':
        '/path/to/new/picture.jpg', */ // This should be updated to the new path after upload
      'followersCount': int.parse(_followersCountController
          .text), // Assuming you have a controller for this
      'description': _descriptionController.text,
      'address': _addressController.text,
      'projects': userProfile!.projects.map((project) {
        return {
          'projectId': project.projectId,
          'projectName': project.projectName,
          'projectURL': project.projectURL,
        };
      }).toList(),
      'projectLinks': userProfile!.projectLinks.map((projectLink) {
        return {
          'projectLinkId': projectLink.projectLinkId,
          'projectName': projectLink.projectName,
          'projectUrl': projectLink.projectUrl,
        };
      }).toList(),
      'courses': userProfile!.courses.map((course) {
        return {
          'courseId': course.courseId,
          'courseName': course.courseName,
        };
      }).toList(),
      'skills': userProfile!.skills.map((skill) {
        return {
          'skillId': skill.skillId,
          'skillName': skill.skillName,
          'skillLevel': skill.skillLevel,
        };
      }).toList(),
      'siteLinks': userProfile!.siteLinks.map((siteLink) {
        return {
          'linkId': siteLink.siteLinkId,
          'linkUrl': siteLink.linkUrl,
        };
      }).toList(),
    };

    try {
      final response = await http.put(
        Uri.parse('${baseUrl}/UserProfile/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HRProfilePage()),
        );
        print('User profile updated successfully.');
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        print(
            'Failed to update user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // If we encountered an error, handle it.
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
            icon: Icon(Icons.save),
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
                    // Text('Skills',
                    //     style: Theme.of(context).textTheme.headline5),
                    // for (int i = 0; i < _skillNameControllers.length; i++)
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _skillNameControllers[i],
                    //           decoration:
                    //               InputDecoration(labelText: 'Skill Name'),
                    //         ),
                    //       ),
                    //       SizedBox(width: 16),
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _skillLevelControllers[i],
                    //           decoration:
                    //               InputDecoration(labelText: 'Skill Level'),
                    //         ),
                    //       ),
                    //       IconButton(
                    //         icon: Icon(Icons.remove_circle_outline),
                    //         onPressed: () {
                    //           setState(() {
                    //             _skillNameControllers.removeAt(i);
                    //             _skillLevelControllers.removeAt(i);
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // TextButton(
                    //   onPressed: _addSkillField,
                    //   child: Text('Add More Skills', style: TextStyle(color: mainAppColor,//fontFamily: appFont
                    //   ),),
                    // ),

                    // SizedBox(
                    //   height: 10,
                    // ),
                    // // Similar for courses, projects, and siteLinks
                    // Text('Courses',
                    //     style: Theme.of(context).textTheme.headline5),
                    // for (int i = 0; i < _courseControllers.length; i++)
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _courseControllers[i],
                    //           decoration: InputDecoration(labelText: 'Course'),
                    //         ),
                    //       ),
                    //       SizedBox(width: 16),
                    //       IconButton(
                    //         icon: Icon(Icons.remove_circle_outline),
                    //         onPressed: () {
                    //           setState(() {
                    //             _courseControllers.removeAt(i);
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // TextButton(
                    //   onPressed: _addCourseField,
                    //   child: Text('Add More Courses', style: TextStyle(color: mainAppColor,//fontFamily: appFont
                    //   ),),
                    // ),

                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Text('Projects',
                    //     style: Theme.of(context).textTheme.headline5),
                    // for (int i = 0; i < _projectNameControllers.length; i++)
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _projectNameControllers[i],
                    //           decoration:
                    //               InputDecoration(labelText: 'Project Name'),
                    //         ),
                    //       ),
                    //       SizedBox(width: 16),
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _projectUrlControllers[i],
                    //           decoration:
                    //               InputDecoration(labelText: 'Project URL'),
                    //         ),
                    //       ),
                    //       IconButton(
                    //         icon: Icon(Icons.remove_circle_outline),
                    //         onPressed: () {
                    //           setState(() {
                    //             _projectNameControllers.removeAt(i);
                    //             _projectUrlControllers.removeAt(i);
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // TextButton(
                    //   onPressed: _addProjectField,
                    //   child: Text('Add More Projects', style: TextStyle(color: mainAppColor,//fontFamily: appFont
                    //   ),),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Text('Sitelinks',
                    //     style: Theme.of(context).textTheme.headline5),
                    // for (int i = 0; i < _siteLinkControllers.length; i++)
                    //   Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: _siteLinkControllers[i],
                    //           decoration:
                    //               InputDecoration(labelText: 'Sitelink'),
                    //         ),
                    //       ),
                    //       SizedBox(width: 16),
                    //       IconButton(
                    //         icon: Icon(Icons.remove_circle_outline),
                    //         onPressed: () {
                    //           setState(() {
                    //             _siteLinkControllers.removeAt(i);
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // TextButton(
                    //   onPressed: _addSiteLinkField,
                    //   child: Text('Add More Sitelinks', style: TextStyle(color: mainAppColor,//fontFamily: appFont
                    //   ),),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
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
                    )
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                icon: Icon(Icons.delete),
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
  String? skillName;
  String? skillLevel;

  Skill({
    required this.skillId,
    this.skillName,
    this.skillLevel,
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

class Projects {
  int projectId;
  String projectName;
  String projectURL;

  Projects(
      {required this.projectId,
      required this.projectName,
      required this.projectURL});

  factory Projects.fromJson(Map<String, dynamic> json) {
    return Projects(
      projectId: json['projectLinkId'], // This should probably be 'ProjectId'
      projectName: json['projectName'],
      projectURL: json['projectUrl'],
    );
  }
}

// Include your UserProfile and related model classes here...
