import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewPasswordPage extends StatefulWidget {
   NewPasswordPage({Key? key,this.email}) : super(key: key);

  final String? email;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
    bool _showNewPassword = false;
    bool _showConfirmPassword = false;
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    

    void resetPassword() async {
  final String newPassword = newPasswordController.text;
  final String confirmPassword = confirmPasswordController.text;

  // Ensure email is provided
  if (widget.email == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email address is missing'),
      ),
    );
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userToken = prefs.getString('token');
  print(userToken);

  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passwords do not match'),
      ),
    );
    return;
  }

  // Encode email address
  final String encodedEmail = base64Encode(utf8.encode(widget.email!));
  

  final Dio dio = Dio();
  final url = '${baseUrl}/Auth/ResetPassword';

  try {
    final response = await dio.post(
      url,
      data: {
        'Token': userToken, // This should be the token received during password reset
        'Email': encodedEmail,
        'NewPassword': newPassword,
        'ConfirmPassword': confirmPassword,
      },
    );
    print(response.data);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset successful'),
        ),
      );
      // Navigate to login screen or any other screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset password. Please try again.'),
        ),
      );
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ),
    );
  }
}





    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'New Password',
          style: TextStyle(color: Colors.white, //fontFamily: appFont
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: ListView(
        children: [
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              CustomNamedField(text: 'Enter new password'),
              CustomTextField(
  controllerText: newPasswordController,
  obsecureText: !_showNewPassword,
  hint: 'Enter new password',
  icon: IconButton(
    icon: Icon(
      _showNewPassword
        ? Icons.visibility
        : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() {
        _showNewPassword = !_showNewPassword;
      });
    },
  ),
),
const SizedBox(height: 20),
CustomNamedField(text: 'Confirm password'),
CustomTextField(
  controllerText: confirmPasswordController,
  obsecureText: !_showConfirmPassword,
  hint: 'Confirm Password',
  icon: IconButton(
    icon: Icon(
      _showConfirmPassword
        ? Icons.visibility
        : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() {
        _showConfirmPassword = !_showConfirmPassword;
      });
    },
  ),
),

              const SizedBox(height: 40),
              CustomButton(
                text: 'Submit',
                onPressed: resetPassword,
              ),
            ],
          ),
        ),
        ]
      ),
    );
  }
}
