
import 'package:system/components/text_feild_container.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';


class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController textController;
  final String errorText;

  const RoundedPasswordField({Key key, this.onChanged, this.errorText,this.textController})
      : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: isHide,
        onChanged: widget.onChanged,
        controller: widget.textController,
        style: TextStyle(fontSize: 22),
        decoration: InputDecoration(
            errorText: widget.errorText,
            hintText: "พาสเวิร์ด",
            icon: Icon(
              Icons.lock,
              // color: kPrimaryColor,
            ),
            suffixIcon: InkWell(
              child: Icon(Icons.visibility),
              onTap: () {
                setState(() {
                  isHide = !isHide;
                });
              },
            ),
            border: InputBorder.none),
      ),
    );
  }
}
