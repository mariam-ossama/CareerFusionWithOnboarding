import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_technical_interviews.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TechnicalInterviewCandidatesPage extends StatefulWidget {
  const TechnicalInterviewCandidatesPage({super.key});

  @override
  State<TechnicalInterviewCandidatesPage> createState() =>
      _TechnicalInterviewCandidatesPageState();
}

class _TechnicalInterviewCandidatesPageState
    extends State<TechnicalInterviewCandidatesPage> {
  String? selectedPositionId; // Selected position ID from dropdown menu
  List<Position> positions = [];
  List<CandidateTechnicatInterview> candidates = [];
  DateTime? selectedTechnicalInterviewDate;
  DateTime? selectedPhysicalInterviewDate;

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    try {
      final response =
          await http.get(Uri.parse('${baseUrl}/JobForm/OpenPos/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          positions = data.map((item) => Position.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch positions: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching positions: $e');
    }
  }

  Future<void> fetchCandidates(String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/telephone-interview-passed/$positionId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          candidates = data
              .map((item) => CandidateTechnicatInterview.fromJson(item))
              .toList();
        });

        // Fetch technical and physical interview dates for each candidate
        await fetchInterviewDates(positionId);
      } else {
        print('Failed to fetch candidates: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<void> fetchInterviewDates(String positionId) async {
    for (var candidate in candidates) {
      await fetchTechnicalInterviewDate(candidate, positionId);
      await fetchPhysicalInterviewDate(candidate, positionId);
    }
  }

  Future<void> fetchTechnicalInterviewDate(
      CandidateTechnicatInterview candidate, String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/${candidate.id}/jobform/$positionId/technical-assessment-date'));
      print('tech_date: ${response.statusCode} --> ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          candidate.technicalInterviewDate = DateTime.parse(data['data']);
        });
      } else {
        print(
            'Failed to fetch technical interview date: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching technical interview date: $e');
    }
  }

  Future<void> fetchPhysicalInterviewDate(
      CandidateTechnicatInterview candidate, String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/${candidate.id}/jobform/$positionId/physical-interview-date'));
      print('ph_date: ${response.statusCode} --> ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          candidate.physicalInterviewDate = DateTime.parse(data['data']);
        });
      } else {
        print(
            'Failed to fetch physical interview date: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching physical interview date: $e');
    }
  }

  Future<Map<String, String>> fetchCandidateInfo(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl}/OpenPosCV/$userId/contact-info'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          'fullName': data['fullName'],
          'phoneNumber': data['phoneNumber'],
          'email': data['email'],
        };
      } else {
        print('Failed to fetch candidate info: ${response.reasonPhrase}');
        return {};
      }
    } catch (e) {
      print('Error fetching candidate info: $e');
      return {};
    }
  }

  void _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showCandidateInfo(
      BuildContext context, CandidateTechnicatInterview candidate) async {
    Map<String, String> candidateInfo =
        await fetchCandidateInfo(candidate.userId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            candidateInfo['fullName'] ?? 'Candidate Info',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: mainAppColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Icon(Icons.phone, color: mainAppColor),
                  SizedBox(width: 7),
                  Text(
                    candidateInfo['phoneNumber'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email, color: mainAppColor),
                  SizedBox(width: 7),
                  Text(
                    candidateInfo['email'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.description, color: mainAppColor),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      candidate.filePath,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Calll'),
              onPressed: () {
                _launchPhoneCall(candidateInfo['phoneNumber']!);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateTime(BuildContext context,
      CandidateTechnicatInterview candidate, String interviewType) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute);
        print(
            'Selected $interviewType interview time for ${candidate.userFullName}: $selectedDateTime');

        if (interviewType == 'technical') {
          setState(() {
            selectedTechnicalInterviewDate = selectedDateTime;
          });
        } else if (interviewType == 'final') {
          setState(() {
            selectedPhysicalInterviewDate = selectedDateTime;
          });
        }

        if (selectedTechnicalInterviewDate != null &&
            selectedPhysicalInterviewDate != null &&
            selectedPositionId != null) {
          await setInterviewDate(
            candidate.id,
            selectedPositionId!,
            selectedTechnicalInterviewDate!.toIso8601String(),
            selectedPhysicalInterviewDate!.toIso8601String(),
          );
        }
      }
    }
  }

  Future<void> setInterviewDate(int candidateId, String positionId,
      String technicalAssessmentDate, String physicalInterviewDate) async {
    final url = Uri.parse(
        '${baseUrl}/OpenPosCV/$candidateId/jobform/$positionId/set-technical-interview-date'
        '?technicalAssessmentDate=$technicalAssessmentDate&physicalInterviewDate=$physicalInterviewDate');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Interview dates set successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Assessment & Physical interview Dates set successfully')),
          );
        } else {
          print('Failed to set interview dates: ${responseData['message']}');
        }
      } else {
        print('Failed to set interview dates: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error setting interview dates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical & Physical Interview',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: secondColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                iconEnabledColor: Colors.white,
                isExpanded: true,
                value: selectedPositionId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPositionId = newValue;
                    fetchCandidates(newValue!);
                  });
                },
                items: positions
                    .map<DropdownMenuItem<String>>((Position position) {
                  return DropdownMenuItem<String>(
                    value:
                        position.jobId?.toString(), // Convert jobId to String
                    child: Center(
                      child: Text(
                        position.title,
                        style: TextStyle(
                          color: mainAppColor,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                hint: Center(
                  child: Text(
                    'Choose Position',
                    style: TextStyle(
                      fontSize: 22,
                      color: mainAppColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selectedPositionId !=
              null) // Show candidates only if a position is selected
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  String candidateName = candidates[index].userFullName;
                  String technicalInterview =
                      candidates[index].technicalInterviewDate != null
                          ? candidates[index].technicalInterviewDate!.toString()
                          : 'Not set';
                  String physicalInterview =
                      candidates[index].physicalInterviewDate != null
                          ? candidates[index].physicalInterviewDate!.toString()
                          : 'Not set';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                candidateName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.assignment_ind,
                                        color: mainAppColor),
                                    onPressed: () {
                                      _selectDateTime(context,
                                          candidates[index], 'technical');
                                      setState(() {
                                        fetchCandidates(candidates[index]
                                            .technicalInterviewDate as String);
                                      });
                                    },
                                    tooltip: 'Set Technical Interview',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.schedule_outlined,
                                        color: mainAppColor),
                                    onPressed: () {
                                      _selectDateTime(
                                          context, candidates[index], 'final');
                                      setState(() {
                                        fetchCandidates(candidates[index]
                                            .physicalInterviewDate as String);
                                      });
                                    },
                                    tooltip: 'Set Final Interview',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.contact_phone,
                                        color: mainAppColor),
                                    onPressed: () {
                                      _showCandidateInfo(
                                          context, candidates[index]);
                                    },
                                    tooltip: 'View Candidate Info',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text('Technical Interview: $technicalInterview'),
                          Text('Physical Interview: $physicalInterview'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
