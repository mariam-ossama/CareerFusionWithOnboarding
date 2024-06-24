

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_cv_screening.dart';
import 'package:career_fusion/screens/HR_screens/cv_insights_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class PostCVScreeningResult extends StatefulWidget {
  const PostCVScreeningResult({super.key});

  @override
  State<PostCVScreeningResult> createState() => _PostCVScreeningResultState();
}

class _PostCVScreeningResultState extends State<PostCVScreeningResult> {
  String? selectedPosition; // Make this nullable
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];
  Map<String, List<String>> positionPDFs = {
    'Position 1': ['CV1.pdf', 'CV2.pdf'], // Example PDFs for Position 1
    'Position 2': ['CV3.pdf', 'CV4.pdf'], // Example PDFs for Position 2
    'Position 3': ['CV5.pdf', 'CV6.pdf'], // Example PDFs for Position 3
  };
  //int totalCVs = 10; // Total number of CVs for the position
  //int screenedCVs = 8; // Number of CVs that have been screened

  Widget buildCVCard(String pdfName) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ListTile(
        leading: Icon(Icons.description, color: mainAppColor),
        title: Text(
          pdfName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: Icon(Icons.contact_phone, color: mainAppColor),
        onTap: () {
          // TODO: Implement view/download PDF functionality
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CVInsightsPage(candidate: CandidateCVScreening(
              email: 'hhhhhhh',
              phoneNumber: 'jjjjjjjjjjjj',
              fileName: 'ffffffffff',
              filePath: 'http://hp',
              matchedSkills: ['aaaa','bbbbb','cccccccc']),)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String>? pdfs = positionPDFs[selectedPosition ?? ''];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Screening Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
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
          /*SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
                child: FAProgressBar(
              size: 10,
              progressColor: mainAppColor,
              backgroundColor: secondColor,
              currentValue:
                  selectedPosition != null ? (screenedCVs * 100 / totalCVs).toInt() : 0,
            )),
          ),*/
          Expanded(
            child: ListView.builder(
              itemCount: pdfs?.length ?? 0,
              itemBuilder: (context, index) {
                String pdfName = pdfs![index];
                return buildCVCard(pdfName);
              },
            ),
          ),
          CustomButton(
            text: 'Export to excel',
            onPressed: () {
              // TODO: Implement export to Excel functionality
            },
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}