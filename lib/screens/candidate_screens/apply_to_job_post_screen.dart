import 'dart:io';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApplyToJobPostPage extends StatefulWidget {
  final int postId;

  ApplyToJobPostPage({required this.postId});

  @override
  _SubmitApplicationScreenState createState() =>
      _SubmitApplicationScreenState();
}

class _SubmitApplicationScreenState extends State<ApplyToJobPostPage> {
  final TextEditingController _coverLetterController = TextEditingController();
  String? _cvFilePath;

  void _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      setState(() {
        _cvFilePath = result.files.single.path;
      });
    }
  }

  void _submitApplication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (_cvFilePath == null) {
      // No CV selected
      return;
    }

    File? file = File(_cvFilePath!);
    if (!file.existsSync()) {
      // File does not exist
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://10.0.2.2:5266/api/CVUpload/${widget.postId}/upload-postcv?userId=${userId}'),
    );

    request.files.add(await http.MultipartFile.fromPath('cvFile', file.path));

    try {
      var response = await request.send();
      print(response.statusCode);

      if (response.statusCode == 200) {
        // CV uploaded successfully
        print('CV uploaded successfully');
        _showSuccessSnackBar();
      } else {
        // Error uploading CV
        print('Error uploading CV: ${response.reasonPhrase}');
        // Print response body for more details
        print(await response.stream.bytesToString());
      }
    } catch (e) {
      print('Error uploading CV: $e');
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your CV has been uploaded successfully.'),
        //backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submit Application',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: cardsBackgroundColor,
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'To apply for any job, please upload your CV using the template found in your profile\'s "My CV" section. Ensure to fill out the template before applying.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                /*Text(
                  'Type Your Cover Letter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _coverLetterController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Cover letter...',
                    border: OutlineInputBorder(),
                  ),
                ),*/
                SizedBox(height: 16.0),
                if (_cvFilePath != null)
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.description,
                              color: mainAppColor, size: 40),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'CV Uploaded: ${_cvFilePath!.split('/').last}',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: appFont,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                CustomButton(
                  text: 'Upload Your CV',
                  onPressed: _pickCV,
                ),
                SizedBox(height: 16.0),
                CustomButton(
                  text: 'Submit',
                  onPressed: _submitApplication,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
