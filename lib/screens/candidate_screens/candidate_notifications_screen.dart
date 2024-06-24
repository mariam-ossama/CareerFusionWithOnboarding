import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:career_fusion/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_fusion/models/notifications.dart' as AppNotification; // Rename your Notification class

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification.Notification> notifications = []; // Use the renamed class here

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      final response = await http.get(Uri.parse('${baseUrl}/OpenPosCV/${userId}/notifications'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          notifications = data.map((item) => AppNotification.Notification.fromJson(item)).toList(); // Use the renamed class here
        });
      } else {
        print('Failed to fetch notifications: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: notifications.isEmpty ? Center(child: CircularProgressIndicator()) : buildListView(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      title: Text(
        'Your Notifications',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: mainAppColor,
      elevation: 0,
    );
  }

  Widget buildListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return buildNotificationTile(notifications[index]);
      },
    );
  }

  Widget buildNotificationTile(AppNotification.Notification notification) { // Use the renamed class here
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prefixIcon(),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message(notification.message!),
                  timeAndDate(DateTime.parse(notification.createdAt!)), // Parse string to DateTime
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget prefixIcon() {
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueGrey.withOpacity(0.2),
      ),
      child: Icon(Icons.notifications, size: 25, color: mainAppColor),
    );
  }

  Widget message(String message) {
    double textSize = 14;
    return Container(
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: '',
          style: TextStyle(
            fontSize: textSize,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: message,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget timeAndDate(DateTime createdAt) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(createdAt);
    String formattedTime = DateFormat('hh:mm a').format(createdAt);

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
