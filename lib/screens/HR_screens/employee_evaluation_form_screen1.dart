


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/employee_evaluation_form.dart';
import 'package:career_fusion/models/evaluation_question.dart';
import 'package:career_fusion/models/question_actual_score.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostEmployeeEvaluationFormPage extends StatefulWidget {
  dynamic employee;
  PostEmployeeEvaluationFormPage({super.key, required this.employee});

  @override
  State<PostEmployeeEvaluationFormPage> createState() => _PostEmployeeEvaluationFormPageState();
}

class _PostEmployeeEvaluationFormPageState extends State<PostEmployeeEvaluationFormPage> {
  List<EvaluationQuestion> questions = [];
  List<dynamic> reports = [];
  String newQuestion = '';
  int newScore = 0;
  TextEditingController actualScoreController = TextEditingController();
  String overallScore = '';
  String status = '';
  bool sendButtonVisible = false; // Initialize to false initially
  int? createdReportId;
  int? latestReportId = 0;

  TextEditingController reportTitleController = TextEditingController();
  TextEditingController reportContentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    fetchReports();
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

    final url = '${baseUrl}/Evaluations/${widget.employee['userId']}/$userId/overallscore/$expectedScore';
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.employee['userFullName']} Evaluation Form',
            style: TextStyle(
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: mainAppColor,
          bottom: TabBar(
            indicatorColor: secondColor,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
            Tab(
              icon: Icon(Icons.rate_review, color: Colors.white,),
            ),
            Tab(
              icon: Icon(Icons.report, color: Colors.white,),
            ),
            Tab(
              icon: Icon(Icons.reply, color: Colors.white,),
            ),
          ]),
        ),
        body: TabBarView(
          children:[
            evaluation_form(),
            employee_report_creation(),
            employee_report_display(),
            ],),
            
      ),
    );
  }

  Widget employee_report_creation(){
    return ListView(
      children: [
        SizedBox(height: 10,),
        CustomNamedField(text: 'Report Title'),
        CustomTextField(obsecureText: false,
        hint: 'Enter report title',
        controllerText: reportTitleController,),
        SizedBox(height: 10,),
        CustomNamedField(text: 'Report Content'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
                controller: reportContentController,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Write report...',
                  border: OutlineInputBorder(),
                ),
              ),
        ),
        SizedBox(height: 10,),
        CustomButton(text: 'Save Report',
        onPressed: () async{
           await _createReport();
        },),
        SizedBox(height: 5,),
        CustomButton(text: 'Send to ${widget.employee['userFullName']}',
        onPressed: () async{
          _sendReport();
        },)
      ],
    );
  }

  Future<void> fetchReports() async {
    final response = await http.get(Uri.parse('${baseUrl}/Report/User/${widget.employee['userId']}'));
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      setState(() {
        reports = json.decode(response.body);
        // Initialize report acceptance state for each report
      });
    } else {
      // Handle the error
      print('Failed to load reports');
    }
  }


  Future<void> _createReport() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');


  final url = '${baseUrl}/Report/Create/$userId';
  print(userId);
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'title': reportTitleController.text,
      'text': reportContentController.text,
      'hrUserId': userId,
    }),
  );

  print(response.statusCode);
  print(response.body);

  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);
    // Handle success
    // Optionally, you can show a success message or update the UI
    setState(() {
      // Clear the text fields after successful submission
      reportTitleController.clear();
      reportContentController.clear();
      // Enable the send button after successful report creation
      latestReportId = responseData['reportId'];
      print(latestReportId);
    });
  } else {
    // Handle error: API request failed
    // You might want to show an error message or handle this case as needed
  }
}


  Future<void> _sendReport() async {

  // Get the latest report ID from the state or use another mechanism to track it // Replace with your mechanism to get the latest report ID
  print('Latest id in _send report: ${latestReportId}');

  final url = '${baseUrl}/Report/$latestReportId/SendTo/${widget.employee['userId']}';
  print(widget.employee['userId']);
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  print(response.statusCode);
  print(response.body);

  if (response.statusCode == 200) {
    // Handle success
    // Optionally, you can show a success message or update the UI
  } else {
    // Handle error: API request failed
    // You might want to show an error message or handle this case as needed
  }
}

  

  Widget employee_report_display(){
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
          color: secondColor,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                color: cardsBackgroundColor,
                child: ListTile(
                  title: Text(report['title'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mainAppColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    overflow: TextOverflow.ellipsis,
                  ),),
                ),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: cardsBackgroundColor,
                  child: ListTile(
                    title: Column(children: [
                      Row(
                        children: [Icon(Icons.person,color: mainAppColor,size: 16,),
                        SizedBox(width: 5,),
                        Text('${widget.employee['userFullName']}')],
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [Icon(Icons.email,color: mainAppColor,size: 16,),
                        SizedBox(width: 5,),
                        Text('${widget.employee['userEmail']}')],
                      )
                    ],)),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: cardsBackgroundColor,
                  child: ListTile(
                    title: Text(report['text'])),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: cardsBackgroundColor,
                  child: ListTile(
                    title: Text('Is Read: ${report['isRead'] == true? 'Yes' : 'No'}')),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: cardsBackgroundColor,
                  child: ListTile(title: Text('Is Accepted: ${report['isAccepted'] == true ? 'Accepted' : 'Rejected'}')),
                ),
              )
            ],
          ),
                ),
        );
      },
    );
  }

  Widget evaluation_form(){
    return SingleChildScrollView(
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
            userId: widget.employee['userId'],
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