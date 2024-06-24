import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class CandidateTechnicalInterview extends StatefulWidget {
  final String candidate;

  CandidateTechnicalInterview({Key? key, required this.candidate})
      : super(key: key);

  @override
  State<CandidateTechnicalInterview> createState() =>
      _CandidateTechnicalInterviewState();
}

class _CandidateTechnicalInterviewState
    extends State<CandidateTechnicalInterview> {
  String? selectedExamModel;
  String? selectedTaskModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.candidate}',
          style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 370,
                decoration: ShapeDecoration(
                  color: mainAppColor,
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
                  value: selectedExamModel,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedExamModel = newValue;
                    });
                  },
                  items: <String>['Exam Model 1', 'Exam Model 2', 'Exam Model 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Center(
                          child: Text(
                            value,
                            style: TextStyle(
                              //fontFamily: appFont,
                              //color: mainAppColor
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  hint: Center(
                    child: Text(
                      'Choose Exam Model',
                      style: TextStyle(
                        //fontFamily: 'Montserrat-VariableFont_wght',
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                  value: selectedTaskModel,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTaskModel = newValue;
                    });
                  },
                  items: <String>['Task Model 1', 'Task Model 2', 'Task Model 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            //fontFamily: appFont,
                            color: mainAppColor
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  hint: Center(
                    child: Text(
                      'Choose Task Model',
                      style: TextStyle(
                        //fontFamily: appFont,
                        fontSize: 20,
                        color: mainAppColor
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Submit',
              onPressed: () {
                // Add functionality for submit button
              },

            ),
          ],
        ),
      ),
    );
  }
}
