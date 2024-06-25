import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JobDescriptionPage extends StatefulWidget {
  final String userId;
  final int jobId;

  const JobDescriptionPage(
      {Key? key, required this.userId, required this.jobId})
      : super(key: key);

  @override
  State<JobDescriptionPage> createState() => _JobDescriptionPageState();
}

class _JobDescriptionPageState extends State<JobDescriptionPage> {
  List<String> jobDescriptions = [];
  List<int> jobDescriptionIds = []; // Added list to store description IDs
  final TextEditingController newDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchJobDescriptions();
  }

  Future<void> fetchJobDescriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = '${baseUrl}/jobform/jobDetails/${userId}/${widget.jobId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jobDetails = json.decode(response.body);
      final List<dynamic> descriptions = jobDetails['jobDescriptions'];
      final List<dynamic> descriptionIds =
          jobDetails['jobDescriptions']; // Extract description IDs
      setState(() {
        jobDescriptions = descriptions
            .map<String>((d) => d['description'] as String)
            .toList();
        jobDescriptionIds = descriptionIds
            .map<int>((d) => d['id'] as int)
            .toList(); // Store description IDs
      });
    } else {
      print('Failed to fetch job descriptions');
    }
  }

  Future<void> editJobDescription(int index, int descriptionId) async {
    String? newDescription = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Job Description'),
        content: TextField(
          controller:
              newDescriptionController, // Use the controller to retrieve entered text
          decoration: InputDecoration(labelText: 'New Description'),
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
              String enteredDescription = newDescriptionController.text;
              String? updatedDescription = await updateDescription(
                enteredDescription, // Use the entered description instead of jobDescriptions[index]
                descriptionId,
              );
              print(updatedDescription);
              if (updatedDescription != null) {
                setState(() {
                  jobDescriptions[index] = updatedDescription;
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (newDescription != null) {
      setState(() {
        jobDescriptions[index] = newDescription;
      });
      print(newDescription);
      print(jobDescriptions[index]);
    }
  }

  Future<String> updateDescription(
      String newDescription, int descriptionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/JobForm/updateDescription/$userId/${widget.jobId}/$descriptionId';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode({
        'id': descriptionId,
        'description': newDescription
      }), // Use newDescription
      headers: {'Content-Type': 'application/json'},
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Return the updated description
      return newDescription; // Return the new description instead of the current one
    } else {
      // Handle error
      print('Failed to update job description');
      return newDescription; // Return the new description if update fails
    }
  }

  Future<void> deleteJobDescription(int descriptionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/JobForm/DeleteJobDescription/$userId/${widget.jobId}/$descriptionId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Job description deleted successfully, update UI or perform any other actions
      // Remove the description from the list based on its index
      setState(() {
        int index = jobDescriptionIds.indexOf(descriptionId);
        if (index != -1) {
          jobDescriptions.removeAt(index);
          jobDescriptionIds.removeAt(index);
        }
      });
    } else {
      // Handle error
      print('Failed to delete job description');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Job Description',
          style: TextStyle(
              //fontFamily: appFont,
              color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.separated(
        itemCount: jobDescriptions.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          return JobDescriptionTile(
            jobDescription: jobDescriptions[index],
            descriptionId: jobDescriptionIds[index], // Pass description ID
            onEdit: (descriptionId) => editJobDescription(index, descriptionId),
            onDelete: (descriptionId) =>
                deleteJobDescription(descriptionId), // Pass onDelete function
          );
        },
      ),
    );
  }
}

class JobDescriptionTile extends StatelessWidget {
  final String jobDescription;
  final int descriptionId;
  final void Function(int) onEdit; // Updated onEdit function signature
  final void Function(int) onDelete; // Function to handle description deletion

  const JobDescriptionTile({
    Key? key,
    required this.jobDescription,
    required this.descriptionId,
    required this.onEdit,
    required this.onDelete, // Add onDelete parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        jobDescription,
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
                onEdit(descriptionId), // Pass descriptionId to onEdit function
          ),
          IconButton(
            icon: Icon(Icons.delete, color: mainAppColor),
            onPressed: () => onDelete(
                descriptionId), // Pass descriptionId to onDelete function
          ),
        ],
      ),
    );
  }
}
