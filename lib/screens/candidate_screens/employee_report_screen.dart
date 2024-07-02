import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_fusion/constants.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final response = await http.get(Uri.parse('${baseUrl}/Report/User/$userId'));
    print(userId);

    if (response.statusCode == 200) {
      setState(() {
        reports = json.decode(response.body);
        // Initialize report acceptance state for each report
        reports.forEach((report) {
          report['isAccepted'];
          markReportAsRead(report['reportId']);
        });
      });
    } else {
      // Handle the error
      print('Failed to load reports');
    }
  }

  Future<void> markReportAsRead(int reportId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print(userId);
    final response = await http.put(Uri.parse('${baseUrl}/Report/$reportId/Read?userId=$userId&isRead=true'));
    

    if (response.statusCode != 200) {
      // Handle the error
      print('Failed to mark report as read');
    }
  }

  Future<void> sendReportResponse(int reportId, bool accept) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print(userId);
    final response = await http.put(Uri.parse('${baseUrl}/Report/$reportId/Accept?userId=$userId&accept=$accept'));
    print(accept);
    if(response.statusCode == 200){

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your response is sent successfully.'),
        //backgroundColor: Colors.green,
      ),
      );

    }else{
      // Handle the error
      print('Failed to send report response');
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to send report response.: ${response.body}'),
        //backgroundColor: Colors.green,
      ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HR Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: secondColor,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: cardsBackgroundColor,
                      child: ListTile(
                        title: Text(
                          report['title'],
                          style: TextStyle(
                              color: mainAppColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: cardsBackgroundColor,
                      child: ListTile(
                        title: Text(report['text']),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: cardsBackgroundColor,
                      child: ListTile(
                        title: Text('Do you accept this report?'),
                        subtitle: Column(
                          children: [
                            RadioListTile<bool>(
                              title: const Text('Accept'),
                              value: true,
                              groupValue: report['accept'],
                              onChanged: (bool? value) {
                                value = true;
                                setState(() {
                                  report['accept'] = value;
                                  sendReportResponse(report['reportId'], true);
                                  print(report['reportId']);
                                });
                              },
                            ),
                            RadioListTile<bool>(
                              title: const Text('Reject'),
                              value: false,
                              groupValue: report['accept'],
                              onChanged: (bool? value) {
                                setState(() {
                                  value = false;
                                  report['accept'] = value;
                                  sendReportResponse(report['reportId'], false);
                                  print(report['reportId']);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
