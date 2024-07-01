

import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool? _reportAccepted;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Reports',
        style: TextStyle(color: Colors.white),),
        backgroundColor: mainAppColor,
      ),
      body: ListView(
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: cardsBackgroundColor,
              child: ListTile(
                title: Text('Report Title',
                style: TextStyle(
                  color: mainAppColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22
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
                title: Text('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh'),
              ),
            ),
          ),
          SizedBox(height: 5,),
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
            groupValue: _reportAccepted,
            onChanged: (bool? value) {
              setState(() {
                _reportAccepted = value;
              });
            },
          ),
          RadioListTile<bool>(
            title: const Text('Reject'),
            value: false,
            groupValue: _reportAccepted,
            onChanged: (bool? value) {
              setState(() {
                _reportAccepted = value;
              });
            },
          ),
        ],
      ),
    ),
  ),
)
        ],
      ),
    );
  }
}