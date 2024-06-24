import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomNamedField extends StatelessWidget {
  CustomNamedField({super.key, required this.text});

  String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                //fontFamily: appFont,
                ),
          ),
        ],
      ),
    );
  }
}
