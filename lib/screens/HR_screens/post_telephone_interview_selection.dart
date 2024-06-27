import 'dart:convert';
import 'package:career_fusion/models/candidate%20_telephone_interview.dart';
import 'package:career_fusion/screens/HR_screens/post_telephone_interview_form.dart';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/candidate_telehpone_form.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfo {
  final String? phoneNumber;
  final String? email;
  final String? filePath;

  ContactInfo({
    this.phoneNumber,
    this.email,
    this.filePath,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      filePath: json['filePath'],
    );
  }
}

class PostTelephoneInterviewSelectionProcessPage extends StatefulWidget {
  final int postId;
  const PostTelephoneInterviewSelectionProcessPage(
      {super.key, required this.postId});

  @override
  State<PostTelephoneInterviewSelectionProcessPage> createState() =>
      _PostTelephoneInterviewSelectionProcessPageState();
}

class _PostTelephoneInterviewSelectionProcessPageState
    extends State<PostTelephoneInterviewSelectionProcessPage> {
  List<Position> positions = []; // List to store fetched positions
  List<PostCandidateTelephoneInterview> candidates = [];
  List<String> candidateEmails = [];
  bool isLoading = true; // To show loading indicator while fetching data

  List<bool> selectedCandidates = [
    false,
    false,
    false
  ]; // Track selected candidates
  bool selectAll = false; // Track select all status

  // Track selected dates and times for candidates
  List<DateTime?> selectedDates = [null, null, null];
  List<TimeOfDay?> selectedTimes = [null, null, null];

  @override
  void initState() {
    super.initState();
    fetchPositions();
    fetchAndProcessCandidates();
  }

  Future<void> fetchPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    final url = '${baseUrl}/jobform/OpenPos/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received positions data: $data'); // Debug print
        final List<Position> fetchedPositions =
            data.map((item) => Position.fromJson(item)).toList();
        print('Parsed positions: $fetchedPositions'); // Debug print
        setState(() {
          positions = fetchedPositions;
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing positions data: $e');
      }
    } else {
      print('Failed to fetch positions: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndProcessCandidates() async {
    await fetchMatchedCVs();
    await updateScreenedCandidates();
    await fetchCandidates();
    await fetchInterviewDates(); // Fetch interview dates after candidates are fetched
  }

  Future<void> fetchMatchedCVs() async {
    final url = 'https://flask-deployment-hev4.onrender.com/get-matched-cvs';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received matched CVs data: $data'); // Debug print
        final List<String> fetchedEmails = data
            .map((item) => item['contact_info']['email'] as String)
            .toList();
        print('Parsed emails: $fetchedEmails'); // Debug print
        setState(() {
          candidateEmails = fetchedEmails;
        });
      } catch (e) {
        print('Error parsing matched CVs data: $e');
      }
    } else {
      print('Failed to fetch matched CVs: ${response.statusCode}');
    }
  }

  Future<void> updateScreenedCandidates() async {
    final url = '${baseUrl}/CVUpload/update-screened/${widget.postId}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(candidateEmails),
    );

    if (response.statusCode == 200) {
      print('Successfully updated screened candidates');
    } else {
      print('Failed to update screened candidates: ${response.statusCode}');
    }
  }

  Future<void> fetchCandidates() async {
    final url = '${baseUrl}/CVUpload/screened/${widget.postId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received candidates data: $data'); // Debug print
        final List<PostCandidateTelephoneInterview> fetchedCandidates = data
            .map((item) => PostCandidateTelephoneInterview.fromJson(item))
            .toList();
        print('Parsed candidates: $fetchedCandidates'); // Debug print
        setState(() {
          candidates = fetchedCandidates;
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing candidates data: $e');
      }
    } else {
      print('Failed to fetch candidates: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchInterviewDates() async {
    for (int i = 0; i < candidates.length; i++) {
      final postCVId = candidates[i].postCVId;
      final url =
          '${baseUrl}/CVUpload/${widget.postId}/get-telephone-interview-date/$postCVId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        try {
          final String interviewDateStr = json.decode(response.body);
          final DateTime interviewDate = DateTime.parse(interviewDateStr);
          setState(() {
            selectedDates[i] = interviewDate;
            selectedTimes[i] = TimeOfDay(
                hour: interviewDate.hour, minute: interviewDate.minute);
          });
        } catch (e) {
          print('Error parsing interview date: $e');
        }
      } else {
        print(
            'Failed to fetch interview date for candidate $postCVId: ${response.statusCode}');
      }
    }
  }

  Future<void> setInterviewDate(
      int index, DateTime date, TimeOfDay time) async {
    final postCVId = candidates[index].postCVId;
    final interviewDate =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final url =
        '${baseUrl}/CVUpload/${widget.postId}/set-telephone-interview-date/$postCVId?interviewDate=${interviewDate.toIso8601String()}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        selectedDates[index] = interviewDate;
        selectedTimes[index] = time;
      });
      print('Successfully set interview date');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telephone interview Date set successfully')),
      );
    } else {
      print('Failed to set interview date: ${response.statusCode}');
    }
  }

  Future<void> toggleTelephoneInterviewStatus(int postCVId) async {
    final url =
        '${baseUrl}/CVUpload/${widget.postId}/$postCVId/toggle-telephone-interview';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Successfully toggled telephone interview status');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TCandidate is set as passed successfully')),
      );
    } else {
      print(
          'Failed to toggle telephone interview status: ${response.statusCode}');
    }
  }

  Future<void> _selectDateAndTime(BuildContext context, int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDates[index] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTimes[index] ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setInterviewDate(index, pickedDate, pickedTime);
      }
    }
  }

  Future<ContactInfo?> fetchCandidateContactInfo(String userId) async {
    final url = '${baseUrl}/OpenPosCV/$userId/contact-info';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return ContactInfo.fromJson(data);
      } catch (e) {
        print('Error parsing contact info: $e');
      }
    } else {
      print('Failed to fetch contact info: ${response.statusCode}');
    }
    return null;
  }

  Future<void> _showCandidateInfoDialog(
      PostCandidateTelephoneInterview candidate) async {
    final contactInfo = await fetchCandidateContactInfo(candidate.userId!);

    if (contactInfo != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              candidate.userFullName ?? 'Candidate Info',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: mainAppColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.phone, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      contactInfo.phoneNumber ?? 'Phone number not available',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 10),
                    /*ElevatedButton(
                      onPressed: () => _callCandidate(contactInfo.phoneNumber),
                      style: ElevatedButton.styleFrom(
                        primary: mainAppColor, // Background color
                        onPrimary: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('Call'),
                    ),*/
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.email, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      contactInfo.email ?? 'Email not available',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (contactInfo.filePath != null)
                  Row(
                    children: [
                      Icon(Icons.description, color: mainAppColor),
                      SizedBox(width: 7),
                      GestureDetector(
                        onTap: () {
                          _launchURL(contactInfo.filePath!);
                        },
                        child: Text(
                          'View CV',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Call'),
                onPressed: () {
                  _callCandidate(contactInfo.phoneNumber);
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Telephone Interview Selection',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CheckboxListTile(
                    title: Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    value: selectAll,
                    onChanged: (bool? value) {
                      setState(() {
                        selectAll = value!;
                        for (int i = 0; i < selectedCandidates.length; i++) {
                          selectedCandidates[i] = selectAll;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostTelephoneInterviewForm(
                                postId: widget.postId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shadowColor: Colors.grey[500],
                          color: Color.fromARGB(255, 235, 233, 255),
                          margin: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: selectedCandidates[index],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedCandidates[index] = value!;
                                          if (value != null && value) {
                                            toggleTelephoneInterviewStatus(
                                                candidates[index].postCVId!);
                                          }
                                          if (!value) {
                                            selectAll = false;
                                          } else if (selectedCandidates
                                              .every((element) => element)) {
                                            selectAll = true;
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        candidates[index].userFullName!,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.calendar_today,
                                          color: mainAppColor),
                                      onPressed: () {
                                        _selectDateAndTime(context, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.contact_phone,
                                          color: mainAppColor),
                                      onPressed: () {
                                        _showCandidateInfoDialog(candidates[
                                            index]); // Pass the selected candidate here
                                      },
                                    ),
                                  ],
                                ),
                                if (selectedDates[index] != null &&
                                    selectedTimes[index] != null)
                                  Text(
                                    '${selectedDates[index]!.toLocal()} ${selectedTimes[index]!.format(context)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
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
