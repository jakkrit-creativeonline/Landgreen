import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  // String appName = '';
  // String packageName = '';
  // String version = '';
  // String buildNumber = '';
  // getVersionApp() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   appName = packageInfo.appName;
  //   packageName = packageInfo.packageName;
  //   version = packageInfo.version;
  //   buildNumber = packageInfo.buildNumber;
  //   print('version =>${version}');
  // }

  @override
  void initState() {
    // getVersionApp();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Image.asset('assets/img/bgFooterText.png'),
          // Positioned(
          //     right: 0,
          //     bottom: 0,
          //     child: Text(
          //       'version '+version+' ',
          //       style: TextStyle(fontSize: 12,
          //         color: Colors.white
          //       ),
          //     ))
        ],
      ),
    );
  }
}
