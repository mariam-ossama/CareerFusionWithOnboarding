import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/HR_screens/open_positions_details_screen.dart';
import 'package:career_fusion/widgets/custom_open_position_card.dart';
//import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OpenPositionsPage extends StatefulWidget {
  @override
  _OpenPositionsPageState createState() => _OpenPositionsPageState();
}

class _OpenPositionsPageState extends State<OpenPositionsPage> {
  List<Position> positions = [];

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
          'Open Positions',
          style: TextStyle(//fontFamily: appFont,
           color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for position...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: positions.length,
              itemBuilder: (context, index) {
                return PositionCard(
                  position: positions[index],
                  onTap: () {
                    final jobId = positions[index].jobId;
                    if (jobId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PositionDetailsPage(
                            userId: positions[index].id,
                            jobId: jobId,
                            jobTitle: positions[index].title
                          ),
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
          ),
        ],
      ),
    );
  }
}




