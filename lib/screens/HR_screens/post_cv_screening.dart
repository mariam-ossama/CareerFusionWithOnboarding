
import 'package:file_picker/file_picker.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:flutter/material.dart';

class PostCVScreeningPage extends StatefulWidget {
  const PostCVScreeningPage({super.key});

  @override
  State<PostCVScreeningPage> createState() => _PostCVScreeningPageState();
}

class _PostCVScreeningPageState extends State<PostCVScreeningPage> {
  List<String>? selectedCVs; // List to store paths of selected CVs
  final TextEditingController minQualificationsController = TextEditingController();
  final TextEditingController prefQualificationsController = TextEditingController();
  List<TextEditingController> skillControllers = []; // List to manage skill controllers

  String? selectedPosition; // Make this nullable
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];
  Map<String, List<String>> positionPDFs = {
    'Position 1': ['CV1.pdf', 'CV2.pdf'], // Example PDFs for Position 1
    'Position 2': ['CV3.pdf', 'CV4.pdf'], // Example PDFs for Position 2
    'Position 3': ['CV5.pdf', 'CV6.pdf'], // Example PDFs for Position 3
  };

  void screenCVs() {
    // Logic to screen CVs based on qualifications
    // This would involve backend logic to process CVs
    print('Screening CVs with selected files: $selectedCVs');
  }

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
        children: [
          SizedBox(height: 5,),
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
                            color: mainAppColor
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
                  text: 'Upload CVs',
                  onPressed: pickCVs,
                ),
                if (selectedCVs != null && selectedCVs!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedCVs!.map((cv) => buildCVCard(cv)).toList(),
                    ),
                  ),
                
          SizedBox(
            height: 5,
          ),
                SizedBox(height: 30),
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
                SizedBox(height: 15),
                CustomButton(
                  text: 'Screen CVs',
                  onPressed: () {
                    if (selectedCVs != null && selectedCVs!.isNotEmpty) {
                      screenCVs();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one CV')),
                      );
                    }
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