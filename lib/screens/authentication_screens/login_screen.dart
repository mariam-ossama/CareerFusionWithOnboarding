import 'dart:developer';
import 'dart:ffi';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/candidate.dart';
import 'package:career_fusion/screens/HR_screens/hr_account_screen.dart';
import 'package:career_fusion/screens/admin_screens/admin_screen.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_account_screen.dart';
import 'package:career_fusion/screens/authentication_screens/forgot_password_screen.dart';
import 'package:career_fusion/screens/authentication_screens/role_selection_screen.dart';
import 'package:career_fusion/screens/authentication_screens/sign_up_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
@immutable
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? showValue = false;

  bool obscurePassword = true;
  bool _checkIfIsLogged = false;

  String? emailError;
  String? passwordError;

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
            color: Colors.white, //fontFamily: appFont
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            Stack(
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
                            //fontFamily: appFont
                          ),
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
                              //fontFamily: appFont,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            /*/const SizedBox(
              height: 20,
            ),*/
            CustomNamedField(text: 'Email'),
            CustomTextField(
              obsecureText: false,
              hint: 'Enter your email',
              controllerText: emailController,
              icon: Icon(Icons.mail),
              errorText: emailError, // Pass error message for email validation
            ),
            const SizedBox(height: 20),
            CustomNamedField(text: 'Password'),
            CustomTextField(
              obsecureText: obscurePassword,
              hint: 'Password',
              controllerText: passwordController,
              icon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              errorText:
                  passwordError, // Pass error message for password validation
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 8,
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    fontSize: 14, //fontFamily: appFont
                  ),
                ),
                const SizedBox(
                  width: 90,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()));
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
            /*const SizedBox(
              height: 20,
            ),*/
            CustomButton(
              text: 'Next',
              onPressed: () async {
                clearErrors(); // Clear previous errors
                bool isValid = validateFields(); // Validate input fields
                if (isValid) {
                  // Only attempt login if fields are valid
                  loginUser(
                      emailController.text, passwordController.text, context);
                }
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
                    Navigator.pop(context, 'SignUpPage');
                  },
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                        fontSize: 14,
                        //fontFamily: appFont,
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

  void clearErrors() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validateFields() {
    bool isValid = true;

    // Validate email
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email cannot be empty';
      });
      isValid = false;
    } else if (!isValidEmail(emailController.text)) {
      setState(() {
        emailError = 'Invalid email format';
      });
      isValid = false;
    }

    // Validate password
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password cannot be empty';
      });
      isValid = false;
    } else if (passwordController.text.length < 6) {
      setState(() {
        passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    }

    return isValid;
  }

  bool isValidEmail(String email) {
    // Simple email validation
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> saveTokenAndNavigate(
      String token, String userId, BuildContext context) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('token', token);
      prefs.setString('userId', userId);
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionPage()),
    );
  }
}

// In the login page after a successful login
void loginUser(String email, String password, BuildContext context) async {
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
      String userId = response.data['userId'];
      List<String> roles = List<String>.from(response.data['roles']);

      // Store the token and userId locally using shared_preferences or flutter_secure_storage
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', token);
        prefs.setString('userId', userId);
      });

      if (roles.contains('HR')) {
        print('\nif is fired');
        // Navigate to RoleSelectionPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HRAccountPage()),
          (Route<dynamic> route) => false,
        );
      } else if (roles.contains('User')) {
        print('else is fired');
        // Navigate to AccountPage and remove all previous screens
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
          (Route<dynamic> route) => false,
        );
      } else if (roles.contains('Admin')) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
          (Route<dynamic> route) => false,
        );
      }
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

class AuthProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners(); // Notify listeners that the user ID has changed
  }
}
