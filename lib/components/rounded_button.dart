import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color,textColor;
  final double widthFactor;
  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
    this.widthFactor = 0.8
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical:9),
      width: size.width * widthFactor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            color: color,
            onPressed: press,
            child: Text(
              text,
              style: TextStyle(color: textColor,fontSize: 25),
            )),
      ),
    );
  }
}