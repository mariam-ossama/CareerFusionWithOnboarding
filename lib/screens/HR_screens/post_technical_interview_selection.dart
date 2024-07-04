import 'package:flutter/material.dart';
import 'package:career_fusion/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PostTechnicalInterviewSelectionProcessPage extends StatefulWidget {
  final int postId;

  const PostTechnicalInterviewSelectionProcessPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostTechnicalInterviewSelectionProcessPage> createState() =>
      _PostTechnicalInterviewSelectionProcessPageState();
}

class _PostTechnicalInterviewSelectionProcessPageState
    extends State<PostTechnicalInterviewSelectionProcessPage> {
  List<Map<String, dynamic>> candidates = [];
  Map<int, bool> candidateSelection = {};
  Map<int, DateTime?> _technicalInterviewDates = {};
  Map<int, DateTime?> _physicalInterviewDates = {};

  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

  Future<void> fetchCandidates() async {
    final url =
        '${baseUrl}/CVUpload/telephone-interview-passed/${widget.postId}';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedCandidates = [];

        for (var item in data) {
          final postCVId = item['postCVId'];
          final technicalDate = await fetchTechnicalInterviewDate(postCVId);
          final physicalDate = await fetchPhysicalInterviewDate(postCVId);

          fetchedCandidates.add({
            'postCVId': postCVId,
            'userFullName': item['userFullName'] ?? '',
            'filePath': item['filePath'] ?? '',
            'technicalDate': technicalDate?.toIso8601String() ?? '',
            'physicalDate': physicalDate?.toIso8601String() ?? '',
            'userId': item['userId'] ?? '',
          });

          // Initialize selection for each candidate
          candidateSelection[postCVId] = false; // Initially none selected
        }

        setState(() {
          candidates = fetchedCandidates;
        });
      } else {
        print('Failed to fetch candidates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<void> setInterviewDates(int postCVId, DateTime technicalInterview,
      DateTime physicalInterview) async {
    final url =
        '${baseUrl}/CVUpload/$postCVId/post/${widget.postId}/set-technical-interview-date?technicalAssessmentDate=${technicalInterview.toIso8601String()}&physicalInterviewDate=${physicalInterview.toIso8601String()}';
    try {
      final response = await http.put(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Interview dates set successfully');
      } else {
        print(postCVId);
        print(widget.postId);
        print(technicalInterview);
        print(physicalInterview);
        print('Failed to set interview dates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error setting interview dates: $e');
    }
  }

  Future<DateTime?> fetchTechnicalInterviewDate(int postCVId) async {
    final url =
        '${baseUrl}/CVUpload/$postCVId/post/${widget.postId}/get-technical-assessment-date';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DateTime.parse(data['data'] ?? '');
      } else {
        print(
            'Failed to fetch technical interview date: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching technical interview date: $e');
      return null;
    }
  }

  Future<DateTime?> fetchPhysicalInterviewDate(int postCVId) async {
    final url =
        '${baseUrl}/CVUpload/$postCVId/post/${widget.postId}/get-physical-interview-date';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DateTime.parse(data['data'] ?? '');
      } else {
        print(
            'Failed to fetch physical interview date: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching physical interview date: $e');
      return null;
    }
  }

  Future<void> _selectDateTime(BuildContext context, String candidateName,
      String interviewType, int postCVId) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (selectedDateTime != null) {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timeOfDay != null) {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        setState(() {
          if (interviewType == 'technical') {
            _technicalInterviewDates[postCVId] = selectedDateTime;
          } else if (interviewType == 'final') {
            _physicalInterviewDates[postCVId] = selectedDateTime;
          }
        });

        if (_technicalInterviewDates[postCVId] != null &&
            _physicalInterviewDates[postCVId] != null) {
          await setInterviewDates(
            postCVId,
            _technicalInterviewDates[postCVId]!,
            _physicalInterviewDates[postCVId]!,
          );
        }
      }
    }
  }

  Future<Map<String, String>> fetchContactInfo(String userId) async {
    final url = '${baseUrl}/OpenPosCV/$userId/contact-info';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Technical & Physical interview Dates set successfully')),
        );
        return {
          'fullName': data['fullName'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'email': data['email'] ?? '',
        };
      } else {
        print('Failed to fetch contact info: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching contact info: $e');
      return {};
    }
  }

  Future<void> _showCandidateInfo(
      BuildContext context, String userId, String candidateName) async {
    final contactInfo = await fetchContactInfo(userId);
    if (contactInfo.isEmpty) {
      // Handle the error if the contact info is not available
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            candidateName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: mainAppColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.phone, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      contactInfo['phoneNumber']!,
                      style: TextStyle(
                        fontSize: 16,
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
                      contactInfo['email']!,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Call'),
              onPressed: () {
                _callCandidate(contactInfo['phoneNumber']);
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

  Future<void> _showMessageDialog(int postCVId) async {
    TextEditingController messageController = TextEditingController();
    bool? isPassed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Technical Interview Passed'),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(
              hintText: 'Enter message to candidate',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (isPassed == true) {
      final message = messageController.text;
      await toggleTechnicalInterviewStatus(postCVId, message);
    }
  }

  Future<void> toggleTechnicalInterviewStatus(
      int postCVId, String message) async {
    final url =
        '${baseUrl}/CVUpload/${widget.postId}/$postCVId/toggle-technical-interview';
    final body = json.encode({
      'passed': true,
      'hrMessage': message,
    });

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        print('Technical interview status updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Candidate is set as passed successfully')),
        );
      } else {
        print(
            'Failed to update technical interview status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating technical interview status: $e');
    }
  }

  void _toggleCandidateSelection(int postCVId) {
    setState(() {
      candidateSelection[postCVId] = !candidateSelection[postCVId]!;
    });

    if (candidateSelection[postCVId]!) {
      _showMessageDialog(postCVId);
    }
  }

  void _toggleSelectAll(bool? isChecked) {
    if (isChecked != null) {
      setState(() {
        candidateSelection.forEach((key, _) {
          candidateSelection[key] = isChecked;
        });
      });
    }
  }

  void _callCandidate(String? phoneNumber) async {
    if (phoneNumber != null) {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical & Physical Interviews',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Checkbox(
                  value:
                      candidateSelection.values.every((selected) => selected),
                  onChanged: _toggleSelectAll,
                ),
                Text('Select All'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final isSelected =
                    candidateSelection[candidate['postCVId']] ?? false;

                return Card(
                  color: cardsBackgroundColor,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (isChecked) {
                                _toggleCandidateSelection(
                                    candidate['postCVId'] ?? 0);
                              },
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                candidate['userFullName'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.assignment_ind,
                                  color: mainAppColor),
                              onPressed: () => _selectDateTime(
                                context,
                                candidate['userFullName'] ?? '',
                                'technical',
                                candidate['postCVId'] ?? 0,
                              ),
                              tooltip: 'Set Technical Interview',
                            ),
                            IconButton(
                              icon: Icon(Icons.schedule_outlined,
                                  color: mainAppColor),
                              onPressed: () => _selectDateTime(
                                context,
                                candidate['userFullName'] ?? '',
                                'final',
                                candidate['postCVId'] ?? 0,
                              ),
                              tooltip: 'Set Final Interview',
                            ),
                            IconButton(
                              icon: Icon(Icons.contact_phone,
                                  color: mainAppColor),
                              onPressed: () => _showCandidateInfo(
                                context,
                                candidate['userId'] ?? '',
                                candidate['userFullName'] ?? '',
                              ),
                              tooltip: 'View Candidate Info',
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Technical interview date: ${candidate['technicalDate'] ?? 'Not set yet'}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Physical interview date: ${candidate['physicalDate'] ?? 'Not set yet'}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
