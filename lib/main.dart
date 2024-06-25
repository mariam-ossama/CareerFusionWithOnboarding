import 'package:career_fusion/screens/HR_screens/post_cv_screening.dart';
import 'package:career_fusion/screens/HR_screens/post_cv_screening_result.dart';
import 'package:career_fusion/screens/HR_screens/post_technical_interview_selection.dart';
import 'package:career_fusion/screens/HR_screens/post_telephone_interview_form.dart';
import 'package:career_fusion/screens/HR_screens/post_telephone_interview_result.dart';
import 'package:career_fusion/screens/HR_screens/post_telephone_interview_selection.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_account_screen.dart';
import 'package:career_fusion/screens/authentication_screens/admin_login_screen.dart';
import 'package:career_fusion/screens/admin_screen.dart';
import 'package:career_fusion/screens/candidate_screens/apply_to_open_position_screen.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_apply_jobs.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_open_positions_list.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_roadmap_screen.dart';
import 'package:career_fusion/screens/HR_screens/cv_screening_result_screen.dart';
import 'package:career_fusion/screens/HR_screens/cv_screening_screen.dart';
import 'package:career_fusion/screens/HR_screens/hr_posts_screen.dart';
import 'package:career_fusion/screens/candidate_screens/recommended_jobs_screen.dart';
import 'package:career_fusion/screens/HR_screens/define_needs_screen.dart';
import 'package:career_fusion/screens/candidate_screens/edit_user_profile_screen.dart';
import 'package:career_fusion/screens/HR_screens/exam_preparation_screen.dart';
import 'package:career_fusion/screens/HR_screens/existing_cvs_screen.dart';
import 'package:career_fusion/screens/HR_screens/hiring_plan_screen.dart';
import 'package:career_fusion/screens/HR_screens/hr_account_screen.dart';
import 'package:career_fusion/screens/HR_screens/hr_edit_profile_screen.dart';
import 'package:career_fusion/screens/HR_screens/hr_profile_screen.dart';

import 'package:career_fusion/screens/candidate_screens/job_details_screen.dart';
import 'package:career_fusion/screens/candidate_screens/job_search_screen.dart';
import 'package:career_fusion/screens/candidate_screens/candidate_notifications_screen.dart';
//import 'package:career_fusion/screens/open_positions_details_screen.dart';
import 'package:career_fusion/screens/HR_screens/open_positions_screen.dart';
import 'package:career_fusion/screens/HR_screens/recruitment_screen.dart';
import 'package:career_fusion/screens/HR_screens/set_timeline_screen.dart';
import 'package:career_fusion/screens/HR_screens/task_preparation_screen.dart';
import 'package:career_fusion/screens/HR_screens/technical_interview_result.dart';
import 'package:career_fusion/screens/HR_screens/technical_interview_selection_process_page.dart';
import 'package:career_fusion/screens/HR_screens/technical_interview_models.dart';
import 'package:career_fusion/screens/HR_screens/technical_interview_positions.dart';
//import 'package:career_fusion/screens/HR_screens/telephone_interview_forms.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_positions.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_result.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_screen.dart';
import 'package:career_fusion/screens/HR_screens/telephone_interview_selection_process_page.dart';
import 'package:career_fusion/screens/HR_screens/update_task_screen.dart';
import 'package:career_fusion/screens/candidate_screens/user_profile_screen.dart';
import 'package:career_fusion/screens/HR_screens/write_post_screen.dart';
//import 'package:career_fusion/widgets/display_image.dart';
import 'package:career_fusion/screens/authentication_screens/forgot_password_screen.dart';
import 'package:career_fusion/screens/authentication_screens/login_screen.dart';
import 'package:career_fusion/screens/authentication_screens/new_password_screen.dart';
import 'package:career_fusion/screens/authentication_screens/role_selection_screen.dart';
import 'package:career_fusion/screens/authentication_screens/sign_up_screen.dart';
import 'package:career_fusion/screens/on_boarding_screens/onboarding_screen.dart';
import 'package:career_fusion/screens/on_boarding_screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(CareerFusion(onboardingCompleted: onboardingCompleted));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
      // Add other providers if needed
    ],
    child: CareerFusion(onboardingCompleted: onboardingCompleted),
  ));
}

class CareerFusion extends StatelessWidget {
  final bool onboardingCompleted;

