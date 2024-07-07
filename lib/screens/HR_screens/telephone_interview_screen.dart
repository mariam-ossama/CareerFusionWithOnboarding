import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/telephone_interview_question_model.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TelephoneInterviewFormPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  TelephoneInterviewFormPage({required this.jobId, required this.jobTitle});

  @override
  _TelephoneInterviewFormPageState createState() =>
      _TelephoneInterviewFormPageState();
}

class _TelephoneInterviewFormPageState
    extends State<TelephoneInterviewFormPage> {
  String? selectedPosition; // Initial value
  String? selectedForm; // Initial value

  List<TelephoneInterviewQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        '${baseUrl}/JobForm/getTelephoneInterviewQuestionsByJobTitle/${widget.jobTitle}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        questions = data
            .map((json) => TelephoneInterviewQuestion.fromJson(json))
            .toList();
      });
    } else {
      print('Failed to load questions: ${response.statusCode}');
    }
  }

  Future<void> addQuestion(TelephoneInterviewQuestion question) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    final url =
        '${baseUrl}/JobForm/add-telephone-interview-questions/$userId/${widget.jobId}';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode([question.toJson()]),
    );

    if (response.statusCode == 200) {
// Assume question is successfully added to the server
      setState(() {
        questions.add(question);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      print('Question added successfully');
    } else {
// Handle HTTP error status codes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add question: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Failed to add question: ${response.statusCode}');
    }
  }

  Future<void> deleteQuestion(int questionId) async {
    final url =
        '${baseUrl}/JobForm/deletetelephoneinterviewquestion/$questionId/${widget.jobTitle}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        questions.removeWhere((question) => question.id == questionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      print('Question deleted successfully');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete question: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Failed to delete question: ${response.statusCode}');
    }
  }

  Future<void> updateQuestion(int questionId, String updatedQuestion) async {
    final url =
        '${baseUrl}/JobForm/update-telephone-interview-question?questionId=$questionId&jobTitle=${widget.jobTitle}';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id': questionId,
        'question': updatedQuestion,
        'jobTitle': widget.jobTitle,
      }),
    );
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Update the question in the local list
      setState(() {
        var index = questions.indexWhere((q) => q.id == questionId);
        if (index != -1) {
          questions[index].question = updatedQuestion;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      print('Question updated successfully');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update question: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Failed to update question: ${response.statusCode}');
    }
  }

  Widget _buildQuestionForm() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(question.question),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: mainAppColor),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String editedQuestion = question.question;
                          return AlertDialog(
                            title: Text('Edit Question'),
                            content: TextField(
                              onChanged: (value) {
                                editedQuestion = value;
                              },
                              controller: TextEditingController(
                                  text: question.question),
                              decoration: InputDecoration(
                                labelText: 'Enter your edited question',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Update'),
                                onPressed: () async {
                                  await updateQuestion(
                                      question.id, editedQuestion);
                                  Navigator.of(context).pop();
                                  print(question.id);
                                  print(editedQuestion);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: mainAppColor),
                    onPressed: () async {
                      await deleteQuestion(question.id);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  String newQuestion = '';

  Widget _buildAddQuestionForm() {
    return Column(
      children: [
        CustomButton(
          text: 'Add Question',
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add New Question'),
                  content: TextField(
                    onChanged: (value) {
                      newQuestion = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter your question',
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Finish'),
                      onPressed: () async {
                        final question = TelephoneInterviewQuestion(
                          0, // Temporary ID before it's replaced by the backend
                          newQuestion,
                          widget.jobTitle,
                        );
                        await addQuestion(question);
                        Navigator.of(context).pop();
                        newQuestion = '';
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: secondColor, // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // BorderRadius
        ),
        minimumSize: const Size(400, 60), // Button size
      ),
      child: Text(
        'Save',
        style: const TextStyle(
          fontSize: 20,
          color: mainAppColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.jobTitle} Form',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            // Display questions list here
            _buildQuestionForm(),
            // Form for adding new questions
            _buildAddQuestionForm(),
            // Save button
            //Center(child: _buildSaveButton()),
          ],
        ),
      ),
    );
  }
}
