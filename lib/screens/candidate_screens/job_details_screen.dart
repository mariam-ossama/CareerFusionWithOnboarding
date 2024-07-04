import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/candidate_screens/apply_to_open_position_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobIds;
  final String user_id;

  JobDetailsPage({required this.jobIds, required this.user_id});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  Map<String, dynamic> jobDetails = {};
  Map<String, dynamic> companyData = {};

  String? profilePicturePath;

  @override
  void initState() {
    super.initState();
    fetchJobDetails();
    fetchCompanyData();
    fetchProfilePicturePath();
  }

  Future<void> fetchJobDetails() async {
    final response = await http.get(
        Uri.parse('${baseUrl}/jobform/jobDetails/${widget.user_id}/${widget.jobIds}'));

    if (response.statusCode == 200) {
      setState(() {
        jobDetails = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load job details');
    }
  }

  Future<void> fetchCompanyData() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/OpenPosCV/${widget.user_id}/contact-info'));

      if (response.statusCode == 200) {
        setState(() {
          companyData = json.decode(response.body);
        });
      } else {
        print('Failed to fetch company data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching company data: $e');
    }
  }

  Future<void> fetchProfilePicturePath() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/UserProfile/${widget.user_id}'));
      print(widget.user_id);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profilePicturePath = data['profilePicturePath'];
          print(profilePicturePath);
        });
      } else {
        print('Failed to fetch profile picture path: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching profile picture path: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          jobDetails['jobTitle'] ?? 'Job Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Card(
                color: cardsBackgroundColor,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (profilePicturePath != null) ...[
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage('${publicDomain}${profilePicturePath}'),
                            ),
                            SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  companyData['fullName'] ?? 'Company Name',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.email, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        companyData['email'] ?? 'Email',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        jobDetails['jobLocation'] ?? 'Location',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Job Description:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Job Description:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (var description in jobDetails['jobDescriptions'] ?? [])
                        Text(
                          description['description'] ?? '',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Text(
                        'Skills and Qualifications:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (var skill in jobDetails['jobSkills'] ?? [])
                        Text(
                          '• ${skill['skillName'] ?? ''}',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Text(
                        'Job Responsibilities:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (var responsibility in jobDetails['jobResponsibilities'] ?? [])
                        Text(
                          responsibility['responsibility'] ?? '',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Text(
                        'Job Type:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        jobDetails['jobType'] ?? '',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Job Location:',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        jobDetails['jobLocation'] ?? '',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomButton(
                text: 'Apply',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubmitApplicationScreen(jobFormId: widget.jobIds),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
