import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class CustomMenuCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onTap;
  final color;
  final fontColor;
  final iconColor;

  const CustomMenuCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
    required this.color,
    required this.fontColor,
    required this.iconColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color, // Change the color here
      elevation: 5, // Change the elevation here
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Change the border radius here
      ),
      child: InkWell(
        onTap: onTap, // Use the passed onTap callback here
        child: SizedBox(
          width: 120, // Specify the desired width
          height: 120, // Specify the desired height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                size: 40.0,
                color: iconColor, // Change the icon color here
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  //fontFamily: appFont,
                  color: fontColor, // Change the text color here
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
