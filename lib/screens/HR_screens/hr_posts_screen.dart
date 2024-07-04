import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/screens/HR_screens/hr_post_candidates.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:career_fusion/models/post.dart';

class HRPostsPage extends StatefulWidget {
  const HRPostsPage({Key? key}) : super(key: key);

  @override
  State<HRPostsPage> createState() => _HRPostsPageState();
}

class _HRPostsPageState extends State<HRPostsPage> {
  List<Post> hrPosts = [];

  @override
  void initState() {
    super.initState();
    fetchHRPosts();
  }

  Future<void> fetchHRPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final apiUrl = '${baseUrl}/Post/HrPost/$userId';
    final response = await http.get(Uri.parse(apiUrl));
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      List<Post> loadedPosts = [];
      for (var postJson in responseData) {
        Post post = Post.fromJson(postJson);
        await post.fetchImageUrls();
        await post.fetchFileUrls();
        loadedPosts.add(post);
      }
      setState(() {
        hrPosts = loadedPosts;
      });
    } else {
      throw Exception('Failed to load HR posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Posts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: hrPosts.isNotEmpty
          ? ListView.builder(
              itemCount: hrPosts.length,
              itemBuilder: (context, index) {
                final post = hrPosts[index];
                return GestureDetector(
                  onTap: () {
                    ///////////////////
                  },
                  child: Card(
                    shadowColor: Colors.grey[500],
                    color: Color.fromARGB(255, 235, 233, 255),
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (post.userProfilePicturePath != null &&
                                  post.userProfilePicturePath!.isNotEmpty)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    '${publicDomain}${post.userProfilePicturePath}',
                                  ),
                                ),
                              SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                child: Text(
                                  post.userFullName,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            post.content,
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(height: 8.0),
                          if (post.fileUrls != null &&
                              post.fileUrls!.isNotEmpty) ...[
                            for (var fileUrl in post.fileUrls!)
                              if (fileUrl != 'Error fetching file URL') ...[
                                SizedBox(height: 10),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.description,
                                              color: mainAppColor,
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Text(
                                                fileUrl,
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
                          ],
                          if (post.imageUrls != null &&
                              post.imageUrls!.isNotEmpty) ...[
                            for (var imageUrl in post.imageUrls!)
                              if (imageUrl != 'Error fetching image URL') ...[
                                SizedBox(height: 10),
                                Center(
                                  child: SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Image.network(
                                      imageUrl,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Text('Image not available');
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                          ],
                          Center(
                            child: Text(
                              'Posted on: ${post.createdAt}',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                  fontFamily: appFont,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          CustomButton(
                            text: 'Applied Candidates',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HRPostCandidatesPage(postId: post.postId),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
