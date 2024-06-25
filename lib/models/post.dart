import 'package:career_fusion/constants.dart';
import 'package:http/http.dart' as http;

class Post {
  final int postId;
  final String content;
  final String createdAt;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String? userProfilePicturePath;
  List<String>? imageUrls;
  List<String>? fileUrls;
  List<int>? fileId;
  List<int>? pictureId;

  Post({
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    this.userProfilePicturePath,
    this.imageUrls,
    this.fileUrls,
    this.fileId,
    this.pictureId,
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
      fileId: json['postFileIds'] != null
          ? List<int>.from(json['postFileIds'])
          : null,
      pictureId: json['postPictureIds'] != null
          ? List<int>.from(json['postPictureIds'])
          : null,
    );
  }

  Future<void> fetchImageUrls() async {
    if (pictureId != null) {
      imageUrls = [];
      for (var id in pictureId!) {
        final apiUrl = '${baseUrl}/PictureUpload/$id/picture-path';
        try {
          final response = await http.get(Uri.parse(apiUrl));
          if (response.statusCode == 200) {
            imageUrls!.add(response.body);
          } else {
            imageUrls!.add('Error fetching image URL');
          }
        } catch (e) {
          imageUrls!.add('Error fetching image URL: $e');
        }
      }
    }
  }

  Future<void> fetchFileUrls() async {
    if (fileId != null) {
      fileUrls = [];
      for (var id in fileId!) {
        final apiUrl = '${baseUrl}/FileUpload/$id/url';
        try {
          final response = await http.get(Uri.parse(apiUrl));
          if (response.statusCode == 200) {
            fileUrls!.add(response.body);
          } else {
            fileUrls!.add('Error fetching file URL');
          }
        } catch (e) {
          fileUrls!.add('Error fetching file URL: $e');
        }
      }
    }
  }
}
