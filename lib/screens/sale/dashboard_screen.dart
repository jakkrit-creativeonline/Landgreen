import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';
// import 'package:background_fetch/background_fetch.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:data_connection_checker/data_connection_checker.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:new_version/new_version.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'package:shimmer/shimmer.dart';
// import 'package:speech_bubble/speech_bubble.dart';
import 'package:provider/provider.dart';
import 'package:system/components/buttom_chart.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/head_team_lead_widget.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/lv12_menu.dart';
import 'package:system/components/lv1_menu.dart';
import 'package:system/components/lv2_menu.dart';
import 'package:system/components/lv3_menu.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/components/sale_ranking_item.dart';
import 'package:system/components/sell_team_lead_widget.dart';
import 'package:system/components/square_button.dart';
import 'package:system/components/sub_menager_team_lead_widget.dart';
import 'package:system/configs/constants.dart';
import 'package:system/screens/ceo/components/ceo_report_car_detail.dart';
// import 'package:system/screens/ceo/components/credit_report_manager_detail.dart';
import 'package:system/screens/ceo/credit_report_manager.dart';
import 'package:system/screens/head/head_kpi_sale.dart';
import 'package:system/screens/manager/manager_kpi_sale.dart';

import 'package:system/screens/sale/create_bill.dart';
import 'package:system/screens/sale/show_bill.dart';
import 'package:system/services/check_update_version.dart';

class MyNoti extends StatelessWidget {
  final int userId;

  const MyNoti({Key key, this.userId}) : super(key: key);

