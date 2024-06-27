import 'dart:convert';

//import 'package:career_fusion/widgets/custom_app_bar.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/authentication_screens/login_screen.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionPage extends StatelessWidget {
  Future<String?> retrieveToken(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _authorizeRoleAsHR(
      BuildContext context, String role, String userId) async {
    // Make a POST request to the API endpoint
    var url = Uri.parse('${baseUrl}/Auth/addrole');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer $token', // Pass the token in the header
      },
      body: jsonEncode({'role': role, 'userId': userId}),
    );
    print(response.body);

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Check the response body for user ID comparison
      var responseBody = json.decode(response.body);
      var authorizedUserId =
          responseBody['userId']; // Assuming the response includes the user ID

      // Compare the authorized user ID with the input user ID
      if (authorizedUserId == userId) {
        // Navigate the user based on the role
        if (role == 'HR') {
          Navigator.pushNamed(context, 'HRAccountPage');
        }
      } else {
        // User ID doesn't match
        print('Unauthorized user ID');
        // Handle unauthorized access
      }
    } else {
      // Handle error response from the API
      print('Failed to authorize role: ${response.statusCode}');
      // You can show an error message to the user or handle the error accordingly
    }
  }

  //String? userId = Provider.of<AuthProvider>(context as BuildContext).userId;

  @override
  Widget build(BuildContext context) {
    //String? userId = Provider.of<AuthProvider>(context).userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Role Selection',
          style: TextStyle(
            color: Colors.white,
            //fontFamily: appFont,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      /*appBar: CustomAppBar(
        title: 'Role Selection',
      ),*/
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text(
                  'Choose your role',
                  style: TextStyle(
                      fontSize: 28,
                      //fontFamily: appFont,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 60),
                CustomButton(
                  text: 'Candidate',
                  onPressed: () async {
                    //Navigator.pushNamed(context, 'AccountPage');
                    String? userId = await AuthManager.retrieveUserId();

                    if (userId != null) {
                      try {
                        await _authorizeRoleAsUser(context, 'User', userId);
                        Navigator.pushNamed(context, 'AccountPage');
                      } catch (e) {
                        print('Navigation error: $e');
                      }
                    } else {
                      print('User ID is null');
                    }
                  },
                ),
                SizedBox(height: 60),
                CustomButton(
                    text: 'Corporate HR Department',
                    onPressed: () async {
                      //Navigator.pushNamed(context, 'HRAccountPage');
                      String? userId = await AuthManager.retrieveUserId();

                      if (userId != null) {
                        try {
                          await _authorizeRoleAsHR(context, 'HR', userId);
                          Navigator.pushNamed(context, 'HRAccountPage');
                        } catch (e) {
                          print('Navigation error: $e');
                        }
                      } else {
                        print('User ID is null');
                      }
                    }),
                SizedBox(height: 60),
                CustomButton(
                    text: 'Admin',
                    onPressed: () async {
                      //Navigator.pushNamed(context, 'HRAccountPage');
                      String? userId = await AuthManager.retrieveUserId();

                      if (userId != null) {
                        try {
                          await _authorizeRoleAsAdmin(context, 'Admin', userId);
                          Navigator.pushNamed(context, 'AdminPage');
                        } catch (e) {
                          print('Navigation error: $e');
                        }
                      } else {
                        print('User ID is null');
                      }
                    }),
                SizedBox(
                  height: 60,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Function to retrieve the token from shared preferences
/*void retrieveToken(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token != null && token.isNotEmpty) {
    // If token is available, perform authorized actions
    print('Token retrieved successfully: $token');
    // You can now use this token to make authorized API requests
    // For example:
    // You can send the token in the Authorization header of your HTTP requests
    // You can navigate the user to different pages based on their role
  } else {
    // If token is not available, handle the situation accordingly
    print('Token not found or empty');
    // You may want to prompt the user to log in or register again
    // Or you may redirect the user to the login page
  }
}*/

Future<void> _authorizeRoleAsUser(
    BuildContext context, String role, String userId) async {
  // Make a POST request to the API endpoint
  var url = Uri.parse('${baseUrl}/Auth/addrole');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      //'Authorization': 'Bearer $token', // Pass the token in the header
    },
    body: jsonEncode({'role': role, 'userId': userId}),
  );
  print(response.body);

  // Check if the request was successful
  if (response.statusCode == 200) {
    // Check the response body for user ID comparison
    var responseBody = json.decode(response.body);
    var authorizedUserId =
        responseBody['userId']; // Assuming the response includes the user ID

    // Compare the authorized user ID with the input user ID
    if (authorizedUserId == userId) {
      // Navigate the user based on the role
      if (role == 'HR') {
        Navigator.pushNamed(context, 'HRAccountPage');
      }
      if (role == 'User') {
        Navigator.pushNamed(context, 'AccountPage');
      }
      if (role == 'Admin') {
        Navigator.pushNamed(context, 'AdminPage');
      }
    } else {
      // User ID doesn't match
      print('Unauthorized user ID');
      // Handle unauthorized access
    }
  } else {
    // Handle error response from the API
    print('Failed to authorize role: ${response.statusCode}');
    // You can show an error message to the user or handle the error accordingly
  }
}

Future<void> _authorizeRoleAsAdmin(
    BuildContext context, String role, String userId) async {
  // Make a POST request to the API endpoint
  var url = Uri.parse('${baseUrl}/Auth/addrole');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      //'Authorization': 'Bearer $token', // Pass the token in the header
    },
    body: jsonEncode({'role': role, 'userId': userId}),
  );
  print(response.body);

  // Check if the request was successful
  if (response.statusCode == 200) {
    // Check the response body for user ID comparison
    var responseBody = json.decode(response.body);
    var authorizedUserId =
        responseBody['userId']; // Assuming the response includes the user ID

    // Compare the authorized user ID with the input user ID
    if (authorizedUserId == userId) {
      // Navigate the user based on the role
      if (role == 'HR') {
        Navigator.pushNamed(context, 'HRAccountPage');
      }
      if (role == 'User') {
        Navigator.pushNamed(context, 'AccountPage');
      }
    } else {
      // User ID doesn't match
      print('Unauthorized user ID');
      // Handle unauthorized access
    }
  } else {
    // Handle error response from the API
    print('Failed to authorize role: ${response.statusCode}');
    // You can show an error message to the user or handle the error accordingly
  }
}

// Define a class to manage authentication state and user ID retrieval
class AuthManager {
  static String? _userId;

  // Method to set the user ID after authentication
  static void setUserId(String userId) {
    _userId = userId;
    storeUserId(userId); // Store the user ID
  }

  // Method to retrieve the current user ID
  static String? getCurrentUserId() {
    return _userId;
  }

  // Storing the user ID
  static void storeUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Retrieving the user ID
  static Future<String?> retrieveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
