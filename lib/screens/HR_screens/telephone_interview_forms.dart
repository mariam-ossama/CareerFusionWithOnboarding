/*import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
class InterviewFormsPage extends StatelessWidget {

  InterviewFormsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview Forms',style: TextStyle(
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
        text: 'Create New Form',
        onPressed: () {
          // Show dialog box to create a new form
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create New Form', style: TextStyle(//fontFamily: appFont
                ),),
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Form Name',
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
                      Navigator.pushNamed(context, 'TelephoneInterviewFormPage');
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
        ],
        
      ),
       
    );
  }
}*/