  Widget billNoti(int billCount) {
    print(" ===> Widget billNoti(int billCount) {");
    if (billCount > 0) {
      return Container(
        decoration: BoxDecoration(color: danger, shape: BoxShape.circle),
        padding: EdgeInsets.all(6),
        child: Text("$billCount",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            )),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(" ===> Widget build(BuildContext context) {");
    var noti = context.watch<NotificationModel>();
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: [
          IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // noti.removeAll();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowBill(
                              userId: userId,
                            )));
                // print('noti click');
              }),
          Positioned(top: 5, right: 5, child: billNoti(noti.offlineBill))
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> checkSaleRankWidget;

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
      cashCountCat1 = 0,
      cashCountCat2 = 0,
      creditCountCat1 = 0,
      creditCountCat2 = 0,
      saleCommissionTotal = 0,
      sumIncomeAll = 0,
      saleRanking = null,
      sumCat1 = 0,
      totalMoneyShareCat1 = 0,
      tax = 0.0,
      net;
  Widget imageAvatar;
  var client = http.Client();
  List<UserMoneyShare> _userMoneyShare = List<UserMoneyShare>();
  bool loading = true, isImageLoaded = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map<String, SellGoal> data;
  FormatMethod f = new FormatMethod();
  String lastDate =
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

  List<Bill> _bill;
  List<Receipt> _receipt;
  List<Trail> _trail;
  FTPConnect ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);

  Future<String> getLocation() async {
    print(" ===>  Future<String> getLocation() async {");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position.toString();
  }

  Future<Null> getOnline(_userId) async {
    print(" ===> Future<Null> getOnline(_userId) async {");

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
    // print('getOnline user_id => ${_userId}');
    // print('getOnline startDate => ${startDate}');
    // print('getOnline endDate => ${endDate}');
    try {
      print('getOnline user_id => ${_userId}');
      final response = await client.post(
          'https://thanyakit.com/systemv2/public/api/getBillOnline',
          body: {
            'User_id': '${_userId}',
            'startDate': startDate.toString(),
            'endDate': endDate.toString()
          });
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
      print('parsed -----> ${parsed.length}');
      if (parsed.length > 0) {
        for (var i = 0; i < parsed.length; i++) {
          // print('${parsed[i]}');
          await Sqlite().insertOrUpdateBillFromOnline(parsed[i]);
        }
      }

      final responseTrail = await client.post(
          'https://thanyakit.com/systemv2/public/api/getTrailOnline',
          body: {
            'User_id': '${_userId}',
            'startDate': startDate,
            'endDate': endDate
          });

      final parsedTrail = jsonDecode(responseTrail.body).cast<Map<String, dynamic>>();
      print('parsedTrail ----> ${parsedTrail.length}');
      if (parsedTrail.length > 0) {
        for (var i = 0; i < parsedTrail.length; i++) {
          print('parsedTrail ----> ${parsedTrail[i]}');
          await Sqlite().insertOrUpdateTrailFromOnline(parsedTrail[i]);
        }
      }
    } catch (e) {
      print('CATCH -----> getOnline ${_userId}');
    }
  }

  Future<Null> getOnlineTrail(_userId) async {
    print(" ===> Future<Null> getOnlineTrail(_userId) async {");
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

    final response = await client.post(
        'https://thanyakit.com/systemv2/public/api/getTrailOnline',
        body: {
          'User_id': '${_userId}',
          'startDate': startDate.toString(),
          'endDate': endDate.toString()
        });
    if (response.body != null) {
      final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

      // print(parsed.length);
      if (parsed.length > 0) {
        for (var i = 0; i < parsed.length; i++) {
          // print('${parsed[i]}');
          await Sqlite().insertOrUpdateTrailFromOnline(parsed[i]);
        }
      }
    }
  }

  Future<Null> savePref() async {
    print(" ===> Future<Null> savePref() async {");
    SharedPreferences prefs = await _prefs;

    // userId สำหรับบันทึกพิกัด
    int userId = await prefs.getInt('user_id');

    //get ค่าพิกัด
    String location = await getLocation();

    //บันทึกค่าพิกัด
  }

  Future<Null> getBill() async {
    print(" ===> Future<Null> getBill() async {");
    //print('get bill');
    var res = await Sqlite().rawQuery(
        'SELECT * FROM BILL WHERE Status <> 0 AND User_id = $user_id');
    var parsed = res.toList().cast<Map<String, dynamic>>();
    _bill = parsed.map<Bill>((json) => Bill.fromJson(json)).toList();
    res = await Sqlite().getReceipt();
    parsed = res.toList().cast<Map<String, dynamic>>();
    _receipt = parsed.map<Receipt>((json) => Receipt.fromJson(json)).toList();
    res = await Sqlite().getAllTrail();
    parsed = res.toList().cast<Map<String, dynamic>>();
    _trail = parsed.map<Trail>((json) => Trail.fromJson(json)).toList();
  }

  Future<Null> _checkBill() async {
    print(" ===> Future<Null> _checkBill() async {");
    //check isSync = 1 ว่า Bill อยู่ใน DB หรือยัง ถ้าอยู่ให้อัพเดท isSync = 2 และอัพเดท Timestamp ให้ตรงกับ  Bill Online
    var result = _bill.where((element) => element.isSync == 1);
    await _updateBill(result);
    result = _bill.where((element) => element.isSync == 2);
    await _updateBill(result);
  }

  Future<Null> _updateBill(var result) async {
    print(" ===> Future<Null> _updateBill(var result) async {");
    //เอาเฉพาะที่ isSync = 2 หา Timestamp ที่ไม่ตรงกัน Download และอัพเดท isSync = 0
    List billNumber = [];
    for (var bill in result) {
      billNumber.add(bill.billNumber);
    }

    if (billNumber.isNotEmpty) {
      var res = await client.post(
          'https://thanyakit.com/systemv2/public/api/checkOnlineBill',
          body: {'billNumber': jsonEncode(billNumber)}).then((value) {
        if (value.statusCode == 200) {
          try {
            var data = jsonDecode(value.body);
            data.forEach((val) async {
              var target = _bill.firstWhere(
                  (element) => element.billNumber == val['Bill_number']);
              if (DateTime.parse(val['Timestamp'])
                  .isAfter(DateTime.parse(target.timestamp))) {
                //print('online ใหม่กว่า');
                //ถ้า Timestamp ไม่ตรงกัน อัพเดท Bill offline
                await Sqlite().updateBill(val, target.iD);
              } else {
                //print('same time ja');
              }
            });
          } catch (e) {}
        }
      });
    }
  }

  //ที่ต้อง upload คือ bill , trail , receipt , contract
  Future<Null> _uploadBill() async {
    print(" ===> Future<Null> _uploadBill() async {");
    var result = _bill.where((element) => element.isSync == 0).toList();
    var noti = context.read<NotificationModel>();
    result != null ? noti.setTotal(result.length) : noti.setTotal(0);
    result = _bill
        .where((element) => element.isSync == 0 && element.status != 0)
        .toList();
    DateTime now = DateTime.now();
    String folderName = now.year.toString();
    String subFolderName = now.month.toString();
    String mainFolder =
        '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/customer/';
    String uploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
    await ftpConnect.changeDirectory(uploadPath);
    for (var bill in result) {
      var offlineCustomer = await Sqlite()
          .query('CUSTOMER', where: 'ID = ${bill.customerId}', firstRow: true);
      var postUri =
          Uri.parse('https://thanyakit.com/systemv2/public/api/recordBill');
      var req = new http.MultipartRequest('POST', postUri);
      bool isImageCustomerUpload = true;
      bool isImageIdCardUpload = true;
      //print('image' + offlineCustomer['Image']);
      if (offlineCustomer['Image'] != null &&
          offlineCustomer['Image'].isNotEmpty) {
        if (offlineCustomer['Image'].startsWith('faarunApp')) {
          req.fields['Image_customer'] = '${offlineCustomer['Image']}';
          req.fields['Image_id_card'] = '${offlineCustomer['Image_id_card']}';
        } else {
          File imageCustomer = File('${offlineCustomer['Image']}');
          File imageIdCard = File('${offlineCustomer['Image_id_card']}');
          String imageCustomerName = offlineCustomer['Image'].split('/')[6];
          String imageIdCardName =
              offlineCustomer['Image_id_card'].split('/')[6];
          isImageCustomerUpload = await ftpConnect
              .uploadFileWithRetry(imageCustomer, pRetryCount: 2);
          isImageIdCardUpload =
              await ftpConnect.uploadFileWithRetry(imageIdCard, pRetryCount: 2);
          req.fields['Image_customer'] =
              'faarunApp/customer/$folderName/$subFolderName/$imageCustomerName';
          req.fields['Image_id_card'] =
              'faarunApp/customer/$folderName/$subFolderName/$imageIdCardName';
          //print('BILL : ' + offlineCustomer['Image']);
          //print('BILL : ' + offlineCustomer['Image_id_card']);
        }
      }
      req.fields['func'] = 'bill_record';
      req.fields['status'] = '${bill.status}';
      req.fields['DocNumber'] = '${bill.billNumber}';
      req.fields['Customer_name'] = '${offlineCustomer['Name']}';
      req.fields['Customer_surname'] = '${offlineCustomer['Surname']}';
      req.fields['Customer_sex'] = '${offlineCustomer['Sex']}';
      req.fields['Customer_id_card'] = '${offlineCustomer['Id_card']}';
      req.fields['Customer_phone'] = '${offlineCustomer['Phone']}';
      req.fields['Customer_address'] = '${offlineCustomer['Address']}';
      req.fields['Customer_province_id'] = '${offlineCustomer['Province_id']}';
      req.fields['Customer_amphur_id'] = '${offlineCustomer['Amphur_id']}';
      req.fields['Customer_district_id'] = '${offlineCustomer['District_id']}';
      req.fields['Customer_zipcode'] = '${offlineCustomer['Zipcode']}';
      req.fields['Customer_type'] = '${offlineCustomer['Type_id']}';
      req.fields['Customer_birthday'] = '${offlineCustomer['Birthday']}';

      req.fields['bill_location'] = '${bill.billLocation}';

      req.fields['Pay_type'] = '${bill.payType}';
      req.fields['Commission_sum'] = '${bill.commissionSum}';

      req.fields['Money_due'] = '${bill.moneyDue}';
      req.fields['Money_earnest'] = '${bill.moneyEarnest}';
      req.fields['Credit_term_id'] = '${bill.creditTermId}';
      req.fields['Date_due'] = '${bill.dateDue}';
      req.fields['Signature_date'] = '${bill.signatureDate}';
      req.fields['Date_send'] = '${bill.dateSend}';
      req.fields['Money_total'] = '${bill.moneyTotal}';

      req.fields['Table_data'] = '${bill.orderDetail}';

      req.fields['Images_sign'] = '${bill.imageSignature}';
      req.fields['User_id'] = '${bill.userId}';
      req.fields['Edit_user_id'] = '${bill.editUserId}';
      req.fields['edit_status'] = '1';

      if (isImageIdCardUpload && isImageCustomerUpload) {
        await req.send().then((response) {
          http.Response.fromStream(response).then((val) async {
            if (val.statusCode == 200) {
              var res = await jsonDecode(val.body);
              if (res['Status'] == 'Success') {
                Sqlite().rawQuery(
                    'UPDATE BILL SET isSync = 1 WHERE ID = ${bill.iD}');
                // var target = _bill.firstWhere((item) => item.iD == bill.iD);
                // target.isSync = 1;
                //target.timestamp = "${DateTime.now().toString().split('.')[0]}";
              }
            }
          });
        });
      }
      req.fields.clear();
    }
  }

  Future<Null> _uploadReceipt() async {
    print(" ===> Future<Null> _uploadReceipt() async {");
    var result = _receipt.where((element) => element.isSync == 0).toList();
    DateTime now = DateTime.now();
    String folderName = now.year.toString();
    String subFolderName = now.month.toString();
    String mainFolder =
        '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/receipt/';
    String uploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
    await ftpConnect.changeDirectory(uploadPath);
    for (var val in result) {
      var postUri =
          Uri.parse('https://thanyakit.com/systemv2/public/api/uploadReceipt');
      var req = new http.MultipartRequest('POST', postUri);
      http.MultipartFile multipartFile;
      //req ของ Receipt
      req.fields['Bill_number'] = '${val.billNumber}';
      req.fields['Receipt_number'] = '${val.receiptNumber}';
      req.fields['User_id'] = '${val.userId}';
      req.fields['Image_signature'] =
          'data:image/png;base64,${val.receiptImageSignature}';
      req.fields['Signature_date'] = '${val.receiptSignatureDate}';
      req.fields['Status'] = '${val.receiptStatus}';
      req.fields['Edit_user_id'] = '${val.receiptEditUserId}';
      bool isImageUpload = true;
      List imageReceipt = [];
      if (val.imageReceive != null) {
        var imgList = jsonDecode(val.imageReceive);
        for (var img in imgList) {
          File image = File('$img');
          String imageName = img.split('/')[6];
          isImageUpload =
              await ftpConnect.uploadFileWithRetry(image, pRetryCount: 2);
          imageReceipt
              .add("faarunApp/receipt/$folderName/$subFolderName/$imageName");
          // multipartFile =
          //     await http.MultipartFile.fromPath('Image_receive[]', img);
          // req.files.add(multipartFile);
        }
        req.fields['Image_receive'] = jsonEncode(imageReceipt);
      }
      //req ของ Contract
      req.fields['Contract_number'] = '${val.contractNumber}';
      req.fields['Contract_image_signature'] =
          'data:image/png;base64,${val.imageSignature}';
      req.fields['Contract_signature_date'] = '${val.signatureDate}';
      req.fields['Image_signature_witness_1'] =
          'data:image/png;base64,${val.imageSignatureWitness1}';
      req.fields['Witness_name_1'] = '${val.witnessName1}';
      req.fields['Image_signature_witness_2'] =
          'data:image/png;base64,${val.imageSignatureWitness2}';
      req.fields['Witness_name_2'] = '${val.witnessName2}';
      req.fields["Other_name_1"] = "${val.otherName1}";
      req.fields["Other_relationship_1"] = "${val.otherRelationship1}";
      req.fields["Other_phone_1"] = "${val.otherPhone1}";
      req.fields["Other_name_2"] = "${val.otherName2}";
      req.fields["Other_relationship_2"] = "${val.otherRelationship2}";
      req.fields["Other_phone_2"] = "${val.otherPhone2}";
      req.fields["Book_number"] = "${val.bookNumber}";
      req.fields["Contract_status"] = "${val.status}";
      req.fields["Contract_edit_user_id"] = "${val.editUserId}";

      if (isImageUpload) {
        req.send().then((response) {
          http.Response.fromStream(response).then((value) async {
            if (value.statusCode == 200) {
              var res = await jsonDecode(value.body);
              //print('upload receipt value $res');
              if (res['Status'] == 'Success') {
                Sqlite().rawQuery(
                    'UPDATE RECEIPT SET isSync = 1 WHERE ID = ${val.receiptId}');
                // var target = _receipt
                //     .firstWhere((item) => item.receiptId == val.receiptId);
                // target.isSync = 1;
              }
            } else {
              //print('upload receipt status : ${value.statusCode}');
              //print(value.body);
            }
          });
        });
      }
      req.fields.clear();
    }
  }

  Future<Null> _checkReceipt() async {
    print(" ===> Future<Null> _checkReceipt() async {");
    var result = _receipt.where((element) => element.isSync == 1);
    await _updateReceipt(result);
    result = _receipt.where((element) => element.isSync == 2);
    await _updateReceipt(result);
  }

  Future<Null> _updateReceipt(var result) async {
    print(" ===> Future<Null> _updateReceipt(var result) async {");
    List receiptNumber = [];
    for (var receipt in result) {
      receiptNumber.add(receipt.receiptNumber);
    }
    //print(receiptNumber);
    if (receiptNumber.isNotEmpty) {
      var res = await client.post(
          'https://thanyakit.com/systemv2/public/api/checkOnlineReceipt',
          body: {'receiptNumber': jsonEncode(receiptNumber)}).then((value) {
        if (value.statusCode == 200) {
          try {
            var data = jsonDecode(value.body);
            data.forEach((val) {
              var target = _receipt.firstWhere(
                  (element) => element.receiptNumber == val['Receipt_number']);
              if (DateTime.parse(val['Timestamp'])
                  .isAfter(DateTime.parse(target.receiptTimestamp))) {
                //print('receipt online ใหม่กว่าจ้า');
                Sqlite().updateReceipt(val, target.receiptId);
              }
            });
          } catch (e) {
            //print(value.body);
          }
        }
      });
    }
  }

  Future<Null> _uploadTrail() async {
    print(" ===>  Future<Null> _uploadTrail() async {");
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
    print(" ===> Future<Null> _checkTrail() async {");
    var result = _trail.where((element) => element.status == 3);
    await _updateTrail(result);
    result = _trail.where((element) => element.status == 4);
    await _updateTrail(result);
  }

  Future<Null> _updateTrail(var result) async {
    print(" ===> Future<Null> _updateTrail(var result) async {");
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
    print(" ===> Future<Null> getWorkCar(var workCarId) async {");
    //print('getWorkCar');
    var result = await Sqlite().getWorkCar(workCarId);
    workCarData = result;
    // setState(() {
    //
    // });
  }

  Future<Null> getCommission(int ID) async {
    print(" ===> Future<Null> getCommission(int ID) async {");
    print('get SaleCommission');
    print(ID);
    try {
      var result = await Sqlite().getCommission(ID);
      print('result =>${result}');
      if (result == null) {
        await getSaleCommission(user_id);
        result = await Sqlite().getCommission(ID);
        // // print("****** ${result}");
        loading = false;
        comData = {
          "ID": user_id,
          "Name":
              "\u0e18\u0e31\u0e19\u0e22\u0e4c\u0e1b\u0e27\u0e31\u0e12\u0e19\u0e4c \u0e18\u0e31\u0e0d\u0e27\u0e07\u0e28\u0e4c\u0e27\u0e23\u0e42\u0e0a\u0e15 ",
          "Level_id": 3,
          "Work_car_id": 6,
          "IdCard": "2301400021417",
          "Qtyordercat": "0,0,0",
          "Qtycredit": "0,0,0",
          "billCommission_sum": 0,
          "sumcommission": "0,0,0",
          "Sum_income": 0,
          "Sum_money_share_headmain": 0,
          "sumusermoney2other": 37060,
          "MoneyRecommend": 0,
          "sumEXPENSES": 0,
          "Bank_account": "0611895526",
          "billcommiss_id": [],
          "sumcat1forsale": 0,
          "cat1forsale": [],
          "car1forsaleother": [],
          "sumcat1team": 0,
          "namerecommend": [],
          "sum_cat1_cash_forsale": 0,
          "sum_cat1_credit_forsale": 0,
          "sum_cat1_credit_wait_forsale": 0,
          "sum_cat1_credit_receive_forsale": 0,
          "sale_commission_receipt_detail": [],
          "sale_received_commission_rate_cat1_590": 120,
          "sale_received_commission_rate_cat1_690": 100,
          "sale_data": {
            "ID": user_id,
            "Username": "000001",
            "Password": "123654",
            "Level_id": 3,
            "Name":
                "\u0e18\u0e31\u0e19\u0e22\u0e4c\u0e1b\u0e27\u0e31\u0e12\u0e19\u0e4c",
            "Surname":
                "\u0e18\u0e31\u0e0d\u0e27\u0e07\u0e28\u0e4c\u0e27\u0e23\u0e42\u0e0a\u0e15",
            "Id_card": "2301400021417",
            "Setting_commission": 0,
            "Setting_recommend": 0,
            "Work_date_start": "2016-12-05",
            "Work_team_user_id": null,
            "Work_manager_user_id": null,
            "Work_car_number": null,
            "Work_status": 1,
            "Work_car_id": 6,
            "Goal": 200,
            "Edit_user_id": 40,
            "Bank_id": 1,
            "Bank_account": "0611895526",
            "Address": "71",
            "District_id": 6355,
            "Amphur_id": 713,
            "Province_id": 49,
            "Sex": 1,
            "Birthday": "1991-06-03",
            "User_id_recommend": 0,
            "Image": "user\/avatar_20200921120730.jpeg",
            "Image_id_card": null,
            "Before_after_type": 0,
            "Setting_commission_percent": null,
            "Sales_Province_id": 56,
            "Timestamp": "2021-06-07 00:56:04",
            "Sale_vip_team_id": 0,
            "Salary": 0,
            "Daily": 0,
            "Visa_text": null,
            "Visa_img": null,
            "DocApprove_text": null,
            "DocApprove_img": null,
            "DocReport_text": null,
            "DocReport_img": null,
            "RegisterFromApp": null,
            "Plate_number": "6 \u0e01\u0e13 3663",
            "PROVINCE_NAME":
                "\u0e01\u0e23\u0e38\u0e07\u0e40\u0e17\u0e1e\u0e21\u0e2b\u0e32\u0e19\u0e04\u0e23   "
          },
          "time_gen": "13:02",
          "day_gen": "2021-06-25",
          "sumMoneyTotal": 0,
          "cash_sumCat1_590": 0,
          "cash_sumCat1_690": 0,
          "cash_sumCat2": 0,
          "cash_sumMoneyTotal": 0,
          "credit_sumCat1_590": 0,
          "credit_sumCat1_690": 0,
          "credit_sumCat2": 0,
          "credit_sumMoneyTotal": 0,
          "credit_wait_sumCat1_590": 0,
          "credit_wait_sumCat1_690": 0,
          "credit_wait_sumCat2": 0,
          "credit_wait_sumMoneyTotal": 0,
          "sumCat1_590_K": 0,
          "sumCat1_690_K": 0,
          "sumCat2_K": 0,
          "sumMoneyTotal_K": 0,
          "dataExpenses": []
        };
        data = {
          'sell': SellGoal(
              'Sell', sumCat1, charts.ColorUtil.fromDartColor(kPrimaryColor)),
          'goal': SellGoal(
              'Goal',
              ((_user['Goal'] - sumCat1) < 0) ? 0 : _user['Goal'] - sumCat1,
              charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)))
        };
        setState(() {});
      }
      setState(() {
        if (result != null) {
          // if(comData = null)
          comData = jsonDecode(result['DataSet']);
          print("comData === ${comData}");
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
            var result2 = comData['car1forsaleother']
                .fold(0, (i, j) => i + j['sale_qty']);
            totalMoneyShareCat1 = result + result2;
            sumIncomeAll = (saleCommissionTotal +
                comData['Sum_income'] +
                comData['sumusermoney2other'] +
                comData['MoneyRecommend']);
          }
          sumCat1 = cashCountCat1 + creditCountCat1;
          if (sumIncomeAll >= 1000) {
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
        }

        print('vat 3 : $tax , net : ${f.SeperateNumber(net)}');
      });
    } catch (e) {
      setState(() {
        // loading = true;
      });
      print('Error get commission $e');
    }
  }

  Future<Null> getUserData(int ID) async {
    print(" ===> Future<Null> getUserData(int ID) async {");
    // print('getUserData');
    print(ID);
    var res = await Sqlite().query('DISTRICT');
    ////print('test query : ${res.toString()}');
    try {
      var result = await Sqlite().getUserData(ID);
      _user = result;
      workCarId = result['Work_car_id'];
      // print("workCarId === ${workCarId}");
      // print("_user === ${_user}");
      // setState(() {
      //
      // });
    } catch (e) {
      //print('ERROR getUserData $e');
    }
  }

  Future<Null> getUserMoneyShare(int ID) async {
    print(" ===> Future<Null> getUserMoneyShare(int ID) async {");
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
        lv_orange += 'คุณ${val.userName}';
        // if (val.toUserId == 123 ||
        //     val.toUserId == 124 ||
        //     val.toUserId == 119 ||
        //     val.toUserId == 145) {
        //   //Sales_overmanager พักก่อน
        // } else {
        //   lv_orange += 'คุณ${val.userName}';
        // }
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
    print(" ===> Widget swithTeamLabel() {");
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
    print(" ===> Widget swithMenu() {");
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
    print(" ===> getPref() async {");
    final SharedPreferences prefs = await _prefs;
    setState(() {
      isLogin = prefs.getInt('isLogin');
      level_id = prefs.getInt('levelid');
      user_id = prefs.getInt('user_id');
      print("user_id ==== ${user_id}");
    });
  }

  Future getData() async {
    print(" ===> Future getData() async {");
    try {
      await getUserData(user_id);
      await getWorkCar(workCarId);
      await getUserMoneyShare(user_id);
      await getCommission(user_id);
      await getImage();
      await getSaleRanking();
      if (mounted) {
        setState(() {});
        CheckEarlyMonth();
      }
    } catch (e) {}
  }

  calWorkTime(var date) {
    print(" ===> calWorkTime(var date) {");
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
    print(" ===> Future loadImage() async {");
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();

      String appDocPath = appDocDir.path;
      print('$appDocPath/user_avatar_$user_id.jpeg');
      if (File('$appDocPath/user_avatar_$user_id.jpeg').existsSync()) {
        imageAvatar = Image.file(File('$appDocPath/user_avatar_$user_id.jpeg'));
        setState(() {});
      } else {
        imageAvatar = Image.asset('assets/avatar.png');
      }
    } catch (e) {
      imageAvatar = Image.asset('assets/avatar.png');
    }
    // setState(() {});
  }

  Future getImage() async {
    print(" ===> Future getImage() async {");
    //print('getImage');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    if (!File('$appDocPath/user_avatar_$user_id.jpeg').existsSync()) {
      print('no file');
      try {
        print(_user);
        if (_user['Image'] != null) {
          print("IMAGE");
          final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
          File file = File('$appDocPath/user_avatar_$user_id.jpeg');
          var res = await client
              .post(url, body: {'path': '${_user['Image']}'}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
            loadImage();
          });
        } else {
          print("NO IMAGE");
        }
      } catch (e) {
        print(e.toString());
      }
    } else {
      print('has file');
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        if (_user['Image'] != null) {
          print("IMAGE");
          final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
          File file = File('$appDocPath/user_avatar_$user_id.jpeg');
          var res = await client
              .post(url, body: {'path': '${_user['Image']}'}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
            loadImage();
          });
        } else {
          print("NO IMAGE");
        }
      }
    }
  }

  @override
  void dispose() {
    internetVariable.cancel();
    super.dispose();
  }

  // Future<void> initPlatformState() async {
  //   print(" ===> Future<void> initPlatformState() async {");
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
  //         // print('task a jaaaaaaaa');
  //         break;
  //       default:
  //         // print("DASHBOARD : [BackgroundFetch] Event received $taskId");
  //         bool isConnect = await DataConnectionChecker().hasConnection;
  //         await getBill();
  //         print("-- >MAIN : [BackgroundFetch] Event received 2 $taskId");
  //         if (isConnect) {
  //           await ftpConnect.connect();
  //           await _uploadBill();
  //           await _checkBill();
  //           await _uploadReceipt();
  //           await _checkReceipt();
  //           await _uploadTrail();
  //           await _checkTrail();
  //           await ftpConnect.disconnect();
  //           print('< ------------------- > 2');
  //         }
  //     }
  //     BackgroundFetch.finish(taskId);
  //   }).then((int status) {
  //     // print('DASHBOARD : [BackgroundFetch] configure success: $status');
  //   }).catchError((e) {
  //     // print('DASHBOARD : [BackgroundFetch] configure ERROR: $e');
  //   });
  // }

  CheckEarlyMonth() async {
    print(" ===> CheckEarlyMonth() async {");
    // print('CheckEarlyMonth');
    AlertNewDesign().showEarlyMonth(context, MediaQuery.of(context).size);
  }

  @override
  void initState() {
    print(" ===> void initState() {");
    CheckVersionUpdate().check(context);

    checkSaleRankWidget = Future.value();
    _prefs.then((SharedPreferences prefs) {
      isLogin = prefs.getInt('isLogin');
      level_id = prefs.getInt('levelid');
      user_id = prefs.getInt('user_id');
      print("user_id  ===  ${user_id}");
    }).then((v) async {
      getOnline(user_id);
      getOnlineTrail(user_id);
      await getData();
      await getProductCanSell(user_id);
      loadCreditKPI(user_id);
    });
    loadImage();
    // print('Current status : ${DataConnectionChecker().connectionStatus}');
    // print('Last results : ${DataConnectionChecker().lastTryResults}');
    // print(await DataConnectionChecker().hasConnection);
    internetVariable = DataConnectionChecker().onStatusChange.listen((status) {
      print('Connected ----> ${status}');
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
    print('End Connect');
    super.initState();
  }

  loadCreditKPI(int userId) async {
    print(" ===> loadCreditKPI(int userId) async {");
    // print('loadCreditKPI');
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1, now.day);
    var selectedMonth =
        '${previousMonth.toString().split('-')[0]}/${previousMonth.toString().split('-')[1]}';
    final body = {
      'func': 'reportCreditPerCarDetailSale',
      'changeMonthSelect': selectedMonth,
      'sale_id': '${userId}'
    };
    // print(body);
    final res = await http.post('$apiPath-credit', body: body);
    if (res.statusCode == 200) {
      if (res.body != '{"nofile":"nofile"}') {
        // print(res.body);
        Sqlite().insertJson(
            'CEO_CREDIT_REPORT_CAR_SALE_${userId}', selectedMonth, res.body);
      }
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลได้');
    }
    print('--------------');
  }

  Future<Null> getProductCanSell(int userId) async {
    print(" ===> Future<Null> getProductCanSell(int userId) async {");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var res = await Sqlite().rawQuery(
        '''SELECT PRODUCT.ID,PRODUCT.Name,PRODUCT.Price_sell,PRODUCT.Price_commission,PRODUCT.Image,PRODUCT.Category_id
        FROM PRODUCT INNER JOIN USER_PRODUCT_CAN_SELL ON PRODUCT.ID = USER_PRODUCT_CAN_SELL.Product_id 
        WHERE PRODUCT.Category_id IN (1,2) AND PRODUCT.Status = 1 AND USER_PRODUCT_CAN_SELL.User_id = "$userId"
        AND USER_PRODUCT_CAN_SELL.Status = 1 ORDER BY Category_id ASC
        ''');
    // print("XYZ :: ${res}");
    res.asMap().forEach((key, value) async {
      if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
        if (value['Image'] != null && value['Image'] != '') {
          // print('Image : ' + value['Image']);
          final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
          File file = File('$appDocPath/product_image_${value['ID']}.png');
          var res = await client
              .post(url, body: {'path': value['Image']}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
          });
        }
      }
    });
    String nowDate = f.DateFormat(DateTime.now());
    res = await Sqlite().rawQuery('''SELECT * FROM PRODUCT
        WHERE Category_id = 3 AND Status = 1 AND End_date > "${nowDate}"
        ORDER BY Category_id
        ''');
    res.asMap().forEach((key, value) async {
      if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
        if (value['Image'] != null && value['Image'] != '') {
          // print('Image : ' + value['Image']);
          final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
          File file = File('$appDocPath/product_image_${value['ID']}.png');
          var res = await client
              .post(url, body: {'path': value['Image']}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
          });
        }
      }
    });
  }

  Future<bool> _onBackPressed() {
    print(" ===> Future<bool> _onBackPressed() {");
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Center(
                child: Text(
              'คุณต้องการออกจากแอพหรือไม่ ?',
              style: TextStyle(fontSize: 23),
            )),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "ไม่",
                    style: TextStyle(color: Colors.white),
                  ),
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

  Future getSaleRankingOnline() async {
    print(" ===> Future getSaleRankingOnline() async {");
    try {
      var res = await client.post(
          'https://thanyakit.com/systemv2/public/api-ceo',
          body: {'func': 'getCacheSaleRanking'});
      var dataSet = res.body;
      // print('getSaleRankingOnline');
      // print(dataSet);
      Sqlite().insertJson('SaleRanking', '1', dataSet);
    } catch (e) {}
  }

  Future getSaleRanking() async {
    print(" ===> Future getSaleRanking() async {");
    try {
      var res = await Sqlite().query('JSON_TABLE',
          firstRow: true, where: 'DATA_TABLE = "SaleRanking"');
      // print('getSaleRanking');
      // print(res);
      if (res != null) {
        var dataSet = jsonDecode(res['JSON_VALUE']);
        dataSet.sort((a, b) =>
            int.parse(b['sumcountcat'].compareTo(a['sumcountcat']).toString()));
        saleRanking = dataSet;

        checkSaleRankWidget = Future.value(true);

        if (mounted) setState(() {});
      }
    } catch (e) {}
  }

  Future getSaleCommission(int userId) async {
    print(" ===> Future getSaleCommission(int userId) async {");
    // print("User ID == ${user_id}");
    //print('get and insert SaleCommission');
    var res = await client.post(
        'https://thanyakit.com/systemv2/public/api/SaleCommission',
        body: {'filename': '$userId'});
    var dataSet = res.body;
    // print("getSaleCommission =>${dataSet}");
    if (dataSet != '') {
      Sqlite().insertCommission(userId, dataSet);
    }
  }

  Future<Null> _refresh() async {
    // print(" ===> ");
    print("User ID == ${user_id}");
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      if (loading) {
        getUserData(user_id);
      }
      // print('loading=> ${loading}');
      await getSaleCommission(user_id);
      await getCommission(user_id);
      await getSaleRankingOnline();
      await getSaleRanking();
      await getImage();
      loadCreditKPI(user_id);
      //print('getdata');
    }
  }

  Widget saleRankingContainer(Size size) {
    print(" ===> Widget saleRankingContainer(Size size) {");
    return Container(
      height: size.height * 0.3,
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        child: Column(
          children: [
            Text('อันดับยอดขายเป้าตามคันรถ (เงินสด + เครดิต + เก็บเครดิต) ',
                style: TextStyle(fontSize: 18)),
            Text(
                'อัพเดท ${saleRanking[0]['time_gen']} น. ${f.ThaiDateFormat(saleRanking[0]['day_gen'])}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  lS(int snR, int enR) {
    List<Widget> _r = new List();
    for (var i = snR - 1; i < enR; i++) {
      var _widget = SaleRankingItem(
        imgUrl: saleRanking[i]['sale_Image'],
        name: saleRanking[i]['sale_name'],
        sumqty: saleRanking[i]['sumcountcat'],
        rank: i + 1,
      );
      _r.add(_widget);
    }
    return _r;
  }

  Widget rankingSaleWidget() {
    print(" ===> Widget rankingSaleWidget() {");
    Size size = MediaQuery.of(context).size;
    var _widthImg = size.width * 0.17;
    var _heightImg = size.width * 0.17;

    if (saleRanking != null) {
      // List<Widget> _row1 = new List();
      // List<Widget> _row2 = new List();
      // List<Widget> _row3 = new List();
      // if (saleRanking.length <= 5) {
      //   _row1 = lS(1, saleRanking.length);
      // }
      // if(saleRanking.length > 5 && saleRanking.length <= 10){
      //   _row1 = lS(1, 5);
      //   _row2 = lS(6, saleRanking.length);
      // }
      // if(saleRanking.length > 10 && saleRanking.length <= 15){
      //   _row1 = lS(1, 5);
      //   _row2 = lS(6, 10);
      //   _row3 = lS(11, saleRanking.length);
      // }
      List<Widget> _row = new List();
      if (saleRanking.length < 15) {
        _row = lS(1, saleRanking.length);
      } else {
        _row = lS(1, 15);
      }

      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Card(
          color: Color(0xFFEFEFEF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'อันดับยอดขาย อัพเดท ${saleRanking[0]['time_gen']} น. ${f.ThaiDateFormat(saleRanking[0]['day_gen'])}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                // width: 400,
                height: 330,
                child: GridView.count(
                  crossAxisCount: 5,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.7,
                  children: _row,
                ),
              )
              // if (_row1.length > 0)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 0, bottom: 10),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: _row1,
              //     ),
              //   ),
              // if (_row2.length > 0)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 0, bottom: 10),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: _row2,
              //     ),
              //   ),
              // if (_row3.length > 0)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 0, bottom: 10),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: _row3,
              //     ),
              //   )
            ],
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    print(" ===>   Widget build(BuildContext context) {");
    Size size = MediaQuery.of(context).size;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        color: kPrimaryColor,
        child: SafeArea(
          bottom: false,
          child: WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(42),
                child: AppBar(
                  titleSpacing: 0.00,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MyNoti(
                        userId: user_id,
                      )
                    ],
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
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () async {
              //     //print('start upload');
              //     await ftpConnect.connect();
              //     await getBill();
              //     await _uploadBill();
              //     await _checkBill();
              //     await _uploadReceipt();
              //     await _checkReceipt();
              //     await _uploadTrail();
              //     await _checkTrail();
              //     await ftpConnect.disconnect();
              //     //print('finish upload');
              //     // notif.Notification notification = notif.Notification();
              //     // notification.showNotificationWithoutSound();
              //   },
              //   child: Icon(Icons.text_snippet, color: Colors.white),
              // ),
              drawer: Drawer(
                elevation: 8.0,
                child: Container(
                  color: kPrimaryColor,
                  child: swithMenu(),
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
                                  if (!loading) CommissionData(),
                                  if (!loading) OtherDataShow(),
                                  // MyDivider(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: FutureBuilder(
                                        future: checkSaleRankWidget,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return rankingSaleWidget();
                                            // return Container(child: Text('test'),);
                                          } else {
                                            return Container();
                                          }
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: RoundedButton(
                                        text: 'คลิ๊กดูอันดับพนักงานอื่นๆ',
                                        widthFactor: 0.9,
                                        press: () {
                                          locator<NavigationService>()
                                              .navigateTo(
                                                  'showRankAll',
                                                  ScreenArguments(
                                                    userId: user_id,
                                                  ));
                                        }),
                                  ),
                                  // MyDivider(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: HeaderText(
                                      text:
                                          'เครื่องมือจัดการงานส่วนพนักงานทั้งหมด',
                                      textSize: 20,
                                      gHeight: 26,
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
                                          press: () async {
                                            locator<NavigationService>()
                                                .navigateTo(
                                                    'createBillTrail',
                                                    ScreenArguments(
                                                        userId: user_id,
                                                        editStatus: 0));
                                          },
                                          text: 'สร้างใบ\nรับสินค้าทดลอง',
                                          icon: FontAwesomeIcons.tasks,
                                        ),
                                        SquareButton(
                                          press: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  settings: RouteSettings(
                                                      name:
                                                          'สร้างใบสั่งจองสินค้า'),
                                                  builder: (context) =>
                                                      CreateBill(
                                                        userId: user_id,
                                                        editStatus: 0,
                                                      )),
                                            );
                                          },
                                          text: 'สร้างใบ\nสั่งจองสินค้า',
                                          icon: FontAwesomeIcons.edit,
                                        ),
                                        SquareButton(
                                          text: 'ข้อมูลบิล\nและข้อมูลใบเสร็จ',
                                          press: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    settings: RouteSettings(
                                                        name: 'ดูข้อมูลบิล'),
                                                    builder: (context) =>
                                                        ShowBill(
                                                          userId: user_id,
                                                        )));
                                          },
                                          icon: FontAwesomeIcons.fileInvoice,
                                        ),
                                        SquareButton(
                                          text: 'ข้อมูลใบ\nแจกสินค้าทดลอง',
                                          press: () {
                                            locator<NavigationService>()
                                                .navigateTo(
                                                    'showTrail',
                                                    ScreenArguments(
                                                      userId: user_id,
                                                    ));
                                          },
                                          icon: FontAwesomeIcons.list,
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
                                            // Navigator.of(context).pushNamed('ceo_topsale');
                                            locator<NavigationService>()
                                                .navigateTo('ceo_topsale',
                                                    ScreenArguments());
                                          },
                                          text: 'TOP Sales\nเซลยอดเยี่ยม',
                                          icon: FontAwesomeIcons.medal,
                                        ),
                                        SquareButton(
                                          press: () async {
                                            // Navigator.of(context).pushNamed('ceo_topteam');
                                            locator<NavigationService>()
                                                .navigateTo('ceo_topteam',
                                                    ScreenArguments());
                                          },
                                          text: 'TOP Teams\nทีมยอดเยี่ยม',
                                          icon: FontAwesomeIcons.star,
                                        ),
                                        SquareButton(
                                          press: () async {
                                            locator<NavigationService>()
                                                .navigateTo(
                                                    'docCertificate',
                                                    ScreenArguments(
                                                        userId: user_id));
                                          },
                                          text: 'ใบอนุญาต\nสามารถขายปุ๋ย',
                                          icon: FontAwesomeIcons.certificate,
                                        ),
                                        SquareButton(
                                          press: () async {
                                            DateTime initDate = DateTime.now();
                                            if (level_id == 3 ||
                                                level_id == 12) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      settings: RouteSettings(
                                                          name:
                                                              'รายงานข้อมูลเครดิตผอ'),
                                                      builder: (context) =>
                                                          CreditReportManager()));
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      settings: RouteSettings(
                                                          name:
                                                              'รายงานข้อมูลเครดิตรายคัน'),
                                                      builder: (context) =>
                                                          CeoReportCarDetail(
                                                            carId: workCarId,
                                                            selectedMonth:
                                                                initDate,
                                                          )));
                                            }
                                          },
                                          text: 'รายงาน\nข้อมูลเครดิต',
                                          icon: FontAwesomeIcons.chartBar,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (level_id != 1)
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
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'moneyTransfer',
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'แจ้งโอน\nเงินสดให้ธุรการ',
                                            icon: FontAwesomeIcons.moneyBillAlt,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'carPayDay',
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'บันทึก\nรายจ่ายรายวัน',
                                            icon: FontAwesomeIcons
                                                .fileInvoiceDollar,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'createSaleOrder',
                                                      ScreenArguments(
                                                          userId: user_id,
                                                          editStatus: 0));
                                            },
                                            text: 'สร้าง\nใบสั่งขาย',
                                            icon: FontAwesomeIcons.clipboard,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'teamStock',
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'คลัง\nสินค้าทีม',
                                            icon: FontAwesomeIcons.boxes,
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (level_id != 1)
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
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'showPTA',
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'จากสินเชื่อ\nดูใบมอบอำนาจ',
                                            icon: FontAwesomeIcons.addressBook,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              String route;
                                              if (level_id == 2) {
                                                route = 'head_dashboard';
                                              } else if (level_id == 12) {
                                                route = 'submanager_dashboard';
                                              } else if (level_id == 3) {
                                                route = 'manager_dashboard';
                                              }
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      route,
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'ข้อมูล\nภายใต้สายบริหาร',
                                            icon: FontAwesomeIcons.users,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              DateTime initDate =
                                                  DateTime.now();
                                              // print(
                                              //     "click รายงาน ทีมเปิดใบสั่งจอง");
                                              if (level_id == 3 ||
                                                  level_id == 12) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        settings: RouteSettings(
                                                            name:
                                                                'ผู้อำนวยการดูรายงานทีมเปิดใบสั่งจอง'),
                                                        builder: (context) =>
                                                            ManagerKPISale(
                                                              manager_id:
                                                                  user_id,
                                                              selectedMonth:
                                                                  initDate,
                                                            )));
                                              } else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        settings: RouteSettings(
                                                            name:
                                                                'Sup.ดูรายงานทีมเปิดใบสั่งจอง'),
                                                        builder: (context) =>
                                                            HeadKPISale(
                                                              carId: workCarId,
                                                              selectedMonth:
                                                                  initDate,
                                                            )));
                                              }
                                            },
                                            text: 'รายงาน\nทีมเปิดใบสั่งจอง',
                                            icon: FontAwesomeIcons.chartPie,
                                          ),
                                          SquareButton(
                                            press: () async {
                                              locator<NavigationService>()
                                                  .navigateTo(
                                                      'historyIncome',
                                                      ScreenArguments(
                                                          userId: user_id));
                                            },
                                            text: 'ประวัติ\nรายได้งานขาย',
                                            icon:
                                                FontAwesomeIcons.handHoldingUsd,
                                          ),
                                          // SquareButton(
                                          //   press: () async {
                                          //     locator<NavigationService>().navigateTo('userSetting',
                                          //         ScreenArguments(userId: user_id));
                                          //   },
                                          //   text:
                                          //   'ตั้งค่า\nข้อมูลส่วนตัว',
                                          //   icon: FontAwesomeIcons.userCog,
                                          // ),
                                        ],
                                      ),
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
      ),
    );
  }

  OtherDataShow() {
    print(" ===> OtherDataShow() ${comData}");
    if ((level_id == 2 || level_id == 3 || level_id == 12) ||
        (comData['MoneyRecommend'] != 0) ||
        (comData['Sum_income'] != 0) ||
        (comData['sumEXPENSES'] != 0)) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          children: [
            HeaderText(text: 'ข้อมูลรายได้เพิ่มเติม'),
            if (comData['MoneyRecommend'] != 0)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child:
                              Text('ค่าแนะนำ', style: TextStyle(fontSize: 18))),
                      Text('${f.SeperateNumber(comData['MoneyRecommend'])} บาท',
                          style: TextStyle(fontSize: 18))
                    ],
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text('(${comData['namerecommend'].length} คน)')),
                ],
              ),
            if (level_id == 2 || level_id == 3 || level_id == 12)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('ค่าส่วนต่าง',
                              style: TextStyle(fontSize: 18))),
                      level_id == 2
                          ? Text(
                              '${f.SeperateNumber(comData['Sum_money_share_headmain'])} บาท',
                              style: TextStyle(fontSize: 18))
                          : Text(
                              '${f.SeperateNumber(comData['sumusermoney2other'])} บาท',
                              style: TextStyle(fontSize: 18))
                    ],
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          '(${f.SeperateNumber(totalMoneyShareCat1)} กระสอบ)')),
                ],
              ),
            if (comData['Sum_income'] != 0)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('รายได้อื่น ๆ',
                              style: TextStyle(fontSize: 18))),
                      Text('${f.SeperateNumber(comData['Sum_income'])} บาท',
                          style: TextStyle(fontSize: 18))
                    ],
                  ),
                  // Align(
                  //     alignment: Alignment.centerRight,
                  //     child: Text('(ดูรายละเอียด)')
                  // ),
                ],
              ),
            if (comData['sumEXPENSES'] != 0)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('หักค่าใช้จ่าย',
                              style: TextStyle(fontSize: 18))),
                      Text('${f.SeperateNumber(comData['sumEXPENSES'])} บาท',
                          style: TextStyle(fontSize: 18, color: Colors.red))
                    ],
                  ),
                  // Align(
                  //     alignment: Alignment.centerRight,
                  //     child: Text('(ดูรายละเอียด)')),
                ],
              ),
            if (tax != 0)
              Row(
                children: [
                  Expanded(
                      child: Text('หัก ณ ที่จ่าย 3%',
                          style: TextStyle(fontSize: 18))),
                  Text('${f.SeperateNumber(tax)} บาท',
                      style: TextStyle(fontSize: 18, color: Colors.red))
                ],
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  // ignore: non_constant_identifier_names
  Row CommissionData() {
    // print('CommissionData ---- OXOXOXOXO');
    int _goal = (_user['Goal'] == 0) ? 1 : _user['Goal'];
    var series = [
      new charts.Series(
          domainFn: (SellGoal clickData, _) => clickData.text,
          measureFn: (SellGoal clickData, _) => clickData.total,
          colorFn: (SellGoal clickData, _) => clickData.color,
          labelAccessorFn: (SellGoal clickData, _) => clickData.text,
          id: 'Clicks',
          data: data.values.toList()),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: <Widget>[
            Stack(
              children: [
                SizedBox(
                  child: HalfDonut(
                    series,
                    animate: true,
                  ),
                  height: 200.0,
                  width: 200.0,
                ),
                Container(
                  height: 225,
                ),
                Positioned(
                  child: Text(
                    '${((sumCat1 / _goal) * 100).floor()} %',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  left: 80,
                  top: 65,
                ),
                Positioned(
                  child: ButtomChart(
                    totalMoney: '${f.SeperateNumber(sumIncomeAll)} บาท',
                    sellProvince: '${_user['PROVINCE_NAME']}',
                    workTime: '${calWorkTime(_user['Work_date_start'])}',
                    updateTime: '${comData['time_gen']}',
                    updateDate: '${f.ThaiDateFormat(comData['day_gen'])}',
                  ),
                  bottom: -5,
                  left: 16,
                )
              ],
            ),
          ],
        ),
        SizedBox(
          width: 8.0,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(),
              Row(
                children: [
                  Expanded(
                      child: Text(
                    'ยอดขาย',
                    style: TextStyle(fontSize: 18),
                  )),
                  Text('${f.SeperateNumber(comData['sumMoneyTotal'])} บาท',
                      style: TextStyle(fontSize: 18))
                ],
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      '(${f.SeperateNumber(sumCat1)} กระสอบ, ${f.SeperateNumber(cashCountCat2 + creditCountCat2)} ขวด)')),
              Row(
                children: [
                  Expanded(
                      child:
                          Text('คอมมิชชั่น', style: TextStyle(fontSize: 18))),
                  Text('${f.SeperateNumber(saleCommissionTotal)} บาท',
                      style: TextStyle(fontSize: 18))
                ],
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text('(วันที่ ${f.ThaiDateFormat(lastDate)})')),
              // if (_user['Setting_recommend'] != 0)

              Row(
                children: [
                  Expanded(
                      child:
                          Text('รายได้สุทธิ', style: TextStyle(fontSize: 18))),
                  Text('${f.SeperateNumber(net)} บาท',
                      style: TextStyle(fontSize: 18, color: Colors.green))
                ],
              ),
              MyDivider(),
              Row(
                children: [
                  Expanded(
                      child:
                          Text('เป้ายอดขาย', style: TextStyle(fontSize: 18))),
                  Text('${f.SeperateNumber(_user['Goal'])} กระสอบ',
                      style: TextStyle(fontSize: 18))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child:
                          Text('ขายได้แล้ว', style: TextStyle(fontSize: 18))),
                  Text('${f.SeperateNumber(sumCat1)} กระสอบ',
                      style: TextStyle(fontSize: 18))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Text('ขาดอีก', style: TextStyle(fontSize: 18))),
                  Text(
                      '${f.SeperateNumber((_user['Goal'] - sumCat1 < 0) ? 0 : _user['Goal'] - sumCat1)} กระสอบ',
                      style: TextStyle(fontSize: 18))
                ],
              )
            ],
          ),
        )),
      ],
    );
  }

  Padding UserInfo(Size size) {
    print(" ===> Padding UserInfo(Size size) {");
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
                              Container(
                                width: 35,
                                child:
                                    Image.asset('assets/icons/icon_mail.png'),
                              ),
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          // 'อัพเดทเมื่อเวลา  น.',
                                          'อัพเดทเมื่อเวลา ${comData['time_gen']} น.',
                                          style: TextStyle(
                                              fontSize: 20, height: 1),
                                        ),
                                        Text(
                                          'วันที่ ${f.ThaiDateFormat(comData['day_gen'])}',
                                          style: TextStyle(
                                              fontSize: 15, height: 1),
                                        )
                                      ],
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

class SellGoal {
  final String text;
  final int total;
  final charts.Color color;

  SellGoal(this.text, this.total, this.color);
}

class SaleRanking extends StatefulWidget {
  final result;

  const SaleRanking({Key key, this.result}) : super(key: key);

  @override
  _SaleRankingState createState() => _SaleRankingState();
}

class _SaleRankingState extends State<SaleRanking> {
  @override
  Widget build(BuildContext context) {
    print(" ===> class _SaleRankingState extends State<SaleRanking> {");
    return Container();
  }
}

bool ch_load(bool load) {
  if (load == true)
    return false;
  else
    return true;
}
