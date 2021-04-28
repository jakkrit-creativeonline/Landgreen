import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SquareButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final Function press;
  final double fontSize;

  const SquareButton(
      {Key key,
      this.text = 'BUTTON',
      this.buttonColor = kPrimaryColor,
      this.textColor = buttonFontColor,
      this.icon = FontAwesomeIcons.edit,
      this.iconColor = Colors.white,
      this.fontSize = 18.0,
      this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: FlatButton(
                  onPressed: press,
                  color: buttonColor,
                  child: FaIcon(
                    icon,
                    color: iconColor,
                  ),
                )),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            text,
            style: TextStyle(fontSize: fontSize, color: textColor,height: 1),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
