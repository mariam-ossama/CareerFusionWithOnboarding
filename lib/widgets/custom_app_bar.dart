import 'package:career_fusion/constants.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final String? title; // Add a title parameter to accept text

  CustomAppBar({this.title}); // Constructor to initialize the title

  Widget build(BuildContext context) {
    return new SizedBox.fromSize(
      size: preferredSize,
      child: new LayoutBuilder(builder: (context, constraint) {
        final width = constraint.maxWidth * 8;
        return new ClipRect(
          child: new OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: new SizedBox(
              width: width,
              height: width,
              child: new Padding(
                padding: new EdgeInsets.only(
                    bottom: width / 2 - preferredSize.height / 3000),
                child: new DecoratedBox(
                  decoration: new BoxDecoration(
                    color: mainAppColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      new BoxShadow(color: Colors.black54, blurRadius: 8.0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(200.0);
}
