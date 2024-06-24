// exam_preparation_screen.dart
import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_question.dart';

class ExamPreparationScreen extends StatefulWidget {
  @override
  _ExamPreparationScreenState createState() => _ExamPreparationScreenState();
}

class _ExamPreparationScreenState extends State<ExamPreparationScreen> {
  List<QuestionWidget> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exam Preparation',
          style: TextStyle(color: Colors.white,//fontFamily: appFont
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return QuestionWidget(
                  onDelete: () {
                    setState(() {
                      questions.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
          Container(
      width: 400,
      height: 60,
      child: ElevatedButton(
        onPressed: (){
          setState(() {
                questions.add(QuestionWidget());
              });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: mainAppColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'Add Question',
          style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              //fontFamily: appFont
              ),
        ),
      ),
    ),
          /*CustomButton(
            text: 'Add Question',
            onPressed: () {
              setState(() {
                questions.add(QuestionWidget());
              });
            },
          ),*/
          SizedBox(height: 10),
          CustomButton(
            text: 'Submit',
            onPressed: () {},
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
