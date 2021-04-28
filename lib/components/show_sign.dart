import 'dart:convert';

import 'package:flutter/material.dart';

class ShowSign extends StatelessWidget {
  const ShowSign({
    Key key,
    @required this.sign,
    this.rear,
    this.text = '',
  }) : super(key: key);

  final String sign;
  final Widget rear;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.6,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            width: 150,
            height: 100,
            child: Image.memory(base64Decode(sign)),
          ),
          if (rear != null) rear
        ],
      ),
    );
  }
}
