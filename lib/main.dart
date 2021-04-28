import 'dart:convert';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;
import 'package:system/configs/routes.dart';

import 'package:flutter/services.dart';
import 'package:system/services/service_analytic.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp])
      .then((_) => runApp(MultiProvider(providers: [
            ChangeNotifierProvider(
              create: (context) => NotificationModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => ShowDetail(),
            ),
          ], child: MyApp())));

  //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String message;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  var client = http.Client();

  List<Bill> _bill;
  List<Receipt> _receipt;
  List<Trail> _trail;
  FTPConnect ftpConnect;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Future<List<Bill>> parseResults(String resBody) async {
  //   final parsed = jsonDecode(resBody).cast<Map<String, dynamic>>();
  //   return await parsed.map<Bill>((json) => Bill.fromJson(json)).toList();
  // }

  Future<Null> getBill() async {
    //print('get bill');
    final SharedPreferences prefs = await _prefs;
    var userId = prefs.getInt('user_id');
    String query = 'SELECT * FROM BILL';
    if (userId != null) {
      query += ' WHERE User_id = $userId';
    }
    var res = await Sqlite().rawQuery(query);
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
    //check isSync = 1 ว่า Bill อยู่ใน DB หรือยัง ถ้าอยู่ให้อัพเดท isSync = 2 และอัพเดท Timestamp ให้ตรงกับ  Bill Online
    var result = _bill.where((element) => element.isSync == 1);
    await _updateBill(result);
    result = _bill.where((element) => element.isSync == 2);
    await _updateBill(result);
  }

  Future<Null> _updateBill(var result) async {
    //เอาเฉพาะที่ isSync = 2 หา Timestamp ที่ไม่ตรงกัน Download และอัพเดท isSync = 0
    List billNumber = [];
    for (var bill in result) {
      billNumber.add(bill.billNumber);
    }

    if (billNumber.isNotEmpty) {
      var res = await client.post(
          'https://landgreen.ml/system/public/api/checkOnlineBill',
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
        '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/customer/';
    String uploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
    await ftpConnect.changeDirectory(uploadPath);
    print('job uplodaBill');
    for (var bill in result) {
      var offlineCustomer = await Sqlite()
          .query('CUSTOMER', where: 'ID = ${bill.customerId}', firstRow: true);
      var postUri =
          Uri.parse('https://landgreen.ml/system/public/api/recordBill');
      var req = new http.MultipartRequest('POST', postUri);
      bool isImageCustomerUpload = true;
      bool isImageIdCardUpload = true;
      //print('image' + offlineCustomer['Image']);
      if (offlineCustomer['Image'] != null &&
          offlineCustomer['Image'].isNotEmpty &&
          offlineCustomer['Image'] != 'null') {
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
      req.fields['edit_status'] = '0';

      if (isImageIdCardUpload && isImageCustomerUpload) {
        await req.send().then((response) {
          http.Response.fromStream(response).then((val) async {
            if (val.statusCode == 200) {
              var res = await jsonDecode(val.body);
              if (res['Status'] == 'Success') {
                noti.remove(1);
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
    }
  }

  Future<Null> _uploadReceipt() async {
    var result = _receipt.where((element) => element.isSync == 0).toList();
    DateTime now = DateTime.now();
    String folderName = now.year.toString();
    String subFolderName = now.month.toString();
    String mainFolder =
        '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/receipt/';
    String uploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
    await ftpConnect.changeDirectory(uploadPath);
    for (var val in result) {
      var postUri =
          Uri.parse('https://landgreen.ml/system/public/api/uploadReceipt');
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
      req.fields['receipt_location'] = '${val.location}';

      bool isImageUpload = true;
      List imageReceipt = [];
      if (val.imageReceive != null && val.imageReceive != 'null') {
        var imgList = jsonDecode(val.imageReceive);
        for (var img in imgList) {
          File image = File('$img');
          String imageName = img.split('/')[6];
          isImageUpload =
              await ftpConnect.uploadFileWithRetry(image, pRetryCount: 2);
          imageReceipt.add("faarunApp/receipt/$imageName");
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

      print(req.fields);

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
    }
  }

  Future<Null> _checkReceipt() async {
    var result = _receipt.where((element) => element.isSync == 1);
    await _updateReceipt(result);
    result = _receipt.where((element) => element.isSync == 2);
    await _updateReceipt(result);
  }

  Future<Null> _updateReceipt(var result) async {
    List receiptNumber = [];
    for (var receipt in result) {
      receiptNumber.add(receipt.receiptNumber);
    }
    //print(receiptNumber);
    if (receiptNumber.isNotEmpty) {
      var res = await client.post(
          'https://landgreen.ml/system/public/api/checkOnlineReceipt',
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
    var result =
        _trail.where((element) => element.status == 0 || element.status == 99);
    DateTime now = DateTime.now();
    String folderName = now.year.toString();
    String subFolderName = now.month.toString();
    String mainFolder =
        '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/customer/';
    String customerUploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');

    mainFolder =
        '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/receipt/';
    String trailUploadPath = '$mainFolder$folderName/$subFolderName';
    await ftpConnect.createFolderIfNotExist(mainFolder);
    await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
    await ftpConnect
        .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');

    for (var trail in result) {
      await ftpConnect.changeDirectory(customerUploadPath);
      var postUri =
          Uri.parse('https://landgreen.ml/system/public/api/recordTrail');
      var req = new http.MultipartRequest('POST', postUri);

      bool isImageUpload = true;
      //req customer
      if (trail.image != null && trail.image != 'null') {
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
      req.fields['trail_location'] = '${trail.location}';

      List imageReceipt = [];
      print('imageReceive ${trail.imageReceive}');
      if (trail.imageReceive != null && trail.imageReceive != 'null') {
        await ftpConnect.changeDirectory(trailUploadPath);
        var imgList = jsonDecode(trail.imageReceive);
        for (var img in imgList) {
          File image = File('$img');
          String imageName = img.split('/')[6];
          isImageUpload =
              await ftpConnect.uploadFileWithRetry(image, pRetryCount: 2);
          imageReceipt.add("faarunApp/receipt/$imageName");
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
          'https://landgreen.ml/system/public/api/checkOnlineTrail',
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

  Future<void> initPlatformState() async {
    ftpConnect = FTPConnect(ftpHost,
        user: ftpUser, pass: ftpPass, port: 21, timeout: 60);
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: true,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      print("MAIN : [BackgroundFetch] Event received $taskId");
      bool isConnect = await DataConnectionChecker().hasConnection;
      await getBill();
      if (isConnect) {
        await ftpConnect.connect();
        await _uploadBill();
        await _checkBill();
        await _uploadReceipt();
        await _checkReceipt();
        await _uploadTrail();
        await _checkTrail();
        await ftpConnect.disconnect();
      }
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('MAIN : [BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('MAIN : [BackgroundFetch] configure ERROR: $e');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print('main initstat');
    initLocalNotification();
    initFirebaseMessaging();

    super.initState();
    initPlatformState();
  }

  initLocalNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {
      print("onDidReceiveLocalNotification called.");
      if (await canLaunch(payload)) {
        await launch(payload);
      } else {
        throw 'Could not launch $payload';
      }
    });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      // when user tap on notification.
      print("กดอ่านแล้ว ${payload}");
      if (await canLaunch(payload)) {
        await launch(payload);
      } else {
        throw 'Could not launch $payload';
      }

      // showDialog(
      //   context: context,
      //   builder: (_) => new AlertDialog(
      //     title: new Text('Notification'),
      //     content: new Text('$payload'),
      //   ),
      // );
    });
  }

  sendNotification({title = '', body = '', url = ''}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            '10000', 'click_action', 'FLUTTER_NOTIFICATION_CLICK',
            importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, '$title', '$body', platformChannelSpecifics, payload: url);
  }

  void initFirebaseMessaging() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        Map mapNotification = message["notification"];
        String title = mapNotification["title"];
        String body = mapNotification["body"];
        Map mapNotiData = message["data"];
        String url = mapNotiData["open_url"];

        sendNotification(title: title, body: body, url: url);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch กดlunch : $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Token : $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('th')],
      theme: ThemeData(
        accentColor: kPrimaryColor,
        fontFamily: 'DB',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme(
            primary: kPrimaryColor,
            primaryVariant: kPrimaryColor,
            secondary: kPrimaryColor,
            secondaryVariant: kPrimaryColor,
            surface: kPrimaryColor,
            background: Colors.white,
            error: kPrimaryColor,
            onPrimary: Colors.white,
            onSecondary: kPrimaryColor,
            onSurface: kPrimaryColor,
            onBackground: Colors.white,
            onError: kPrimaryColor,
            brightness: Brightness.light),
      ),
      navigatorKey: locator<NavigationService>().navigatorKey,
      initialRoute: 'splash',
      onGenerateRoute: Routes.generateRoute,
      navigatorObservers: [
        locator<AnalyticsService>().getAnalyticsObserver(),
      ],
    );
  }
}
