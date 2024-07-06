import 'dart:io';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PostTechnicalInterviewResultPage extends StatefulWidget {
  final int postId;

  const PostTechnicalInterviewResultPage({Key? key, required this.postId})
      : super(key: key);

  @override
  State<PostTechnicalInterviewResultPage> createState() =>
      _PostTechnicalInterviewResultPageState();
}

class _PostTechnicalInterviewResultPageState
    extends State<PostTechnicalInterviewResultPage> {
  List<Map<String, dynamic>> candidates = [];

  @override
  void initState() {
    super.initState();
    fetchCandidates();
  }

  Future<void> fetchCandidates() async {
    final url = '$baseUrl/CVUpload/technical-interview-passed/${widget.postId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedCandidates = [];

        for (var item in data) {
          fetchedCandidates.add({
            'postCVId': item['postCVId'],
            'userId': item['userId'],
            'userFullName': item['userFullName'],
            'userEmail': item['userEmail'],
            'filePath': item['filePath'],
          });
        }

        setState(() {
          candidates = fetchedCandidates;
        });
      } else {
        print('Failed to fetch candidates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching candidates: $e');
    }
  }

  Future<void> _showCandidateInfo(
      BuildContext context, String userId, String candidateName) async {
    final contactInfo = await fetchContactInfo(userId);
    if (contactInfo.isEmpty) {
      // Handle the error if the contact info is not available
      return;
    }

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
                      contactInfo['phoneNumber']!,
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
                      contactInfo['email']!,
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
                _callCandidate(contactInfo['phoneNumber']);
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

  Future<Map<String, String>> fetchContactInfo(String userId) async {
    final url = '$baseUrl/OpenPosCV/$userId/contact-info';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'fullName': data['fullName'],
          'phoneNumber': data['phoneNumber'],
          'email': data['email'],
        };
      } else {
        print('Failed to fetch contact info: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching contact info: $e');
      return {};
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

  Future<void> _exportToExcel() async {
    final url =
        '$baseUrl/CVUpload/export-technical-interview-passed/${widget.postId}';
    try {
      final response = await http.get(Uri.parse(url));
      print('_exportToExcel: ${response.statusCode} --> ${response.body}');
      if (response.statusCode == 200) {
        // Save the Excel file to device storage
        final bytes = response.bodyBytes;
        final directory = await getExternalStorageDirectory();
        final documentsDirectory =
              await Directory('${directory!.path}/Documents')
                  .create(recursive: true);
          final filePath = '${documentsDirectory.path}/Technical_interview_results.xlsx';
          File file = File(filePath);
          await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file downloaded to Downloads directory.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed to download Excel file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading Excel file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Interview Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                String candidateName = candidate['userFullName'] ?? '';
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      candidateName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      candidate['filePath'] ?? '',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.contact_phone, color: mainAppColor),
                      onPressed: () {
                        _showCandidateInfo(context, candidate['userId'],
                            candidate['userFullName'] ?? '');
                      },
                    ),
                    onTap: () {
                      // Handle tapping on the candidate tile
                    },
                  ),
                );
              },
            ),
          ),
          CustomButton(
            text: 'Export to excel',
            onPressed: () {
              _exportToExcel();
            },
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
