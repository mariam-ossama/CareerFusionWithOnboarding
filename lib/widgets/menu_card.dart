import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap, // Use the passed onTap callback here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 40.0,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                //fontFamily: appFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}