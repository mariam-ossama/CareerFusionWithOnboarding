import 'dart:convert';
import 'package:career_fusion/screens/HR_screens/HR_post_recruitment.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:career_fusion/constants.dart';

class HRPostCandidatesPage extends StatefulWidget {
  final int postId;

  const HRPostCandidatesPage({Key? key, required this.postId}) : super(key: key);

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
      body: cvPaths != null
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
                          Icons.picture_as_pdf,
                          color: mainAppColor,
                        ),
                        title: Text(cvPath),
                        onTap: () {
                          // Handle tap to view or download CV
                          // You can implement this based on your requirements
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
                          text:'Download all CVs',
                          onPressed: () {
                            // Handle second button press
                          },
                        ),
                        SizedBox(height: 10),
                        CustomButton(
                          text:'Go to Interviews',
                          onPressed: () {
                             Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HRPostRecruitmentPage(),
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
