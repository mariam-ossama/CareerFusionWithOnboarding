import 'dart:convert';
import 'dart:io';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CVScreeningPage extends StatefulWidget {
  @override
  _CVScreeningPageState createState() => _CVScreeningPageState();
}

class _CVScreeningPageState extends State<CVScreeningPage> {
  List<File> selectedCVs = []; // List to store selected CV files
  final TextEditingController minQualificationsController =
      TextEditingController();
  final TextEditingController prefQualificationsController =
      TextEditingController();
  List<TextEditingController> skillControllers = []; // List to manage skill controllers
  String? selectedPosition; // Nullable string to store selected position
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];
  Map<String, List<String>> positionPDFs = {
    'Position 1': ['CV1.pdf', 'CV2.pdf'], // Example PDFs for Position 1
    'Position 2': ['CV3.pdf', 'CV4.pdf'], // Example PDFs for Position 2
    'Position 3': ['CV5.pdf', 'CV6.pdf'], // Example PDFs for Position 3
  };

  List<Map<String, dynamic>> uploadedFiles = []; // List to store uploaded files info
  List<Map<String, dynamic>> screenedResults = []; // List to store screened CV results

  Future<void> pickCVs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedCVs.addAll(result.paths.map((path) => File(path!)));
      });
    } else {
      // User canceled the picker
      setState(() {
        selectedCVs = [];
      });
    }
  }

  void addSkillField() {
    setState(() {
      skillControllers.add(TextEditingController());
    });
  }

  void removeSkillField(int index) {
    setState(() {
      skillControllers.removeAt(index);
    });
  }

  Widget buildCVCard(File cvFile) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(Icons.description, color: mainAppColor),
        title: Text(
          cvFile.path.split('/').last,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: mainAppColor,),
          onPressed: () {
            setState(() {
              selectedCVs.remove(cvFile);
            });
          },
        ),
      ),
    );
  }

  Widget buildScreenedCVCard(Map<String, dynamic> cvResult) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(Icons.file_copy, color: mainAppColor),
        title: Text(
          cvResult['file_name'],
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matched Skills: ${cvResult['matched_skills'].join(', ')}'),
            Text('Email: ${cvResult['contact_info']['email']}'),
            Text('Phone: ${cvResult['contact_info']['phone_number']}'),
          ],
        ),
      ),
    );
  }

  Future<void> uploadCVs() async {
    // Create multipart request for file upload
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://flask-deployment-hev4.onrender.com/upload-cv'),
    );

    // Add each selected CV file to the request
    for (var cv in selectedCVs) {
      request.files.add(await http.MultipartFile.fromPath('file', cv.path));
    }

    // Send the request
    http.StreamedResponse response = await request.send();
    
    print(response.stream);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Parse the response JSON
      List<dynamic> responseData = json.decode(await response.stream.bytesToString());

      // Update UI with uploaded files info
      setState(() {
        uploadedFiles = responseData.cast<Map<String, dynamic>>();
        selectedCVs = []; // Clear selected CVs after successful upload
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files uploaded successfully')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload files')),
      );
    }
  }

  Future<void> screenCVs() async {
    // Prepare skills list from skillControllers
    List<String> skills = skillControllers
        .map((controller) => controller.text.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    // Prepare request body
    Map<String, dynamic> requestBody = {
      'skills': skills,
    };

    // Send POST request to screen CVs
    final response = await http.post(
      Uri.parse('https://flask-deployment-hev4.onrender.com/match-cvs'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // Parse response JSON
      List<dynamic> responseData = json.decode(response.body);

      // Update UI with screened results
      setState(() {
        screenedResults = responseData.cast<Map<String, dynamic>>();
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to screen CVs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Screening',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView(
        children: [
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: secondColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1.0, style: BorderStyle.solid, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: DropdownButton<String>(
                  iconEnabledColor: Colors.white,
                  isExpanded: true,
                  value: selectedPosition,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPosition = newValue;
                    });
                  },
                  items: positions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                        //fontFamily: appFont,
                        fontSize: 20,
                        color: mainAppColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomButton(
                  text: 'Select CVs',
                  onPressed: pickCVs,
                ),
                if (selectedCVs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedCVs
                          .map((cv) => buildCVCard(cv))
                          .toList(),
                    ),
                  ),
                SizedBox(height: 10),
                CustomNamedField(text: 'Skills'),
                SizedBox(height: 15),
                ...List.generate(skillControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: skillControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Enter skill...',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: mainAppColor),
                          onPressed: () => removeSkillField(index),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 5),
                TextButton(
                  onPressed: addSkillField,
                  child: Text(
                    'Add More',
                    style: TextStyle(
                      color: mainAppColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                CustomButton(
                  text: 'Upload Selected CVs',
                  onPressed: () {
                    if (selectedCVs.isNotEmpty) {
                      uploadCVs();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one CV')),
                      );
                    }
                  },
                               ),
                SizedBox(height: 15),
                CustomButton(
                  text: 'Screen CVs',
                  onPressed: () {
                    if (skillControllers.isNotEmpty) {
                      screenCVs();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least one skill')),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                if (screenedResults.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Screened CVs:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: screenedResults
                            .map((cvResult) => buildScreenedCVCard(cvResult))
                            .toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
