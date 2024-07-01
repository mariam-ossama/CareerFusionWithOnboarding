import 'dart:convert';
import 'dart:io';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PostCVScreeningPage extends StatefulWidget {
  final int postId;

  const PostCVScreeningPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostCVScreeningPage> createState() => _PostCVScreeningPageState();
}

class _PostCVScreeningPageState extends State<PostCVScreeningPage> {
  TextEditingController positionController = TextEditingController();

  List<String>? selectedCVs; // List to store paths of selected CVs
  /*final TextEditingController minQualificationsController =
      TextEditingController();
  final TextEditingController prefQualificationsController =
      TextEditingController();*/
  List<TextEditingController> skillControllers =
      []; // List to manage skill controllers

  /*String? selectedPosition; // Make this nullable
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];
  Map<String, List<String>> positionPDFs = {
    'Position 1': ['CV1.pdf', 'CV2.pdf'], // Example PDFs for Position 1
    'Position 2': ['CV3.pdf', 'CV4.pdf'], // Example PDFs for Position 2
    'Position 3': ['CV5.pdf', 'CV6.pdf'], // Example PDFs for Position 3
  };*/

  Future<void> pickCVs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedCVs = result.paths.cast<String>();
      });
    } else {
      // User canceled the picker
      setState(() {
        selectedCVs = null;
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

  Widget buildCVCard(String cvPath) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(Icons.description, color: mainAppColor),
        title: Text(
          cvPath.split('/').last,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Widget buildScreenedCvCard(String fileName) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green),
        title: Text(
          fileName,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Future<void> uploadCVs() async {
    if (selectedCVs == null || selectedCVs!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one CV'),
        ),
      );
      return;
    }

    try {
      // Create multipart request for uploading CV files
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://flask-deployment-hev4.onrender.com/upload-cv'),
      );

      // Add files to the request
      for (var cvPath in selectedCVs!) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            cvPath,
          ),
        );
      }

      // Send request
      var response = await request.send();
      print(response.statusCode);

      // Check response status
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CVs uploaded successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload CVs'),
          ),
        );
      }
    } catch (e) {
      print('Error uploading CVs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading CVs'),
        ),
      );
    }
  }

  Future<void> screenCVs() async {
    if (selectedCVs == null || selectedCVs!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one CV'),
        ),
      );
      return;
    }

    List<String> skills = skillControllers
        .map((controller) => controller.text.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    // Prepare the JSON body for the request
    var requestBody = jsonEncode({
      "skills": skills,
    });

    try {
      var response = await http.post(
        Uri.parse('https://flask-deployment-hev4.onrender.com/match-cvs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CV screening completed successfully'),
          ),
        );

        // Parse the response JSON array
        List<dynamic> screenedCvs = jsonDecode(response.body);

        // Update the UI with screened CV cards
        setState(() {
          screenedCvs.forEach((cv) {
            String fileName = cv['file_name'];
            // Add the file name to the UI
            _screenedCvCards.add(buildScreenedCvCard(fileName));
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to screen CVs'),
          ),
        );
      }
    } catch (e) {
      print('Error screening CVs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error screening CVs'),
        ),
      );
    }
  }

  Future<void> addPosition(String positionController) async {
    if (positionController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a position')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://cv-screening.onrender.com/enter-positions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'position': positionController}),
    );
    print(positionController);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add position')),
      );
    }
  }

  Future<void> downloadExcel() async {
    // Request permission to access storage
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        // Get the directory to save the file
        Directory? downloadsDirectory = await getExternalStorageDirectory();

        if (downloadsDirectory != null) {
          String filePath = '${downloadsDirectory.path}/candidates.xlsx';
          final response = await http.get(Uri.parse('https://cv-screening.onrender.com/export-to-excel'));
          print(filePath);

          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Excel file downloaded successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to download Excel file')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading Excel file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  List<Widget> _screenedCvCards = []; // List to store screened CV cards

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post CV Screening',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          /*Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: secondColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPosition,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPosition = newValue;
                });
              },
              items: positions.map((String value) {
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
                    fontSize: 20,
                    color: mainAppColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),*/
          CustomNamedField(text: 'Enter a Position First'),
          CustomTextField(obsecureText: false,
          controllerText: positionController,
          hint: 'Enter Position',
          ),
          SizedBox(height: 10),
          CustomButton(
            text: 'Select CVs',
            onPressed: (){
              addPosition(positionController.text);
              pickCVs();
              },
          ),
          if (selectedCVs != null && selectedCVs!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Selected CVs:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                ...selectedCVs!.map((cvPath) => buildCVCard(cvPath)).toList(),
                SizedBox(height: 10),
                CustomButton(
                  text: 'Upload CVs',
                  onPressed: uploadCVs,
                ),
              ],
            ),
          SizedBox(height: 20),

          /*CustomNamedField(text: 'Qualifications'),
          SizedBox(height: 5),
          TextFormField(
            maxLines: 4,
            controller: minQualificationsController,
            decoration: InputDecoration(
              hintText: 'Write min. qualifications...',
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter minimum qualifications';
              }
              return null;
            },
          ),*/
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
          SizedBox(height: 20),
          CustomButton(
            text: 'Screen CVs',
            onPressed: () {
              if (selectedCVs != null && selectedCVs!.isNotEmpty) {
                screenCVs();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select at least one CV'),
                  ),
                );
              }
            },
          ),
          SizedBox(height: 20),
          if (_screenedCvCards.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screened CVs:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ..._screenedCvCards,
              ],
            ),
            CustomButton(text: 'Export to excel',
            onPressed: (){
              downloadExcel();
            },)
        ],
      ),
    );
  }
}
