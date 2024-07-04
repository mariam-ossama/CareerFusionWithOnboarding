import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class HRSideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: cardsBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: mainAppColor,
              /*image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg')
                    ),*/
            ),
            child: Text(
              'CareerFusion',
              style: TextStyle(color: Colors.white, fontSize: 25,//fontFamily: appFont
              ),
            ),
          ),
          /*ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home',style: TextStyle(//fontFamily: appFont
            ),),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile',style: TextStyle(//fontFamily: appFont
            ),),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, 'HRProfilePage');
            },
          ),
          /*ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings',style: TextStyle(//fontFamily: appFont
            ),),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Upgrade to premium',style: TextStyle(//fontFamily: appFont
            ),),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout',style: TextStyle(//fontFamily: appFont
            ),),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, 'WelcomePage');
            },
          ),
        ],
      ),
    );
  }
}
