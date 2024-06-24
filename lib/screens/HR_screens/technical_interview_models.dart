import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
class TechnicalInterviewModelsPage extends StatelessWidget {

  TechnicalInterviewModelsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Models and Tasks',style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          // Show list of previously prepared telephone interview forms
          // If there are no forms, show a button to create a new form
          // else, show the list of forms
          // Implement the UI accordingly based on your needs
          SizedBox(height: 20,),
          CustomButton(
        text: 'Create New Model',
        onPressed: () {
          // Show dialog box to create a new form
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create New Model', style: TextStyle(//fontFamily: appFont
                ),),
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Model Name',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel', style: TextStyle(//fontFamily: appFont
                    ),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Create', style: TextStyle(//fontFamily: appFont
                    ),),
                    onPressed: () {
                      // Implement logic to create a new form
                      // Get the name from the text field
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, 'ExamPreparationScreen');
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      SizedBox(height: 10,),
      Container(
      width: 400,
      height: 60,
      child: ElevatedButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create New Task', style: TextStyle(//fontFamily: appFont
                ),),
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel', style: TextStyle(//fontFamily: appFont
                    ),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Create', style: TextStyle(
                      //fontFamily: appFont
                    ),),
                    onPressed: () {
                      // Get the name from the text field
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, 'TaskPreparationScreen');
                    },
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: secondColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'Create New Task',
          style: const TextStyle(
              fontSize: 20,
              color: mainAppColor,
              //fontFamily: appFont
              ),
        ),
      ),
    ),
        ],
        
      ),
       
    );
  }
}
