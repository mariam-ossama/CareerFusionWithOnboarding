import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate_cv_screening.dart';
import 'package:career_fusion/screens/HR_screens/cv_insights_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';

class PostCVScreeningResult extends StatefulWidget {
  final int postId;

  const PostCVScreeningResult({Key? key, required this.postId})
      : super(key: key);

  @override
  State<PostCVScreeningResult> createState() => _PostCVScreeningResultState();
}

class _PostCVScreeningResultState extends State<PostCVScreeningResult> {
  String? selectedPosition;
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];
  Map<String, List<String>> positionPDFs = {
    'Position 1': ['CV1.pdf', 'CV2.pdf'],
    'Position 2': ['CV3.pdf', 'CV4.pdf'],
    'Position 3': ['CV5.pdf', 'CV6.pdf'],
  };

  List<CandidateCVScreening> screenedCVs = [];

  @override
  void initState() {
    super.initState();
    fetchScreenedCVs();
  }

  Future<void> fetchScreenedCVs() async {
    try {
      var response = await http.get(
        Uri.parse('https://flask-deployment-hev4.onrender.com/get-matched-cvs'),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<CandidateCVScreening> cvScreenings =
            jsonList.map((e) => CandidateCVScreening.fromJson(e)).toList();

        setState(() {
          screenedCVs = cvScreenings;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch screened CVs'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching screened CVs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching screened CVs'),
        ),
      );
    }
  }

  void _showCandidateContactDialog(CandidateCVScreening cv) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            cv.fileName,
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
                    cv.phoneNumber,
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
                    cv.email,
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
            TextButton(
              child: Text('Call'),
              onPressed: () {
                _launchPhoneCall(cv.phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  void _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildCVCard(CandidateCVScreening cv) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ListTile(
        leading: Icon(Icons.description, color: mainAppColor),
        title: Text(
          cv.fileName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.contact_phone,
            color: mainAppColor,
          ),
          onPressed: () {
            _showCandidateContactDialog(cv);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CVInsightsPage(candidate: cv),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV Screening Result',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
              child: Center(
                child: DropdownButton<String>(
                  iconEnabledColor: Colors.white,
                  isExpanded: true,
                  value: selectedPosition,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPosition = newValue;
                    });
                  },
                  items: positions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: screenedCVs.length,
              itemBuilder: (context, index) {
                CandidateCVScreening cv = screenedCVs[index];
                return buildCVCard(cv);
              },
            ),
          ),
          CustomButton(
            text: 'Export to excel',
            onPressed: () {
              // TODO: Implement export to Excel functionality
            },
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
