import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controllerText;
  final Widget? icon;
  final bool obsecureText;
  final String? errorText; // New field for error message

  CustomTextField({
    this.hint,
    this.controllerText,
    this.icon,
    required this.obsecureText,
    this.errorText, // Initialize errorText parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            obscureText: obsecureText,
            controller: controllerText,
            decoration: InputDecoration(
              suffixIcon: icon,
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              // Check if errorText is provided, show error style
              errorText: errorText,
              errorStyle: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          // Display error message if errorText is not null
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorText!,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
