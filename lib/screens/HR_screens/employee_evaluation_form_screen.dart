import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/employee.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class EvaluationFormPage extends StatefulWidget {
  Employee employee;
  EvaluationFormPage({super.key, required this.employee});

  @override
  State<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends State<EvaluationFormPage> {
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
    );
  }
}


