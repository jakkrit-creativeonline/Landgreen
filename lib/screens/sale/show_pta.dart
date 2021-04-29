import 'dart:convert';
import 'dart:io';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/components/show_modal_bottom_sheet.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:system/screens/sale/doc_pta.dart';
import 'package:http/http.dart' as http;

class ShowPTA extends StatefulWidget {
  final int userId;

  const ShowPTA({Key key, this.userId}) : super(key: key);

  @override
  _ShowPTAState createState() => _ShowPTAState();
}

class _ShowPTAState extends State<ShowPTA> {
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();
  Future<bool> isLoaded;
  List _listDocPTA = [];
  var _userId;
  TextStyle _baseFontStyle = TextStyle(fontSize: 18);

  @override
  void initState() {
    _userId = widget.userId;
    getData();
    super.initState();
  }

  getData() async {
    var res = await Sqlite().getJson('DOC_PTA_FOR_USER_${_userId}', 'PTA');

    isLoaded = Future.value();
    print('showPTA res=>${res}');
    if (res != null) {
      _listDocPTA = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var result = await s.getPTA(id: _userId, selectedMonth: 'PTA');
        _listDocPTA = jsonDecode(result);
      }
    }
    isLoaded = Future.value(true);
    setState(() {});
  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      isLoaded = Future.value();
      var result = await s.getPTA(id: _userId, selectedMonth: 'PTA');
      _listDocPTA = jsonDecode(result);

