import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/candidate_telehpone_form.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TelephoneInterviewSelectionPage extends StatefulWidget {
  @override
  _TelephoneInterviewSelectionPageState createState() =>
      _TelephoneInterviewSelectionPageState();
}

class _TelephoneInterviewSelectionPageState
    extends State<TelephoneInterviewSelectionPage> {
  String? selectedPosition; // Selected position from dropdown menu
  List<Position> positions = []; // List to store fetched positions
  bool isLoading = true; // To show loading indicator while fetching data

  // Data for candidates
  List<Map<String, dynamic>> candidates = [];

  List<bool> selectedCandidates = []; // Track selected candidates
  bool selectAll = false; // Track select all status

  // Track selected dates for candidates
  List<DateTime?> selectedDates = [];

  @override
  void initState() {
    super.initState();
    fetchPositions();
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

  Future<void> fetchCandidates(int jobFormId) async {
    final url = '${baseUrl}/OpenPosCV/screened/$jobFormId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received candidates data: $data'); // Debug print
        setState(() {
          candidates = data.cast<Map<String, dynamic>>();
          selectedCandidates = List<bool>.filled(candidates.length, false);
          selectedDates = List<DateTime?>.filled(candidates.length, null);

          // Fetch telephone interview dates for each candidate
          for (int i = 0; i < candidates.length; i++) {
            fetchTelephoneInterviewDate(
                    candidates[i]['id'], int.parse(selectedPosition!))
                .then((date) {
              setState(() {
                selectedDates[i] = date;
              });
            });
          }
        });
      } catch (e) {
        print('Error parsing candidates data: $e');
      }
    } else {
      print('Failed to fetch candidates: ${response.statusCode}');
    }
  }

  Future<DateTime?> fetchTelephoneInterviewDate(int cvId, int jobFormId) async {
    final url =
        '${baseUrl}/OpenPosCV/$cvId/jobform/$jobFormId/get-telephone-interview-date';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Received telephone interview date: $data'); // Debug print
        final String? dateTimeString = data['data'];
        if (dateTimeString != null) {
          return DateTime.parse(dateTimeString);
        }
      } catch (e) {
        print('Error parsing telephone interview date: $e');
      }
    } else {
      print('Failed to fetch telephone interview date: ${response.statusCode}');
    }
    return null;
  }

  Future<void> fetchContactInfo(String userId) async {
    final url = '${baseUrl}/OpenPosCV/$userId/contact-info';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Received contact info: $data'); // Debug print
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                data['fullName'],
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
                        '${data['phoneNumber']}',
                        style: TextStyle(
                          fontSize: 14,
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
                        '${data['email']}',
                        style: TextStyle(
                          fontSize: 14,
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
                    _callCandidate(data['phoneNumber']);
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
      } catch (e) {
        print('Error parsing contact info: $e');
      }
    } else {
      print('Failed to fetch contact info: ${response.statusCode}');
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

  Future<void> toggleTelephoneInterviewStatus(
      int jobFormId, int cvId, bool isChecked) async {
    final url =
        '${baseUrl}/OpenPosCV/$jobFormId/$cvId/toggle-telephone-interview';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isChecked': isChecked}),
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Received response: $data'); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Candidate is set as passed successfully')),
        );
        if (data['success']) {
          print(data['message']);
        } else {
          print('Failed to toggle status: ${data['message']}');
        }
      } catch (e) {
        print('Error parsing toggle status response: $e');
      }
    } else {
      print(
          'Failed to toggle telephone interview status: ${response.statusCode}');
    }
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDates[index] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          selectedDates[index] = combinedDateTime;
        });

        // Call API to set interview date for the candidate
        _setInterviewDate(candidates[index]['id'], int.parse(selectedPosition!),
            selectedDates[index]!);
      }
    }
  }

  Future<void> _setInterviewDate(
      int cvId, int jobFormId, DateTime interviewDate) async {
    final url =
        '${baseUrl}/OpenPosCV/$cvId/jobform/$jobFormId/set-telephone-interview-date?interviewDate=$interviewDate';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('Interview date set successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telephone interview Date set successfully')),
      );
    } else {
      print('Failed to set interview date: ${response.statusCode}');
    }
  }

  Future<void> updateScoresForScreened(
      int jobFormId, List<String> emails) async {
    final url = '${baseUrl}/OpenPosCV/update-scores-for-screened/$jobFormId';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(emails),
    );
    print('updateScoresForScreened');
    print(response.body);

    if (response.statusCode == 200) {
      print('Scores updated successfully');
      await fetchCandidates(jobFormId);
    } else {
      print('Failed to update scores: ${response.statusCode}');
    }
  }

  Future<void> fetchMatchedCVsAndUpdateScores(int jobFormId) async {
    final url = 'https://flask-deployment-hev4.onrender.com/get-matched-cvs';
    final response = await http.get(Uri.parse(url));

    print('fetchMatchedCVsAndUpdateScores');

    print(response.body);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received matched CVs: $data'); // Debug print
        final List<String> emails = data
            .map((item) => item['contact_info']['email'] as String)
            .toList();
        await updateScoresForScreened(jobFormId, emails);
      } catch (e) {
        print('Error parsing matched CVs data: $e');
      }
    } else {
      print('Failed to fetch matched CVs: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
// Debug print statements
    print('Positions: $positions');
    print('Selected Position: $selectedPosition');

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
                      value: selectedPosition,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedPosition = newValue;
                            fetchCandidates(int.parse(newValue));
                          });
                        }
                      },
                      items: positions
                          .map<DropdownMenuItem<String>>((Position position) {
                        return DropdownMenuItem<String>(
                          value: position.jobId.toString(),
                          child: Center(
                            child: Text(
                              position.title,
                              style: TextStyle(
                                fontSize: 20,
                                color: mainAppColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      hint: Center(
                        child: Text(
                          'Choose Position',
                          style: TextStyle(
                            fontSize: 20,
                            color: mainAppColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedPosition != null)
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
                            if (selectedCandidates[i]) {
                              toggleTelephoneInterviewStatus(
                                  int.parse(selectedPosition!),
                                  candidates[i]['id'],
                                  true);
                            } else {
                              toggleTelephoneInterviewStatus(
                                  int.parse(selectedPosition!),
                                  candidates[i]['id'],
                                  false);
                            }
                          }
                        });
                      },
                    ),
                  ),
                if (selectedPosition != null && candidates.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CandidateTelephoneFormPage(
                                  jobTitle: positions
                                      .firstWhere((p) =>
                                          p.jobId.toString() ==
                                          selectedPosition)
                                      .title,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shadowColor: Color(0xFF9E9E9E),
                            color: Color(0xFFEBE9FF),
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
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
                                          if (value != null) {
                                            setState(() {
                                              selectedCandidates[index] = value;
                                              toggleTelephoneInterviewStatus(
                                                  int.parse(selectedPosition!),
                                                  candidates[index]['id'],
                                                  value);
                                              if (!value) {
                                                selectAll = false;
                                              } else if (selectedCandidates
                                                  .every(
                                                      (element) => element)) {
                                                selectAll = true;
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          candidates[index]['userFullName'],
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.calendar_today,
                                            color: mainAppColor),
                                        onPressed: () {
                                          _selectDate(context, index);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.contact_phone,
                                            color: mainAppColor),
                                        onPressed: () {
                                          fetchContactInfo(candidates[index]
                                                  ['userId']
                                              .toString());
                                        },
                                      ),
                                    ],
                                  ),
                                  if (selectedDates[index] != null)
                                    Text(
                                      '${selectedDates[index]!.toString()}',
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
                /*if (selectedPosition != null && candidates.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  text: 'Export to Excel',
                  onPressed: () {
                    // Implement your export to Excel logic here
                  },
                ),
              ),*/
              ],
            ),
    );
  }
}
