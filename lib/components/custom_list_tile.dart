import 'package:flutter/rendering.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onTap;
  final Color iconColor,textColor;

  const CustomListTile(
      {Key key,
        this.text = 'TEXT',
        this.icon = FontAwesomeIcons.home,
        this.onTap,
        this.textColor = menuFontColor,
        this.iconColor = menuFontColor
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0,left: 14.0,bottom: 5.0),
      child: InkWell(
        child: Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:35,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(text, style: TextStyle(color: textColor,fontSize: 20,))

          ],
        ),
        onTap: onTap,
      ),
    );
  }
}