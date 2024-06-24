import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HiringPlanPage extends StatefulWidget {
  @override
  _HiringPlanPageState createState() => _HiringPlanPageState();
}

class _HiringPlanPageState extends State<HiringPlanPage> {
  bool isHiringNeedsExpanded = false;
  bool isAvailableStrategiesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hiring Plan',
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
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text(
              'Set Timeline',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                //fontFamily: appFont,
                fontSize: 20,
              ),
            ),
            tileColor: const Color.fromARGB(240, 240, 240, 240),
            onTap: () {
              Navigator.pushNamed(context, 'SetTimelinePage');
            },
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            indent: 8,
            endIndent: 8,
          ),
          SizedBox(
            height: 5,
          ),
          ExpansionTile(
            leading: Icon(Icons.business_center),
            title: Text(
              'Hiring Needs',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontFamily: appFont,
                  fontSize: 22),
            ),
            collapsedBackgroundColor: const Color.fromARGB(240, 240, 240, 240),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Define Needs',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'DefineNeedsPage');
                },
              ),
              ListTile(
                title: Text(
                  'Open Positions',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'OpenPositionsPage');
                },
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            indent: 8,
            endIndent: 8,
          ),
          SizedBox(
            height: 5,
          ),
          ExpansionTile(
            leading: Icon(Icons.lightbulb_outline),
            title: Text(
              'Available Strategies',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //fontFamily: appFont,
                  fontSize: 22),
            ),
            collapsedBackgroundColor: const Color.fromARGB(240, 240, 240, 240),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Write Post',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'WritePostPage');
                },
              ),
              ListTile(
                title: Text(
                  'Existing CVs',
                  style: TextStyle(
                      color: mainAppColor,
                      //fontFamily: appFont,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, 'ExistingCVsPage');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
