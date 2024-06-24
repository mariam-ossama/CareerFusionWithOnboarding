import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class CandidateRoadmapPage extends StatefulWidget {
  const CandidateRoadmapPage({super.key});

  @override
  State<CandidateRoadmapPage> createState() => _CandidateRoadmapPageState();
}

class _CandidateRoadmapPageState extends State<CandidateRoadmapPage> {
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
    );
  }
}