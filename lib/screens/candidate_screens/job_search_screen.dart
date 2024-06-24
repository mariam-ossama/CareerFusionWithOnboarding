import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JobSearchPage extends StatefulWidget {
  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  final String graphicImagePath =
      'assets/images/WhatsApp Image 2023-11-26 at 20.32.41.jpeg'; 
      TextEditingController searchJobTitle = TextEditingController();
      TextEditingController searchLocation = TextEditingController();

 // Replace with your image asset path
  void _onSearchItemTap(String category) {
    // You can navigate to a new screen or perform other actions based on the category
    print('Tapped on $category');
  }

  List<Job> jobs = [
    /*Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),
    Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),
    Job(
      companyName: 'Valeo',
      jobTitle: 'Software Engineer',
      location: 'Egypt, Cairo',
      type: 'Full-Time',
      logoUrl: 'assets/images/Valeo_Logo.svg.png',
    ),*/
    // Add more jobs as needed
  ];

   Future<void> _searchJobsByTitle() async {
    final url = Uri.parse('http://10.0.2.2:5266/api/JobSearch/SearchByJobTitle?keyword=${searchJobTitle.text}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        jobs = responseData.map((jobData) => Job.fromJson(jobData)).toList();
      });
      // Here you can handle the response data, update the UI, etc.
      print(responseData); // For demonstration, you can print the response data
      print(response.body);
      print(response.statusCode);
      print('search done by title only');
    } else {
      // If the server did not return a 200 OK response, throw an error.
      throw Exception('Failed to load jobs');
    }
  }

  Future<void> _searchJobsByLocation() async {
    final url = Uri.parse('http://10.0.2.2:5266/api/JobSearch/SearchTitleWithLocation?keyword=${searchJobTitle.text}&location=${searchLocation.text}');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        jobs = responseData.map((jobData) => Job.fromJson(jobData)).toList();
      });
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Search',
          style: TextStyle(//fontFamily: appFont,
           color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: mainAppColor,
        elevation: 0, // No shadow
      ),
      //extendBodyBehindAppBar: true,
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          /*Container(
            height: 200,
            width: 200, // Adjust the height to fit your graphic image
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(graphicImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),*/
          Positioned(
            top: 200, // Position where the search bar should start
            left: 20,
            right: 20,
            child: Container(
              width: 350,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Job Title',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchJobsByTitle,),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Update the search keyword when the text changes
                  setState(() {
                    searchJobTitle.text = value;
                  });
                },
                controller: searchJobTitle,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: 350,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Job Location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchJobsByLocation,),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                // Update the search keyword when the text changes
                setState(() {
                  searchLocation.text = value;
                });
              },
              controller: searchLocation,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          /*Expanded(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('Advanced filter',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat-VariableFont_wght',
                        )),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                ListTile(
                  title: Center(
                      child: Text(
                    'by Location',
                    style: TextStyle(
                      fontFamily: 'Montserrat-VariableFont_wght',
                    ),
                  )),
                  onTap: () => _onSearchItemTap('Location'),
                ),
                ListTile(
                  title: Center(
                      child: Text(
                    'by Industry',
                    style: TextStyle(
                      fontFamily: 'Montserrat-VariableFont_wght',
                    ),
                  )),
                  onTap: () => _onSearchItemTap('Industry'),
                ),
                ListTile(
                  title: Center(
                      child: Text(
                    'by Experience level',
                    style: TextStyle(
                      fontFamily: 'Montserrat-VariableFont_wght',
                    ),
                  )),
                  onTap: () => _onSearchItemTap('Experience level'),
                ),
              ],
            ),
          ),*/
          Container(
            height: 40,
            child: ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                SizedBox(
                  width: 35,
                ),
                GestureDetector(
                  onTap: _searchJobsByLocation,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: mainAppColor),
                    child: const Center(
                      child: Text(
                        'Location',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            //fontFamily: appFont
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: secondColor),
                    child: const Center(
                        child: Text(
                      'Industry',
                      style: TextStyle(
                          fontSize: 18, color: mainAppColor, //fontFamily: appFont
                          ),
                    )),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: (){},
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: mainAppColor),
                    child: const Center(
                      child: Text(
                        'Experience Level',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            //fontFamily: appFont
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: _searchJobsByTitle,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: secondColor),
                    child: Center(
                      child: Text(
                        'Job Title',
                        style: TextStyle(
                            fontSize: 18,
                            color: mainAppColor,
                            //fontFamily: appFont
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                /*Container(
                  width: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: mainAppColor),
                ),*/
              ],
            ),
          ),
          /*SizedBox(height: 130,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 200, // Specify the desired width
                height: 150, // Specify the desired height
                child: Image.asset(
                    'assets/images/undraw_adventure_map_hnin_new.png'),
              ),
            ],
          ),*/
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return SearchedJobCard(
                  job: jobs[index],
                  onTap: () {
                    Navigator.pushNamed(context, 'JobDetailsPage');
                    // Handle job card click here
                    // You can implement navigation or other actions as needed
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  SearchedJobCard({required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shadowColor: Colors.indigo,
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    job.logoUrl,
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            //fontFamily: appFont,
                          ),
                        ),
                        Text(
                          job.location,
                          style: TextStyle(
                            //fontFamily: appFont,
                          ),
                        ),
                        Text(
                          job.type,
                          style: TextStyle(
                            //fontFamily: appFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Job {
  int id;
  String companyName = 'Company Name';
  final String jobTitle;
  final String location;
  final String type;
  String logoUrl;

  Job({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.location,
    required this.type,
    required this.logoUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 1,
      companyName: json['companyName'] ?? 'Company Name',
      jobTitle: json['jobTitle'] ?? 'job Title',
      location: json['jobLocation'] ?? 'job Location',
      type: json['jobType'] ?? 'Job type',
      logoUrl: json['logoUrl'] ?? 'assets/images/Valeo_Logo.svg.png',
    );
  }
}
