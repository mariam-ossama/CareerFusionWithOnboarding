import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:career_fusion/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class OpenPositionApplicants extends StatefulWidget {
  final int jobFormId;

  const OpenPositionApplicants({Key? key, required this.jobFormId}) : super(key: key);

  @override
  State<OpenPositionApplicants> createState() => _OpenPositionApplicantsState();
}

class _OpenPositionApplicantsState extends State<OpenPositionApplicants> {
  late Future<List<String>> _fetchCVs;

  @override
  void initState() {
    super.initState();
    _fetchCVs = _fetchCVUrls();
  }

  Future<List<String>> _fetchCVUrls() async {
    final apiUrl = 'http://10.0.2.2:5266/api/OpenPosCV/${widget.jobFormId}/cvs';
    print(widget.jobFormId);

    final response = await http.get(Uri.parse(apiUrl));

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> urls = data.map((item) => item['filePath'] as String).toList();
      return urls;
    } else {
      throw Exception('Failed to load CVs');
    }
  }

  Future<void> _downloadAllCVs() async {
    final apiUrl = 'http://10.0.2.2:5266/api/OpenPosCV/${widget.jobFormId}/download-cvs';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/CVs_${widget.jobFormId}.zip';
        final file = File(filePath);

        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download successful: ${filePath}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download CVs')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Open Position Applicants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _fetchCVs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final cvUrls = snapshot.data!;
                  return ListView.builder(
                    itemCount: cvUrls.length,
                    itemBuilder: (context, index) {
                      String cvUrl = cvUrls[index];
                      // Truncate the URL for display purposes
                      String displayUrl = cvUrl.length > 30 ? cvUrl.substring(0, 30) + '...' : cvUrl;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shadowColor: Colors.grey[500],
                          color: Color.fromARGB(255, 235, 233, 255),
                          child: ListTile(
                            leading: Icon(Icons.description, color: mainAppColor), // PDF icon
                            title: Text(
                              displayUrl,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              _launchURL(cvUrl); // Call function to open URL
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: 'Download All CVs',
                  onPressed: _downloadAllCVs,
                ),
                SizedBox(height: 5,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
