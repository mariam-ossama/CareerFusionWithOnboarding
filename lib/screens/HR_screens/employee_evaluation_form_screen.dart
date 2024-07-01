import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/employee.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EvaluationFormPage extends StatefulWidget {
  final Employee employee;

  EvaluationFormPage({Key? key, required this.employee}) : super(key: key);

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
  List<EvaluationQuestion> questions = [];
  String newQuestion = '';
  int newScore = 0;
  TextEditingController actualScoreController = TextEditingController();
  String overallScore = '';
  String status = '';

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      // Handle error: user ID not found
      return;
    }

    final url = '${baseUrl}/Evaluations/$userId/questions';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        questions = data.map((item) => EvaluationQuestion.fromJson(item)).toList();
      });
    } else {
      // Handle error: API request failed
    }
  }

  Future<void> _addQuestion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      // Handle error: user ID not found
      return;
    }

    final url = '${baseUrl}/Evaluations/$userId/questions';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'question': newQuestion,
        'defaultScore': newScore,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        questions.add(EvaluationQuestion(
          question: newQuestion,
          defaultScore: newScore,
        ));
      });
    } else {
      // Handle error: API request failed
    }
  }

  Future<void> _submitEvaluationScores(List<QuestionActualScore> scores) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      // Handle error: user ID not found
      return;
    }

    final url = '${baseUrl}/Evaluations/$userId/questions/scores';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(scores.map((score) => score.toJson()).toList()),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      // Handle success
      // Optionally, you can navigate to a success screen or show a success message
    } else {
      // Handle error: API request failed
    }
  }

  Future<void> _calculateFinalResult(int expectedScore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      // Handle error: user ID not found
      return;
    }

    final url = '${baseUrl}/Evaluations/${widget.employee.userId}/$userId/overallscore/$expectedScore';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      EmployeeEvaluationForm evaluationForm = EmployeeEvaluationForm.fromJson(responseData['userEvaluation']);

      setState(() {
      overallScore = evaluationForm.overallScore.toString();
      status = responseData['status'];
    });
    } else {
      // Handle error: API request failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.employee.userFullName} Evaluation Form',
          style: TextStyle(
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: mainAppColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
  padding: const EdgeInsets.all(8.0),
  child: Card(
    shadowColor: Colors.grey,
    color: cardsBackgroundColor,
    child: ListTile(
      title: Text('Overall Score: $overallScore'), // Display overall score
      subtitle: Text('Status: $status'), // Display status
    ),
  ),
),
            SizedBox(height: 10),
            _buildQuestionForm(),
            _buildAddQuestionForm(),
            Center(child: _buildSaveButton()),
            SizedBox(height: 13,),
            Center(child: _buildDisplayOverallResult()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionForm() {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: questions.length,
    itemBuilder: (context, index) {
      final question = questions[index];
      final TextEditingController actualScoreController = TextEditingController(); // Create controller for each question

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(question.question ?? ''),
            subtitle: Row(
              children: [
                SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: actualScoreController, // Use specific controller for each question
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      question.defaultScore = int.tryParse(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter actual score',
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Expected Score: ${question.defaultScore ?? 0}'),
                IconButton(
                  icon: Icon(Icons.edit, color: mainAppColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String editedQuestion = question.question ?? '';
                        int editedScore = question.defaultScore ?? 0;

                        return AlertDialog(
                          title: Text('Edit Question'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  editedQuestion = value;
                                },
                                controller: TextEditingController(
                                  text: question.question,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Enter your edited question',
                                ),
                              ),
                              TextField(
                                onChanged: (value) {
                                  editedScore = int.tryParse(value) ?? 0;
                                },
                                controller: TextEditingController(
                                  text: question.defaultScore.toString(),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Enter expected score',
                                ),
                                keyboardType: TextInputType.number,
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
                              child: Text('Update'),
                              onPressed: () {
                                setState(() {
                                  question.question = editedQuestion;
                                  question.defaultScore = editedScore;
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
                      questions.removeAt(index);
                    });
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
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          newQuestion = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter your question',
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          newScore = int.tryParse(value) ?? 0;
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter expected score',
                        ),
                        keyboardType: TextInputType.number,
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
                      child: Text('Finish'),
                      onPressed: () async {
                        await _addQuestion();
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        List<QuestionActualScore> scores = [];

        // Populate scores list from questions
        questions.forEach((question) {
          int scoreToSubmit = question.defaultScore ?? 0; // Default to question's default score

          // Check if actualScoreController has a value and use that instead
          if (actualScoreController.text.isNotEmpty) {
            scoreToSubmit = int.tryParse(actualScoreController.text) ?? 0;
          }

          scores.add(QuestionActualScore(
            userId: widget.employee.userId,
            questionId: question.id,
            score: scoreToSubmit,
          ));
        });

        await _submitEvaluationScores(scores);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(400, 60),
      ),
      child: Text(
        'Submit Evaluation Scores',
        style: const TextStyle(
          fontSize: 20,
          color: mainAppColor,
        ),
      ),
    );
  }

  Widget _buildDisplayOverallResult() {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            int expectedScore = 0;

            return AlertDialog(
              title: Text('Enter Expected Overall Score'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      expectedScore = int.tryParse(value) ?? 0;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter expected overall score',
                    ),
                    keyboardType: TextInputType.number,
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
                  child: Text('Display'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _calculateFinalResult(expectedScore);
                  },
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: secondColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: const Size(400, 60),
      ),
      child: Text(
        'Display Result',
        style: const TextStyle(
          fontSize: 20,
          color: mainAppColor,
        ),
      ),
    );
  }
}

class EmployeeEvaluationForm {
  String? userId;
  double? overallScore; // Change from int? to double?
  List<EvaluationQuestion>? questions;
  String? comparisonResult;

  EmployeeEvaluationForm({
    this.userId,
    this.overallScore,
    this.questions,
    this.comparisonResult,
  });

  EmployeeEvaluationForm.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    overallScore = json['overallScore']?.toDouble(); // Convert to double
    if (json['questions'] != null) {
      questions = <EvaluationQuestion>[];
      json['questions'].forEach((v) {
        questions!.add(EvaluationQuestion.fromJson(v));
      });
    }
    comparisonResult = json['comparisonResult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['overallScore'] = overallScore;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    data['comparisonResult'] = comparisonResult;
    return data;
  }
}

class QuestionActualScore {
  String? userId;
  int? questionId;
  int? score;

  QuestionActualScore({this.userId, this.questionId, this.score});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['questionId'] = this.questionId;
    data['score'] = this.score;
    return data;
  }
}

class EvaluationQuestion {
  int? id;
  String? hrId;
  String? question;
  int? defaultScore;

  EvaluationQuestion({
    this.id,
    this.hrId,
    this.question,
    this.defaultScore,
  });

  EvaluationQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hrId = json['hrId'];
    question = json['question'];
    defaultScore = json['defaultScore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hrId'] = hrId;
    data['question'] = question;
    data['defaultScore'] = defaultScore;
    return data;
  }
}



