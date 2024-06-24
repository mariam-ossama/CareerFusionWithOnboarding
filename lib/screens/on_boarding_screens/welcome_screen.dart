//import 'package:career_fusion/screens/sign_up_screen.dart';
//import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        /*appBar: AppBar(
        title: const Text('CareerFusion'),
        backgroundColor: const Color.fromARGB(217,217,217,217),
      ) ,*/
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(
                flex: 3,
              ),
              Image.asset('assets/images/undraw_Happy_feeling_re_e76r.png'),
              const Center(
                child: Text(
                  'Welcome to',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      //fontStyle: FontStyle.italic,
                      //fontFamily: appFont,
                      ),
                ),
              ),
              /*const SizedBox(width: 30,
            height: 100,),*/
              const Center(
                child: Text(
                  'CareerFusion',
                  style: TextStyle(
                      fontSize: 28,
                      //fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      //fontFamily: appFont,
                      ),
                ),
              ),
              const SizedBox(
                width: 30,
                height: 100,
              ),

              /*GestureDetector(
              onTap: () {
                Navigator.pushNamed(context,'SignUpPage');
              },
              child: 
              CustomButton(text: 'Create Account',onPressed: (){
              Navigator.pushNamed(context,'SignUpPage');
            }, ),
            ),*/
              const Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'LoginPage');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          //fontFamily: appFont,
                          color: Colors.black),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'LoginPage');
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'SignUpPage');
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          //fontFamily: appFont,
                          color: Colors.black),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'SignUpPage');
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'AdminLoginPage');
                    },
                    child: const Text(
                      'Login as Admin',
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          //fontFamily: appFont,
                          color: Colors.black),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'AdminLoginPage');
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ));
  }
}
