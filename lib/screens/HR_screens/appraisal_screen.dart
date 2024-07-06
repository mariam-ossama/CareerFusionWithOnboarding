import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/employee.dart';
import 'package:career_fusion/models/goal.dart';
import 'package:career_fusion/screens/HR_screens/employee_evaluation_form_screen.dart';
import 'package:career_fusion/screens/HR_screens/employee_evaluation_form_screen1.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_employee_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CompanyEmployeesPage extends StatefulWidget {
  const CompanyEmployeesPage({super.key});

  @override
  State<CompanyEmployeesPage> createState() => _CompanyEmployeesPageState();
}

class _CompanyEmployeesPageState extends State<CompanyEmployeesPage> {
  List<Employee> employees = [];
  bool isLoading = true;
  List<Goal?> goals = [];
  List<dynamic> postEmployees= [];

  @override
  void initState() {
    super.initState();
    fetchGoals();
    fetchJobFormEmployees();
    fetchPostEmployees();
  }

  Future<void> fetchJobFormEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("User ID not found in shared preferences");
      }

      final url = '${baseUrl}/OpenPosCV/$userId/technical-interview-passed';
      final response = await http.get(Uri.parse(url));
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          employees = data.map((json) => Employee.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load employees");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }
  Future<void> fetchPostEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("User ID not found in shared preferences");
      }

      final url = '${baseUrl}/CVUpload/$userId/technical-interview-passed/all-posts';
      final response = await http.get(Uri.parse(url));

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          postEmployees = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load post employees");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<void> fetchGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("User ID not found in shared preferences");
      }

      final url = '${baseUrl}/Goals/hruser/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          goals = data.map((json) => Goal.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load goals");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<void> addGoal(String description) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception("User ID not found in shared preferences");
      }

      final url = '${baseUrl}/Goals/hruser/$userId';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description, 'score': 0}),
      );

      if (response.statusCode == 201) {
        final newGoal = Goal.fromJson(jsonDecode(response.body));
        setState(() {
          goals.add(newGoal);
        });
      } else {
        throw Exception("Failed to add goal");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      final url = '${baseUrl}/Goals/${goal.id}';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'description': goal.description, 'score': goal.score}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update goal");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      final url = '${baseUrl}/Goals/$goalId';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to delete goal");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Employee Appraisal',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: mainAppColor,
          bottom: TabBar(indicatorColor: secondColor, tabs: [
            Tab(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.group,
                color: Colors.white,
              ),
            ),
          ]),
        ),
        body: TabBarView(children: [
          buildGoalsForm(),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    buildJobFormEmployeeList("Job Form Employees", employees),
                    buildPostEmployeeList("Post Employees", postEmployees),
                  ],
                ),
        ]),
      ),
    );
  }

  Widget buildJobFormEmployeeList(String title, List<Employee> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            return EmployeeCard(
              employee_name: employees[index].userFullName!,
              employee_email: employees[index].userEmail!,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EvaluationFormPage(employee: employees[index]),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildPostEmployeeList(String title, List<dynamic> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: postEmployees.length,
          itemBuilder: (context, index) {
            return EmployeeCard(
              employee_name: postEmployees[index]['userFullName'],
              employee_email: postEmployees[index]['userEmail'],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostEmployeeEvaluationFormPage(employee: postEmployees[index]),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildGoalsForm() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              _buildQuestionForm(),
              _buildAddQuestionForm(),
              // Save button
              //Center(child: _buildSaveButton()),
            ],
          );
  }

  Widget _buildQuestionForm() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                goal!.description!,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'Selected Score: ${goal.score}' ?? '0',
                style: TextStyle(fontSize: 14),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: goal.id,
                    items: List.generate(10, (index) => index + 1)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        goal.score = value!;
                        updateGoal(goal);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: mainAppColor),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String editedGoal = goal.description!;
                          return AlertDialog(
                            title: Text('Edit Goal'),
                            content: TextField(
                              onChanged: (value) {
                                editedGoal = value;
                              },
                              controller: TextEditingController(
                                  text: goal.description!),
                              decoration: InputDecoration(
                                labelText: 'Enter your edited goal',
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
                                onPressed: () {
                                  setState(() {
                                    goal.description = editedGoal;
                                    updateGoal(goal);
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
                    onPressed: () async {
                      await deleteGoal(goal.id!);
                      setState(() {
                        goals.removeAt(index);
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

  String newQuestion = '';

  Widget _buildAddQuestionForm() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
        backgroundColor: secondColor, // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // BorderRadius
        ),
        minimumSize: const Size(400, 60), // Button size
      ),
          child: Text('Add Company Goal',
          style: TextStyle(color: mainAppColor, fontSize: 20),),
          
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add New Goal'),
                  content: TextField(
                    onChanged: (value) {
                      newQuestion = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter your goal',
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
                        if (newQuestion.isNotEmpty) {
                          addGoal(newQuestion);
                          setState(() {
                            goals.add(Goal(description: newQuestion, score: 1));
                          });
                        }
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
}
