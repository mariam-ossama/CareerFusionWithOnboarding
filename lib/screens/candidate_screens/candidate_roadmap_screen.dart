import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/roadmap_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateRoadmapPage extends StatefulWidget {
  const CandidateRoadmapPage({super.key});

  @override
  State<CandidateRoadmapPage> createState() => _CandidateRoadmapPageState();
}

class _CandidateRoadmapPageState extends State<CandidateRoadmapPage> {
  List<String> roadmaps = [];

   @override
  void initState() {
    super.initState();
    fetchRoadmaps();
  }


  Future<void> fetchRoadmaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = Uri.parse('http://10.0.2.2:5000/recommend_roadmaps/${userId}');
    
    try {
      final response = await http.get(url);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          roadmaps = List<String>.from(data['recommended_roadmaps']);
          print(roadmaps);
        });
      } else {
        throw Exception('Failed to fetch roadmaps');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Roadmap',
        style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: mainAppColor,
      ),
      body:  ListView.builder(
        itemCount: roadmaps.length,
        itemBuilder: (context, index) {
          return CustomCard(url: roadmaps[index]);
        },
      ),
    );
  }
}








