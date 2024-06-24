import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/screens/candidate_screens/job_details_screen.dart';
import 'package:career_fusion/screens/HR_screens/open_positions_details_screen.dart';
import 'package:career_fusion/widgets/custom_open_position_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CandidateOpenPositionsListPage extends StatefulWidget {
  const CandidateOpenPositionsListPage({Key? key}) : super(key: key);

  @override
  State<CandidateOpenPositionsListPage> createState() =>
      _CandidateOpenPositionsListPageState();
}

class _CandidateOpenPositionsListPageState
    extends State<CandidateOpenPositionsListPage> {
  late List<Position> positions = [];

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchPositions() async {
    final response = await http.get(
        Uri.parse('${baseUrl}/JobForm/all-open-positions'));
        print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Position> fetchedPositions =
          data.map((json) => Position.fromJson(json)).toList();
      setState(() {
        positions = fetchedPositions;
      });
    } else {
      throw Exception('Failed to load positions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Open Positions',
          style: TextStyle(
            //fontFamily: appFont,
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.builder(
        itemCount: positions.length,
        itemBuilder: (context, index) {
          return PositionCard(
            position: positions[index],
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsPage(
                    jobIds: positions[index].jobId!,
                    user_id: positions[index].userId!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
