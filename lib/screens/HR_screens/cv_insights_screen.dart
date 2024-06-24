import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_cv_screening.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CVInsightsPage extends StatefulWidget {
  final CandidateCVScreening candidate;

  CVInsightsPage({super.key, required this.candidate});

  @override
  State<CVInsightsPage> createState() => _CVInsightsPageState();
}

class _CVInsightsPageState extends State<CVInsightsPage> {
  late CandidateCVScreening candidateDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCandidateDetails();
  }

  Future<void> fetchCandidateDetails() async {
    final url = 'https://flask-deployment-hev4.onrender.com/get-matched-cvs';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final candidateData = data.firstWhere(
          (item) => item['contact_info']['email'] == widget.candidate.email,
        );
        setState(() {
          candidateDetails = CandidateCVScreening.fromJson(candidateData);
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing candidate details: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to fetch candidate details: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Insights',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: cardsBackgroundColor,
                    margin: EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(
                        'Candidate Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mainAppColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email,color: mainAppColor,),
                              SizedBox(width: 3,),
                              Text(candidateDetails.email),  
                            ],
                          ),
                          SizedBox(height: 3,),
                          Row(
                            children: [
                              Icon(Icons.phone,color: mainAppColor,),
                              SizedBox(width: 3,),
                              Text(candidateDetails.phoneNumber),
                            ],
                          ),
                          SizedBox(height: 3,),
                          Row(
                            children: [
                              Icon(Icons.description,color: mainAppColor,),
                              SizedBox(width: 3,),
                              Text(candidateDetails.fileName),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Matched Skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mainAppColor,
                      ),
                    ),
                  ),
                  ...candidateDetails.matchedSkills.map((skill) {
                    return Card(
                      color: cardsBackgroundColor,
                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: ListTile(
                        title: Text(skill),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
