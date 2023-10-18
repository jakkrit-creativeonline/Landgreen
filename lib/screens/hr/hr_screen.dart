import 'dart:convert';
import 'dart:io';

// import 'package:background_fetch/background_fetch.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/components/buttom_chart.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/head_team_lead_widget.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/lv12_menu.dart';
import 'package:system/components/lv1_menu.dart';
import 'package:system/components/lv2_menu.dart';
import 'package:system/components/lv3_menu.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/components/sale_ranking_item.dart';
import 'package:system/components/sell_team_lead_widget.dart';
import 'package:system/components/square_button.dart';
import 'package:system/components/sub_menager_team_lead_widget.dart';
import 'package:system/configs/constants.dart';
import 'package:system/screens/ceo/components/ceo_report_car_detail.dart';
import 'package:system/screens/ceo/credit_report_manager.dart';
import 'package:system/screens/head/head_kpi_sale.dart';
import 'package:system/screens/hr/hr_holiday.dart';
import 'package:system/screens/hr/hr_overtime.dart';
import 'package:system/screens/hr/hr_personal.dart';
import 'package:system/screens/hr/hr_sick.dart';
import 'package:system/screens/hr/hr_soldier.dart';
import 'package:system/screens/hr/scan_qrcode.dart';
import 'package:system/screens/hr/scan_qrcode2.dart';
import 'package:system/screens/manager/manager_kpi_sale.dart';
import 'package:system/screens/sale/create_bill.dart';
import 'package:system/screens/sale/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:system/screens/sale/show_bill.dart';
import 'package:system/services/check_update_version.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:system/services/hr_services.dart';

import 'hr_baby.dart';
import 'hr_meeting.dart';

class HrScreen extends StatefulWidget {
  final int userId;

  const HrScreen({Key key, this.userId}) : super(key: key);

  @override
  _HrScreenState createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> checkSaleRankWidget;

  var _timestamp = "";
  var _timestampOut = "";
  var _location = "";

  var isLogin,
      level_id,
      user_id,
      _user,
      lv_red = '',
      lv_orange = '',
      lv_yellow = '',
      workCarId,
      userImage,
      workCarData,
      internetVariable,
      comData,
      cashCountCat1,
      cashCountCat2,
      creditCountCat1,
      creditCountCat2,
      saleCommissionTotal,
      sumIncomeAll,
      saleRanking = null,
      sumCat1,
      totalMoneyShareCat1,
      tax = 0.0,
      net;
  Widget imageAvatar;
  var client = http.Client();
  List<UserMoneyShare> _userMoneyShare = List<UserMoneyShare>();
  bool loading = true, isImageLoaded = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map<String, SellGoal> data;
  FormatMethod f = new FormatMethod();
  String lastDate;

