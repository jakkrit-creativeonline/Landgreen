import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      width: size.width * 0.8,
      decoration: BoxDecoration(
          color: bgInputColor, borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}