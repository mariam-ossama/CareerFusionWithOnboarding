import 'dart:developer';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_account_screen.dart';
import 'package:career_fusion/screens/admin_screens/admin_screen.dart';
import 'package:career_fusion/screens/HR_screens/hr_account_screen.dart';
import 'package:career_fusion/widgets/custom_app_bar.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// ignore: must_be_immutable
class AdminLoginPage extends StatefulWidget {
  AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  bool _showPassword = false;
  bool _checkIfIsLogged = false;

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CareerFusion',
          style: TextStyle(
              //fontFamily: appFont,
              color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            /*Stack(
              children: <Widget>[
                Image.asset('assets/images/undraw_adventure_map_hnin.png'),
                const Row(
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.black,
                              fontFamily: 'Montserrat-VariableFont_wght'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(
                      width: 35,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                        ),
                        Text(
                          'sign in to access your account',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Montserrat-VariableFont_wght',
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),*/
            /*/const SizedBox(
              height: 20,
            ),*/
            CustomNamedField(text: 'Email'),
            CustomTextField(
              obsecureText: false,
              hint: 'Enter your email',
              controllerText: emailController,
              icon: Icon(Icons.email),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomNamedField(text: 'Password'),
            CustomTextField(
              obsecureText: !_showPassword,
              hint: 'Password',
              controllerText: passwordController,
              icon: GestureDetector(
                onTap: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Checkbox(
                  value: _checkIfIsLogged,
                  onChanged: (value) {
                    setState(() {
                      _checkIfIsLogged = value!;
                    });
                  },
                ),
                const Text(
                  'remember me',
                  style: TextStyle(
                    fontSize: 14, //fontFamily: appFont,
                  ),
                ),
                const SizedBox(
                  width: 130,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'ForgotPasswordPage');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                        fontSize: 14,
                        //fontFamily: appFont,
                        color: mainAppColor),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
              text: 'Next',
              onPressed: () async {
                log(emailController.text);
                log(passwordController.text);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                  (route) => false,
                );
                /*loginAdmin(
                    emailController.text, passwordController.text, context);*/
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New member?',
                  style: TextStyle(
                    fontSize: 14,
                    //fontFamily: appFont,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'LoginPage');
                  },
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                        fontSize: 14,
                        //fontFamily: 'Montserrat-VariableFont_wght',
                        color: mainAppColor),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void loginAdmin(String email, String password, BuildContext context) async {
  final dio = Dio();
  const url = '${baseUrl}/Auth/token';

  try {
    Map<String, dynamic> userData = {
      "Email": email,
      "Password": password,
    };

    var response = await dio.post(
      url,
      data: userData,
    );

    if (response.statusCode == 200) {
      String token = response.data['token'];
      String userId = response.data['userId']; // Extract token from response
      // Store the token locally using shared_preferences or flutter_secure_storage
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', token);
        prefs.setString('userId', userId);
      });

      // Navigate to role selection page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
        (route) => false,
      );
    } else {
      // Handle unsuccessful login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your credentials.'),
        ),
      );
    }

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ),
    );
  }
}
