import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final double paddingTop;
  const MyDivider({
    Key key,
    this.paddingTop = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: paddingTop),
      width: size.width * 0.9,
      child: Divider(),
    );
  }
}