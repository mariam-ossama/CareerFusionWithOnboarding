import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefineNeedsPage extends StatefulWidget {
  @override
  _DefineNeedsPageState createState() => _DefineNeedsPageState();
}

class _DefineNeedsPageState extends State<DefineNeedsPage> {
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController jobLocationController = TextEditingController();
  final TextEditingController jobTypeController = TextEditingController();
  List<TextEditingController> jobDescriptionsControllers = [
    TextEditingController()
  ];
  List<TextEditingController> jobResponsibilitiesControllers = [
    TextEditingController()
  ];
  List<TextEditingController> skillsQualificationsControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
  }

  void addJobDescriptionField() {
    setState(() {
      jobDescriptionsControllers.add(TextEditingController());
    });
  }

  void addJobResponsibilitiesField() {
    setState(() {
      jobResponsibilitiesControllers.add(TextEditingController());
    });
  }

  void addSkillsQualificationsField() {
    setState(() {
      skillsQualificationsControllers.add(TextEditingController());
    });
  }

  Future<void> submitJobForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    var url = Uri.parse(
        '${baseUrl}/jobform/add/$userId');
    var requestBody = {
      "JobTitle": jobTitleController.text,
      "JobType": jobTypeController.text,
      "JobLocation": jobLocationController.text,
      "JobSkills": skillsQualificationsControllers
          .map((controller) => {"SkillName": controller.text})
          .toList(),
      "JobDescriptions": jobDescriptionsControllers
          .map((controller) => {"Description": controller.text})
          .toList(),
      "JobResponsibilities": jobResponsibilitiesControllers
          .map((controller) => {"Responsibility": controller.text})
          .toList(),
    };

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['success']) {
        // Assuming response payload structure is as provided
        int jobId = data['payload']['jobId'];
        List<int> skillIds = List<int>.from(data['payload']['skillIds']);
        List<int> descriptionIds =
            List<int>.from(data['payload']['descriptionIds']);
        List<int> responsibilityIds =
            List<int>.from(data['payload']['responsibilityIds']);

        // Store the IDs as needed. For example, you could store them in SharedPreferences
        prefs.setInt('jobId', jobId);
        prefs.setString('skillIds', jsonEncode(skillIds));
        prefs.setString('descriptionIds', jsonEncode(descriptionIds));
        prefs.setString('responsibilityIds', jsonEncode(responsibilityIds));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job form added successfully')),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add job form: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Define Needs',
          style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomNamedField(text: 'Job Title'),
            CustomTextField(
              obsecureText: false,
              hint: 'Job Title',
              controllerText: jobTitleController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Location'),
            CustomTextField(
              obsecureText: false,
              hint: 'Job Location',
              controllerText: jobLocationController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Type'),
            CustomTextField(
              obsecureText: false,
              hint: 'Job Type',
              controllerText: jobTypeController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Description'),
            for (var controller in jobDescriptionsControllers)
              CustomTextField(
                obsecureText: false,
                  hint: 'Job Description', controllerText: controller),
            TextButton(
              onPressed: addJobDescriptionField,
              child: Text('Add More',
          style: TextStyle(
              //fontFamily: appFont,
              color: mainAppColor),
        ),
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Responsibilities'),
            for (var controller in jobResponsibilitiesControllers)
              CustomTextField(
                obsecureText: false,
                  hint: 'Job Responsibilities', controllerText: controller),
            TextButton(
              onPressed: addJobResponsibilitiesField,
              child: Text('Add More',
          style: TextStyle(
              //fontFamily: appFont,
              color: mainAppColor),)
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Skills/Qualifications'),
            for (var controller in skillsQualificationsControllers)
              CustomTextField(
                obsecureText: false,
                  hint: 'Skills/Qualifications', controllerText: controller),
            TextButton(
              onPressed: addSkillsQualificationsField,
              child: Text('Add More',
          style: TextStyle(
              //fontFamily: appFont,
              color: mainAppColor),),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Submit',
              onPressed: submitJobForm,
            ),
          ],
        ),
      ),
    );
  }
}
