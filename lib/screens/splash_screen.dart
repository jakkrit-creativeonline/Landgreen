import 'dart:io';
import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:system/configs/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  var client = http.Client();
  var internetVariable;
  bool hasData = false;
  var _user;
  var isInit;
  bool loading = true;
  bool isConnect = true;
  double _progress = 0;
  List<int> _bytes = [];
  String stateText = '';
  FTPConnect ftpConnect =
      FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  @override
  void initState() {
    animationController = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);
    animationController.addListener(() {
      setState(() {});
    });
    animationController.forward();

    internetVariable =
        DataConnectionChecker().onStatusChange.listen((status) async {
      switch (status) {
        case DataConnectionStatus.connected:
          stateText = "Data connection is available.";
          // print('Data connection is available.');
          isConnect = true;
          setState(() {});
          await initDB();
          await readUser();
          break;
        case DataConnectionStatus.disconnected:
          // print('You are disconnected from the internet.');
          isConnect = false;
          setState(() {});
          await readUser();
          break;
      }
      if (_user.length == 0) {
        hasData = false;
      } else {
        hasData = true;
        loading = false;
        Navigator.of(context).pushReplacementNamed(LOGIN_PAGE);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    internetVariable.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: animationController != null
                  ? Opacity(
                      opacity: animationController.value,
                      child: Image.network(
                        // 'https://landgreen.ml/system/storage/app/Logoimage.png',
                         'assets/img/logo.png',
                        width: size.width * 0.5,
                      ),
                    )
                  : Container(
                      child: Center(child: Text('WOWOWOWOWOWOOW')),
                    ),
            ),
            if (loading)
              Container(
                width: size.width * 0.7,
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 5,
                  backgroundColor: kSecondaryColor,
                ),
              ),
            // CircularProgressIndicator(
            //   value: _progress,
            // ),
            Text(stateText),
            Visibility(
                visible:
                    animationController.isCompleted && !hasData && !isConnect,
                child: Text(
                  'กรุณาเชื่อมต่ออินเทอร์เน็ต',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }

  Future<Null> readUser() async {
    // print('readUser');
    var res = await Sqlite().getUser();
    setState(() {
      _user = res;
      // print('_user ${_user.length}');
    });
  }

  Future<Null> downloadJsonZip() async {
    // try {
      String filename = 'json_data_table.zip';
      stateText = "กำลังดาวน์โหลดไฟล์ระบบ";
      _progress = 0;
      setState(() {});
      Future.delayed(Duration(seconds: 1), () {
        _progress += 0.2;
      });
      setState(() {});
      await ftpConnect.connect();
      File downloadedZipFile =
          File("${(await getApplicationDocumentsDirectory()).path}/$filename");
      // stateText ="${(await getApplicationDocumentsDirectory()).path}/$filename";
      bool res = await ftpConnect.downloadFileWithRetry(
          zipFileDirectory + filename, downloadedZipFile);
      if (res) {
        stateText = "กำลังแตกไฟล์ระบบลงเครื่อง";
        _progress += 0.2;
        setState(() {});
        // print(
        //     'zip file downloaded path : ${(await getApplicationDocumentsDirectory()).path}/$filename');
        //
        // print('Unzip file...');
        // print('origin zip file\n' +
        //     downloadedZipFile.path +
        //     '\n\n\n Extracted files\n' +
        //     (await FTPConnect.unZipFile(
        //             downloadedZipFile, downloadedZipFile.parent.path))
        //         .reduce((v, e) => v + '\n' + e));
        stateText = "กำลังบันทึกข้อมูลสำหรับใช้งานแบบออฟไลน์";
        _progress = null;
        List<String> extractedFiles = await FTPConnect.unZipFile(
            downloadedZipFile, downloadedZipFile.parent.path);
        int i = 0;
        for (String path in extractedFiles) {
          _progress = i / extractedFiles.length;
          await insertJsonTest(path);
          i++;
          setState(() {});
        }
        _progress = null;
        setState(() {});
      } else {
        // print('download failed');
      }
      await ftpConnect.disconnect();
    // } catch (e) {
    //   // stateText = "download failed : ${e.toString()}";
    //   // print('download failed : ${e.toString()}');
    //   // downloadJsonZip();
    // }
  }

  Future<Null> insertJsonTest(String pathFile) async {
    final file = File(pathFile);
    String data = await file.readAsString();
    var decodeData = jsonDecode(data);
    var _lenght = pathFile.split('/').length;
    String filename = pathFile.split('/')[_lenght - 1];
    filename = filename.split('.')[0];
    switch (filename) {
      case 'SETTING_COMPANY':
        await Sqlite().insertSettingCompany(decodeData);
        break;
      case 'PROVINCE':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'DISTRICT':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'AMPHUR':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'GEOGRAPHY':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'PRODUCT':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'CATEGORY':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'STOCK_NOT_PRICE':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'USER_PRODUCT_CAN_SELL':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'CUSTOMER_TYPE':
        await Sqlite().insertLand(decodeData, filename);
        break;
      case 'USER':
        await Sqlite().insertUser(decodeData);
        break;
      case 'SETTING_CAR':
        await Sqlite().insertUserAll(decodeData, filename);
        break;
      case 'USER_MONEY_SHARE':
        await Sqlite().insertUserAll(decodeData, filename);
        break;
      case 'CONDITION_OPEN_BILL_CREDIT':
        await Sqlite().insertLand(decodeData, filename);
        break;
    }
  }

  Future<Null> insertJson(String api, String filename) async {
    stateText = 'กำลังดาวน์โหลด $filename.json';
    final url = 'https://landgreen.ml/system/public/api/$api';
    final req = http.Request('GET', Uri.parse(url));
    final http.StreamedResponse response = await http.Client().send(req);
    final contentLength =
        double.parse(response.headers['x-decompressed-content-length']);
    response.stream.listen(
      (List<int> newBytes) {
        _bytes.addAll(newBytes);
        final downloadLength = _bytes.length;
        _progress = downloadLength / contentLength;
        setState(() {});
      },
      onDone: () async {
        stateText = 'กำลังบันทึกข้อมูล $filename.json';
        final file = File(
            "${(await getApplicationDocumentsDirectory()).path}/$filename.json");
        await file.writeAsBytes(_bytes);
        String data = await file.readAsString();
        var decodeData = jsonDecode(data);
        switch (filename) {
          case 'SETTING_COMPANY':
            await Sqlite().insertSettingCompany(decodeData);
            break;
          case 'PROVINCE':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'DISTRICT':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'AMPHUR':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'GEOGRAPHY':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'PRODUCT':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'CATEGORY':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'USER_PRODUCT_CAN_SELL':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'CUSTOMER_TYPE':
            await Sqlite().insertLand(decodeData, filename);
            break;
          case 'USER':
            await Sqlite().insertUser(decodeData);
            break;
          case 'SETTING_CAR':
            await Sqlite().insertUserAll(decodeData, filename);
            break;
          case 'USER_MONEY_SHARE':
            await Sqlite().insertUserAll(decodeData, filename);
            break;
          case 'CONDITION_OPEN_BILL_CREDIT':
            await Sqlite().insertLand(decodeData, filename);
            break;
        }
        _bytes.clear();
        stateText = '';
        _progress = 0;
        setState(() {});
      },
    );
  }

  Future<Null> insertSettingCompany() async {
    // print('download setting company json');
    await insertJson('getSettingCompany', 'SETTING_COMPANY');
  }

  Future<bool> insertUser() async {
    // print('download user json');
    await insertJson('getUser', 'USER');
  }

  Future<Null> insertLand() async {
    // print('download province json');
    await insertJson('Province', 'PROVINCE');

    // print('download district json');
    await insertJson('District', 'DISTRICT');

    print('download amphur json');
    await insertJson('Amphur', 'AMPHUR');

    // print('download geo json');
    await insertJson('Geo', 'GEOGRAPHY');

    // print('download product json');
    await insertJson('Product', 'PRODUCT');

    // print('download category json');
    await insertJson('Category', 'CATEGORY');

    // print('download pruduct can sell json');
    await insertJson('ProductCanSell', 'USER_PRODUCT_CAN_SELL');

    // print('download customer type json');
    await insertJson('CustomerType', 'CUSTOMER_TYPE');
  }

  savePref() async {
    // print('savePref');
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('initApp', 1);
  }

  initFail() async {
    // print('initFail');
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('initApp', 0);
  }

  Future<bool> getPref() async {
    // print('getPref');
    final SharedPreferences prefs = await _prefs;
    var initApp = prefs.getInt('initApp');
    if (initApp != 1) {
      return await Future.value(false);
    } else {
      return await Future.value(true);
    }
  }

  Future<Null> initDB() async {
    //isInit = await getPref();
    // print('initDB');
    try {
      await downloadJsonZip();
      await savePref();
    } catch (e) {
      initFail();
      // print('initDB Error : ${e.toString()}');
    }

    // if (isInit) {
    //   print('isInit = true');
    //   await insertUser();
    // } else {
    //   try {
    //     print('isInit = false');
    //     await insertSettingCompany();
    //     await insertLand();
    //     await insertUserAll();
    //     await savePref();
    //   } catch (e) {
    //     initFail();
    //     print('initDB Error : ${e.toString()}');
    //   }
    // }
  }

  Future<Null> insertUserAll() async {
    // print('download user json');
    await insertJson('getUser', 'USER');

    // print('download setting car json');
    await insertJson('SettingCar', 'SETTING_CAR');

    // print('download user money share json');
    await insertJson('UserMoneyShare', 'USER_MONEY_SHARE');
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Center(child: Text('คุณต้องการออกจากแอพหรือไม่ ?')),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("กลับ"),
                  color: kPrimaryLightColor,
                ),
                SizedBox(width: 16),
                FlatButton(
                  onPressed: () {
                    //SystemNavigator.pop();
                    //exit(0);
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "ยืนยัน",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: kPrimaryColor,
                ),
              ],
            ),
          ),
        ) ??
        false;
  }
}


