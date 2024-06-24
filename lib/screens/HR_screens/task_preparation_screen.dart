import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class TaskPreparationScreen extends StatefulWidget {
  const TaskPreparationScreen({super.key});

  @override
  State<TaskPreparationScreen> createState() => _TaskPreparationScreenState();
}

class _TaskPreparationScreenState extends State<TaskPreparationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Preparation',
        style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              maxLines: 10, // Set to null to allow for infinite lines
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                fillColor: const Color.fromARGB(240, 240, 240, 255),
                hintText: 'write task...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () {
                    // Add your logic to handle image insertion
                  },
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    // Add your logic to handle attachments
                  },
                ),
                SizedBox(width: 220),
                /*FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.send),
                  backgroundColor: const Color.fromARGB(255, 108, 99, 255),
                  shape: CircleBorder(),
                )*/
              ],
            ),
            SizedBox(height: 50,),
            CustomButton(text: 'Save Task',
            onPressed: (){},),
            SizedBox(height: 10,),
            Container(
      width: 400,
      height: 60,
      child: ElevatedButton(
        onPressed: (){
          Navigator.pushNamed(context, 'UpdateTaskPage');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: secondColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'Edit Task',
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
      ),
    );
  }
}

