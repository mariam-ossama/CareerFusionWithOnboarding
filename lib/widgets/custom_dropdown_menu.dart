import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatelessWidget {
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final String hint;

  CustomDropdownMenu({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      decoration: ShapeDecoration(
        color: mainAppColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1.0, style: BorderStyle.solid, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      child: DropdownButton<String>(
        itemHeight: 48,
        iconEnabledColor: const Color.fromARGB(240, 240, 240, 255),
        value: value,
        hint: Text(hint,
        //style: TextStyle(fontFamily: appFont),
        ),
        isExpanded: true,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String position) {
          return DropdownMenuItem<String>(
            value: position,
            child: Text(position,style: TextStyle(fontFamily: appFont),),
          );
        }).toList(),
      ),
    );
  }
}
