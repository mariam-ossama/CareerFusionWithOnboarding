import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/candidate_telehpone_form.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostTelephoneInterviewSelectionProcessPage extends StatefulWidget {
  const PostTelephoneInterviewSelectionProcessPage({super.key});

  @override
  State<PostTelephoneInterviewSelectionProcessPage> createState() => _PostTelephoneInterviewSelectionProcessPageState();
}

class _PostTelephoneInterviewSelectionProcessPageState extends State<PostTelephoneInterviewSelectionProcessPage> {
  List<Position> positions = []; // List to store fetched positions
  bool isLoading = true; // To show loading indicator while fetching data

  // Dummy data for candidates
  List<String> candidates = [
    'Candidate 1',
    'Candidate 2',
    'Candidate 3',
  ];

  List<bool> selectedCandidates = [false, false, false]; // Track selected candidates
  bool selectAll = false; // Track select all status

  // Track selected dates and times for candidates
  List<DateTime?> selectedDates = [null, null, null];
  List<TimeOfDay?> selectedTimes = [null, null, null];

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
        setState(() {
          selectedDates[index] = pickedDate;
          selectedTimes[index] = pickedTime;
        });
      }
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
                              builder: (context) => CandidateTelephoneFormPage(
                                jobTitle: positions.isNotEmpty ? positions[index].title : 'Job Title',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shadowColor: Colors.grey[500],
                          color: Color.fromARGB(255, 235, 233, 255),
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                                          if (!value) {
                                            selectAll = false;
                                          } else if (selectedCandidates.every((element) => element)) {
                                            selectAll = true;
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        candidates[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.calendar_today, color: mainAppColor),
                                      onPressed: () {
                                        _selectDateAndTime(context, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.contact_phone, color: mainAppColor),
                                      onPressed: () {
                                        // Handle contact info icon button press
                                      },
                                    ),
                                  ],
                                ),
                                if (selectedDates[index] != null && selectedTimes[index] != null)
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
                /*Padding(
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
