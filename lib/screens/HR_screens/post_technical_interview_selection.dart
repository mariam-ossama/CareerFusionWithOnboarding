import 'package:flutter/material.dart';
import 'package:career_fusion/constants.dart';

class PostTechnicalInterviewSelectionProcessPage extends StatefulWidget {
  const PostTechnicalInterviewSelectionProcessPage({super.key});

  @override
  State<PostTechnicalInterviewSelectionProcessPage> createState() => _PostTechnicalInterviewSelectionProcessPageState();
}

class _PostTechnicalInterviewSelectionProcessPageState extends State<PostTechnicalInterviewSelectionProcessPage> {
  String? selectedPositionId;
  List<Map<String, String>> positions = [
    {'jobId': '1', 'title': 'Software Developer'},
    {'jobId': '2', 'title': 'Data Scientist'},
    {'jobId': '3', 'title': 'Project Manager'},
  ];

  List<Map<String, String>> candidates = [];
  DateTime? selectedTechnicalInterviewDate;
  DateTime? selectedPhysicalInterviewDate;

  void fetchCandidates(String positionId) {
    // Hardcoded candidate data for each position
    Map<String, List<Map<String, String>>> allCandidates = {
      '1': [
        {'userId': '1', 'userFullName': 'Alice Johnson', 'filePath': 'resume_alice.pdf'},
        {'userId': '2', 'userFullName': 'Bob Smith', 'filePath': 'resume_bob.pdf'},
      ],
      '2': [
        {'userId': '3', 'userFullName': 'Charlie Brown', 'filePath': 'resume_charlie.pdf'},
      ],
      '3': [
        {'userId': '4', 'userFullName': 'David Wilson', 'filePath': 'resume_david.pdf'},
        {'userId': '5', 'userFullName': 'Eve Davis', 'filePath': 'resume_eve.pdf'},
      ],
    };

    setState(() {
      candidates = allCandidates[positionId] ?? [];
    });
  }

  Future<void> _showCandidateInfo(BuildContext context, Map<String, String> candidate) async {
    // Hardcoded candidate info
    Map<String, Map<String, String>> candidateInfo = {
      '1': {'fullName': 'Alice Johnson', 'phoneNumber': '123-456-7890', 'email': 'alice@example.com'},
      '2': {'fullName': 'Bob Smith', 'phoneNumber': '234-567-8901', 'email': 'bob@example.com'},
      '3': {'fullName': 'Charlie Brown', 'phoneNumber': '345-678-9012', 'email': 'charlie@example.com'},
      '4': {'fullName': 'David Wilson', 'phoneNumber': '456-789-0123', 'email': 'david@example.com'},
      '5': {'fullName': 'Eve Davis', 'phoneNumber': '567-890-1234', 'email': 'eve@example.com'},
    };

    final info = candidateInfo[candidate['userId']];

    if (info != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              info['fullName'] ?? 'Candidate Info',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: mainAppColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.phone, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      info['phoneNumber'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.email, color: mainAppColor),
                    SizedBox(width: 7),
                    Text(
                      info['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.description, color: mainAppColor),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        candidate['filePath'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectDateTime(BuildContext context, String candidateName, String interviewType) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        print('Selected $interviewType interview time for $candidateName: $selectedDateTime');

        if (interviewType == 'technical') {
          setState(() {
            selectedTechnicalInterviewDate = selectedDateTime;
          });
        } else if (interviewType == 'final') {
          setState(() {
            selectedPhysicalInterviewDate = selectedDateTime;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical & Physical Interviews',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: secondColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                iconEnabledColor: Colors.white,
                isExpanded: true,
                value: selectedPositionId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPositionId = newValue;
                    fetchCandidates(newValue!);
                  });
                },
                items: positions.map<DropdownMenuItem<String>>((position) {
                  return DropdownMenuItem<String>(
                    value: position['jobId'],
                    child: Center(
                      child: Text(
                        position['title'] ?? '',
                        style: TextStyle(
                          color: mainAppColor,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                hint: Center(
                  child: Text(
                    'Choose Position',
                    style: TextStyle(
                      fontSize: 22,
                      color: mainAppColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selectedPositionId != null) // Show candidates only if a position is selected
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: mainAppColor),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              candidate['userFullName'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.assignment_ind, color: mainAppColor),
                            onPressed: () => _selectDateTime(context, candidate['userFullName'] ?? '', 'technical'),
                            tooltip: 'Set Technical Interview',
                          ),
                          IconButton(
                            icon: Icon(Icons.schedule_outlined, color: mainAppColor),
                            onPressed: () => _selectDateTime(context, candidate['userFullName'] ?? '', 'final'),
                            tooltip: 'Set Final Interview',
                          ),
                          IconButton(
                            icon: Icon(Icons.contact_phone, color: mainAppColor),
                            onPressed: () => _showCandidateInfo(context, candidate),
                            tooltip: 'View Candidate Info',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
