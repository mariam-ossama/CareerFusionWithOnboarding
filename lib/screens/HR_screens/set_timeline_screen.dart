import 'dart:convert';

import 'package:career_fusion/constants.dart';
import 'package:career_fusion/models/timeline_item.dart';
import 'package:career_fusion/screens/authentication_screens/role_selection_screen.dart';
import 'package:career_fusion/widgets/timeline_tile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeline_tile/timeline_tile.dart';

class SetTimelinePage extends StatefulWidget {
  const SetTimelinePage({Key? key}) : super(key: key);

  @override
  State<SetTimelinePage> createState() => _SetTimelinePageState();
}

class _SetTimelinePageState extends State<SetTimelinePage> {
  List<TimelineItem> timelineItems = [];
  //final Color mainAppColor = Colors.blue; // Define your main app color here
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    fetchTimelineData();
  }

  Widget build(BuildContext context) {
    void handleCheckboxChange(bool? newValue, int index) async {
      setState(() {
        timelineItems[index].isChecked =
            newValue ?? false; // Update the isChecked property
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      int? stageId = timelineItems[index].stageId;

      try {
        final response = await http.put(
          Uri.parse(
              '${baseUrl}/HiringTimeline/UpdateTimelineStage/$userId/$stageId'),
          body: jsonEncode({
            'stageId': stageId,
            'status': newValue ?? false, // Update the status field
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          print('Status updated successfully');
        } else {
          throw Exception('Failed to update status: ${response.body}');
        }
      } catch (e) {
        print('Error updating status: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Timeline',
          style: TextStyle(
            //fontFamily: appFont,
            color: Colors.white,
          ),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: ListView(
          children: timelineItems.asMap().entries.map((entry) {
            final int index = entry.key;
            final TimelineItem item = entry.value;

            return CustomTimelineTile(
              isFirst: index == 0,
              isLast: index == timelineItems.length - 1,
              isPast: item.isChecked, // Assuming all items are in the past
              eventCard: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: item.description,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(item.startDate, style: TextStyle(color: Colors.white)),
                  Text(item.endDate, style: TextStyle(color: Colors.white)),
                ],
              ),
              onDelete: () {
                deleteTimelineItem(item.stageId!);
              },
              onEdit: () {
                // Handle edit
                // You can navigate to another page for editing or show another dialog, based on your requirements
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController descriptionController =
                        TextEditingController(text: item.description);

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(
                            'Enter Details',
                            style: TextStyle(
                                //fontFamily: 'Montserrat-VariableFont_wght'
                                ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                    labelText: 'New Description'),
                              ),
                              ListTile(
                                leading: Icon(Icons.calendar_today),
                                title: Text(
                                    'Start Date: ${startDate?.toString() ?? 'Select Start Date'}'),
                                onTap: () async {
                                  final DateTime? pickedStartDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedStartDate != null) {
                                    setState(() {
                                      startDate = pickedStartDate;
                                    });
                                  }
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.calendar_today),
                                title: Text(
                                    'End Date: ${endDate?.toString() ?? 'Select End Date'}'),
                                onTap: () async {
                                  final DateTime? pickedEndDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: endDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedEndDate != null) {
                                    setState(() {
                                      endDate = pickedEndDate;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    //fontFamily: 'Montserrat-VariableFont_wght'
                                    ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String newDescription =
                                    descriptionController.text;
                                String newStartDate = startDate != null
                                    ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                        .format(startDate!)
                                    : "";
                                String newEndDate = endDate != null
                                    ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                        .format(endDate!)
                                    : "";
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? userId = prefs.getString('userId');

                                try {
                                  if (item.stageId != null) {
                                    final response = await http.put(
                                      Uri.parse(
                                          '${baseUrl}/HiringTimeline/UpdateTimelineStage/${userId}/${item.stageId}'),
                                      body: jsonEncode({
                                        'stageId':
                                            item.stageId, // Provide stageId
                                        'description': newDescription,
                                        'startTime': newStartDate,
                                        'endTime': newEndDate,
                                        'updatedStage':
                                            'someValue', // Provide updatedStage
                                      }),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      print(
                                          'Timeline item updated successfully');
                                      setState(() {
                                        timelineItems[index] = TimelineItem(
                                          stageId: item.stageId,
                                          description: newDescription,
                                          startDate: newStartDate,
                                          endDate: newEndDate,
                                        );
                                      });
                                      fetchTimelineData();
                                    } else {
                                      throw Exception(
                                          'Failed to update timeline item: ${response.body}');
                                    }
                                  } else {
                                    throw Exception('stageId is null');
                                  }
                                } catch (e) {
                                  print('Error updating timeline item: $e');
                                }

                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    //fontFamily: 'Montserrat-VariableFont_wght'
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              onCheckboxChanged: (newValue) =>
                  handleCheckboxChange(newValue, index), // Update to pass index
              item: item,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController descriptionController =
                  TextEditingController();
              String startDateText =
                  startDate?.toString() ?? 'Select Start Date';
              String endDateText = endDate?.toString() ?? 'Select End Date';

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text(
                      'Enter Details',
                      style:
                          TextStyle(//fontFamily: 'Montserrat-VariableFont_wght'
                              ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('Start Date: $startDateText'),
                          onTap: () async {
                            final DateTime? pickedStartDate =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedStartDate != null) {
                              setState(() {
                                startDate = pickedStartDate;
                                startDateText = pickedStartDate.toString();
                              });
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('End Date: $endDateText'),
                          onTap: () async {
                            final DateTime? pickedEndDate =
                                await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedEndDate != null) {
                              setState(() {
                                endDate = pickedEndDate;
                                endDateText = pickedEndDate.toString();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              //fontFamily: 'Montserrat-VariableFont_wght'
                              ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String description = descriptionController.text;
                          String formattedStartDate = startDate != null
                              ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                  .format(startDate!)
                              : "";
                          String formattedEndDate = endDate != null
                              ? DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                  .format(endDate!)
                              : "";

                          addTimelineItem(description, formattedStartDate,
                              formattedEndDate);

                          print('Description: $description');
                          print('Start Date: ${startDate?.toString()}');
                          print('End Date: ${endDate?.toString()}');

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                              //fontFamily: 'Montserrat-VariableFont_wght'
                              ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: mainAppColor,
      ),
    );
  }

  void addTimelineItem(
      String description, String startDate, String endDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/HiringTimeline/SetTimeline/$userId'),
        body: jsonEncode({
          'model': {}, // Adding an empty model field
          'stages': [
            {
              'description': description,
              'startTime': formatDate(startDate), // Format start date
              'endTime': formatDate(endDate), // Format end date
            },
          ],
          'userId': userId
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print('Timeline item added successfully');
        setState(() {
          timelineItems.add(TimelineItem(
            description: description,
            startDate: startDate,
            endDate: endDate,
          ));
        });
      } else {
        throw Exception('Failed to add timeline item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding timeline item: $e');
    }
  }

  // Helper function to format date strings
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.toUtc().toIso8601String(); // Convert to ISO 8601 format
  }

  Future<void> fetchTimelineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/HiringTimeline/GetTimelinesForUser/$userId'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          timelineItems = responseData.map((itemData) {
            return TimelineItem.fromJson(itemData);
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch timeline data: ${response.body}');
      }
    } catch (e) {
      throw 'Error fetching timeline data: $e';
    }
  }

  void deleteTimelineItem(int stageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      final response = await http.delete(
        Uri.parse(
            '${baseUrl}/HiringTimeline/DeleteTimelineStage/$userId/$stageId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Timeline item deleted successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timeline item deleted successfully')),
        );

        // Remove the deleted timeline item from the list
        setState(() {
          timelineItems.removeWhere((item) => item.stageId == stageId);
        });
      } else {
        throw Exception('Failed to delete timeline item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting timeline item: $e');
    }
  }
}
