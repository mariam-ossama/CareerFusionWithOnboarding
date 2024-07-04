import 'dart:ui';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/HR_screens/hr_account_screen.dart';
import 'package:career_fusion/screens/admin_screens/admin_screen.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_account_screen.dart';
import 'package:career_fusion/screens/on_boarding_screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
    checkOnboardingStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  void checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    print("Onboarding completed: $onboardingCompleted");

    if (onboardingCompleted) {
      checkUserLoggedInStatus();
    }
  }

  void checkUserLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('roles');
    print("Roles: $roles");

    if (roles != null && roles.isNotEmpty) {
      if (roles.contains('HR')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HRAccountPage()),
        );
      } else if (roles.contains('User')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
      } else if (roles.contains('Admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: demo_data.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingContent(
                      image: demo_data[index].image,
                      title: demo_data[index].title,
                      description: demo_data[index].description,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                  ),
                  Spacer(),
                  ...List.generate(
                    demo_data.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex == demo_data.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: const CircleBorder(),
                      ),
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
}

class Onboard {
  final String image;
  final String title;
  final String description;

  Onboard(
      {required this.image, required this.title, required this.description});
}

final List<Onboard> demo_data = [
  Onboard(
      image: 'assets/undraw_Balloons_re_8ymj.png',
      title: 'Welcome to Career Fusion',
      description: 'Your one-stop solution for job searching and recruitment.'),
  Onboard(
      image: 'assets/undraw_Job_hunt_re_q203.png',
      title: 'Job Seeker Features',
      description:
          'Explore the features designed for job seekers in the following slides.'),
  Onboard(
      image: 'assets/undraw_upload_re_pasx.png',
      title: 'Easy Job Applications',
      description:
          'Apply directly to open positions and posts shared by companies.'),
  Onboard(
      image: 'assets/undraw_Search_re_x5gq.png',
      title: 'Advanced Job Search',
      description:
          'Utilize advanced search options to find the perfect job for you.'),
  Onboard(
      image: 'assets/undraw_right_direction_tge8.png',
      title: 'Career Roadmap',
      description:
          'Get career roadmaps and job recommendations based on your skills.'),
  Onboard(
      image: 'assets/undraw_Business_decisions_re_84ag.png',
      title: 'HR Features',
      description:
          'Discover the features designed for HR professionals in the next slides.'),
  Onboard(
      image: 'assets/undraw_Control_panel_re_y3ar.png',
      title: 'Organized Hiring Plans',
      description:
          'Establish a comprehensive hiring plan with timelines and strategies.'),
  Onboard(
      image: 'assets/undraw_People_search_re_5rre.png',
      title: 'Efficient Recruitment Process',
      description:
          'Easily recruit and filter candidates through a structured process.'),
  Onboard(
      image: 'assets/undraw_Job_offers_re_634p.png',
      title: 'Get Started Now',
      description:
          'Experience all these features and streamline your job search and hiring processes.'),
];

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  const OnboardingContent(
      {super.key,
      required this.image,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Image.asset(image, height: 250),
        Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 16),
        Text(description, textAlign: TextAlign.center),
        Spacer(),
      ],
    );
  }
}

class DotIndicator extends StatelessWidget {
  final bool isActive;
  DotIndicator({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive
            ? mainAppColor
            : const Color.fromARGB(255, 196, 170, 241).withOpacity(0.4),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
