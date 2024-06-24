import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class TecnicalInterviewResultPage extends StatefulWidget {
  const TecnicalInterviewResultPage({super.key});

  @override
  State<TecnicalInterviewResultPage> createState() => _TecnicalInterviewResultPageState();
}

class _TecnicalInterviewResultPageState extends State<TecnicalInterviewResultPage> {
  String? selectedPosition;
  final List<String> positions = ['Position 1', 'Position 2', 'Position 3'];

  // Map to store candidate status: promising, maybe, disqualified
  Map<String, String> candidateStatus = {
    'Candidate 1': 'promising',
    'Candidate 2': 'maybe',
    'Candidate 3': 'disqualified',
    'Candidate 4': 'promising',
    'Candidate 5': 'maybe',
    'Candidate 6': 'maybe',
    'Candidate 7': 'promising',
    'Candidate 8': 'promising',
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Interview Result',
          style: TextStyle(
              //fontFamily: appFont,
               color: Colors.white),
        ),
        backgroundColor: mainAppColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 370,
              decoration: ShapeDecoration(
                color: mainAppColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
              padding: EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                iconEnabledColor: Colors.white,
                isExpanded: true,
                value: selectedPosition,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPosition = newValue;
                  });
                },
                items: positions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                          //fontFamily: appFont,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                hint: Center(
                  child: Text(
                    'Choose Position',
                    style: TextStyle(
                      //fontFamily: appFont,
                      fontSize: 20,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: candidateStatus.length,
              itemBuilder: (context, index) {
                String candidateName = candidateStatus.keys.elementAt(index);
                String status = candidateStatus[candidateName] ?? 'maybe';
                Color statusColor;
                switch (status) {
                  case 'promising':
                    statusColor = Colors.green;
                    break;
                  case 'maybe':
                    statusColor = Colors.blue;
                    break;
                  case 'disqualified':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.black;
                }
                return ListTile(
                  tileColor: const Color.fromARGB(240, 240, 240, 255),
                  title: Text(
                    candidateName,
                    style: TextStyle(
                      fontFamily: appFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  trailing: Icon(Icons.person,color: mainAppColor,),
                  onTap: () {
                    // TODO: Implement candidate details page
                  },
                  subtitle: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontFamily: appFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          CustomButton(
            text: 'Export to excel',
            onPressed: () {
              ///////////////////////////////////////////
            },
          ),
          SizedBox(height: 5,)
        ],
      ),
    );
  }
}