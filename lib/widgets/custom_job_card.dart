import 'package:career_fusion/constants.dart';

import '../models/job.dart';
import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  JobCard({required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shadowColor: Colors.grey[500],
        color: cardsBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    job.logoUrl,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            //fontFamily: appFont,
                          ),
                        ),
                        Text(
                          job.location,
                          style: TextStyle(
                            //fontFamily: appFont,
                          ),
                        ),
                        Text(
                          job.type,
                          style: TextStyle(
                            //fontFamily: appFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}