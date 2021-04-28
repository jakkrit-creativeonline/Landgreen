import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String text;
  final double gHeight;
  final double textSize;
  const HeaderText({
    Key key,
    this.text = 'รายได้รวมของคุณ',
    this.textSize = 18.0,
    this.gHeight = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: kPrimaryLightColor,
            width: 6,
            height: gHeight,
          ),
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                child: Text(
                  text,
                  style: TextStyle(fontSize: textSize, color: Colors.white),
                ),
              ),
              color: backgroudBarColor,
            ),
          ),
        ],
      ),
      borderRadius: BorderRadius.circular(1),
    );
  }
}