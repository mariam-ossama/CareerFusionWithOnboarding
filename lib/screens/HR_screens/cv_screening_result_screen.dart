import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_cv_screening.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/cv_insights_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class CVScreeningResultPage extends StatefulWidget {
  @override
  _CVScreeningResultPageState createState() => _CVScreeningResultPageState();
}

class _CVScreeningResultPageState extends State<CVScreeningResultPage> {
  String? selectedPosition; // Make this nullable
  List<Position> positions = [];
  List<CandidateCVScreening> candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchCandidates() async {
    final response = await http.get(Uri.parse(
        'https://flask-deployment-hev4.onrender.com/get-matched-cvs'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        candidates =
            data.map((item) => CandidateCVScreening.fromJson(item)).toList();
      });
    } else {
      print('Failed to fetch candidates: ${response.reasonPhrase}');
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

  @override
  Widget build(BuildContext context) {
    bool hasCandidates = candidates.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Screening Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: secondColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: DropdownButton<String>(
                  iconEnabledColor: Colors.white,
                  isExpanded: true,
                  value: selectedPosition,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPosition = newValue;
                      fetchCandidates();
                    });
                  },
                  items: positions
                      .map<DropdownMenuItem<String>>((Position position) {
                    return DropdownMenuItem<String>(
                      value: position.jobId.toString(),
                      child: Center(
                        child: Text(
                          position.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                CandidateCVScreening candidate = candidates[index];
                return buildCVCard(candidate);
              },
            ),
          ),
          if (hasCandidates)
            CustomButton(
              text: 'Export to excel',
              onPressed: () {
                // TODO: Implement export to Excel functionality
              },
            ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget buildCVCard(CandidateCVScreening candidate) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CVInsightsPage(candidate: candidate)),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: ListTile(
          leading: Icon(Icons.description, color: mainAppColor),
          title: Text(
            candidate.fileName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.contact_phone, color: mainAppColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      candidate.fileName,
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
                              candidate.phoneNumber,
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
                              candidate.email,
                              style: TextStyle(
                                fontSize: 18,
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
                          _callCandidate(candidate.phoneNumber);
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
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CVInsightsPage(candidate: candidate)),
            );
          },
        ),
      ),
    );
  }
}
