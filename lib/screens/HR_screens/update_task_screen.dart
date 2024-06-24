import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class UpdateTaskPage extends StatefulWidget {
  const UpdateTaskPage({super.key});

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task',
        style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              maxLines: 10, // Set to null to allow for infinite lines
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                fillColor: const Color.fromARGB(240, 240, 240, 255),
                //hintText: 'update task...',
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
            CustomButton(text: 'Save Updates',
            onPressed: (){},),
          ],
        ),
      ),
    );
  }
}