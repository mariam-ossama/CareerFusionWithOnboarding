import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final String employee_name;
  final String employee_email;
  final onPressed;

  const EmployeeCard({
    super.key,
    required this.employee_name,
    required this.employee_email,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shadowColor: Colors.grey,
        color: cardsBackgroundColor,
        child: ListTile(
          title: Row(
            children: [
              Icon(
                Icons.person_4,
                color: mainAppColor,
                size: 16,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                employee_name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.email,
                color: mainAppColor,
                size: 14,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                employee_email,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}
