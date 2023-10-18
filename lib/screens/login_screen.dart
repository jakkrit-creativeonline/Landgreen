import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/components/rounded_input.dart';
import 'package:system/components/rounded_password.dart';
import 'package:system/configs/constants.dart';
import 'package:system/services/check_update_version.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _usernameError = false;
  bool _passwordError = false;
  bool _validateInput = false;
  var value;
  var client = http.Client();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool hasData = true;

  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  getVersionApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    print('version =>${version}');
    setState(() {});
  }

  Future<bool> _locationDenied() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Center(
                child: Text(
                    'เพื่อการใช้งานอย่างต่อเนื่อง อนุญาตการเข้าถึง Location'),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('ยกเลิก'),
                    color: kPrimaryLightColor,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      child: Text('ตกลง')),
                ],
              ),
            ));
  }

  Future<String> getCurrPosition() async {
    try {
      print('get current location');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position.toString();
    } catch (e) {
      bool gotoSetting = await _locationDenied();
      if (gotoSetting) {
        await Geolocator.openAppSettings();
      } else {
        Navigator.of(context).pop();
      }
      print('get location failed');
      return '';
    }
  }

  Future<void> _loginFail() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Login ไม่สำเร็จ')),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Username หรือ Password ไม่ถูกต้อง',
                textAlign: TextAlign.center,
              ),
              FlatButton(
                  color: kPrimaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'ปิด',
                    style: TextStyle(color: btTextColor),
                  ))
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    var result = await Sqlite().getLogin(_username.text, _password.text);
    if (result != null) {
      await savePref(result.levelId, result.iD, 1);
      //await getSaleCommission(result.iD);
      print('result.levelId=>${result.levelId}');
      if (result.levelId == 1 ||
          result.levelId == 2 ||
          result.levelId == 3 ||
          result.levelId == 12) {
        await Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);
      } else if (result.levelId == 4) {
        // await Navigator.of(context).pushReplacementNamed('ceo_dashboard');
        await Navigator.of(context).pushReplacementNamed(
          'ceo_dashboard',
          arguments: ScreenArguments(userId: result.iD),
        );
      }

      // var location = await getCurrPosition();
      // if (location == '') {
      //   _loginFail();
      // } else {
      //   await savePref(result.levelId, result.iD, 1);
      //   //await getSaleCommission(result.iD);
      //   await Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);
      // }
    } else {
      _loginFail();
    }
  }

  Future getSaleCommission(int userId) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      print('get and insert SaleCommission');
      var res = await client.post(
          'https://thanyakit.com/systemv2/public/api/SaleCommission',
          body: {'filename': '$userId'});
      var dataSet = res.body;
      //var dataSet = await jsonDecode(res.body);
      Sqlite().insertCommission(userId, dataSet);
      setState(() {
        hasData = true;
      });
    } else {
      var result = await Sqlite().getCommission(userId);
      if (result != null) {
        setState(() {
          hasData = true;
        });
      } else {
        setState(() {
          hasData = false;
        });
      }
    }
  }

  Future savePref(int lv, int userId, int isLogin) async {
    print('levelid : $lv , user_id : $userId');
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('isLogin', isLogin);
    await prefs.setInt('levelid', lv);
    await prefs.setInt('user_id', userId);
    //await prefs.setString('location', location);
  }

  void _validate() {
    setState(() {
      _usernameError = _username.text.isEmpty;
      _passwordError = _password.text.isEmpty;
      _validateInput = !_usernameError && !_passwordError;
    });
    if (_validateInput) {
      _submit();
    }
  }

  getPref() async {
    final SharedPreferences prefs = await _prefs;
    value = prefs.getInt('isLogin');
    var _levelid = await prefs.getInt('levelid');
    int _userid = await prefs.getInt('user_id');
    print('_levelid =>${_levelid}');
    if (value == 1 && _levelid == 4) {
      Navigator.of(context).pushReplacementNamed(
        'ceo_dashboard',
        arguments: ScreenArguments(userId: _userid),
      );
    } else if (value == 1) {
      Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);
    }
  }

  @override
  void initState() {
    CheckVersionUpdate().check(context);
    getVersionApp();
    super.initState();
    // _username.text = 'ceo001';
    // _password.text = '123456';

    getPref();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        color: kPrimaryColor,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(42),
                  child: AppBar(
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
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'กรุณาเข้าระบบ',
                            style: TextStyle(fontSize: 38),
                          ),
                          Text(
                            'ด้วยยูสเซอร์เนม และพาสเวิร์ดของท่าน',
                            style: TextStyle(fontSize: 28),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Container(
                              width: size.width * 0.8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    width: 2,
                                    color: kPrimaryLightColor,
                                  )),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 28, right: 28, top: 25),
                                    child: RoundedInputField(
                                      textController: _username,
                                      hintText: 'ล็อกอินไอดี',
                                      errorText: _usernameError
                                          ? 'กรุณาใส่ Username'
                                          : null,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 28, right: 28, top: 5),
                                    child: RoundedPasswordField(
                                      textController: _password,
                                      errorText: _passwordError
                                          ? 'กรุณาใส่ Password'
                                          : null,
                                    ),
                                  ),
                                  if (!hasData)
                                    Text(
                                        'กรุณาเชื่อมต่ออินเทอร์เน็ต หากเป็นการเข้าใช้งานครั้งแรก'),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 28, right: 28, bottom: 0),
                                    child: RoundedButton(
                                        text: 'กดเพื่อเข้าสู่ระบบ',
                                        press: _validate),
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(
                                  //       left: 28, right: 28, bottom: 0),
                                  //   child: RoundedButton(
                                  //       text: 'กดเพื่อสมัครสมาชิก',
                                  //       press: (){
                                  //         locator<NavigationService>()
                                  //             .navigateTo('register',
                                  //             ScreenArguments());
                                  //       }),
                                  // ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 28, right: 28, bottom: 18),
                                    child: RoundedButton(
                                        text: 'ดูแคตตาล็อกสินค้า',
                                        press: () async {
                                          locator<NavigationService>()
                                              .navigateTo('product_screen',
                                                  ScreenArguments());
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 5),
                            child: Image.asset(
                              'assets/img/logo_nopading.png',
                              width: size.width * 0.35,
                            ),
                          ),
                          Text(
                            'ระบบบริหารจัดการโรงงานปุ๋ย เวอร์ชั่น ${version}',
                            style: TextStyle(fontSize: 25, height: 1),
                          ),
                          Text(
                            'สร้างบิล ส่งของ บันทึกรับจ่าย คิดค่าคอม.',
                            style: TextStyle(
                                fontSize: 23, color: grayFontColor, height: 1),
                          ),
                          Text(
                            'บริหารงานขายครบวงจร',
                            style: TextStyle(
                                fontSize: 23, color: grayFontColor, height: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 15),
                            child: Image.asset(
                              'assets/img/imgBrand.png',
                              width: size.width * 0.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Footer(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   body: Container(
    //     width: double.infinity,
    //     height: size.height,
    //     child: Stack(
    //       alignment: Alignment.center,
    //       children: <Widget>[
    //         SingleChildScrollView(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               Image.asset(
    //                 'assets/logo.png',
    //                 width: 250,
    //                 height: 250,
    //               ),
    //               RoundedInputField(
    //                 textController: _username,
    //                 hintText: 'Username',
    //                 errorText: _usernameError ? 'กรุณาใส่ Username' : null,
    //               ),
    //               RoundedPasswordField(
    //                 textController: _password,
    //                 errorText: _passwordError ? 'กรุณาใส่ Password' : null,
    //               ),
    //               if (!hasData)
    //                 Text(
    //                     'กรุณาเชื่อมต่ออินเทอร์เน็ต หากเป็นการเข้าใช้งาน Username นี้ครั้งแรก'),
    //               SizedBox(
    //                 height: size.height * 0.03,
    //               ),
    //               RoundedButton(text: 'LOGIN', press: _validate),
    //             ],
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
