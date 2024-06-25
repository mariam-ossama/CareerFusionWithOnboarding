import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobQualificationsPage extends StatefulWidget {
  final String userId;
  final int jobId;
  JobQualificationsPage({super.key, required this.userId, required this.jobId});

  @override
  State<JobQualificationsPage> createState() => _JobQualificationsPageState();
}

class _JobQualificationsPageState extends State<JobQualificationsPage> {
  List<String> jobSkills = [];
  List<int> jobSkillIds = []; // Added list to store description IDs
  final TextEditingController newSkillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchJobSkills();
  }

  Future<void> fetchJobSkills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = '${baseUrl}/jobform/jobDetails/${userId}/${widget.jobId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jobDetails = json.decode(response.body);
      final List<dynamic> skills = jobDetails['jobSkills'];
      final List<dynamic> skillIds =
          jobDetails['jobSkills']; // Extract description IDs
      setState(() {
        jobSkills =
            skills.map<String>((d) => d['skillName'] as String).toList();
        jobSkillIds = skillIds
            .map<int>((d) => d['id'] as int)
            .toList(); // Store description IDs
      });
    } else {
      print('Failed to fetch job skill/qualification');
    }
  }

  Future<void> editJobSkill(int index, int skillId) async {
    String? newSkill = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Job skill/qualification'),
        content: TextField(
          controller:
              newSkillController, // Use the controller to retrieve entered text
          decoration: InputDecoration(labelText: 'New skill/qualification'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Retrieve the text from the text field controller
              String enteredSkill = newSkillController.text;
              String? updatedSkill = await updateJobSkill(
                enteredSkill, // Use the entered description instead of jobDescriptions[index]
                skillId,
              );
              print(updatedSkill);
              if (updatedSkill != null) {
                setState(() {
                  jobSkills[index] = updatedSkill;
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (newSkill != null) {
      setState(() {
        jobSkills[index] = newSkill;
      });
      print(newSkill);
      print(jobSkills[index]);
    }
  }

  Future<String> updateJobSkill(String newSkill, int skillId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/JobForm/updateSkill/$userId/${widget.jobId}/$skillId';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(
          {'id': skillId, 'skillName': newSkill}), // Use newDescription
      headers: {'Content-Type': 'application/json'},
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Return the updated description
      return newSkill; // Return the new description instead of the current one
    } else {
      // Handle error
      print('Failed to update job skill/qualification');
      return newSkill; // Return the new description if update fails
    }
  }

  Future<void> DeleteJobSkill(int skill) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/JobForm/DeleteJobSkill/$userId/${widget.jobId}/$skill';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Job description deleted successfully, update UI or perform any other actions
      // Remove the description from the list based on its index
      setState(() {
        int index = jobSkillIds.indexOf(skill);
        if (index != -1) {
          jobSkills.removeAt(index);
          jobSkillIds.removeAt(index);
        }
      });
    } else {
      // Handle error
      print('Failed to delete job skill/qualification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Job Skills/Qualifications',
          style: TextStyle(
              //fontFamily: appFont,
              color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.separated(
        itemCount: jobSkills.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          return JobSkillTile(
            jobSkill: jobSkills[index],
            skillId: jobSkillIds[index], // Pass description ID
            onEdit: (skillId) => editJobSkill(index, skillId),
            onDelete: (skillId) =>
                DeleteJobSkill(skillId), // Pass onDelete function
          );
        },
      ),
    );
  }
}

class JobSkillTile extends StatelessWidget {
  final String jobSkill;
  final int skillId;
  final void Function(int) onEdit; // Updated onEdit function signature
  final void Function(int) onDelete; // Function to handle description deletion

  const JobSkillTile({
    Key? key,
    required this.jobSkill,
    required this.skillId,
    required this.onEdit,
    required this.onDelete, // Add onDelete parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        jobSkill,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          //fontFamily: appFont,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: mainAppColor),
            onPressed: () =>
                onEdit(skillId), // Pass responsibilityId to onEdit function
          ),
          IconButton(
            icon: Icon(Icons.delete, color: mainAppColor),
            onPressed: () =>
                onDelete(skillId), // Pass responsibilityId to onDelete function
          ),
        ],
      ),
    );
  }
}
