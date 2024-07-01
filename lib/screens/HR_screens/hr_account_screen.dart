import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_app_bar.dart';
import 'package:career_fusion/widgets/candidate_side_menu.dart';
import 'package:career_fusion/widgets/hr_side_menu.dart';
import 'package:flutter/material.dart';

class HRAccountPage extends StatelessWidget {
  const HRAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
              //fontFamily: appFont,
              color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      drawer: HRSideMenu(),
      body: Column(
        children: <Widget>[
          /*const SizedBox(
            height: 100,
          ),
          const Text(
            'CareerFusion',
            style: TextStyle(
              fontSize: 30,
              color: mainAppColor,
              fontWeight: FontWeight.bold,
              //fontFamily: appFont,
            ),
          ),*/
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: <Widget>[
                MenuCard(
                  title: 'Profile',
                  iconData: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(context, 'HRProfilePage');
                  },
                ),
                MenuCard(
                  title: 'Hiring Plan',
                  iconData: Icons.group_work_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, 'HiringPlanPage');
                  },
                ),
                MenuCard(
                  title: 'Recruitment',
                  iconData: Icons.person_search_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, 'RecruitmentPage');
                  },
                ),
                /*MenuCard(
                  title: 'Assessments',
                  iconData: Icons.quiz_rounded,
                  onTap: () {
                    Navigator.pushNamed(
                        context, 'TechnicalInterviewModelsPage');
                  },
                ),*/
                MenuCard(
                  title: 'Job Anouncements',
                  iconData: Icons.announcement_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, 'HRPostsPage');
                  },
                ),
                MenuCard(
                  title: 'Appraisals',
                  iconData: Icons.rate_review_rounded,
                  onTap: () {
                    Navigator.pushNamed(context, 'CompanyEmployeesPage');
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 200, // Specify the desired width
                height: 120, // Specify the desired height
                child: Image.asset(
                    'assets/images/undraw_adventure_map_hnin_new.png'),
              ),
            ],
          ),
          /*const SizedBox(
            height: 30,
          ),*/
          // Add your bottom artwork widget here
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onTap;

  const MenuCard({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardsBackgroundColor,
      child: InkWell(
        onTap: onTap, // Use the passed onTap callback here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 50.0,
              color: mainAppColor,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                //fontFamily: appFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
