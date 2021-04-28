import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:system/configs/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyTeamStock extends StatefulWidget {
  final int userId;
  final int docId;

  const SurveyTeamStock({Key key, this.userId, this.docId}) : super(key: key);

  @override
  _SurveyTeamStockState createState() => _SurveyTeamStockState();
}

class _SurveyTeamStockState extends State<SurveyTeamStock> {
  FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    print("https://landgreen.ml/system/public/viewinapp?id=${widget.docId}");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        color: kPrimaryColor,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(42),
                child: AppBar(
                  titleSpacing: 0.00,
                  // title: Text('สร้างใบสั่งจองสินค้า'),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/bgTop2.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  title: Text(''),
                ),
              ),
              body: WebView(
                initialUrl:
                    "https://landgreen.ml/system/public/viewinapp?id=${widget.docId}",
                javascriptMode: JavascriptMode.unrestricted,
              )),
        ),
      ),
    );
  }
}
