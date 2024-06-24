
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class EditOpenPositionPage extends StatefulWidget {
  const EditOpenPositionPage({super.key});

  @override
  State<EditOpenPositionPage> createState() => _EditOpenPositionPageState();
}

class _EditOpenPositionPageState extends State<EditOpenPositionPage> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Define Needs',
          style: TextStyle(
              fontFamily: appFont, color: Colors.white),
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
              //controllerText: jobTitleController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Location'),
            CustomTextField(
              obsecureText: false,
              hint: 'Job Location',
              //controllerText: jobLocationController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Type'),
            CustomTextField(
              obsecureText: false,
              hint: 'Job Type',
              //controllerText: jobTypeController,
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Description'),
            /*for (var controller in jobDescriptionsControllers)
              CustomTextField(
                  hint: 'Job Description', controllerText: controller),*/
            TextButton(
              onPressed: addJobDescriptionField,
              child: Text('Add More'),
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Job Responsibilities'),
            for (var controller in jobResponsibilitiesControllers)
              CustomTextField(
                obsecureText: false,
                  hint: 'Job Responsibilities', controllerText: controller),
            TextButton(
              onPressed: addJobResponsibilitiesField,
              child: Text('Add More'),
            ),
            SizedBox(height: 10),
            CustomNamedField(text: 'Skills/Qualifications'),
            for (var controller in skillsQualificationsControllers)
              CustomTextField(
                obsecureText: false,
                  hint: 'Skills/Qualifications', controllerText: controller),
            TextButton(
              onPressed: addSkillsQualificationsField,
              child: Text('Add More'),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Submit',
              //onPressed: editJobForm,
            ),
          ],
        ),
      ),
    );
  }
}