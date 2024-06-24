// custom_question.dart
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_question_answer.dart';

class QuestionWidget extends StatefulWidget {
  final VoidCallback? onDelete;

  QuestionWidget({Key? key, this.onDelete}) : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String questionText = '';
  List<OptionWidget> options = [];
  TextEditingController questionController = TextEditingController(); // Controller for the custom text field

  void _editQuestion() {
    String updatedQuestionText = questionText; // Store the current value
    TextEditingController updatedController = TextEditingController(text: questionText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Question",style: TextStyle(//fontFamily: appFont
          ),),
          content: CustomTextField( // Use the CustomTextField widget
          obsecureText: false,
            controllerText: updatedController,
            hint: 'Enter your question here',
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel",style: TextStyle(//fontFamily: appFont
              ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Update",style: TextStyle(//fontFamily: appFont
              ),),
              onPressed: () {
                setState(() {
                  questionText = updatedQuestionText; // Update the state with the new value
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomTextField( // Use the CustomTextField widget
                obsecureText: false,
                  controllerText: questionController,
                  hint: 'Enter your question here',
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: _editQuestion,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: widget.onDelete, // Call the onDelete callback
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Options:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return OptionWidget(
                onDelete: () {
                  setState(() {
                    options.removeAt(index);
                  });
                },
              );
            },
          ),
          SizedBox(height: 8.0),
          CustomButton(
            text: 'Add Option',
            onPressed: () {
              setState(() {
                options.add(OptionWidget());
              });
            },
          ),
        ],
      ),
    );
  }
}
