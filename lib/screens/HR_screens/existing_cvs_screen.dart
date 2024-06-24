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
  String? selectedPosition;
  List<String> positions = [];
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

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        positions = data.map<String>((item) => item['jobTitle']).toList();
      });
    } else {
      throw Exception('Failed to load open positions');
    }
  } else {
    throw Exception('User ID is null');
  }
}

  Future<void> _fetchCVsByTitle(String jobTitle) async {
    final apiUrl =
        '${baseUrl}/CVSearch/cvs-by-title/$jobTitle';

    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        positionCVs[jobTitle] = data.cast<String>();
      });
    } else {
      throw Exception('Failed to load CVs for the selected job title');
    }
  }

  @override
Widget build(BuildContext context) {
  List<String>? cvs =
      selectedPosition != null ? positionCVs[selectedPosition!] : [];

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Existing CVs',
        style: TextStyle(
          //fontFamily: appFont,
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
        Container(
          width: 370,
          decoration: ShapeDecoration(
            color: mainAppColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.0,
                style: BorderStyle.solid,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
          ),
          child: DropdownButton<String>(
            itemHeight: 48,
            iconEnabledColor: const Color.fromARGB(240, 240, 240, 255),
            value: selectedPosition,
            hint: Center(
              child: Text(
                'Choose Position',
                style: TextStyle(
                  //fontFamily: appFont,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                selectedPosition = newValue;
                _fetchCVsByTitle(newValue!);
              });
            },
            items: positions.isNotEmpty
                ? positions
                    .map<DropdownMenuItem<String>>((String position) {
                    return DropdownMenuItem<String>(
                      value: position,
                      child: Center(
                        child: Text(
                          position,
                          style: TextStyle(
                            fontSize: 22,
                            //fontFamily: appFont
                          ),
                        ),
                      ),
                    );
                  }).toList()
                : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Choose Position',
                        style: TextStyle(
                          fontSize: 22,
                          //fontFamily: appFont
                          color: Colors.white
                        ),
                      ),
                    ),
                  ],
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
          leading: Icon(Icons.picture_as_pdf,color: mainAppColor,),
          title: Text(
            cvs[index],
            style: TextStyle(
              fontFamily: appFont,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
          // trailing: IconButton(
          //   icon: Icon(Icons.delete),
          //   onPressed: () {
          //     // Add your logic for deleting the CV
          //   },
          // ),
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
