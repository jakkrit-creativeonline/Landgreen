import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;

class DocCertificate extends StatefulWidget {
  final int userId;

  const DocCertificate({Key key, this.userId}) : super(key: key);
  @override
  _DocCertificateState createState() => _DocCertificateState();
}

class _DocCertificateState extends State<DocCertificate> {
  int user_id;
  var client = http.Client();
  var imageCertificate;
  Future<bool> haveCertificate;

  @override
  void initState() {
    user_id = widget.userId;
    // TODO: implement initState
    getCertificate();
    super.initState();
  }

  Future refresh() async {}
  loadimage() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      var res = await client
          .post('https://thanyakit.com/systemv2/public/api-settingall', body: {
        'func': 'getShowCertificationSale',
        'Sale_id': widget.userId.toString()
      });
      print('res =>${res.body}');
      await Sqlite()
          .insertJson('CERTIFICATE_DOC', 'certificate_$user_id', res.body);
      var resSQLiteAgain =
          await Sqlite().getJson('CERTIFICATE_DOC', 'certificate_$user_id');
      print('again ${resSQLiteAgain}');
      if (resSQLiteAgain != null) {
        var json = jsonDecode(resSQLiteAgain['JSON_VALUE']);
        imageCertificate = json['Image'];
        setState(() {});
      }
    }
  }

  Future getCertificate() async {
    var resSQLite =
        await Sqlite().getJson('CERTIFICATE_DOC', 'certificate_$user_id');
    print('resSQLite=>${resSQLite}');
    if (resSQLite == null) {
      await loadimage();
    } else {
      print('have sql lite ${resSQLite}');
      if(resSQLite['JSON_VALUE'] == "{}"){
        await loadimage();
      }else{
        var json = jsonDecode(resSQLite['JSON_VALUE']);
        imageCertificate = json['Image'];
        if (mounted) setState(() {});
      }
    }

    // if (!File('$appDocPath/certificate_$user_id.jpeg').existsSync()) {
    //   print('no file');
    //
    //   if (isConnect) {
    //     var res = await client.post('https://thanyakit.com/systemv2/public/api-settingall',
    //         body: {'func': 'getShowCertificationSale','Sale_id':widget.userId.toString()});
    //     // var result = res.body;
    //     Sqlite().insertJson('CERTIFICATE_DOC', 'certificate_$user_id', res.body);
    //     // if(result != "{}"){
    //     //   var json = jsonDecode(result);
    //     //   print('มีค่า${json['Image']}');
    //     //   final url = '$storagePath/${json['Image']}';
    //     //   File file = File('$appDocPath/certificate_$user_id.jpeg');
    //     //   var res = await client.post(url).then((val){
    //     //     file.writeAsBytesSync(val.bodyBytes);
    //     //     imageCertificate = Image.file(File('$appDocPath/certificate_$user_id.jpeg'));
    //     //     haveCertificate = Future.value(true);
    //     //   });
    //     // }else{
    //     //   print('ไม่มีไฟล์');
    //     //   haveCertificate = Future.value(false);
    //     // }
    //
    //   } else {
    //     print('has file');
    //     haveCertificate = Future.value(false);
    //   }
    // }
  }

  // Future getImage() async {
  //   //print('getImage');
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   String appDocPath = appDocDir.path;
  //   if (!File('$appDocPath/user_avatar_$user_id.jpeg').existsSync()) {
  //     //print('no file');
  //     if (_user['Image'] != null) {
  //       final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
  //       File file = File('$appDocPath/user_avatar_$user_id.jpeg');
  //       var res = await client
  //           .post(url, body: {'path': '${_user['Image']}'}).then((val) {
  //         file.writeAsBytesSync(val.bodyBytes);
  //         loadImage();
  //       });
  //     }
  //   } else {
  //     //print('has file');
  //   }
  // }

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
                    title: Text(''),
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/bgTop2.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                body: CustomScrollView(
                  primary: false,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: kPrimaryColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      FontAwesomeIcons.certificate,
                                      color: btTextColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'เอกสารใบอนุญาตขายปุ๋ย',
                                        style: TextStyle(
                                            fontSize: 24.0, height: 1),
                                      ),
                                      Text(
                                        'ใช้สำหรับแสดงสิทธิในการขายปุ๋ยต่อเจ้าหน้าที่ราชการ',
                                        style: TextStyle(
                                            fontSize: 16.0, height: 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          (imageCertificate != null)
                              ? InteractiveViewer(
                                  panEnabled: false,
                                  minScale: 1,
                                  maxScale: 3,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        '$storagePath/${imageCertificate}',
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'ติดต่อธุรการให้ธุรการทำใบอนุญาตขายปุ๋ยให้',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Footer(),
                      ),
                    )
                  ],
                )),
          ),
        ));
  }
}