  const CareerFusion({super.key, required this.onboardingCompleted});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'OnboardingScreen': (context) => OnboardingScreen(),
        'WelcomePage': (context) => const WelcomePage(),
        'SignUpPage': (context) => SignUpPage(),
        'LoginPage': (context) => LoginPage(),
        //'ForgotPasswordPage': (context) => ForgotPasswwordPage(),
        'NewPasswordPage': (context) => NewPasswordPage(),
        'RoleSelectionPage': (context) => RoleSelectionPage(),
        //'CandidateProfilePage': (context) => CandidateProfilePage(),
        'NotificationsPage': (context) => NotificationsPage(),
        'AdminPage': (context) => AdminPage(),
        'JobSearchPage': (context) => JobSearchPage(),
        'RecommendedJobsPage': (context) => RecommendedJobsPage(),
        //'JobDetailsPage': (context) => JobDetailsPage(),
        //'SubmitApplicationScreen': (context) => SubmitApplicationScreen(),
        'HRAccountPage': (context) => HRAccountPage(),
        'HRProfilePage': (context) => HRProfilePage(),
        'HiringPlanPage': (context) => HiringPlanPage(),
        'SetTimelinePage': (context) => SetTimelinePage(),
        'DefineNeedsPage': (context) => DefineNeedsPage(),
        'OpenPositionsPage': (context) => OpenPositionsPage(),
        'WritePostPage': (context) => WritePostPage(),
        'ExistingCVsPage': (context) => ExistingCVsPage(),
        'RecruitmentPage': (context) => RecruitmentPage(),
        'CVScreeningPage': (context) => CVScreeningPage(),
        'CVScreeningResultPage': (context) => CVScreeningResultPage(),
        'AdminLoginPage': (context) => AdminLoginPage(),
        'AccountPage': (context) => AccountPage(),
        'UserProfilePage': (context) => UserProfilePage(),
        'EditUserProfilePage': (context) => EditUserProfilePage(),
        'EditHRProfilePage': (context) => EditHRProfilePage(),
        //'TelephoneInterviewFormPage': (context) => TelephoneInterviewFormPage(),
        //'InterviewFormsPage':(context) => InterviewFormsPage(),
        'TelephoneInterviewPositionsPage': (context) =>
            TelephoneInterviewPositionsPage(),
        'TelephoneInterviewSelectionPage': (context) =>
            TelephoneInterviewSelectionPage(),
        'TelephonInterviewResultPage': (context) =>
            TelephonInterviewResultPage(),
        'TechnicalInterviewModelsPage': (context) =>
            TechnicalInterviewModelsPage(),
        'TechnicalInterviewPositionsPage': (context) =>
            TechnicalInterviewPositionsPage(),
        'ExamPreparationScreen': (context) => ExamPreparationScreen(),
        'TaskPreparationScreen': (context) => TaskPreparationScreen(),
        'UpdateTaskPage': (context) => UpdateTaskPage(),
        'TechnicalInterviewCandidatesPage': (context) =>
            TechnicalInterviewCandidatesPage(),
        'TecnicalInterviewResultPage': (context) =>
            TecnicalInterviewResultPage(),
        'AppliedJobsPage': (context) => AppliedJobsPage(),
        'CandidateOpenPositionsListPage': (context) =>
            CandidateOpenPositionsListPage(),
        'HRPostsPage': (context) => HRPostsPage(),
        'CandidateRoadmapPage': (context) => CandidateRoadmapPage(),
        //'PostCVScreeningPage':(context) => PostCVScreeningPage(),
        //'PostCVScreeningResult':(context) => PostCVScreeningResult(),
        //'PostTelephoneInterviewForm': (context) => PostTelephoneInterviewForm(),
        'PostTelephoneInterviewSelectionProcessPage': (context) =>
            PostTelephoneInterviewSelectionProcessPage(),
        'PostTelephoneInterviewResultPage': (context) =>
            PostTelephoneInterviewResultPage(),
        'PostTechnicalInterviewSelectionProcessPage': (context) =>
            PostTechnicalInterviewSelectionProcessPage(),
      },
      debugShowCheckedModeBanner: false,
      initialRoute: onboardingCompleted ? 'WelcomePage' : 'OnboardingScreen',
    );
  }
}
