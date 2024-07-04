import 'dart:convert';
import 'package:career_fusion/widgets/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/post.dart';
import 'package:career_fusion/screens/candidate_screens/apply_to_job_post_screen.dart';
import 'package:career_fusion/screens/candidate_screens/apply_to_open_position_screen.dart';
import 'package:career_fusion/widgets/candidate_side_menu.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/widgets/custom_job_card.dart';
import 'package:career_fusion/widgets/custom_menu_card.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Post> posts = []; // List to store posts
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String? connectionId;
  HubConnection? connection;

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Fetch posts when the page initializes
    initializeSignalR();
    initializeNotifications();
  }

  void initializeSignalR() async {
    connection = HubConnectionBuilder()
        .withUrl("http://10.0.2.2:5266/notificationHub")
        .build();

    await connection!.start();
    print('SignalR Connected.');

    connectionId = (await connection!.invoke('ReceiveNotification')) as String?;
    print('Connection ID: $connectionId');


    connection!.on("ReceiveNotification", (message) {
      _showNotification(message.toString());
    });
  }



  void initializeNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'career_fusion@2024', 'CareerFusion',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'New Notification', message, platformChannelSpecifics,
        payload: 'item id 2');
    print(message);
  }
  @override
  void dispose() {
    connection?.stop();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    final apiUrl = '${baseUrl}/Post';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      List<Post> loadedPosts = [];
      for (var postJson in responseData) {
        Post post = Post.fromJson(postJson);
        await post.fetchImageUrls(); // Fetch the image URL for each post
        await post.fetchFileUrls();
        loadedPosts.add(post);
      }
      setState(() {
        posts = loadedPosts;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _openPDF(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/temp.pdf");

      await file.writeAsBytes(response.bodyBytes, flush: true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(path: file.path),
        ),
      );
    } catch (e) {
      print("Error opening PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      drawer: CandidateSideMenu(),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomMenuCard(
                  iconColor: Colors.white,
                  fontColor: Colors.white,
                  color: mainAppColor,
                  title: 'My profile',
                  iconData: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(context, 'UserProfilePage');
                  },
                ),
                CustomMenuCard(
                  iconColor: mainAppColor,
                  fontColor: mainAppColor,
                  color: secondColor,
                  title: 'Notifications',
                  iconData: Icons.notifications,
                  onTap: () {
                    Navigator.pushNamed(context, 'NotificationsPage');
                  },
                ),
                CustomMenuCard(
                  iconColor: Colors.white,
                  fontColor: Colors.white,
                  color: mainAppColor,
                  title: 'Job search',
                  iconData: Icons.search,
                  onTap: () {
                    Navigator.pushNamed(context, 'JobSearchPage');
                  },
                ),
                CustomMenuCard(
                  iconColor: mainAppColor,
                  fontColor: mainAppColor,
                  color: secondColor,
                  title: 'Recommended',
                  iconData: Icons.recommend,
                  onTap: () {
                    Navigator.pushNamed(context, 'RecommendedJobsPage');
                  },
                ),
                CustomMenuCard(
                  iconColor: Colors.white,
                  fontColor: Colors.white,
                  color: mainAppColor,
                  title: 'My Roadmap',
                  iconData: Icons.timeline,
                  onTap: () {
                    Navigator.pushNamed(context, 'CandidateRoadmapPage');
                  },
                ),
                CustomMenuCard(
                  iconColor: mainAppColor,
                  fontColor: mainAppColor,
                  color: secondColor,
                  title: 'Vacancies',
                  iconData: Icons.announcement,
                  onTap: () {
                    Navigator.pushNamed(
                        context, 'CandidateOpenPositionsListPage');
                  },
                ),
                CustomMenuCard(
                  iconColor: Colors.white,
                  fontColor: Colors.white,
                  color: mainAppColor,
                  title: 'HR Reports',
                  iconData: Icons.report,
                  onTap: () {
                    Navigator.pushNamed(context, 'ReportPage');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  shadowColor: Colors.grey[500],
                  color: Color.fromARGB(255, 235, 233, 255),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: posts[index]
                                              .userProfilePicturePath !=
                                          null &&
                                      posts[index]
                                          .userProfilePicturePath!
                                          .isNotEmpty
                                  ? NetworkImage(
                                      '${publicDomain}${posts[index].userProfilePicturePath}')
                                  : AssetImage('assets/images/111.avif')
                                      as ImageProvider,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  posts[index].userFullName ?? 'Unknown User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  posts[index].userEmail ?? 'Unknown Email',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          posts[index].content ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (posts[index].fileId != null &&
                            posts[index].fileUrls != null &&
                            posts[index].fileUrls!.isNotEmpty) ...[
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: ListTile(
                                  onTap: () {
                                    _openPDF('${posts[index].fileId}');
                                  },
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        color: mainAppColor,
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          posts[index].fileUrls![0],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: appFont,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                        if (posts[index].imageUrls != null &&
                            posts[index].imageUrls!.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.network(
                                posts[index].imageUrls![0],
                                errorBuilder: (context, error, stackTrace) {
                                  return Text('Image not available');
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            posts[index].createdAt ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: appFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: secondColor,
                          thickness: 2.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Apply Now',
                                onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ApplyToJobPostPage(
                                                postId: posts[index].postId),
                                      ),
                                    );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


