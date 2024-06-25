import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/HR_screens/HR_post_recruitment.dart';
import 'package:career_fusion/widgets/custom_button.dart';

class HRPostCandidatesPage extends StatefulWidget {
  final int postId;

  const HRPostCandidatesPage({Key? key, required this.postId})
      : super(key: key);

  @override
  State<HRPostCandidatesPage> createState() => _HRPostCandidatesPageState();
}

class _HRPostCandidatesPageState extends State<HRPostCandidatesPage> {
  late List<String> cvPaths = [];

  @override
  void initState() {
    super.initState();
    fetchCVPaths();
  }

  Future<void> fetchCVPaths() async {
    final apiUrl = '${baseUrl}/CVUpload/${widget.postId}/cv-paths';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        cvPaths = List<String>.from(responseData);
      });
    } else {
      throw Exception('Failed to load CV paths');
    }
  }

  Future<void> downloadCV(String cvPath) async {
    try {
      var response = await http.get(Uri.parse(cvPath));
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/${cvPath.split('/').last}");
      print('file location:${file}');

      print(response.statusCode);
      print(response.body);

      await file.writeAsBytes(response.bodyBytes, flush: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV downloaded successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error downloading CV: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download CV'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Applied Candidates by Post',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: cvPaths.isNotEmpty
          ? Stack(
              children: [
                ListView.builder(
                  itemCount: cvPaths.length,
                  itemBuilder: (context, index) {
                    final cvPath = cvPaths[index];
                    return Card(
                      shadowColor: Colors.grey[500],
                      color: Color.fromARGB(255, 235, 233, 255),
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.description,
                          color: mainAppColor,
                        ),
                        title: Text(
                            cvPath.split('/').last), // Display only filename
                        onTap: () {
                          downloadCV(cvPath); // Call download function on tap
                        },
                      ),
                    );
                  },
                ),
                if (cvPaths.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Download all CVs',
                          onPressed: () {
                            // Handle download all CVs
                            for (var cvPath in cvPaths) {
                              downloadCV(cvPath);
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        CustomButton(
                          text: 'Go to Interviews',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HRPostRecruitmentPage(
                                    postId: widget.postId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
