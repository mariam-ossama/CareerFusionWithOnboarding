import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/recommended_job.dart';
import 'package:career_fusion/widgets/recommended_job_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecommendedJobsPage extends StatefulWidget {
  const RecommendedJobsPage({super.key});

  @override
  State<RecommendedJobsPage> createState() => _RecommendedJobsPageState();
}

class _RecommendedJobsPageState extends State<RecommendedJobsPage> {
  List<RecommendedJob> jobs = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendedJobs();
  }

  Future<void> fetchRecommendedJobs() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = Uri.parse('http://10.0.2.2:5000/recommend-jobs/${userId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          jobs = data.map((job) => RecommendedJob.fromJson(job)).toList();
        });
      } else {
        throw Exception('Failed to fetch recommended jobs');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recommended for you',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Handle filter action
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return RecommendedJobCard(
            jobTitle: job.jobTitle,
            similarity: job.similarity,
          );
        },
      ),
    );
  }
}




