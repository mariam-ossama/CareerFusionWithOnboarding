

import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class HRPostRecruitmentPage extends StatefulWidget {
  const HRPostRecruitmentPage({super.key});

  @override
  State<HRPostRecruitmentPage> createState() => _HRPostRecruitmentPageState();
}

class _HRPostRecruitmentPageState extends State<HRPostRecruitmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Recruitment',
          style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          ExpansionTile(
            leading: Icon(Icons.document_scanner_rounded),
            title: Text(
              'CV Screening',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontFamily: appFont,
                  fontSize: 22),
            ),
            collapsedBackgroundColor: const Color.fromARGB(240, 240, 240, 240),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Perform CV Screening',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostCVScreeningPage');
                },
              ),
              ListTile(
                title: Text(
                  'View Result',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostCVScreeningResult');
                },
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          ExpansionTile(
            leading: Icon(Icons.phone_in_talk_rounded),
            title: Text(
              'Telephone Interview',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontFamily: appFont,
                  fontSize: 22),
            ),
            collapsedBackgroundColor: const Color.fromARGB(240, 240, 240, 240),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Prepare Forms',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostTelephoneInterviewForm');
                },
              ),
              ListTile(
                title: Text(
                  'Selection Process',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostTelephoneInterviewSelectionProcessPage');
                },
              ),
              ListTile(
                title: Text(
                  'View Result',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostTelephoneInterviewResultPage');
                },
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          ExpansionTile(
            leading: Icon(Icons.task_rounded),
            title: Text(
              'Technical Interview',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontFamily: appFont,
                  fontSize: 22),
            ),
            collapsedBackgroundColor: const Color.fromARGB(240, 240, 240, 240),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Prepare Exam or Task',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  //Navigator.pushNamed(context, 'TechnicalInterviewPositionsPage');
                },
              ),
              ListTile(
                title: Text(
                  'Selection Process',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'PostTechnicalInterviewSelectionProcessPage');
                },
              ),
              ListTile(
                title: Text(
                  'View Result',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  //Navigator.pushNamed(context, 'TecnicalInterviewResultPage');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}