      isLoaded = Future.value(true);
      setState(() {});
    }
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
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
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
                                  FontAwesomeIcons.addressBook,
                                  color: btTextColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ใบมอบอำนาจจากฝ่ายสินเชื่อ',
                                    style: TextStyle(fontSize: 24.0, height: 1),
                                  ),
                                  Text(
                                    'สามารถแสดงเอกสารนี้เพื่อเก็บเงินลูกค้า',
                                    style: TextStyle(fontSize: 16.0, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: isLoaded,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (_listDocPTA.length > 0) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: _listDocPTA.length,
                                  itemBuilder: (context, index) {
                                    var obj = _listDocPTA[index];
                                    return Card(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          HeaderText(
                                            text:
                                                '${index + 1}. ลูกค้าชื่อ ${obj['Customer_name']}',
                                            gHeight: 26,
                                            textSize: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 10,
                                                top: 8,
                                                bottom: 8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ที่อยู่ ${obj['Customer_address'].toString().replaceAll('  ', ' ')}',
                                                        style: _baseFontStyle,
                                                      ),
                                                      Text(
                                                        'เบอร์โทร ${obj['Phone']}',
                                                        style: _baseFontStyle,
                                                      ),
                                                      Text(
                                                        'บิลเลขที่ ${obj['Bill_number']}',
                                                        style: _baseFontStyle,
                                                      ),
                                                      Text(
                                                        'ผู้สร้างใบมอบอำนาจให้ ${obj['Credit_create']}',
                                                        style: _baseFontStyle,
                                                      ),
                                                      Text(
                                                        'จำนวนเงินที่ให้ไปเก็บลูกค้า ${f.SeperateNumber(obj['Money_due'])} บาท',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                (obj['Money_due'] >
                                                                        0)
                                                                    ? dangerColor
                                                                    : Colors
                                                                        .black,
                                                            height: 1),
                                                      ),
                                                      if (obj['Sale_record_status'] ==
                                                          0)
                                                        Text(
                                                          '(แจ้งบันทึกไปแล้วรอสินเชื่อตรวจสอบ)',
                                                          style: _baseFontStyle,
                                                        ),
                                                      if (obj['Sale_record_status'] ==
                                                          1)
                                                        Text(
                                                          '(รายการแจ้งบันทึกอนุมัติแล้ว)',
                                                          style: _baseFontStyle,
                                                        ),
                                                      if (obj['Sale_record_status'] ==
                                                          2)
                                                        Text(
                                                          '(รายการแจ้งบันทึกไม่อนุมัติแล้ว)',
                                                          style: _baseFontStyle,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Wrap(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          MyFunction().openURL(
                                                              linkStr:
                                                                  "tel:${obj['Phone']}");
                                                        },
                                                        child: Card(
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        80,
                                                                    minHeight:
                                                                        40),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.phone,
                                                                  color:
                                                                      dangerColor,
                                                                  size: 22,
                                                                ),
                                                                Text(
                                                                  'โทรหาลูกค้า',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          dangerColor),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DocPTA(
                                                                          obj:
                                                                              obj)));
                                                        },
                                                        child: Card(
                                                          color: kPrimaryColor,
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        80,
                                                                    minHeight:
                                                                        40),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .search,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 18,
                                                                ),
                                                                Text(
                                                                  'กดดูใบมอบอำนาจ',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          if ((obj['Money_due'] > 0))
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2,
                                                  left: 10,
                                                  right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showModalNote(
                                                            context, obj);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: dangerColor),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Center(
                                                            child: Text(
                                                              'บันทึกโน้ต\nลูกค้าขอเลื่อนชำระ',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 22,
                                                                color:
                                                                    whiteColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () {
                                                          showModal(
                                                              context, obj);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color:
                                                                  kPrimaryColor),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Center(
                                                              child: Text(
                                                                'แจ้งบันทึก\nเก็บเงินลูกค้า',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 22,
                                                                  color:
                                                                      whiteColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Container(
                                    width: size.width * 0.98,
                                    height: size.height * 0.42,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/img/bgAlert.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.28,
                                          child: Image.asset(
                                              "assets/icons/icon_alert.png"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 15),
                                          child: Text(
                                            "ไม่มีข้อมูลที่ท่านเรียก",
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้ออกแจกสินค้าทดลอง \nในวันเวลา ดังกล่าวที่คุณเลือกมานี้",
                                            style: TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                height: 1),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return ShimmerLoading(
                                type: 'boxText',
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Footer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void showModal(context, obj) {
    var callBack = showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return FormRecord(
            obj: obj,
            userId: widget.userId,
          );
        });
    callBack.then((value) {
      print('value=>${value}');
      if (value != null) {
        ShowModalBottom()
            .alertDialog(context, 'แจ้งบันทึกเก็บเงินลูกค้าเรียบร้อย');
        _refresh();
      }
    });
  }

  void showModalNote(context, obj) {
    var callBack = showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return FormRecordNote(
            obj: obj,
            userId: widget.userId,
          );
        });
    callBack.then((value) {
      print('value=>${value}');
      if (value != null) {
        ShowModalBottom().alertDialog(context, 'บันทึกโน๊ตเรียบร้อย');
        _refresh();
      }
    });
  }
}

class FormRecord extends StatefulWidget {
  final obj;
  final userId;

  const FormRecord({Key key, this.obj, this.userId}) : super(key: key);

  @override
  _FormRecordState createState() => _FormRecordState();
}

class _FormRecordState extends State<FormRecord> {
  var _obj;
  var _userId;
  var _user;
  File _image;
  FormatMethod f = FormatMethod();
  final picker = ImagePicker();
  FTPConnect ftpConnect;

  var _moneytransferInp = TextEditingController();
  var _noteInp = TextEditingController();
  var _dateCusPayInp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectDateCusPay = DateTime.now();

  @override
  void initState() {
    _userId = widget.userId;
    _obj = widget.obj;
    _moneytransferInp.text = _obj['Money_due'].toString();
    super.initState();
    getUserData(_userId);
  }

  Future<Null> getUserData(ID) async {
    try {
      var result = await Sqlite().getUserData(ID);
      _user = result;
      _noteInp.text = '${_user['Name']} ${_user['Surname']} ผู้บันทึกเก็บเงิน ';
    } catch (e) {
      //print('ERROR getUserData $e');
    }
  }

  Future<Null> _showDatePickerDateCusPay(context) async {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        initialDate: _selectDateCusPay,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        _selectDateCusPay = picked;
        _dateCusPayInp.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      });
  }

  Future pickImage(bool isFromCamera) async {
    var pickedFile;
    if (isFromCamera) {
      pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 70, maxWidth: 700);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 700);
    }
    if (pickedFile != null) {
      //_showLoading(context);
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  Future submit() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
      double percentage = 0.0;
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.Download, isDismissible: false);
      pr.style(
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        message: 'กรุณารอสักครู่\nระบบกำลังประมวลผล',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        progressWidgetAlignment: Alignment.center,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      await pr.show();
      Future.delayed(Duration(seconds: 2)).then((value) {
        percentage += 30.0;
        pr.update(
          progress: percentage,
          message: "ส่งข้อมูล...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.green, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );
      });

      var postUri = Uri.parse(
          'https://landgreen.ml/system/public/api/recordMoneyReceivePTA');
      var req = new http.MultipartRequest('POST', postUri);
      req.fields['bill_id'] = '${_obj['Bill_id']}';
      req.fields['user_id'] = '${_userId}';
      req.fields['money'] = '${_moneytransferInp.text}';
      req.fields['note'] = '${_noteInp.text}';
      req.fields['Date_customer_pay'] = '${f.DateFormat(_selectDateCusPay)}';
      bool isUpload = false;
      if (_image != null) {
        print('${req}');
        await ftpConnect.connect();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        DateTime now = DateTime.now();
        String folderName = now.year.toString();
        String subFolderName = now.month.toString();
        String mainFolder =
            '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/recordMoneyReceivePTA/';
        String uploadPath = '$mainFolder$folderName/$subFolderName';
        await ftpConnect.createFolderIfNotExist(mainFolder);
        await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
        await ftpConnect
            .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
        await ftpConnect.changeDirectory(uploadPath);
        String name =
            '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${_userId}';
        File file = await _image.copy('$appDocPath/$name.jpeg');
        String imageName =
            'faarunApp/recordMoneyReceivePTA/$folderName/$subFolderName/$name.jpeg';
        req.fields['ImageSlip'] = '$imageName';
        isUpload = await ftpConnect.uploadFileWithRetry(file, pRetryCount: 2);
        await ftpConnect.disconnect();
      }

      if (isUpload) {
        print('isUpload รูป');
        print('${req}');
        req.send().then((value) {
          percentage = percentage + 30.0;
          pr.update(progress: percentage, message: "ส่งข้อมูล...");

          percentage = percentage + 30.0;
          pr.update(progress: percentage, message: "ส่งข้อมูล...");

          http.Response.fromStream(value).then((res) {
            if (res.statusCode == 200) {
              print(jsonDecode(res.body));
            } else {
              print(res.body);
            }
            Future.delayed(Duration(seconds: 2)).then((value) {
              pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
              pr.hide().then((value) {
                // locator<NavigationService>().moveWithArgsTo(
                //     'moneyTransfer', ScreenArguments(userId: widget.userId));
                Navigator.pop(context, 'โอนเงินเสร็จแล้ว');
              });
            });

            percentage = 0.0;
          });
        });
      } else {
        pr.update(
            progress: percentage,
            message: "ส่งข้อมูลล้มเหลว กรุณาลองใหม่ในภายหลัง");
        pr.hide().then((value) {
          Navigator.pop(context, 'โอนเงินเสร็จแล้ว');
          // locator<NavigationService>().moveWithArgsTo(
          //     'moneyTransfer', ScreenArguments(userId: widget.userId));
        });
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext contexts) {
          return AlertDialog(
            title: Center(child: Text('แจ้งเตือน !!! ')),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'แจ้งบันทึกเก็บเงินลูกค้า ต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตแล้วกดส่งข้อมูลใหม่นะครับ',
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                    color: kPrimaryColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'ok',
                      style: TextStyle(color: btTextColor),
                    ))
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 16, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 30,
                        ),
                      ),
                    )
                  ],
                ),
                HeaderText(
                  text: 'แจ้งบันทึกเก็บเงินลูกค้า',
                  textSize: 18.0,
                  gHeight: 26,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '1. กรอกจำนวนเงินที่ลูกค้าจ่าย',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SquareInput(
                  hintText: 'จำนวนเงินที่ลูกค้าจ่าย',
                  labelText: 'จำนวนเงินที่ลูกค้าจ่าย',
                  enable: true,
                  textController: _moneytransferInp,
                  inputType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                  validate: (val) {},
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '2. เลือกวันที่ลูกค้าชำระเงิน',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      _showDatePickerDateCusPay(context);
                      node.unfocus();
                    },
                    child: AbsorbPointer(
                      child: SquareInput(
                        hintText: 'วันที่ลูกค้าชำระเงิน',
                        labelText: 'วันที่ลูกค้าชำระเงิน',
                        textController: _dateCusPayInp,
                        validate: (val) => val.isEmpty ? '' : null,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '3. กรอกรายละเอียดเพื่อแจ้งให้สินเชื่อทราบ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SquareInput(
                  hintText: 'กรอกรายละเอียดที่นี่',
                  labelText: 'กรอกรายละเอียดที่นี่',
                  maxLine: 3,
                  enable: true,
                  textController: _noteInp,
                  inputType: TextInputType.multiline,
                  onEditingComplete: () => node.nextFocus(),
                  validate: (val) {},
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '4. แนบภาพถ่ายสลิป',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                if (_image != null)
                  SizedBox(
                    height: 200,
                    child: Image.file(
                      _image,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                            icon: Icon(Icons.photo_camera),
                            onPressed: () => pickImage(true)),
                        Text('ถ่ายภาพ')
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            icon: Icon(Icons.photo_library),
                            onPressed: () => pickImage(false)),
                        Text('เลือกรูปจากอัลบั้ม')
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'บันทึกเก็บเงินลูกค้า',
                      onPress: () async {
                        if (_image == null) {
                          ShowModalBottom()
                              .alertDialog(context, 'กรุณาแนบสลิป');
                        } else if (_selectDateCusPay == null) {
                          ShowModalBottom().alertDialog(
                              context, 'กรุณาเลือกวันที่ลูกค้าชำระ');
                        } else {
                          await submit();
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormRecordNote extends StatefulWidget {
  final obj;
  final userId;

  const FormRecordNote({Key key, this.obj, this.userId}) : super(key: key);

  @override
  _FormRecordNoteState createState() => _FormRecordNoteState();
}

class _FormRecordNoteState extends State<FormRecordNote> {
  var _obj;
  var _userId;
  var _user;
  File _image;
  FormatMethod f = FormatMethod();
  final picker = ImagePicker();
  FTPConnect ftpConnect;

  var _moneytransferInp = TextEditingController();
  var _noteInp = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime _selectDateCusPay = DateTime.now();

  @override
  void initState() {
    _userId = widget.userId;
    _obj = widget.obj;
    super.initState();
    getUserData(_userId);
  }

  Future<Null> getUserData(ID) async {
    try {
      var result = await Sqlite().getUserData(ID);
      _user = result;
      _noteInp.text = '${_user['Name']} ${_user['Surname']} ผู้บันทึก ';
    } catch (e) {
      //print('ERROR getUserData $e');
    }
  }

  Future submit() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
      double percentage = 0.0;
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.Download, isDismissible: false);
      pr.style(
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        message: 'กรุณารอสักครู่\nระบบกำลังประมวลผล',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        progressWidgetAlignment: Alignment.center,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      await pr.show();
      Future.delayed(Duration(seconds: 2)).then((value) {
        percentage += 30.0;
        pr.update(
          progress: percentage,
          message: "ส่งข้อมูล...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.green, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );
      });

      var postUri = Uri.parse(
          'https://landgreen.ml/system/public/api/recordMoneyReceivePTANote');
      var req = new http.MultipartRequest('POST', postUri);
      req.fields['bill_id'] = '${_obj['Bill_id']}';
      req.fields['user_id'] = '${_userId}';
      req.fields['note'] = '${_noteInp.text}';
      bool isUpload = true;

      if (isUpload) {
        print('isUpload รูป');
        print('${req}');
        req.send().then((value) {
          percentage = percentage + 30.0;
          pr.update(progress: percentage, message: "ส่งข้อมูล...");

          percentage = percentage + 30.0;
          pr.update(progress: percentage, message: "ส่งข้อมูล...");

          http.Response.fromStream(value).then((res) {
            if (res.statusCode == 200) {
              print(jsonDecode(res.body));
            } else {
              print(res.body);
            }
            Future.delayed(Duration(seconds: 2)).then((value) {
              pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
              pr.hide().then((value) {
                // locator<NavigationService>().moveWithArgsTo(
                //     'moneyTransfer', ScreenArguments(userId: widget.userId));
                Navigator.pop(context, 'บันทึกโน๊ตเรียบร้อย');
              });
            });

            percentage = 0.0;
          });
        });
      } else {
        pr.update(
            progress: percentage,
            message: "ส่งข้อมูลล้มเหลว กรุณาลองใหม่ในภายหลัง");
        pr.hide().then((value) {
          Navigator.pop(context, 'บันทึกโน๊ตเรียบร้อย');
          // locator<NavigationService>().moveWithArgsTo(
          //     'moneyTransfer', ScreenArguments(userId: widget.userId));
        });
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext contexts) {
          return AlertDialog(
            title: Center(child: Text('แจ้งเตือน !!! ')),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'บันทึกโน๊ต ต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตแล้วกดส่งข้อมูลใหม่นะครับ',
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                    color: kPrimaryColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'ok',
                      style: TextStyle(color: btTextColor),
                    ))
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 5, bottom: 16, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 30,
                        ),
                      ),
                    )
                  ],
                ),
                HeaderText(
                  text: 'แจ้งบันทึกโน้ตลูกค้าขอเลื่อนชำระ',
                  textSize: 18.0,
                  gHeight: 26,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'กรอกรายละเอียดเพื่อแจ้งให้สินเชื่อทราบถึงสาเหตุที่ลูกค้าเลื่อนชำระ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SquareInput(
                  hintText: 'กรอกรายละเอียดที่นี่',
                  labelText: 'กรอกรายละเอียดที่นี่',
                  maxLine: 3,
                  enable: true,
                  textController: _noteInp,
                  inputType: TextInputType.multiline,
                  onEditingComplete: () => node.nextFocus(),
                  validate: (val) {},
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'บันทึกโน๊ต',
                      onPress: () async {
                        await submit();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
