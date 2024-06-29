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

class Goal {
  int? id;
  String? hrUserId;
  String? description;
  int? score;
  String? createdAt;

  Goal({this.id, this.hrUserId, this.description, this.score, this.createdAt});

  Goal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hrUserId = json['hrUserId'];
    description = json['description'];
    score = json['score'] ?? 1; // Ensure score is not null
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['hrUserId'] = this.hrUserId;
    data['description'] = this.description;
    data['score'] = this.score;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
