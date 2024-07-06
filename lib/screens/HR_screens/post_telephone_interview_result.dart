import 'dart:convert';
import 'dart:io';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PostTelephoneInterviewResultPage extends StatefulWidget {
  final int postId;

  const PostTelephoneInterviewResultPage({Key? key, required this.postId})
      : super(key: key);

  @override
  State<PostTelephoneInterviewResultPage> createState() =>
      _PostTelephoneInterviewResultPageState();
}

class _PostTelephoneInterviewResultPageState
    extends State<PostTelephoneInterviewResultPage> {
  List<Map<String, dynamic>> candidates = []; // Updated to fetch from API
  PostPosition? selectedPosition;

  @override
  void initState() {
    super.initState();
    fetchPassedCandidates();
  }

  Future<void> fetchPassedCandidates() async {
    final url =
        '${baseUrl}/CVUpload/telephone-interview-passed/${widget.postId}';
    final response = await http.get(Uri.parse(url));

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        print('Received passed candidates data: $data'); // Debug print
        final List<Map<String, dynamic>> fetchedCandidates =
            await Future.wait(data.map((item) async {
          final contactUrl =
              '${baseUrl}/OpenPosCV/${item['userId']}/contact-info';
          final contactResponse = await http.get(Uri.parse(contactUrl));
          if (contactResponse.statusCode == 200) {
            final contactData = json.decode(contactResponse.body);
            return {
              'userId': item['userId'],
              'userFullName': item['userFullName'],
              'filePath': item['filePath'],
              'phoneNumber': contactData['phoneNumber'],
              'email': contactData['email'],
            };
          } else {
            throw 'Failed to fetch contact info: ${contactResponse.statusCode}';
          }
        }));

        print('Parsed passed candidates: $fetchedCandidates'); // Debug print
        setState(() {
          candidates = fetchedCandidates;
        });
      } catch (e) {
        print('Error fetching passed candidates: $e');
      }
    } else {
      print('Failed to fetch passed candidates: ${response.statusCode}');
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> _exportToExcel() async {
    final excelExportUrl =
        '${baseUrl}/CVUpload/export-telephone-interview-passed/${widget.postId}';
    try {
      final response = await http.get(Uri.parse(excelExportUrl));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final documentsDirectory =
              await Directory('${directory.path}/Documents')
                  .create(recursive: true);
          final filePath = '${documentsDirectory.path}/Telephone_interview_results.xlsx';
          File file = File(filePath);
          await file.writeAsBytes(bytes);

          _launchURL(filePath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel file downloaded successfully')),
          );
        } else {
          throw 'Failed to get downloads directory';
        }
      } else {
        print('Failed to export to Excel: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export to Excel')),
        );
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to Excel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Telephone Interview Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                String candidateName = candidates[index]['userFullName'];
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
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        candidates[index]['filePath'],
                        style: TextStyle(
                          color: Colors.grey,
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
                                  candidateName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: mainAppColor,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: mainAppColor),
                                          SizedBox(width: 7),
                                          Text(
                                            candidates[index]['phoneNumber'],
                                            style: TextStyle(
                                              fontSize: 16,
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
                                            candidates[index]['email'],
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                      _callCandidate(
                                          candidates[index]['phoneNumber']);
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
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              text: 'Export to Excel',
              onPressed: _exportToExcel,
            ),
          ),
        ],
      ),
    );
  }
}

class PostPosition {
  final int jobId;
  final String title;

  PostPosition({required this.jobId, required this.title});

  // Dummy fromJson method
  factory PostPosition.fromJson(Map<String, dynamic> json) {
    return PostPosition(
      jobId: json['jobId'],
      title: json['title'],
    );
  }
}
