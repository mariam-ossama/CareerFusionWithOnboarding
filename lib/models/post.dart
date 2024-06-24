import 'package:career_fusion/constants.dart';
import 'package:http/http.dart' as http;

class Post {
  final int postId;
  final String content;
  final String createdAt;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String userProfilePicturePath;
  String? imageUrl;
  String? file;

  Post({
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.userProfilePicturePath,
    this.imageUrl,
    this.file,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      content: json['content'],
      createdAt: json['createdAt'],
      userId: json['userId'],
      userFullName: json['userFullName'],
      userEmail: json['userEmail'],
      userProfilePicturePath: json['userProfilePicturePath'],
    );
  }

  Future<void> fetchImageUrl() async {
    final apiUrl = '${baseUrl}/PictureUpload/$postId/picture-path';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        imageUrl = response.body;
      } else {
        imageUrl = null;
      }
    } catch (e) {
      imageUrl = null;
      print('Error fetching image URL: $e');
    }
  }


  Future<void> fetchFileUrl() async {
    final apiUrl = '${baseUrl}/FileUpload/$postId/url';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        file = response.body;
        print(response.body);
      } else {
        file = null;
      }
    } catch (e) {
      file = null;
      print('Error fetching file URL: $e');
    }
  }
}

