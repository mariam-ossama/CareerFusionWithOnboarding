import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
   EventCard({super.key, required this.isPast,required this.child});

   final bool isPast;
   final child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isPast ? mainAppColor : Colors.deepPurple[200],
      borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }
}