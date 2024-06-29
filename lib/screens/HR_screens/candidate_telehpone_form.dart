import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/telephone_interview_question_model.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CandidateTelephoneFormPage extends StatefulWidget {
  final String jobTitle;

  CandidateTelephoneFormPage({required this.jobTitle});

  @override
  _CandidateTelephoneFormPageState createState() =>
      _CandidateTelephoneFormPageState();
}

class _CandidateTelephoneFormPageState
    extends State<CandidateTelephoneFormPage> {
  String? selectedPosition;
  String? selectedForm;

  List<TelephoneInterviewQuestion> questions = [];
  Map<String, String> answers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        '${baseUrl}/JobForm/getTelephoneInterviewQuestionsByJobTitle/${widget.jobTitle}';
    final response = await http.get(Uri.parse(url));

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<TelephoneInterviewQuestion> fetchedQuestions = data
            .map((item) => TelephoneInterviewQuestion.fromJson(item))
            .toList();
        setState(() {
          questions = fetchedQuestions;
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing questions data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to fetch questions: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Telephone Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(questions[index].question),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: mainAppColor),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String editedQuestion =
                                        questions[index].question;
                                    String editedAnswer =
                                        answers[questions[index].question] ??
                                            '';
                                    return AlertDialog(
                                      title: Text('Edit Question'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            onChanged: (value) {
                                              editedQuestion = value;
                                            },
                                            controller: TextEditingController()
                                              ..text = editedQuestion,
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Edit your question'),
                                          ),
                                          SizedBox(height: 10),
                                          TextField(
                                            onChanged: (value) {
                                              editedAnswer = value;
                                            },
                                            controller: TextEditingController()
                                              ..text = editedAnswer,
                                            decoration: InputDecoration(
                                                labelText: 'Edit your answer'),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Save'),
                                          onPressed: () {
                                            setState(() {
                                              questions[index].question =
                                                  editedQuestion;
                                              answers[editedQuestion] =
                                                  editedAnswer;
                                            });
                                            Navigator.of(context).pop();
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
                              onPressed: () {
                                setState(() {
                                  answers.remove(questions[index].question);
                                  questions.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        /*subtitle: TextField(
                          onChanged: (value) {
                            answers[questions[index].question] = value;
                          },
                          controller: TextEditingController()..text = answers[questions[index].question] ?? '',
                          decoration: InputDecoration(
                            hintText: 'Enter your answer',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),*/
                      );
                    },
                  ),
                ),
                CustomButton(
                  text: 'Add Question',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String newQuestion = '';
                        return AlertDialog(
                          title: Text('Add Question'),
                          content: TextField(
                            onChanged: (value) {
                              newQuestion = value;
                            },
                            decoration: InputDecoration(
                                labelText: 'Enter your question'),
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
                              onPressed: () {
                                setState(() {
                                  questions.add(TelephoneInterviewQuestion(
                                      0, newQuestion, widget.jobTitle));
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(400, 60),
                  ),
                  child: Text(
                    'Submit Form',
                    style: const TextStyle(fontSize: 20, color: mainAppColor),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
    );
  }
}
