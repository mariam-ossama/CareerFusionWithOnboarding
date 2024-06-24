import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_job_card.dart';
import 'package:flutter/material.dart';

import '../../models/job.dart';

class RecommendedJobsPage extends StatelessWidget {
  final List<Job> jobs = [
    /*Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),
    Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),
    Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),*/
    // Add more jobs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recommended for you',
          style: TextStyle(
            //fontFamily: appFont,
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
          return JobCard(
            job: jobs[index],
            onTap: () {
              Navigator.pushNamed(context, 'JobDetailsPage');
              // Handle job card click here
              // You can implement navigation or other actions as needed
            },
          );
        },
      ),
    );
  }
}




