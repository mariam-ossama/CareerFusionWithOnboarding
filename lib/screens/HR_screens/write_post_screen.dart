import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class WritePostPage extends StatefulWidget {
  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _postController = TextEditingController();
  File? _selectedFile;
  File? _selectedImage;
  String? _uploadedFilePath;
  String? _uploadedImagePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadFile(String postId) async {
    if (_selectedFile == null) return;

    final String fileUploadUrl = '${baseUrl}/FileUpload/$postId/upload-file';
    var request = http.MultipartRequest('POST', Uri.parse(fileUploadUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var responseJson = jsonDecode(responseData.body);
      setState(() {
        _uploadedFilePath =
            responseJson['file']; // Assuming the server returns the file path
      });
      print('File uploaded successfully');
    } else {
      print('File upload failed with status code: ${response.statusCode}');
    }
  }

  Future<void> _uploadImage(String postId) async {
    if (_selectedImage == null) return;

    final String imageUploadUrl =
        '${baseUrl}/PictureUpload/$postId/upload-picture';
    var request = http.MultipartRequest('POST', Uri.parse(imageUploadUrl));
    request.files.add(
        await http.MultipartFile.fromPath('picture', _selectedImage!.path));
    var response = await request.send();
    print('Image upload response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      try {
        var responseJson = jsonDecode(responseData.body);
        setState(() {
          _uploadedImagePath = responseJson[
              'picture']; // Assuming the server returns the image path
        });
        print('Image uploaded successfully');
      } catch (e) {
        print('Failed to parse response: $e');
      }
    } else {
      print('Image upload failed with status code: ${response.statusCode}');
      print('Response body: ${await response.stream.bytesToString()}');
      print(response.statusCode);
    }
  }

  Future<void> _sharePost() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final String postContent = _postController.text;
    final String apiUrl = '${baseUrl}/Post/add/$userId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'content': postContent,
          'userId': userId!,
        }),
      );

      print('Post creation response status code: ${response.statusCode}');
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final postId = responseData['postId'].toString();

        // Upload the file and image if selected
        await _uploadFile(postId);
        await _uploadImage(postId);

        // Show success SnackBar
        _showSuccessSnackBar();

        print('Post shared successfully');
        Navigator.pop(context); // Return to previous screen after posting
      } else {
        print('Error sharing post: ${response.body}');
      }
    } catch (error) {
      print('Error sharing post: $error');
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post shared successfully.'),
        //backgroundColor: Colors.green,
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_camera,
                  color: mainAppColor,
                ),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: mainAppColor,
                ),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Write Post',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            TextField(
              controller: _postController,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Write post...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.photo,
                    color: mainAppColor,
                  ),
                  onPressed: _showImageSourceActionSheet,
                ),
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: mainAppColor,
                  ),
                  onPressed: _pickFile,
                ),
                Spacer(),
                FloatingActionButton(
                  onPressed: _sharePost,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  backgroundColor: mainAppColor,
                  shape: CircleBorder(),
                )
              ],
            ),
            SizedBox(height: 16.0),
            if (_selectedImage != null || _selectedFile != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      if (_selectedImage != null)
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      if (_selectedFile != null) ...[
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected file:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _selectedFile!.path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            SizedBox(
              height: 70,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  height: 150,
                  child: Image.asset(
                      'assets/images/undraw_adventure_map_hnin_new.png'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
