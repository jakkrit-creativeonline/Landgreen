import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyFunction extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Container();
  }
  openURL({linkStr}) async {

    var url = linkStr.toString();
    print(linkStr);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
