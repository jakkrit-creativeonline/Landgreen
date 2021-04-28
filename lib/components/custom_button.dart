import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key key, this.text = '', this.onPress, this.color = kPrimaryColor, this.textColor = Colors.white,
  }) : super(key: key);
  final String text;
  final Function onPress;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPress,
      child: Text(text),
      color: color,
      textColor: textColor,
    );
  }
}