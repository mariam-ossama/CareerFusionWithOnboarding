import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomCard extends StatelessWidget {
  final String url;

  const CustomCard({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: cardsBackgroundColor,
        child: ListTile(
          title: Text(
            url,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: mainAppColor,
              overflow: TextOverflow.ellipsis,
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            launchURL(url);
            print(url);
          },
        ),
      ),
    );
  }

  void launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url; // Prepend https:// if scheme is missing
    }

    try {
      if (await canLaunch(url)) {
        await launch(url); // Launch the URL in the device browser
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Handle the error as per your application's requirements
    }
  }
}