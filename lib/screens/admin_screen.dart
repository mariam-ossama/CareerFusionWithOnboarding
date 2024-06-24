import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];
  String? userId; // Store user names
  @override
  void initState() {
    super.initState();
    getUsers(); // Fetch users when the page initializes
  }

  // Helper function to fetch users from the API
  Future<void> getUsers() async {
    final response = await http
        .get(Uri.parse('${baseUrl}/crud/users'));

    if (response.statusCode == 200) {
      // Parse the response body and update the user list
      final List<dynamic> userList = json.decode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(userList); // Update user list
      });
    } else {
      // Handle error cases
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error',style: TextStyle(//fontFamily: appFont
          ),),
          content: Text('Failed to fetch users. Please try again later.',style: TextStyle(//fontFamily: appFont
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(//fontFamily: appFont
              ),),
            ),
          ],
        ),
      );
    }
  }

  Future<void> editUser(String userId, String newName, String email,
      String fullName, String phoneNumber) async {
    final uri = Uri.parse(
        '${baseUrl}/crud/updateUser/$userId');
    print(
        'Editing user with ID: $userId'); // Log the userId for debugging purposes

    final response = await http.put(
      uri,
      body: json.encode({
        'UserName': newName,
        'Email': email,
        'FullName': fullName,
        'PhoneNumber': phoneNumber
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // User edited successfully
      getUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User updated successfully',style: TextStyle(fontFamily: appFont),),
        ),
      );
    } else if (response.statusCode == 404) {
      // User not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error',style: TextStyle(//fontFamily: appFont
          ),),
          content: Text('User not found. Unable to edit user.',style: TextStyle(//fontFamily: appFont
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(//fontFamily: appFont
              ),),
            ),
          ],
        ),
      );
    } else {
      // Handle other error cases
      print(
          'Failed to edit user: ${response.body}'); // Log the response body for debugging purposes
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error',style: TextStyle(//fontFamily: appFont
          ),),
          content: Text(
              'Failed to edit user. Status code: ${response.statusCode} and ${response.body}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(//fontFamily: appFont
              ),),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}/crud/userDel/$userId'),
    );

    print(response.body);

    if (response.statusCode == 200) {
      // User deleted successfully
      // You may want to refresh the user list or update the UI accordingly
      getUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
        ),
      );
    } else if (response.statusCode == 404) {
      // User not found
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error',style: TextStyle(//fontFamily: appFont
          ),),
          content: Text('User not found.${response.body}',style: TextStyle(//fontFamily: appFont
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(//fontFamily: appFont
              ),),
            ),
          ],
        ),
      );
    } else {
      // Other error occurred
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error',style: TextStyle(//fontFamily: appFont
          ),),
          content: Text('Failed to delete user. Please try again later.',style: TextStyle(//fontFamily: appFont
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK',style: TextStyle(//fontFamily: appFont
              ),),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            //fontFamily: appFont,
          ),
        ),
        backgroundColor: mainAppColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        //fontFamily: appFont,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(240, 240, 240, 255),
                      contentPadding: EdgeInsets.only(left: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement search functionality
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Color.fromARGB(240, 240, 240, 255),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                  ),
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(8.0),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return UserTile(
                  userId: users[index]['userId'].toString(),
                  userName: users[index]['userName'].toString(),
                  email: users[index]['email'].toString(),
                  fullName: users[index]['fullName'].toString(),
                  phoneNumber: users[index]['phoneNumber'].toString(),
                  deleteUser: () =>
                      deleteUser(users[index]['userId'].toString()),
                  editUser: (String newName, String newEmail,
                          String newFullName, String newPhoneNumber) =>
                      editUser(users[index]['userId'].toString(), newName,
                          newEmail, newFullName, newPhoneNumber),
                  // Pass the editUser method // Pass the deleteUser method// Pass the deleteUser method
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String userName;
  final String email;
  final String fullName;
  final String phoneNumber;
  final Function() deleteUser;
  final Function(String, String, String, String) editUser;

  UserTile({
    required this.userId,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.deleteUser,
    required this.editUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: GestureDetector(
        onTap: () {
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CandidateProfilePage(userId: userId),
            ),
          );*/
        },
        child: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            //fontFamily: appFont,
          ),
          selectionColor: mainAppColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              // Call the deleteUser method with the userId
              deleteUser();
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              // Prompt user for new name and call editUser method
              _promptEditUserName(context);
            },
          ),
        ],
      ),
    );
  }

  // Function to prompt user for new name and call editUser method
  void _promptEditUserName(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();

    // Prefill the text fields with current details
    nameController.text = userName;
    emailController.text = email;
    fullNameController.text = fullName;
    phoneNumberController.text = phoneNumber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User Details',style: TextStyle(//fontFamily: appFont
        ),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'New User Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',style: TextStyle(//fontFamily: appFont
            ),),
          ),
          TextButton(
            onPressed: () {
              // Validate and save the new user details
              String newName = nameController.text.trim();
              String newEmail = emailController.text.trim();
              String newFullName = fullNameController.text.trim();
              String newPhoneNumber = phoneNumberController.text.trim();
              if (newName.isNotEmpty &&
                  newEmail.isNotEmpty &&
                  newFullName.isNotEmpty &&
                  newPhoneNumber.isNotEmpty) {
                editUser(newName, newEmail, newFullName, newPhoneNumber);
              }
              Navigator.of(context).pop();
            },
            child: Text('Save',style: TextStyle(//fontFamily: appFont
            ),),
          ),
        ],
      ),
    );
  }
}
