import 'dart:convert';
import 'dart:io';
import 'package:career_fusion/models/open_position.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class TelephonInterviewResultPage extends StatefulWidget {
  @override
  _TelephonInterviewResultPageState createState() =>
      _TelephonInterviewResultPageState();
}

class _TelephonInterviewResultPageState
    extends State<TelephonInterviewResultPage> {
  Position? selectedPosition;
  List<Position> positions = [];
  List<Map<String, dynamic>> candidates = [];
  String? excelDownloadUrl;

  bool isLoading = true;

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
        final List<Position> fetchedPositions =
            data.map((item) => Position.fromJson(item)).toList();

        setState(() {
          positions = fetchedPositions;
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing positions data: $e');
      }
    } else {
      print('Failed to fetch positions: ${response.statusCode}');
    }
  }

  Future<void> fetchCandidates(int jobFormId) async {
    final url = '${baseUrl}/OpenPosCV/telephone-interview-passed/$jobFormId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedCandidates =
            List<Map<String, dynamic>>.from(data);

        setState(() {
          candidates = fetchedCandidates;
        });
      } catch (e) {
        print('Error parsing candidates data: $e');
      }
    } else {
      print('Failed to fetch candidates: ${response.statusCode}');
    }
  }

  Future<void> exportToExcel(int jobFormId) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final url =
          'http://10.0.2.2:5266/api/OpenPosCV/export-telephone-interview-passed/$jobFormId';
      final response = await http.get(Uri.parse(url));

      print('ExportToExcel Function');
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        try {
          final bytes = response.bodyBytes;

          // Use path_provider to get the external storage directory
          Directory? directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Construct the path to the documents directory
            final documentsPath = '${directory.path}/Documents';
            final documentsDirectory = Directory(documentsPath);
            if (!documentsDirectory.existsSync()) {
              documentsDirectory.createSync(recursive: true);
            }

            final file = File('$documentsPath/telephon_interview_result.xlsx');
            await file.writeAsBytes(bytes);

            setState(() {
              excelDownloadUrl = file.path;
            });

            print('File saved at: ${file.path}');
          } else {
            print('Could not get external storage directory');
          }
        } catch (e) {
          print('Error saving Excel file: $e');
        }
      } else {
        print('Failed to export to Excel: ${response.statusCode}');
      }
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> fetchAndShowContactInfo(String userId, String candidateName, String phoneNumber) async {
  final url = '${baseUrl}/OpenPosCV/$userId/contact-info';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    String candidatePhoneNumber = data['phoneNumber'];
    //print(data[])

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            candidateName,
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
                    candidatePhoneNumber,
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
                    data['email'],
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
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Call'),
              onPressed: () {
                _launchPhoneCall(candidatePhoneNumber);
              },
            ),
          ],
        );
      },
    );
  } else {
    print('Failed to fetch contact info: ${response.statusCode}');
  }
}

void _launchPhoneCall(String phoneNumber) async {
  String url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Telephone Interview Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                        borderRadius:
                            BorderRadius.all(Radius.circular(16.0)),
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
                              (position) =>
                                  position.jobId.toString() == newValue,
                            );
                            fetchCandidates(selectedPosition!.jobId!);
                          });
                        }
                      },
                      items: positions
                          .map<DropdownMenuItem<String>>(
                              (Position position) {
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
                SizedBox(height: 10),
                if (selectedPosition != null && candidates.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        String candidateName =
                            candidates[index]['userFullName'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                candidateName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                candidates[index]['filePath'],
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.contact_phone,
                                    color: mainAppColor),
                                onPressed: () {
                                  fetchAndShowContactInfo(
                                      candidates[index]['userId'],
                                      candidateName,
                                      candidates[index]['phoneNumber'].toString());
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (selectedPosition != null && candidates.isEmpty)
                  Text(
                    'No candidates available for selected position',
                    style: TextStyle(fontSize: 18),
                  ),
                if (selectedPosition != null && candidates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Export to Excel',
                          onPressed: () {
                            exportToExcel(selectedPosition!.jobId!);
                          },
                        ),
                        SizedBox(height: 10),
                        if (excelDownloadUrl != null)
                          CustomButton(
                            text: 'Download Excel File',
                            onPressed: () {
                              OpenFile.open(excelDownloadUrl);
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
