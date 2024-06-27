import 'dart:convert';
import 'package:career_fusion/models/post_telephone_interview_question.dart';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/telephone_interview_question_model.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostTelephoneInterviewForm extends StatefulWidget {
  final int postId;
  const PostTelephoneInterviewForm({super.key, required this.postId});

  @override
  State<PostTelephoneInterviewForm> createState() =>
      _PostTelephoneInterviewFormState();
}

class _PostTelephoneInterviewFormState
    extends State<PostTelephoneInterviewForm> {
  String? selectedPosition; // Initial value
  String? selectedForm; // Initial value

  List<PostTelephoneInterviewQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        '${baseUrl}/TelephoneInterviewQuestions/getTelephoneInterviewQuestionsByPost/${widget.postId}';
    final response = await http.get(Uri.parse(url));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        questions = data
            .map((json) => PostTelephoneInterviewQuestion.fromJson(json))
            .toList();
      });
    } else {
      print('Failed to load questions: ${response.statusCode}');
    }
  }

  Future<void> addQuestion(String questionText) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    final url =
        '${baseUrl}/TelephoneInterviewQuestions/add-telephone-interview-questions/${widget.postId}';
    final body = jsonEncode([
      {
        'questionId': 0, // Assuming 0 or a unique identifier for new questions
        'question': questionText
      }
    ]);

    print('Request URL: $url');
    print('Request Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    print('Response Body: ${response.body}');
    print('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      setState(() {
        questions.add(PostTelephoneInterviewQuestion(question: questionText));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      print('Question added successfully');
    } else {
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
        '${baseUrl}/TelephoneInterviewQuestions/delete-telephone-interview-question/${widget.postId}/${questionId}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        questions.removeWhere((question) => question.questionId == questionId);
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
        '${baseUrl}/TelephoneInterviewQuestions/update-telephone-interview-question/${widget.postId}/${questionId}';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'questionId': questionId,
        'question': updatedQuestion,
        //'jobTitle': widget.jobTitle,
      }),
    );
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      // Update the question in the local list
      setState(() {
        var index = questions.indexWhere((q) => q.questionId == questionId);
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
      print('Response Body: ${response.body}');
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
                                  await updateQuestion(question.questionId!,
                                      editedQuestion); // Error occurs here
                                  Navigator.of(context).pop();
                                  print(question.questionId);
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
                      await deleteQuestion(question.questionId!);
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
                        await addQuestion(newQuestion);
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
          'Telephone In. Post Form',
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
            Center(child: _buildSaveButton()),
          ],
        ),
      ),
    );
  }
}
