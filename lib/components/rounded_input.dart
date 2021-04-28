
import 'package:system/components/text_feild_container.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final String errorText;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.errorText,
    this.textController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        style: TextStyle(fontSize: 22),
        decoration: InputDecoration(
            icon: Icon(
              icon,
              // color: kPrimaryColor,
            ),
            hintText: hintText,
            errorText: errorText,
            border: InputBorder.none),
      ),
    );
  }
}