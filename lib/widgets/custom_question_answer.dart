// custom_question_answer.dart
import 'package:career_fusion/constants.dart';
import 'package:career_fusion/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class OptionWidget extends StatefulWidget {
  final VoidCallback? onDelete;

  OptionWidget({Key? key, this.onDelete}) : super(key: key);

  @override
  _OptionWidgetState createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  String optionText = '';
  bool isCorrect = false;

  void _editOption() {
    String updatedOptionText = optionText; // Store the current value
    TextEditingController controller = TextEditingController(text: optionText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Option",style: TextStyle(//fontFamily: appFont
          ),),
          content: CustomTextField(
            obsecureText: false,
            controllerText: controller,
            hint: 'Enter option text',
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel",style: TextStyle(//fontFamily: appFont
              ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Update",style: TextStyle(//fontFamily: appFont
              ),),
              onPressed: () {
                setState(() {
                  optionText = updatedOptionText; // Update the state with the new value
                });
                controller.text = updatedOptionText; // Update the text field immediately
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isCorrect,
          onChanged: (value) {
            setState(() {
              isCorrect = value!;
            });
          },
        ),
        Expanded(
          child: CustomTextField(
            obsecureText: false,
            controllerText: TextEditingController(text: optionText),
            hint: 'Enter option text',
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: widget.onDelete, // Call the onDelete callback
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: _editOption,
        ),
      ],
    );
  }
}
