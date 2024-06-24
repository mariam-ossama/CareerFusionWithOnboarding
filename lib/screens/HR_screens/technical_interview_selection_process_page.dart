import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_technical_interviews.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TechnicalInterviewCandidatesPage extends StatefulWidget {
  const TechnicalInterviewCandidatesPage({super.key});

  @override
  State<TechnicalInterviewCandidatesPage> createState() => _TechnicalInterviewCandidatesPageState();
}

class _TechnicalInterviewCandidatesPageState extends State<TechnicalInterviewCandidatesPage> {
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
      final response = await http.get(Uri.parse('${baseUrl}/JobForm/OpenPos/$userId'));
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
      final response = await http.get(Uri.parse('${baseUrl}/OpenPosCV/telephone-interview-passed/$positionId'));
      print(positionId);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          candidates = data.map((item) => CandidateTechnicatInterview.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch candidates: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<Map<String, String>> fetchCandidateInfo(String userId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}/OpenPosCV/$userId/contact-info'));
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

  Future<void> _showCandidateInfo(BuildContext context, CandidateTechnicatInterview candidate) async {
    Map<String, String> candidateInfo = await fetchCandidateInfo(candidate.userId);
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
                      decoration: TextDecoration.underline,
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
                      decoration: TextDecoration.underline,
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
                        decoration: TextDecoration.underline,
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

  Future<void> _selectDateTime(BuildContext context, CandidateTechnicatInterview candidate, String interviewType) async {
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
        final DateTime selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        print('Selected $interviewType interview time for ${candidate.userFullName}: $selectedDateTime');

        if (interviewType == 'technical') {
          setState(() {
            selectedTechnicalInterviewDate = selectedDateTime;
          });
        } else if (interviewType == 'final') {
          setState(() {
            selectedPhysicalInterviewDate = selectedDateTime;
          });
        }

        if (selectedTechnicalInterviewDate != null && selectedPhysicalInterviewDate != null && selectedPositionId != null) {
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

  Future<void> setInterviewDate(int candidateId, String positionId, String technicalAssessmentDate, String physicalInterviewDate) async {
    final url = Uri.parse('${baseUrl}/OpenPosCV/$candidateId/jobform/$positionId/set-technical-interview-date'
        '?technicalAssessmentDate=$technicalAssessmentDate&physicalInterviewDate=$physicalInterviewDate');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Interview dates set successfully');
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
          'Technical Interview Candidates',
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
                items: positions.map<DropdownMenuItem<String>>((Position position) {
                  return DropdownMenuItem<String>(
                    value: position.jobId?.toString(), // Convert jobId to String
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

          if (selectedPositionId != null) // Show candidates only if a position is selected
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: mainAppColor),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              candidates[index].userFullName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.assignment_ind, color: mainAppColor),
                            onPressed: () => _selectDateTime(context, candidates[index], 'technical'),
                            tooltip: 'Set Technical Interview',
                          ),
                          IconButton(
                            icon: Icon(Icons.schedule_outlined, color: mainAppColor),
                            onPressed: () => _selectDateTime(context, candidates[index], 'final'),
                            tooltip: 'Set Final Interview',
                          ),
                          IconButton(
                            icon: Icon(Icons.contact_phone, color: mainAppColor),
                            onPressed: () => _showCandidateInfo(context, candidates[index]),
                            tooltip: 'View Candidate Info',
                          ),
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