  // List<Bill> _bill;
  // List<Receipt> _receipt;
  List<Trail> _trail;
  FTPConnect ftpConnect =
      FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);

  Future<String> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    DateTime _now = DateTime.now();
    print(
        'เวลา: ${_now.hour}:${_now.minute}:${_now.second}.${_now.millisecond}');
    return position.toString();
  }

  // Future<Null> getOnline(_userId) async{
  //
  //   print('getOnline user_id => ${_userId}');
  //   var now =  DateTime.now();
  //   var startDate = DateTime(now.year,now.month,1,0,0,0);
  //   int lastday = DateTime(now.year, now.month + 1, 0).day;
  //   var endDate = DateTime(now.year,now.month,lastday,23,59,59);
  //   if(DateTime.now().day >=1 && DateTime.now().day<=5){
  //     //1-5 ให้เอาบิลของเดือนที่แล้วมาโชว์
  //     startDate = DateTime(now.year,now.month-1,1,0,0,0);
  //     int lastdaypreiousmonth = DateTime(now.year, now.month, 0).day;
  //     endDate = DateTime(now.year,now.month,lastdaypreiousmonth,23,59,59);
  //   }
  //   final response = await client.post(
  //       'https://thanyakit.com/systemv2/public/api/getBillOnline',
  //       body: {
  //         'User_id': '${_userId}',
  //         'startDate':startDate.toString(),
  //         'endDate':endDate.toString()
  //       });
  //   print('getOnline startDate = ${response}');
  //   print('getOnline endDate =>');
  //   final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  //
  //   print(parsed.length);
  //   if(parsed.length>0){
  //     for(var i=0;i<parsed.length;i++){
  //       // print('${parsed[i]}');
  //       await Sqlite().insertOrUpdateBillFromOnline(parsed[i]);
  //     }
  //   }
  //
  // }
  Future<Null> getOnlineTrail(_userId) async {
    var now = DateTime.now();
    var startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
    int lastday = DateTime(now.year, now.month + 1, 0).day;
    var endDate = DateTime(now.year, now.month, lastday, 23, 59, 59);
    if (DateTime.now().day >= 1 && DateTime.now().day <= 5) {
      //1-5 ให้เอาบิลของเดือนที่แล้วมาโชว์
      startDate = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
      int lastdaypreiousmonth = DateTime(now.year, now.month, 0).day;
      endDate = DateTime(now.year, now.month, lastdaypreiousmonth, 23, 59, 59);
    }
    final response = await client
        .post('https://thanyakit.com/systemv2/public/api/getTrailOnline', body: {
      'User_id': '${_userId}',
      'startDate': startDate.toString(),
      'endDate': endDate.toString()
    });

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

    print(parsed.length);
    if (parsed.length > 0) {
      for (var i = 0; i < parsed.length; i++) {
        // print('${parsed[i]}');
        await Sqlite().insertOrUpdateTrailFromOnline(parsed[i]);
      }
    }
  }

  Future<Null> savePref() async {
    SharedPreferences prefs = await _prefs;

    // userId สำหรับบันทึกพิกัด
    int userId = await prefs.getInt('user_id');

    //get ค่าพิกัด
    String location = await getLocation();

    //บันทึกค่าพิกัด
  }

  Future<Null> _uploadTrail() async {
    var result =
        _trail.where((element) => element.status == 0 || element.status == 99);
    DateTime now = DateTime.now();
    String folderName = now.year.toString();
    String subFolderName = now.month.toString();
    String mainFolder =
        '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/customer/';
    String customerUploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');

    mainFolder =
        '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/receipt/';
    String trailUploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');

    for (var trail in result) {
      await ftpConnect.changeDirectory(customerUploadPath);
      var postUri =
          Uri.parse('https://thanyakit.com/systemv2/public/api/recordTrail');
      var req = new http.MultipartRequest('POST', postUri);

      bool isImageUpload = true;
      //req customer
      if (trail.image != null) {
        if (trail.image.startsWith('faarunApp')) {
          req.fields['Image_customer'] = '${trail.image}';
          req.fields['Image_id_card'] = '${trail.imageIdCard}';
        } else {
          File imageCustomer = File('${trail.image}');
          File imageIdCard = File('${trail.imageIdCard}');
          String imageCustomerName = trail.image.split('/')[6];
          String imageIdCardName = trail.imageIdCard.split('/')[6];
          isImageUpload = await ftpConnect.uploadFileWithRetry(imageCustomer,
              pRetryCount: 2);
          isImageUpload =
              await ftpConnect.uploadFileWithRetry(imageIdCard, pRetryCount: 2);
          req.fields['Image_customer'] =
              'faarunApp/customer/$folderName/$subFolderName/$imageCustomerName';
          req.fields['Image_id_card'] =
              'faarunApp/customer/$folderName/$subFolderName/$imageIdCardName';
        }
      }
      req.fields['Customer_name'] = '${trail.name}';
      req.fields['Customer_surname'] = '${trail.surname}';
      req.fields['Customer_sex'] = '${trail.sex}';
      req.fields['Customer_id_card'] = '${trail.idCard}';
      req.fields['Customer_phone'] = '${trail.phone}';
      req.fields['Customer_address'] = '${trail.address}';
      req.fields['Customer_province_id'] = '${trail.provinceId}';
      req.fields['Customer_amphur_id'] = '${trail.amphurId}';
      req.fields['Customer_district_id'] = '${trail.districtId}';
      req.fields['Customer_zipcode'] = '${trail.zipcode}';
      req.fields['Customer_type'] = '${trail.typeId}';
      req.fields['Customer_birthday'] = '${trail.birthday}';
      //จบ req customer

      //req trail
      req.fields['DocNumber'] = '${trail.trialNumber}';
      req.fields['Status'] = '${trail.status}';
      req.fields['User_id'] = '${trail.userId}';
      req.fields['Order_detail'] = '${trail.orderDetail}';

      List imageReceipt = [];
      if (trail.imageReceive != null) {
        await ftpConnect.changeDirectory(trailUploadPath);
        var imgList = jsonDecode(trail.imageReceive);
        for (var img in imgList) {
          File image = File('$img');
          String imageName = img.split('/')[6];
          isImageUpload =
              await ftpConnect.uploadFileWithRetry(image, pRetryCount: 2);
          imageReceipt
              .add("faarunApp/receipt/$folderName/$subFolderName/$imageName");
        }
        req.fields['Image_receive'] = jsonEncode(imageReceipt);
      }
      req.fields['Image_signature'] =
          'data:image/png;base64,${trail.imageSignature}';
      // req.fields['Timestamp'] = '${trail.timestamp}';
      //จบ req trail

      ////print(isImageUpload);
      if (isImageUpload) {
        await req.send().then((response) {
          http.Response.fromStream(response).then((val) async {
            if (val.statusCode == 200) {
              var res = await jsonDecode(val.body);
              //print(res);
              if (res['Status'] == 'Success') {
                Sqlite().rawQuery(
                    'UPDATE TRAIL SET Status = 3 WHERE ID = ${trail.iD}');
              }
            } else {
              //print(val.body);
            }
          });
        });
      }
      req.fields.clear();
    }
  }

  Future<Null> _checkTrail() async {
    var result = _trail.where((element) => element.status == 3);
    await _updateTrail(result);
    result = _trail.where((element) => element.status == 4);
    await _updateTrail(result);
  }

  Future<Null> _updateTrail(var result) async {
    List trailNumber = [];
    for (var trail in result) {
      trailNumber.add(trail.trialNumber);
    }
    //print(trailNumber);
    if (trailNumber.isNotEmpty) {
      var res = await client.post(
          'https://thanyakit.com/systemv2/public/api/checkOnlineTrail',
          body: {'trailNumber': jsonEncode(trailNumber)}).then((value) {
        if (value.statusCode == 200) {
          try {
            var data = jsonDecode(value.body);
            data.forEach((val) {
              var target = _trail.firstWhere(
                  (element) => element.trialNumber == val['Trial_number']);
              if (DateTime.parse(val['Timestamp'])
                  .isAfter(DateTime.parse(target.timestamp))) {
                //print('trail online ใหม่กว่าจ้า');
                Sqlite().rawQuery(
                    'UPDATE TRAIL SET Status = ${val['Status']},Timestamp = "${val['Timestmap']}" WHERE ID = ${target.iD}');
                //update trail offline
              }
            });
          } catch (e) {
            //print(value.body);
          }
        }
      });
    }
  }

  Future<Null> getWorkCar(var workCarId) async {
    //print('getWorkCar');
    var result = await Sqlite().getWorkCar(workCarId);
    workCarData = result;
    // setState(() {
    //
    // });
  }

  Future<Null> getCommission(int ID) async {
    print('get SaleCommission');
    try {
      var result = await Sqlite().getCommission(ID);
      if (result == null) {
        await getSaleCommission(user_id);
        result = await Sqlite().getCommission(ID);
      }
      setState(() {
        comData = jsonDecode(result['DataSet']);
        var listQty = comData['Qtyordercat'].split(',');
        cashCountCat1 = int.parse(listQty[0]) + int.parse(listQty[1]);
        cashCountCat2 = int.parse(listQty[2]);
        listQty = comData['Qtycredit'].split(',');
        creditCountCat1 = int.parse(listQty[0]) + int.parse(listQty[1]);
        creditCountCat2 = int.parse(listQty[2]);
        listQty = comData['sumcommission'].split(',');
        saleCommissionTotal = int.parse(listQty[0]) +
            int.parse(listQty[1]) +
            int.parse(listQty[2]);
        if (level_id == 2 || level_id == 1) {
          sumIncomeAll = (saleCommissionTotal +
              comData['Sum_income'] +
              comData['Sum_money_share_headmain'] +
              comData['MoneyRecommend']);
          if (level_id == 2) {
            totalMoneyShareCat1 =
                comData['cat1forsale'].fold(0, (i, j) => i + j['sale_qty']);
          }
        } else {
          var result =
              comData['cat1forsale'].fold(0, (i, j) => i + j['sale_qty']);
          var result2 =
              comData['car1forsaleother'].fold(0, (i, j) => i + j['sale_qty']);
          totalMoneyShareCat1 = result + result2;
          sumIncomeAll = (saleCommissionTotal +
              comData['Sum_income'] +
              comData['sumusermoney2other'] +
              comData['MoneyRecommend']);
        }
        sumCat1 = cashCountCat1 + creditCountCat1;
        if (sumIncomeAll >= 25000) {
          tax = num.parse((sumIncomeAll * 3 / 100).toStringAsFixed(2));
        } else {
          tax = 0.0;
        }
        net = sumIncomeAll - tax - comData['sumEXPENSES'];
        //print('user goal ${_user['Goal']}');
        data = {
          'sell': SellGoal(
              'Sell', sumCat1, charts.ColorUtil.fromDartColor(kPrimaryColor)),
          'goal': SellGoal(
              'Goal',
              ((_user['Goal'] - sumCat1) < 0) ? 0 : _user['Goal'] - sumCat1,
              charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)))
        };
        DateTime now = DateTime.now();
        lastDate =
            '${now.year}-${now.month}-${DateTime(now.year, now.month + 1, 0).day}';
        loading = false;

        ////print('vat 3 : $tax , net : ${f.SeperateNumber(net)}');
      });
    } catch (e) {
      setState(() {
        loading = true;
      });
      //print('Error get commission $e');
    }
  }

  Future<Null> getUserData(int ID) async {
    print('getUserData');
    //var res = await Sqlite().query('DISTRICT');
    ////print('test query : ${res.toString()}');
    try {
      var result = await Sqlite().getUserData(ID);
      _user = result;
      //print('userData ${result.toString()}');
      workCarId = result['Work_car_id'];
      // setState(() {
      //
      // });
    } catch (e) {
      //print('ERROR getUserData $e');
    }
  }

  Future<Null> getUserMoneyShare(int ID) async {
    //print('getUserMoneyShare');
    var result = await Sqlite().getUserMoneyShareById(ID);
    setState(() {
      _userMoneyShare = result;
    });
    var redCount = 0, orangeCount = 0, yellowCount = 0;
    _userMoneyShare.forEach((val) {
      //print(val.toJson());
      if (val.userLevelId == 2) {
        // แดง
        if (redCount > 0) {
          lv_red += ',';
        }
        lv_red += 'คุณ${val.userName}';
        redCount++;
      } else if (val.userLevelId == 3) {
        //ส้ม
        if (orangeCount > 0) {
          lv_orange += ',';
        }
        if (val.toUserId == 123 ||
            val.toUserId == 124 ||
            val.toUserId == 119 ||
            val.toUserId == 145) {
          //Sales_overmanager พักก่อน
        } else {
          lv_orange += 'คุณ${val.userName}';
        }
        orangeCount++;
      } else {
        // เหลือง
        if (yellowCount > 0) {
          lv_yellow += ',';
        }
        lv_yellow += 'คุณ${val.userName}';
        yellowCount++;
      }
    });
    if (redCount == 0 || orangeCount == 0 || yellowCount == 0) {
      if (redCount == 0) {
        lv_red = '--';
      } else if (orangeCount == 0) {
        lv_orange = '--';
      } else {
        lv_yellow = '--';
      }
    }
  }

  Widget swithTeamLabel() {
    switch (level_id) {
      case 1:
        return SellTeamLead(
            lv_red: lv_red, lv_yellow: lv_yellow, lv_orange: lv_orange);
        break;
      case 2:
        return HeadTeamLead(lv_yellow: lv_yellow, lv_orange: lv_orange);
        break;
      case 3:
        return Container();
        break;
      case 12:
        return SubMenagerTeamLead(lv_orange: lv_orange);
        break;
      default:
        return Container();
    }
  }

  Widget swithMenu() {
    switch (level_id) {
      case 1:
        return SellMenu(
          userId: user_id,
        );
        break;
      case 2:
        return RedMenu(
          userId: user_id,
        );
        break;
      case 3:
        return OrangeMenu(
          userId: user_id,
        );
        break;
      case 12:
        return YellowMenu(
          userId: user_id,
        );
        break;
      default:
        return SellMenu(
          userId: user_id,
        );
    }
  }

  getPref() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      isLogin = prefs.getInt('isLogin');
      level_id = prefs.getInt('levelid');
      user_id = prefs.getInt('user_id');
    });
  }

  Future getData() async {
    await getUserData(user_id);
    await getWorkCar(workCarId);
    await getUserMoneyShare(user_id);
    await getCommission(user_id);
    await getImage();
    // await getSaleRanking();
    setState(() {});
  }

  calWorkTime(var date) {
    var listDate = date.split('-');
    var workTime = DateTime.parse(date);
    var now = new DateTime.now();
    //print(workTime);
    //print(now.day);
    //print(workTime.day);
    var result = {'years': 0, 'months': 0, 'days': 0};
    result['months'] =
        now.year * 12 + now.month - workTime.year * 12 - workTime.month;
    result['days'] = now.day - workTime.day;
    if (0 > result['days']) {
      var y = now.year, m = now.month;
      //print('original month : $m');
      //m = (--m < 0) ? 11 : m;
      m = (--m == 0) ? 11 : m;
      //print('edit month : $m');
      result['days'] += [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m] +
          (((1 == m) && ((y % 4) == 0) && (((y % 100) > 0) || ((y % 400) == 0)))
              ? 1
              : 0);
      result['months'] = result['months'] - 1;
    }
    result['years'] = (result['months'] - (result['months'] % 12)) ~/ 12;
    result['months'] = (result['months'] % 12);
    var str = '';
    if (result['years'] != 0) {
      str = str + result['years'].toString() + ' ปี ';
    }
    if (result['months'] != 0) {
      str = str + result['months'].toString() + ' เดือน ';
    }
    if (result['days'] != 0) {
      str = str + result['days'].toString() + ' วัน';
    }
    return str;
  }

  Future loadImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    if (File('$appDocPath/user_avatar_$user_id.jpeg').existsSync()) {
      imageAvatar = Image.file(File('$appDocPath/user_avatar_$user_id.jpeg'));
    } else {
      imageAvatar = Image.asset('assets/avatar.png');
    }
    // setState(() {});
  }

  Future getImage() async {
    //print('getImage');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    if (!File('$appDocPath/user_avatar_$user_id.jpeg').existsSync()) {
      //print('no file');
      if (_user['Image'] != null) {
        final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
        File file = File('$appDocPath/user_avatar_$user_id.jpeg');
        var res = await client
            .post(url, body: {'path': '${_user['Image']}'}).then((val) {
          file.writeAsBytesSync(val.bodyBytes);
          loadImage();
        });
      }
    } else {
      //print('has file');
    }
  }

  @override
  void dispose() {
    internetVariable.cancel();
    super.dispose();
  }

  // Future<void> initPlatformState() async {
  //   //ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
  //   BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 15,
  //           stopOnTerminate: true,
  //           enableHeadless: false,
  //           requiresBatteryNotLow: false,
  //           requiresCharging: false,
  //           requiresStorageNotLow: false,
  //           requiresDeviceIdle: false,
  //           requiredNetworkType: NetworkType.ANY), (String taskId) async {
  //     switch (taskId) {
  //       case 'taskA':
  //         print('task a jaaaaaaaa');
  //         break;
  //       default:
  //         print("DASHBOARD : [BackgroundFetch] Event received $taskId");
  //         bool isConnect = await DataConnectionChecker().hasConnection;
  //         // await getBill();
  //         if (isConnect) {
  //           await ftpConnect.connect();
  //           await _uploadTrail();
  //           await _checkTrail();
  //           await ftpConnect.disconnect();
  //         }
  //     }
  //     BackgroundFetch.finish(taskId);
  //   }).then((int status) {
  //     print('DASHBOARD : [BackgroundFetch] configure success: $status');
  //   }).catchError((e) {
  //     print('DASHBOARD : [BackgroundFetch] configure ERROR: $e');
  //   });
  // }

  @override
  void initState() {
    print("https://thanyakit.com/systemv2/public/viewinapp?id=${widget.userId}");
    // TODO: implement initState
    CheckVersionUpdate().check(context);

    checkSaleRankWidget = Future.value();
    _prefs.then((SharedPreferences prefs) {
      isLogin = prefs.getInt('isLogin');
      level_id = prefs.getInt('levelid');
      user_id = prefs.getInt('user_id');
    }).then((v) async {
      // getOnline(user_id);
      getOnlineTrail(user_id);
      await getData();
      // await getProductCanSell(user_id);
      loadCreditKPI(user_id);
    });
    loadImage();
    internetVariable = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Connected');

          _refresh();
          break;
        case DataConnectionStatus.disconnected:
          print('No Connection');
          break;
      }
    });
    super.initState();
  }

  loadCreditKPI(int userId) async {
    print('loadCreditKPI');
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1, now.day);
    var selectedMonth =
        '${previousMonth.toString().split('-')[0]}/${previousMonth.toString().split('-')[1]}';
    final body = {
      'func': 'reportCreditPerCarDetailSale',
      'changeMonthSelect': selectedMonth,
      'sale_id': '${userId}'
    };
    print(body);
    final res = await http.post('$apiPath-credit', body: body);
    if (res.statusCode == 200) {
      if (res.body != '{"nofile":"nofile"}') {
        print(res.body);
        Sqlite().insertJson(
            'CEO_CREDIT_REPORT_CAR_SALE_${userId}', selectedMonth, res.body);
      }
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลได้');
    }
  }

  Future getSaleCommission(int userId) async {
    //print('get and insert SaleCommission');
    var res = await client.post(
        'https://thanyakit.com/systemv2/public/api/SaleCommission',
        body: {'filename': '$userId'});
    var dataSet = res.body;
    ////print(dataSet);
    if (dataSet != '') {
      Sqlite().insertCommission(userId, dataSet);
    }
  }

  Future<Null> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      if (loading) {
        getUserData(user_id);
      }
      print('loading=> ${loading}');
      await getSaleCommission(user_id);
      await getCommission(user_id);
      // await getSaleRankingOnline();
      // await getSaleRanking();
      await getImage();
      loadCreditKPI(user_id);
      //print('getdata');
    }
  }

  Widget rankingSaleWidget() {
    Size size = MediaQuery.of(context).size;
    var _widthImg = size.width * 0.17;
    var _heightImg = size.width * 0.17;
    // print("rankingSaleWidget");
    // print(saleRanking);
    if (saleRanking != null) {
      List<Widget> _row1 = new List();
      for (var i = 0; i < 5; i++) {
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i + 1,
        );
        _row1.add(_widget);
      }
      List<Widget> _row2 = new List();
      for (var i = 5; i < 10; i++) {
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i + 1,
        );
        _row2.add(_widget);
      }
      List<Widget> _row3 = new List();
      for (var i = 10; i < 15; i++) {
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i + 1,
        );
        _row3.add(_widget);
      }
      // setState(() {});
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [],
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bgTop2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                // leading: Builder(
                //   builder: (context) => IconButton(
                //     icon: Icon(Icons.menu, size: 40),
                //     onPressed: () => Scaffold.of(context).openDrawer(),
                //   ),
                // ),
              ),
            ),
            body: SafeArea(
                bottom: false,
                child: Container(
                    height: double.infinity,
                    width: size.width,
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              // mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (loading)
                                  ShimmerLoading(
                                    type: "userInfo",
                                  ),
                                // หมุนติ้วกับทิวเขา
                                if (!loading) UserInfo(size),
                                //ข้อมูล Sale
                                // MyDivider(),
                                // MyDivider(),
                                if (loading) ShimmerLoading(),

                                // MyDivider(),
                                // MyDivider(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      RaisedButton.icon(
                                        color: kPrimaryColor,
                                        textColor: Colors.white,
                                        onPressed: () async {
                                          final callBackCheckIn =
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ScanQrCode()));
                                          if (callBackCheckIn != null) {
                                            _timestamp = await HrServices()
                                                .getValue("currentCheckin");
                                            _location = await HrServices()
                                                .getValue("locationCheckin");
                                            print(
                                                '_timestamp ${_timestamp.toString()}');
                                            setState(() {});
                                          }
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.camera,
                                          color: btTextColor,
                                        ),
                                        label: Text('เข้างาน'),
                                      ),
                                      RaisedButton.icon(
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            final resultCallBackCheckOut =
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ScanQrCode2()));
                                            if (resultCallBackCheckOut !=
                                                null) {
                                              _timestampOut = await HrServices()
                                                  .getValue("currentCheckOut");
                                              print(
                                                  '_timestamp ${_timestampOut.toString()}');
                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(
                                            FontAwesomeIcons.outdent,
                                            color: btTextColor,
                                          ),
                                          label: Text('ออกงาน')),
                                      RaisedButton.icon(
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HrOverTime()));
                                          },
                                          icon: Icon(
                                            FontAwesomeIcons.businessTime,
                                            color: btTextColor,
                                          ),
                                          label: Text('โอที')),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Container(
                                    child: Card(
                                      child: Column(
                                        children: [
                                          HeaderText(
                                            text: 'ประวัติการบันทึกเวลา',
                                            textSize: 20,
                                            gHeight: 26,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'เข้า',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          _timestamp,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'ออก',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          _timestampOut,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'สถานที่',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        Text(
                                                          _location,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        HeaderText(
                                          text: 'โควต้าที่เหลือทั้งหมด',
                                          textSize: 20,
                                          gHeight: 26,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'ลาป่วย',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    '5 ครั้ง',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'ลากิจ',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    '2 ครั้ง',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'ลาพักร้อน',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    '6 ครั้ง',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'ลาคลอด',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                  Text(
                                                    '1 ครั้ง',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SquareButton(
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrSick()));
                                        },
                                        text: 'ลาป่วย',
                                        icon: FontAwesomeIcons.hospital,
                                      ),
                                      SquareButton(
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrPersonal()));
                                        },
                                        text: 'ลากิจ',
                                        icon:
                                            FontAwesomeIcons.solidEnvelopeOpen,
                                      ),
                                      SquareButton(
                                        text: 'ลาพักร้อน',
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrHoliday()));
                                        },
                                        icon: FontAwesomeIcons.car,
                                      ),
                                    ],
                                  ),
                                ),
                                //saleRankingContainer(size),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SquareButton(
                                        press: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrBaby()));
                                        },
                                        text: 'ลาคลอด',
                                        icon: FontAwesomeIcons.babyCarriage,
                                      ),
                                      SquareButton(
                                        press: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrSoldier()));
                                        },
                                        text: 'ลารับ\nราชการทหาร',
                                        icon: FontAwesomeIcons.personBooth,
                                      ),
                                      SquareButton(
                                        press: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HrMeeting()));
                                        },
                                        text: 'ลาฝึกอบรม',
                                        icon: FontAwesomeIcons.fileContract,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: RoundedButton(
                                      text: 'กลับไปยังหน้าหลัก',
                                      widthFactor: 0.8,
                                      press: () {
                                        Navigator.of(context).pop();
                                      }),
                                ),

                                Footer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))),
          ),
        ),
      ),
    );
  }

  Padding UserInfo(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: _user != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${_user['Name']} ${_user['Surname']}',
                            style: TextStyle(
                                fontSize: 30, color: mainFontColor, height: 1),
                          ),
                          Text('รหัสพนักงาน : ${_user['Username']}',
                              style:
                                  TextStyle(fontSize: 24, color: subFontColor)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'ทะเบียนรถ : ',
                                style: TextStyle(
                                    color: subFontColor, fontSize: 20),
                              ),
                              workCarData != null
                                  ? Text(
                                      "${workCarData['Plate_number']}",
                                      // "${workCarData['Plate_number']} - ${workCarData['PROVINCE_NAME']}",
                                      style: TextStyle(
                                          color: subFontColor, fontSize: 18),
                                    )
                                  : Text('')
                            ],
                          ),
                          swithTeamLabel(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: imageAvatar),
                      width: size.width * 0.4,
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
