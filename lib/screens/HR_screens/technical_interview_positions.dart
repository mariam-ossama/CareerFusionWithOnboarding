
import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class TechnicalInterviewPositionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Positions',
        style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.builder(
        itemCount: openPositions.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(openPositions[index], style: TextStyle(//fontFamily: appFont
              ),),
              onTap: () {
                Navigator.pushNamed(context, 'TechnicalInterviewModelsPage');
              },
            ),
          );
        },
      ),
    );
  }
}

List<String> openPositions = ['Position 1', 'Position 2', 'Position 3'];