

import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class RecommendedJobCard extends StatelessWidget {
  final String jobTitle;
  final double similarity;

  RecommendedJobCard({super.key, required this.jobTitle, required this.similarity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: cardsBackgroundColor,
        child: ListTile(
          title: Text(
            jobTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'Similarity: ${(similarity * 100).toStringAsFixed(2)}%',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}