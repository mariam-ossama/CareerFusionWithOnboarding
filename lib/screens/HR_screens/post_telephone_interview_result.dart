import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class PostTelephoneInterviewResultPage extends StatefulWidget {
  const PostTelephoneInterviewResultPage({super.key});

  @override
  State<PostTelephoneInterviewResultPage> createState() => _PostTelephoneInterviewResultPageState();
}

class _PostTelephoneInterviewResultPageState extends State<PostTelephoneInterviewResultPage> {
  // Dummy data for positions
  List<PostPosition> positions = [
    PostPosition(jobId: 1, title: 'Software Engineer'),
    PostPosition(jobId: 2, title: 'Data Scientist'),
    PostPosition(jobId: 3, title: 'Product Manager'),
  ];

  // Dummy data for candidates
  List<Map<String, dynamic>> candidates = [
    {
      'userId': '1',
      'userFullName': 'John Doe',
      'filePath': 'Resume.pdf',
      'phoneNumber': '123-456-7890',
      'email': 'john.doe@example.com',
    },
    {
      'userId': '2',
      'userFullName': 'Jane Smith',
      'filePath': 'Resume.pdf',
      'phoneNumber': '987-654-3210',
      'email': 'jane.smith@example.com',
    },
  ];

  PostPosition? selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Telephone In. Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
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
                value: selectedPosition?.jobId.toString(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPosition = positions.firstWhere(
                        (position) => position.jobId.toString() == newValue,
                      );
                    });
                  }
                },
                items: positions.map<DropdownMenuItem<String>>((PostPosition position) {
                  return DropdownMenuItem<String>(
                    value: position.jobId.toString(),
                    child: Center(
                      child: Text(
                        position.title,
                        style: TextStyle(
                          fontSize: 20,
                          color: mainAppColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                hint: Center(
                  child: Text(
                    'Choose Position',
                    style: TextStyle(
                      fontSize: 20,
                      color: mainAppColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          if (selectedPosition != null)
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  String candidateName = candidates[index]['userFullName'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          candidateName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          candidates[index]['filePath'],
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.contact_phone, color: mainAppColor),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    candidateName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: mainAppColor,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: mainAppColor),
                                          SizedBox(width: 7),
                                          Text(
                                            candidates[index]['phoneNumber'],
                                            style: TextStyle(
                                              fontSize: 18,
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
                                            candidates[index]['email'],
                                            style: TextStyle(
                                              fontSize: 18,
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
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (selectedPosition != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                text: 'Export to Excel',
                onPressed: () {
                  // Implement your export to Excel logic here
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PostPosition {
  final int jobId;
  final String title;

  PostPosition({required this.jobId, required this.title});

  // Dummy fromJson method
  factory PostPosition.fromJson(Map<String, dynamic> json) {
    return PostPosition(
      jobId: json['jobId'],
      title: json['title'],
    );
  }
}
