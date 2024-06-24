import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_forms.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_screen.dart';
import 'package:career_fusion/widgets/custom_open_position_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TelephoneInterviewPositionsPage extends StatefulWidget {
  @override
  _TelephoneInterviewPositionsPageState createState() => _TelephoneInterviewPositionsPageState();
}

class _TelephoneInterviewPositionsPageState extends State<TelephoneInterviewPositionsPage> {
  List<Position> openPositions = [];

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
    print(response.body);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received positions data: $data'); // Debug print
        final List<Position> fetchedPositions =
            data.map((item) => Position.fromJson(item)).toList();
        print('Parsed positions: $fetchedPositions'); // Debug print
        setState(() {
          openPositions = fetchedPositions;
        });
      } catch (e) {
        print('Error parsing positions data: $e');
      }
    } else {
      print('Failed to fetch positions: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Telephone In. Open Positions',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.builder(
        itemCount: openPositions.length,
        itemBuilder: (context, index) {
          return PositionCard(
            position: openPositions[index],
            onTap: () {
              final jobId = openPositions[index].jobId;
              final jobTitle = openPositions[index].title;
              if (jobId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelephoneInterviewFormPage(
                      jobId: jobId,
                      jobTitle: jobTitle,),
                  ),
                );
              } else {
                // Handle the case where jobId is null
                print('Job ID is null for position at index $index');
              }
            },
          );
        },
      ),
    );
  }
}
