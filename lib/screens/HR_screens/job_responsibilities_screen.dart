
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobResponsibilitiesPage extends StatefulWidget {
  final String userId;
  final int jobId;
  JobResponsibilitiesPage({super.key,required this.userId, required this.jobId});

  @override
  State<JobResponsibilitiesPage> createState() => _JobResponsibilitiesPageState();
}

class _JobResponsibilitiesPageState extends State<JobResponsibilitiesPage> {
  List<String> jobResponsibilities = [];
  List<int> jobResponsibilityIds = []; // Added list to store description IDs
  final TextEditingController newResponsibilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchJobResponsibilities();
  }

  Future<void> fetchJobResponsibilities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = '${baseUrl}/jobform/jobDetails/${userId}/${widget.jobId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jobDetails = json.decode(response.body);
      final List<dynamic> responsibilities = jobDetails['jobResponsibilities'];
      final List<dynamic> responsibilityIds = jobDetails['jobResponsibilities']; // Extract description IDs
      setState(() {
        jobResponsibilities = responsibilities.map<String>((d) => d['responsibility'] as String).toList();
        jobResponsibilityIds = responsibilityIds.map<int>((d) => d['id'] as int).toList(); // Store description IDs
      });
    } else {
      print('Failed to fetch job responsibility');
    }
  }

  Future<void> editJobResponsibility(int index, int responsibilityId) async {
  String? newResponsibility = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit Job Responsibility'),
      content: TextField(
        controller: newResponsibilityController, // Use the controller to retrieve entered text
        decoration: InputDecoration(labelText: 'New Responsibility'),
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
            String enteredResponsibility = newResponsibilityController.text;
            String? updatedResponsibility = await updateResponsibility(
              enteredResponsibility, // Use the entered description instead of jobDescriptions[index]
              responsibilityId,
            );
            print(updatedResponsibility);
            if (updatedResponsibility != null) {
              setState(() {
                jobResponsibilities[index] = updatedResponsibility;
              });
            }
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    ),
  );

  if (newResponsibility != null) {
    setState(() {
      jobResponsibilities[index] = newResponsibility;
    });
    print(newResponsibility);
    print(jobResponsibilities[index]);
  }
}


  Future<String> updateResponsibility(String newResponsibility, int responsibilityId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  final url = '${baseUrl}/JobForm/updateResponsibility/$userId/${widget.jobId}/$responsibilityId';
  final response = await http.put(
    Uri.parse(url),
    body: jsonEncode({'id': responsibilityId, 'responsibility': newResponsibility}), // Use newDescription
    headers: {'Content-Type': 'application/json'},
  );

  print(response.body);
  print(response.statusCode);

  if (response.statusCode == 200) {
    // Return the updated description
    return newResponsibility; // Return the new description instead of the current one
  } else {
    // Handle error
    print('Failed to update job responsibility');
    return newResponsibility; // Return the new description if update fails
  }
}

Future<void> DeleteJobResponsibility(int responsibility) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  final url = '${baseUrl}/JobForm/DeleteJobResponsibility/$userId/${widget.jobId}/$responsibility';
  final response = await http.delete(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    // Job description deleted successfully, update UI or perform any other actions
    // Remove the description from the list based on its index
    setState(() {
      int index = jobResponsibilityIds.indexOf(responsibility);
      if (index != -1) {
        jobResponsibilities.removeAt(index);
        jobResponsibilityIds.removeAt(index);
      }
    });
  } else {
    // Handle error
    print('Failed to delete job responsibility');
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Job Responsibilities',
          style: TextStyle(//fontFamily: appFont,
           color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.separated(
  itemCount: jobResponsibilities.length,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) {
    return JobResponsibilityTile(
      jobResponsibility: jobResponsibilities[index],
      responsibilityId: jobResponsibilityIds[index], // Pass description ID
      onEdit: (responsibilityId) => editJobResponsibility(index, responsibilityId),
      onDelete: (responsibilityId) => DeleteJobResponsibility(responsibilityId), // Pass onDelete function
    );
  },
),
    );
  }
}

class JobResponsibilityTile extends StatelessWidget {
  final String jobResponsibility;
  final int responsibilityId;
  final void Function(int) onEdit; // Updated onEdit function signature
  final void Function(int) onDelete; // Function to handle description deletion

  const JobResponsibilityTile({
    Key? key,
    required this.jobResponsibility,
    required this.responsibilityId,
    required this.onEdit,
    required this.onDelete, // Add onDelete parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        jobResponsibility,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          //fontFamily: appFont,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => onEdit(responsibilityId), // Pass responsibilityId to onEdit function
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onDelete(responsibilityId), // Pass responsibilityId to onDelete function
          ),
        ],
      ),
    );
  }
}