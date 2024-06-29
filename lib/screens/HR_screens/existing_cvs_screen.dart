import 'package:career_fusion/models/open_position.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_fusion/constants.dart';

class ExistingCVsPage extends StatefulWidget {
  @override
  _ExistingCVsPageState createState() => _ExistingCVsPageState();
}

class _ExistingCVsPageState extends State<ExistingCVsPage> {
  Position? selectedPosition;
  List<Position> positions = [];
  Map<String, List<String>> positionCVs = {};

  @override
  void initState() {
    super.initState();
    _fetchOpenPositions();
  }

  Future<void> _fetchOpenPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print(userId);

    if (userId != null) {
      final apiUrl = '${baseUrl}/jobform/OpenPos/$userId';

      final response = await http.get(Uri.parse(apiUrl));

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          positions = data
              .map<Position>((item) => Position(
                  jobId: item['jobId'],
                  title: item['jobTitle'],
                  location: item['jobLocation'],
                  type: item['jobType'],
                  id: item['userId']))
              .toList();
        });
      } else {
        throw Exception('Failed to load open positions');
      }
    } else {
      throw Exception('User ID is null');
    }
  }

  Future<void> _fetchCVsByTitle(String jobTitle) async {
    final apiUrl = '${baseUrl}/CVSearch/cvs-by-title/$jobTitle';

    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        positionCVs[jobTitle] = data.cast<String>();
        print(positionCVs);
      });
    } else {
      throw Exception('Failed to load CVs for the selected job title');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String>? cvs =
        selectedPosition != null ? positionCVs[selectedPosition!.title] : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Existing CVs',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: secondColor, // Replace with your app's color
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
                value: selectedPosition?.jobId.toString(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPosition = positions.firstWhere(
                        (position) => position.jobId == newValue,
                      );
                      if (selectedPosition != null) {
                        _fetchCVsByTitle(selectedPosition!.title);
                      }
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
                          color: mainAppColor, // Replace with your app's color
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
                      color: mainAppColor, // Replace with your app's color
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cvs!.length,
              itemBuilder: (context, index) {
                return Card(
                  shadowColor: Colors.grey[500],
                  color: Color.fromARGB(255, 235, 233, 255),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    tileColor: const Color.fromARGB(240, 240, 240, 255),
                    leading: Icon(
                      Icons.description,
                      color: mainAppColor,
                    ),
                    title: Text(
                      cvs[index],
                      style: TextStyle(
                          fontFamily: appFont,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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
