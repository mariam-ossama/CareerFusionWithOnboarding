import 'dart:convert';
import 'dart:io';
import 'package:career_fusion/models/candidate_technical_interviews.dart';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TecnicalInterviewResultPage extends StatefulWidget {
  const TecnicalInterviewResultPage({super.key});

  @override
  State<TecnicalInterviewResultPage> createState() =>
      _TecnicalInterviewResultPageState();
}

class _TecnicalInterviewResultPageState
    extends State<TecnicalInterviewResultPage> {
  String? selectedPosition;
  String? selectedPositionId;
  List<Position> positions = [];
  List<CandidateTechnicatInterview> candidates = [];
  String? excelDownloadUrl;

  @override
  void initState() {
    super.initState();
    fetchPositions();
  }

  Future<void> fetchCandidates(String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/technical-interview-passed-for-jobform/$positionId'));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          candidates = data
              .map((item) => CandidateTechnicatInterview.fromJson(item))
              .toList();
        });

        await fetchInterviewDates(positionId);
      } else {
        print('Failed to fetch candidates: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<void> fetchPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    try {
      final response =
          await http.get(Uri.parse('${baseUrl}/JobForm/OpenPos/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          positions = data.map((item) => Position.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch positions: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching positions: $e');
    }
  }

  Future<void> fetchInterviewDates(String positionId) async {
    for (var candidate in candidates) {
      await fetchTechnicalInterviewDate(candidate, positionId);
      await fetchPhysicalInterviewDate(candidate, positionId);
    }
  }

  Future<void> fetchTechnicalInterviewDate(
      CandidateTechnicatInterview candidate, String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/${candidate.id}/jobform/$positionId/technical-assessment-date'));
      print('tech_date: ${response.statusCode} --> ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          candidate.technicalInterviewDate = DateTime.parse(data['data']);
        });
      } else {
        print(
            'Failed to fetch technical interview date: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching technical interview date: $e');
    }
  }

  Future<void> fetchPhysicalInterviewDate(
      CandidateTechnicatInterview candidate, String positionId) async {
    try {
      final response = await http.get(Uri.parse(
          '${baseUrl}/OpenPosCV/${candidate.id}/jobform/$positionId/physical-interview-date'));
      print('ph_date: ${response.statusCode} --> ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          candidate.physicalInterviewDate = DateTime.parse(data['data']);
        });
      } else {
        print(
            'Failed to fetch physical interview date: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching physical interview date: $e');
    }
  }

  Future<Map<String, String>> fetchCandidateInfo(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl}/OpenPosCV/$userId/contact-info'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return {
          'fullName': data['fullName'],
          'phoneNumber': data['phoneNumber'],
          'email': data['email'],
        };
      } else {
        print('Failed to fetch candidate info: ${response.reasonPhrase}');
        return {};
      }
    } catch (e) {
      print('Error fetching candidate info: $e');
      return {};
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

  Future<void> _showCandidateInfo(
      BuildContext context, CandidateTechnicatInterview candidate) async {
    Map<String, String> candidateInfo =
        await fetchCandidateInfo(candidate.userId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            candidateInfo['fullName'] ?? 'Candidate Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: mainAppColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.phone, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      candidateInfo['phoneNumber'] ?? 'N/A',
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
                      candidateInfo['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.description, color: mainAppColor),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        candidate.filePath,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Call'),
              onPressed: () {
                _launchPhoneCall(candidateInfo['phoneNumber']!);
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

  Future<void> exportToExcel(int jobFormId) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final url =
          '$baseUrl/OpenPosCV/export-technical-interview-passed-for-jobform/$jobFormId';
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);

      if (response.statusCode == 200) {
        try {
          final bytes = response.bodyBytes;

          Directory? directory = await getExternalStorageDirectory();
          if (directory != null) {
            final documentsPath = '${directory.path}/Documents';
            final documentsDirectory = Directory(documentsPath);
            if (!documentsDirectory.existsSync()) {
              documentsDirectory.createSync(recursive: true);
            }

            final file = File('$documentsPath/technical_interview_result.xlsx');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Interview Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
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
                value: selectedPositionId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPositionId = newValue;
                    fetchCandidates(newValue!);
                  });
                },
                items: positions.map((Position position) {
                  return DropdownMenuItem<String>(
                    value: position.jobId?.toString(),
                    child: Center(
                      child: Text(
                        position.title,
                        style: TextStyle(
                          color: mainAppColor,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                hint: Center(
                  child: Text(
                    'Choose Position',
                    style: TextStyle(
                      fontSize: 22,
                      color: mainAppColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: candidates.isEmpty
                ? Center(child: Text('No candidates available'))
                : ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      CandidateTechnicatInterview candidate = candidates[index];
                      String candidateName = candidate.userFullName;
                      String technicalInterviewDate =
                          candidate.technicalInterviewDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(candidate.technicalInterviewDate!)
                              : 'Interview Date not available';
                      String physicalInterviewDate =
                          candidate.technicalInterviewDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(candidate.technicalInterviewDate!)
                              : 'Interview Date not available';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: cardsBackgroundColor,
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              candidateName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Text(
                                  'Technical Interview Date: $technicalInterviewDate',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Physical Interview Date: $physicalInterviewDate',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.contact_phone,
                                  color: mainAppColor),
                              onPressed: () {
                                _showCandidateInfo(context, candidate);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          CustomButton(
            text: 'Export to excel',
            onPressed: () {
              if (selectedPositionId != null && selectedPositionId!.isNotEmpty) {
                exportToExcel(int.parse(selectedPositionId!));
              } else {
                print('No position selected');
              }
            },
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
