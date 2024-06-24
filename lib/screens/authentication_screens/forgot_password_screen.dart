import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/authentication_screens/new_password_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    void resetPassword() async {
      final String email = emailController.text;
      final Dio dio = Dio();
      final url = '${baseUrl}/Auth/forgetpassword?email=$email';

      try {
        final response = await dio.post(
          url,
          data: {'email': email},
        );
        print(response.data);
        print(response.statusCode);

        if (response.statusCode == 200) {
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordPage(email: email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset failed. Please try again.'),
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
          'Forgot Password',
          style: TextStyle(color: Colors.white, //fontFamily: appFont
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    //fontFamily: appFont,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Provide your email and we will send you a link to reset your password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                //fontFamily: appFont,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controllerText: emailController,
              obsecureText: false,
              hint: 'Enter your email',
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Reset Password',
              onPressed: resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}
