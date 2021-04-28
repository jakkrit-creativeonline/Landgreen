import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double widthScreen;
  final setBGColor;
  const FormCard({
    Key key,
    this.child,
    this.title = '',
    this.widthScreen = double.infinity,
    this.setBGColor = bgCardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(left: 0,right: 0),
      child: Card(
        color: setBGColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HeaderText(text: title,textSize: 20,gHeight: 26,),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 16,top: 8,bottom: 8),
                    //   child: Text(
                    //     title,
                    //     style: TextStyle(
                    //         color: Colors.white, fontSize: 18),
                    //   ),
                    // ),
                  ],
                ),
                color: darkColor,
                width: widthScreen,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
            child
          ],
        ),
      ),
    );
  }
}