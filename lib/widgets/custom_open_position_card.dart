import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/open_position.dart';
import 'package:flutter/material.dart';
class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback onTap;

  PositionCard({required this.position, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardsBackgroundColor,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onTap,
        title:
            Text(position.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: <Widget>[
            Icon(Icons.work_outline, size: 20.0),
            SizedBox(width: 5.0),
            Text(
              position.type,
              style: TextStyle(
                //fontFamily: appFont,
              ),
            ),
            SizedBox(width: 10.0),
            Icon(Icons.location_on_outlined, size: 20.0),
            SizedBox(width: 5.0),
            Text(
              position.location,
              style: TextStyle(
                //fontFamily: appFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}