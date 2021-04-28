import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';
class TeamLabel extends StatelessWidget {
  final String text;
  final Color color;

  const TeamLabel({Key key, this.text = '', this.color = Colors.red})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(right: 8),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(3)
          ),
        ),
        Text(text,
          style: TextStyle(
            color: subFontColor,
            fontSize: 18
          ),
        )
      ],
    );
  }
}