import 'dart:convert';
import 'dart:developer';

import 'package:career_fusion/constants.dart';

import 'package:career_fusion/screens/authentication_screens/role_selection_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_named_field.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

String prettyPrint(Map json) {
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

// ignore: must_be_immutable
class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController fullNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isChecked = false;
  bool obsecureText = true;

  String? usernameError;
  String? fullNameError;
  String? emailError;
  String? phoneNumberError;
  String? passwordError;

  Map<String, dynamic>? _userData;
  AccessToken? _accessToken;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
      // now you can call to  FacebookAuth.instance.getUserData();
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    }
  }

  void _printCredentials() {
    print(
      prettyPrint(_accessToken!.toJson()),
    );
  }

  Future<void> _login() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Login successful
        // Proceed with further actions
      } else {
        // Login failed
        print('Facebook login failed: ${result.status}: ${result.message}');
      }
    } catch (e) {
      // Exception occurred
      print('An error occurred during Facebook login: $e');
    }

    setState(() {
      _checking = false;
    });
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'CareerFusion',
          style: TextStyle(
            color: Colors.white,
            //fontFamily: appFont,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Form(
          child: ListView(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/undraw_adventure_map_hnin.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 63,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 150,
                            ),
                            Text(
                              'Get Started',
                              style: TextStyle(
                                  fontSize: 40,
                                  //fontFamily: appFont,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      SizedBox(
                        width: 45,
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                          ),
                          Text(
                            'by creating a free account',
                            style: TextStyle(
                              fontSize: 20,
                              //fontFamily: appFont,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CustomNamedField(text: 'User Name'),
              CustomTextField(
                obsecureText: false,
                icon: Icon(Icons.person_2),
                hint: 'User Name',
                controllerText: usernameController,
                errorText:
                    usernameError, // Pass error message for username validation
              ),
              const SizedBox(height: 20),
              CustomNamedField(text: 'Full Name'),
              CustomTextField(
                icon: Icon(Icons.person),
                obsecureText: false,
                hint: 'Full Name',
                controllerText: fullNameController,
                errorText:
                    fullNameError, // Pass error message for full name validation
              ),
              const SizedBox(height: 20),
              CustomNamedField(text: 'Valid Email'),
              CustomTextField(
                obsecureText: false,
                icon: Icon(Icons.email),
                hint: 'Valid Email',
                controllerText: emailController,
                errorText:
                    emailError, // Pass error message for email validation
              ),
              const SizedBox(height: 20),
              CustomNamedField(text: 'Phone Number'),
              CustomTextField(
                obsecureText: false,
                icon: Icon(Icons.phone),
                hint: 'Phone Number',
                controllerText: phoneNumberController,
                errorText:
                    phoneNumberError, // Pass error message for phone number validation
              ),
              const SizedBox(height: 20),
              CustomNamedField(text: 'Strong Password'),
              CustomTextField(
                obsecureText: obsecureText,
                hint: 'Strong Password',
                controllerText: passwordController,
                icon: IconButton(
                  icon: Icon(
                    obsecureText ? Icons.visibility_off:Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obsecureText = !obsecureText;
                    });
                  },
                ),
                errorText:
                    passwordError, // Pass error message for password validation
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: mainAppColor,
                  ),
                  const Text(
                    'by checking the box you agree to our',
                    style: TextStyle(fontSize: 10),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Terms',
                      style: TextStyle(fontSize: 10, color: mainAppColor),
                    ),
                  ),
                  const Text(
                    'and ',
                    style: TextStyle(fontSize: 10),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Conditions',
                      style: TextStyle(fontSize: 10, color: mainAppColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CustomButton(
                text: 'Submit',
                onPressed: isChecked
                    ? () async {
                        clearErrors(); // Clear previous errors
                        bool isValid =
                            validateFields(); // Validate input fields
                        if (isValid) {
                          registerUser(
                            fullNameController.text,
                            usernameController.text,
                            emailController.text,
                            passwordController.text,
                            phoneNumberController.text,
                            context,
                          );
                        }
                      }
                    : null,
              ),
              /*SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  'Or sign up using',
                  style: TextStyle(
                      //fontFamily: appFont,
                      fontSize: 25),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        final googleSignInApi = GoogleSignInApi();
                        final GoogleSignInAccount? googleUser =
                            await googleSignInApi.login();

                        if (googleUser != null) {
                          // Retrieve authentication information
                          final GoogleSignInAuthentication googleAuth =
                              await googleUser.authentication;

                          // Use the email to proceed with registration or other actions
                          registerUser(
                            googleUser.displayName!,
                            googleUser.displayName!,
                            googleUser.email,
                            passwordController.text,
                            phoneNumberController.text,
                            context,
                          );
                        } else {
                          // User canceled the sign-in
                          print('User canceled the sign-in process');
                        }
                      } catch (error) {
                        // Handle sign-in error
                        print('Error signing in with Google: $error');
                        // Show a user-friendly error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to sign in with Google. Please try again.'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 75,
                      height: 75,
                      child: Image.asset('assets/images/googleIcon.com'),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  GestureDetector(
                    onTap: () {
                      _login();
                    },
                    child: Container(
                      width: 75,
                      height: 75,
                      child:
                          Image.asset('assets/images/facebookSquaredIcon.com'),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 6,
              ),*/
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already a member? ',
                    style: TextStyle(
                      fontSize: 16,
                      //fontFamily: appFont
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'LoginPage');
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                          fontSize: 16,
                          //fontFamily: appFont,
                          color: mainAppColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateFields() {
    bool isValid = true;

    // Validate username
    if (usernameController.text.isEmpty ||
        !isValidUsername(usernameController.text)) {
      setState(() {
        usernameError = 'Please enter a valid username';
      });
      isValid = false;
    }

    // Validate full name
    if (fullNameController.text.isEmpty ||
        !isValidFullName(fullNameController.text)) {
      setState(() {
        fullNameError = 'Please enter a valid full name';
      });
      isValid = false;
    }

    // Validate email
    if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
      setState(() {
        emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate phone number
    if (phoneNumberController.text.isEmpty ||
        !isValidPhoneNumber(phoneNumberController.text)) {
      setState(() {
        phoneNumberError = 'Please enter a valid phone number';
      });
      isValid = false;
    }

    // Validate password
    if (passwordController.text.isEmpty ||
        !isValidPassword(passwordController.text)) {
      setState(() {
        passwordError =
            'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, and a number';
      });
      isValid = false;
    }

    return isValid;
  }

  void clearErrors() {
    setState(() {
      usernameError = null;
      fullNameError = null;
      emailError = null;
      phoneNumberError = null;
      passwordError = null;
    });
  }

  bool isValidUsername(String username) {
    // Username validation: at least 3 characters, no special characters
    String pattern = r'^[a-zA-Z0-9]{3,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(username);
  }

  bool isValidFullName(String fullName) {
    // Full name validation: at least 3 characters
    String pattern = r'^[a-zA-Z ]{3,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(fullName);
  }

  bool isValidEmail(String email) {
    // Simple regex for email validation
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Phone number validation: must be 11 digits
    String pattern = r'^\d{11}$';
    RegExp regex = RegExp(pattern);
    return true;
  }

  bool isValidPassword(String password) {
    // Password validation: at least 8 characters, 1 uppercase, 1 lowercase, 1 number
    //String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
    //RegExp regex = RegExp(pattern);
    //return regex.hasMatch(password);
    return true;
  }
}

// In the registration page after a successful registration
void registerUser(String fullName, String userName, String email,
    String password, String phoneNumber, BuildContext context) async {
  final dio = Dio();
  dio.options.connectTimeout = Duration(seconds: 10);
  const url = '${baseUrl}/Auth/register';

  try {
    Map<String, dynamic> userData = {
      "FullName": fullName,
      "UserName": userName,
      "Email": email,
      "Password": password,
      "PhoneNumber": phoneNumber
    };

    var response = await dio.post(
      url,
      data: userData,
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      String token = response.data['token'];
      String userId = response.data['userId']; // Extract token from response
      // Store the token locally using shared_preferences or flutter_secure_storage
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', token);
        prefs.setString('userId', userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Success'),
        ),
      );

      // Navigate to role selection page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionPage()),
        (route) => false,
      );
    }

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
  } catch (error) {
    print('Error: $error');
  }
}

/*class LoginApi {
  static final _googleSignIn = GoogleSignIn();
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static Future signOut = _googleSignIn.signOut();
}*/

Future signIn(BuildContext context) async {
  final googleSignInApi = GoogleSignInApi();
  await googleSignInApi.login();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => RoleSelectionPage()),
    (route) => false,
  );
}

class GoogleSignInApi {
  static const String clientId =
      '395198127186-ii0d370galjna3t49tmo7cb123rc1qhq.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    serverClientId: clientId,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
