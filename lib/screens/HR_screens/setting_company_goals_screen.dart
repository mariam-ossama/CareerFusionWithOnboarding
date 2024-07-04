import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingGoalsPage extends StatefulWidget {
  const SettingGoalsPage({super.key});

  @override
  State<SettingGoalsPage> createState() => _SettingGoalsPageState();
}

class _SettingGoalsPageState extends State<SettingGoalsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goal Setting',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
    );
  }
}
