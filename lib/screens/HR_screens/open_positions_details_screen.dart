import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/job_description_screen.dart';
import 'package:career_fusion/screens/HR_screens/job_qualifications_screen.dart';
import 'package:career_fusion/screens/HR_screens/job_responsibilities_screen.dart';
import 'package:career_fusion/screens/HR_screens/open_position_applicants_screen.dart';
import 'package:career_fusion/screens/HR_screens/open_positions_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming Position model has a jobId field
class PositionDetailsPage extends StatefulWidget {
  final String userId; // Pass the user ID to fetch job details
  final int? jobId; // Pass the job ID to fetch job details
  final String jobTitle;

  PositionDetailsPage({required this.userId,this.jobId,required this.jobTitle});

  @override
  _PositionDetailsPageState createState() => _PositionDetailsPageState();
}

class _PositionDetailsPageState extends State<PositionDetailsPage> {
  Map<String, dynamic> jobDetails = {};

  @override
  void initState() {
    super.initState();
    fetchJobDetails();
  }

  Future<void> fetchJobDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url =
        '${baseUrl}/jobform/jobDetails/${userId}/${widget.jobId}';
        //print(userId);
        print(widget.jobId);
    final response = await http.get(Uri.parse(url));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      setState(() {
        jobDetails = json.decode(response.body);
      });
    } else {
      // Handle error or show a message
      print('Failed to load job details');
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use jobDetails to populate your UI
    // For example:
    List<String> responsibilities = jobDetails['jobResponsibilities']
            ?.map<String>((r) => r['responsibility'] as String ?? '')
            ?.toList() ??
        [];
    List<String> skills = jobDetails['jobSkills']
            ?.map<String>((s) => s['skillName'] as String ?? '')
            ?.toList() ??
        [];
    List<String> descriptions = jobDetails['jobDescriptions']
            ?.map<String>((d) => d['description'] as String ?? '')
            ?.toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.jobTitle,
          style: TextStyle(//fontFamily: appFont,
           color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDescriptionPage(
          userId: widget.userId, // Pass the userId
          jobId: widget.jobId!,   // Pass the jobId
        ),
      ),
    );
  },
  child: DetailsCard(
    title: 'Job Description',
    contentList: descriptions, // Pass job descriptions here
  ),
),
              SizedBox(height: 16.0),
              // Job Responsibilities Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobResponsibilitiesPage(
                        userId: widget.userId, // Pass the userId
                        jobId: widget.jobId!,   // Pass the jobId
                      ),
                    ),
                  );
                },
                child: DetailsCard(
                  title: 'Job Responsibilities',
                  contentList: responsibilities,
                ),
              ),
              SizedBox(height: 16.0),
              // Skills/Qualifications Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobQualificationsPage(
                        userId: widget.userId, // Pass the userId
                        jobId: widget.jobId!,   // Pass the jobId
                      ),
                    ),
                  );
                },
                child: DetailsCard(
                  title: 'Skills/Qualifications',
                  contentList: skills,
                ),
              ),
              SizedBox(height: 16.0),
              // Job Type Section
              SectionCard(
                title: 'Job Type',
                content: jobDetails['jobType'] ?? '',
              ),
              SizedBox(height: 16.0),
              // Job Location Section
              SectionCard(
                title: 'Job Location',
                content: jobDetails['jobLocation'] ?? '',
              ),
              SizedBox(height: 10,),
              CustomButton(
              text: 'Show Applicants',
              onPressed: (){
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => OpenPositionApplicants(jobFormId: widget.jobId!,)));
                print(widget.jobId);
              },)
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsCard extends StatelessWidget {
  final String title;
  final List<String> contentList;

  DetailsCard({required this.title, required this.contentList});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                //fontFamily: appFont,
              ),
            ),
            SizedBox(height: 10.0),
            for (var content in contentList) ...[
              Text('• $content'),
              SizedBox(height: 6.0),
            ],
            
          ],
          
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String content;

  SectionCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                //fontFamily: appFont,
              ),
            ),
            SizedBox(height: 10.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}
