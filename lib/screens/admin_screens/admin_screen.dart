import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/timeline_item.dart';
import 'package:career_fusion/screens/admin_screens/user_details_screen.dart';
import 'package:career_fusion/widgets/timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    final response = await http.get(Uri.parse('${baseUrl}/crud/users'));

    if (response.statusCode == 200) {
      final List<dynamic> userList = json.decode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(userList);
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch users. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> editUser(String userId, String newName, String email,
      String fullName, String phoneNumber) async {
    final uri = Uri.parse('${baseUrl}/crud/updateUser/$userId');
    print('Editing user with ID: $userId');

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
      getUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User updated successfully'),
        ),
      );
    } else if (response.statusCode == 404) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('User not found. Unable to edit user.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('Failed to edit user: ${response.body}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Failed to edit user. Status code: ${response.statusCode} and ${response.body}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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

    if (response.statusCode == 200) {
      getUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
        ),
      );
    } else if (response.statusCode == 404) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('User not found. ${response.body}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete user. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: mainAppColor,
            elevation: 0,
          ),
          body: buildUserList()),
    );
  }

  Widget buildUserList() {
    return ListView.separated(
      padding: EdgeInsets.all(8.0),
      itemCount: users.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserTile(
          userId: user['userId'].toString(),
          userName: user['userName'].toString(),
          email: user['email'].toString(),
          fullName: user['fullName'].toString(),
          phoneNumber: user['phoneNumber'].toString(),
          deleteUser: () => deleteUser(user['userId'].toString()),
          editUser: (String newName, String newEmail, String newFullName,
                  String newPhoneNumber) =>
              editUser(user['userId'].toString(), newName, newEmail,
                  newFullName, newPhoneNumber),
        );
      },
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(
                userData: {
                  'userId': userId,
                  'userName': userName,
                  'email': email,
                  'fullName': fullName,
                  'phoneNumber': phoneNumber,
                },
              ),
            ),
          );
        },
        child: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.delete, color: mainAppColor),
            onPressed: deleteUser,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: mainAppColor),
            onPressed: () {
              _promptEditUserName(context);
            },
          ),
        ],
      ),
    );
  }

  void _promptEditUserName(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController phoneNumberController = TextEditingController();

    nameController.text = userName;
    emailController.text = email;
    fullNameController.text = fullName;
    phoneNumberController.text = phoneNumber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User Details'),
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
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
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
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
