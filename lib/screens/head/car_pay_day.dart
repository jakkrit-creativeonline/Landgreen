import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/drop_down.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:http/http.dart' as http;

class CarPayDay extends StatefulWidget {
  final int userId;

  const CarPayDay({Key key, this.userId}) : super(key: key);

  @override
  _CarPayDayState createState() => _CarPayDayState();
}

class _CarPayDayState extends State<CarPayDay> {
  var client = http.Client();
  List showMoney = [];
  List typePay = [];
  Future<bool> isLoaded;
  Future<bool> isHistoryLoaded;
  FormatMethod f = FormatMethod();
  List<DropdownMenuItem<String>> _expenseList = [];
  List<DropdownMenuItem<String>> _carsList = [];

  List carPayHistory = [];

  DateTime selectedDate = DateTime.now();
  var selectedDateText = TextEditingController();
  var _money = TextEditingController();
  var _detail = TextEditingController();
  var _selectImage = TextEditingController();
  var selectedType;
  var selectedCarId;
  File image;

  final _formKey = GlobalKey<FormState>();

  final picker = ImagePicker();
  int carId = 0;

  @override
  void initState() {
    // getData();
    // getCarPayHistory();
    getCardId();
    _refresh();
    super.initState();
  }

  Future<Null> getCardId() async {
    var res = await Sqlite()
        .rawQuery('SELECT Work_car_id FROM USER WHERE ID = ${widget.userId}');
    carId = res[0]['Work_car_id'];
    print(carId);
  }

  Future _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print('isConnect ${isConnect}');
    if (isConnect) {
      getData();

      getCarPayHistory();
    } else {
      print('isConnect');
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
                  'หน้านี้เป็นหน้าบันทึกรายจ่ายรายวัน ต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนต้องอยู่ในที่ ที่มีสัญญาณอินเทอร์เน็ต\nถึงจะใช้งานได้ครับ',
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                    color: kPrimaryColor,
                    onPressed: () {
                      // Navigator.of(context).pop();
                      // Navigator.of(context).pushNamedAndRemoveUntil(contexts, 'dashboard',);
                      Navigator.pushNamedAndRemoveUntil(context, 'dashboard',
                          ModalRoute.withName('dashboard'));
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

  Future<void> getData() async {
    await getCarMoney();
    setState(() {});
  }

  Future<Null> getCarPayHistory() async {
    print('get car pay history');
    var res =
        await client.post('https://thanyakit.com/systemv2/public/api-head', body: {
      'Type': 'tbcaridhead',
      'user_id': '${widget.userId}',
      'startDate': '',
      'endDate': '',
    });
    carPayHistory = jsonDecode(res.body);
    //print(carPayHistory);
    isHistoryLoaded = Future.value(true);
    if (mounted) setState(() {});
  }

  Future<void> getCarMoney() async {
    var res = await client.post('https://thanyakit.com/systemv2/public/api-head',
        body: {'Type': 'showcarmoney', 'user_id': '${widget.userId}'});
    showMoney = jsonDecode(res.body);
    showMoney
        .map((e) => DropDown().getDropDownWidget(e, 'Car_id', 'Plate_number'))
        .forEach((element) {
      _carsList.add(element);
    });
    var typeList = await client
        .get('https://thanyakit.com/systemv2/public/api-head/TypePayDay');
    typePay = jsonDecode(typeList.body);
    typePay
        .map((e) => DropDown().getDropDownWidget(e, 'ID', 'Name'))
        .forEach((element) {
      _expenseList.add(element);
    });
    _selectImage.text = '0/1';
    isLoaded = Future.value(true);
    setState(() {});
  }

  Future<Null> _showDatePicker(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        initialDate: selectedDate,
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(data: Theme.of(context).copyWith(), child: child);
        });
    if (picked != null) {
      selectedDateText.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      selectedDate = picked;
      setState(() {});
    }
  }

  Future imgPicker(bool isFromCamera) async {
    var picked;
    if (isFromCamera) {
      picked = await picker.getImage(
          source: ImageSource.camera, imageQuality: 80, maxWidth: 700);
    } else {
      picked = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 700);
    }

    if (picked != null) {
      image = File(picked.path);
      _selectImage.text = '1/1';
      setState(() {});
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    imgPicker(true);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () {
                    imgPicker(false);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ));
        });
  }

  void clearData() {
    selectedDate = DateTime.now();
    selectedDateText.clear();
    _money.clear();
    _detail.clear();
    _selectImage.text = '0/1';
    selectedType = null;
    image = null;
    setState(() {});
  }

  Future<Null> submit() async {
    FTPConnect ftpConnect =
        FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
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
    var postUri =
        Uri.parse('https://thanyakit.com/systemv2/public/api/recordCarPayDay');
    var req = new http.MultipartRequest('POST', postUri);

    req.fields['Type'] = 'insert';
    req.fields['Car_id'] = '$selectedCarId';
    req.fields['Type_pay_day'] = '$selectedType';
    req.fields['Date_slip'] = '${selectedDate.toString().split(' ')[0]}';
    req.fields['Money_pay'] = '${_money.text}';
    req.fields['Detail'] = '${_detail.text}';
    req.fields['Status'] = '0';
    req.fields['Edit_user_id'] = '${widget.userId}';

    bool isUpload = false;
    if (image != null) {
      await ftpConnect.connect();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      DateTime now = DateTime.now();
      String folderName = now.year.toString();
      String subFolderName = now.month.toString();
      String subFolderName2 = now.day.toString();
      String mainFolder =
          '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/slip_car_pay_day/';
      String uploadPath =
          '$mainFolder$folderName/$subFolderName/$subFolderName2';
      await ftpConnect.createFolderIfNotExist(mainFolder);
      await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
      await ftpConnect
          .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
      await ftpConnect.createFolderIfNotExist(
          '$mainFolder$folderName/$subFolderName/$subFolderName2');
      await ftpConnect.changeDirectory(uploadPath);
      String name =
          '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
      File file = await image.copy('$appDocPath/$name.jpeg');
      String imageName =
          'faarunApp/slip_car_pay_day/$folderName/$subFolderName/$subFolderName2/$name.jpeg';
      req.fields['Image_slip'] = '$imageName';
      isUpload = await ftpConnect.uploadFileWithRetry(file, pRetryCount: 2);
      await ftpConnect.disconnect();
    }

    if (isUpload) {
      req.send().then((response) {
        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");
        http.Response.fromStream(response).then((val) async {
          if (val.statusCode == 200) {
            var res = await jsonDecode(val.body);
            print(res);
          } else {
            print(val.body);
          }

          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
            pr.hide().then((value) {
              getCarPayHistory();
              clearData();
            });
          });

          percentage = 0.0;
        });
      });
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
                title: Text('บันทึกรายจ่ายรายวัน'),
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
            body: Container(
              // padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: showCarMoney(size, context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: recordForm(size, context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    child: showHistory(size, context),
                  ),
                  Footer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String paidStatus(var status) {
    switch (status) {
      case 0:
        return 'รอบัญชีอนุมัติ';
        break;
      case 1:
        return 'อนุมัติแล้ว';
        break;
      case 2:
        return 'ไม่อนุมัติ';
        break;
      default:
        return '';
    }
  }

  Future deleteCarPay(var id, var imageSlip) async {
    var res = await client.post(
        'https://thanyakit.com/systemv2/public/api/deleteCarPayDay',
        body: {'ID': '$id', 'Image_slip': '$imageSlip'});
    print(res.body);
  }

  Future showConfirmDelete(context, var items) async {
    return showDialog(
            context: context,
            builder: (BuildContext bc) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ต้องการลบรายการนี้ใช่หรือไม่ ?'),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          color: kPrimaryColor,
                          text: 'ยืนยัน',
                          onPress: () async {
                            await deleteCarPay(
                                items['ID'], items['Image_slip']);
                            Navigator.of(context).pop(true);
                          },
                        ),
                        CustomButton(
                          color: kPrimaryLightColor,
                          text: 'ยกเลิก',
                          textColor: darkColor,
                          onPress: () {
                            Navigator.of(context).pop(false);
                          },
                        )
                      ],
                    ),
                  ],
                ),
              );
            }) ??
        false;
  }

  void showImageDetail(context, String tag, String url, Size size) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return AlertDialog(
            content: Container(
                height: size.height * 0.5,
                child: Hero(
                    tag: tag,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      progressIndicatorBuilder:
                          (context, uri, downloadProgress) =>
                              LinearProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, uri, error) => Icon(Icons.error),
                    ))),
          );
        });
  }

  Future showEditForm(context, var items) async {
    return showDialog(
            context: context,
            builder: (BuildContext bc) {
              return AlertDialog(
                content: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                        right: -40,
                        top: -40,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop(false);
                          },
                          child: CircleAvatar(
                            child: Icon(
                              Icons.close,
                              color: darkColor,
                            ),
                            backgroundColor: backgroundColor,
                          ),
                        )),
                    SingleChildScrollView(
                      child: EditFormCarPay(
                        expenseList: _expenseList,
                        typePay: typePay,
                        items: items,
                        userId: widget.userId,
                      ),
                    ),
                  ],
                ),
              );
            }) ??
        true;
  }

  void showModal(context, var items) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('แก้ไข'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showEditForm(context, items).then((value) {
                      //print(value);
                      getCarPayHistory();
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('ลบ'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showConfirmDelete(context, items).then((value) {
                      if (value == true) {
                        getCarPayHistory();
                      }
                    });
                  },
                ),
              ],
            ),
          ));
        });
  }

  Widget showHistory(Size size, BuildContext context) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return FutureBuilder(
        future: isHistoryLoaded,
        builder: (BuildContext bc, AsyncSnapshot snap) {
          if (snap.hasData) {
            return Container(
              width: size.width,
              child: Card(
                elevation: 2,
                child: Column(
                  children: [
                    HeaderText(
                      text: 'ข้อมูลรายจ่ายประจำสัปดาห์นี้',
                      textSize: 20,
                      gHeight: 26,
                    ),
                    Container(
                      height: size.height * 0.7,
                      padding: EdgeInsets.all(8),
                      child: (carPayHistory.length>0)?ListView.builder(
                          itemCount: carPayHistory.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (bc, i) {
                            var result = carPayHistory[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              child: Card(
                                elevation: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    if (result['Status'] == 0) {
                                      showModal(context, result);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              showImageDetail(
                                                  context,
                                                  '${result['ID']}',
                                                  '$storagePath${result['Image_slip']}',
                                                  size);
                                              // Navigator.push(context,
                                              //     MaterialPageRoute(builder: (_) {
                                              //   return ShowImageDetail(
                                              //     tag: '${result['ID']}',
                                              //     url:
                                              //         '$storagePath${result['Image_slip']}',
                                              //   );
                                              // }));
                                            },
                                            child: Hero(
                                              tag: '${result['ID']}',
                                              child: Container(
                                                height: 150,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            '$storagePath${result['Image_slip']}'),
                                                        fit: BoxFit.fill),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Flexible(
                                            flex: 6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ทะเบียน ${result['Plate_number']}-${result['PROVINCE_NAME']}',
                                                  style: _baseFontStyle,
                                                ),
                                                Text(
                                                  'ประเภท ${result['Name']}',
                                                  style: _baseFontStyle,
                                                ),
                                                Text(
                                                  'รายละเอียด ${(result['Detail'] == null) ? '-' : result['Detail']}',
                                                  style: _baseFontStyle,
                                                ),
                                                Text(
                                                  'วันที่ตามใบเสร็จ ${f.ThaiFormat(result['Date_slip'])}',
                                                  style: _baseFontStyle,
                                                ),
                                                Text(
                                                  'จำนวน ${f.SeperateNumber(result['Money_pay'])} บาท',
                                                  style: _baseFontStyle,
                                                ),
                                                Text(
                                                  'สถานะ ${paidStatus(result['Status'])}',
                                                  style: _baseFontStyle,
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }):Center(
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
                                  "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้บันทึกรายจ่าย \nในวันเวลา ดังกล่าวที่คุณเลือกมานี้",
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
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ShimmerLoading(
              type: 'boxItem',
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: size.width,
                child: Card(
                  elevation: 2,
                  child: Container(
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget recordForm(Size size, BuildContext context) {
    return Container(
      width: size.width,
      child: Card(
        elevation: 2.0,
        child: Container(
          child: formCarPay(context, _formKey),
        ),
      ),
    );
  }

  Form formCarPay(BuildContext context, GlobalKey<FormState> _formKey) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText(
            text: 'กรอกรายละเอียดแล้วกดปุ่มบันทึกรายจ่าย',
            textSize: 20,
            gHeight: 26,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: isLoaded,
                    builder: (BuildContext bc, AsyncSnapshot snap) {
                      if (snap.hasData) {
                        var result = showMoney[0];
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ทะเบียนรถ : ',
                                style: _baseFontStyle,
                              ),
                            ),
                            Expanded(
                                flex: 7,
                                child: DropDown(
                                  items: _carsList,
                                  hintText: 'เลือกทะเบียนรถ',
                                  // value: selectedType,
                                  validator: (val) => val == null
                                      ? 'กรุณาเลือกทะเบียนรถ'
                                      : null,
                                  onChange: (val) {
                                    print('onchange selectedCarId =>$val');
                                    selectedCarId = val;
                                    setState(() {});
                                  },
                                ))
                            // Expanded(
                            //   flex: 7,
                            //   child: Text(
                            //     '${result['Plate_number']}-${result['PROVINCE_NAME']}',
                            //     style: _baseFontStyle,
                            //   ),
                            // ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'ทะเบียนรถ : ',
                                style: _baseFontStyle,
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Text(
                                'รอระบบดึงข้อมูลทะเบียนรถแปป..',
                                style: _baseFontStyle,
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          'ค่าใช้จ่าย : ',
                          style: _baseFontStyle,
                        )),
                    Expanded(
                        flex: 7,
                        child: DropDown(
                          items: _expenseList,
                          hintText: 'เลือกประเภทค่าใช้จ่าย',
                          // value: selectedType,
                          validator: (val) =>
                              val == null ? 'กรุณาเลือกประเภทค่าใช้จ่าย' : null,
                          onChange: (val) {
                            selectedType = val;
                            setState(() {});
                          },
                        ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          'จำนวนเงิน : ',
                          style: _baseFontStyle,
                        )),
                    Expanded(
                        flex: 7,
                        child: SquareInput(
                          hintText: 'จำนวนเงิน',
                          textController: _money,
                          inputType: TextInputType.number,
                          validate: (val) =>
                              val.isEmpty ? 'กรุณาระบุจำนวนเงิน' : null,
                        ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          'วันที่ตามใบเสร็จ : ',
                          style: _baseFontStyle,
                        )),
                    Expanded(
                        flex: 7,
                        child: GestureDetector(
                          onTap: () => _showDatePicker(context),
                          child: AbsorbPointer(
                            child: SquareInput(
                              textController: selectedDateText,
                              hintText: 'เลือกวันที่',
                              validate: (val) =>
                                  val.isEmpty ? 'กรุณาเลือกวันที่' : null,
                            ),
                          ),
                        ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(
                          'รายละเอียดค่าใช้จ่าย : ',
                          style: _baseFontStyle,
                        )),
                    Expanded(
                        flex: 7,
                        child: SquareInput(
                          hintText: 'รายละเอียดค่าใช้จ่าย',
                          textController: _detail,
                        ))
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(
                              'แนบไฟล์ใบเสร็จ : ',
                              style: _baseFontStyle,
                            )),
                        Expanded(
                          flex: 7,
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 0, right: 10, bottom: 0),
                            child: TextFormField(
                              controller: _selectImage,
                              readOnly: true,
                              validator: (val) =>
                                  val == '0/1' ? 'กรุณาแนบไฟล์ใบเสร็จ' : null,
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                  border: InputBorder.none),
                            ),
                          ),
                        )
                        // Expanded(
                        //     flex: 7,
                        //     child: image != null
                        //         ? Text('1/1')
                        //         : Text('0/1'))
                      ],
                    ),
                    image != null
                        ? GestureDetector(
                            onTap: () => _showPicker(context),
                            child: SizedBox(
                              height: 200,
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(8),
                            color: backgroundColor,
                            child: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => _showPicker(context)),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                      text: 'บันทึกรายจ่าย',
                      onPress: () async {
                        if (_formKey.currentState.validate() && image != null) {
                          await submit();
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget showCarMoney(Size size, BuildContext context) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return FutureBuilder(
        future: isLoaded,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var result = showMoney[0];
            return Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Stack(
                children: [
                  Container(
                      width: size.width * 0.92,
                      height: 120,
                      child: Swiper(
                        itemBuilder: (BuildContext bc, int i) {
                          var result = showMoney[i];
                          return Container(
                            width: size.width * 0.92,
                            child: Card(
                              elevation: 2.0,
                              child: Container(
                                  // padding: EdgeInsets.all(16),
                                  child: Column(
                                children: [
                                  HeaderText(
                                    text: 'รายการเงินคงเหลือ',
                                    textSize: 20,
                                    gHeight: 26,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, top: 8, bottom: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ทะเบียนรถ ${result['Plate_number']}-${result['PROVINCE_NAME']}',
                                              style: _baseFontStyle,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'ยอดคงเหลือ ${f.SeperateNumber(result['Money'])} บาท',
                                                style: _baseFontStyle,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                'รวมรายจ่าย ${f.SeperateNumber( (result['Money_paytotal'] == null)?0:result['Money_paytotal'] )} บาท',
                                                style: _baseFontStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // DotsIndicator(
                                  //   dotsCount: showMoney.length,
                                  //   position: i.toDouble(),
                                  //   decorator: DotsDecorator(
                                  //     spacing: const EdgeInsets.only(left: 2,right: 2),
                                  //     activeColor: kPrimaryLightColor,
                                  //   ),
                                  // )
                                ],
                              )),
                            ),
                          );
                        },
                        itemCount: showMoney.length,
                        pagination: new SwiperPagination(
                            builder:
                                DotSwiperPaginationBuilder(color: Colors.grey)),
                        // control: new SwiperControl(),
                      )
                      // ListView.builder(
                      //     itemCount: showMoney.length,
                      //     scrollDirection: Axis.horizontal,
                      //     shrinkWrap: false,
                      //     itemBuilder: (bc, i) {
                      //       var result = showMoney[i];
                      //       return Container(
                      //         width: size.width * 0.92,
                      //         child: Card(
                      //           elevation: 2.0,
                      //           child: Container(
                      //               // padding: EdgeInsets.all(16),
                      //             child: Column(
                      //
                      //             children: [
                      //               HeaderText(
                      //                 text: 'รายการเงินคงเหลือ',
                      //                 textSize: 20,
                      //                 gHeight: 26,
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.only(
                      //                     left: 16, right: 16, top: 8, bottom: 8),
                      //                 child: Column(
                      //                   children: [
                      //                     Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.start,
                      //                       children: [
                      //                         Text(
                      //                           'ทะเบียนรถ ${result['Plate_number']}-${result['PROVINCE_NAME']}',
                      //                           style: _baseFontStyle,
                      //                         ),
                      //                       ],
                      //                     ),
                      //                     Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.start,
                      //                       children: [
                      //                         Expanded(
                      //                           flex: 1,
                      //                           child: Text(
                      //                             'ยอดคงเหลือ ${f.SeperateNumber(result['Money'])} บาท',
                      //                             style: _baseFontStyle,
                      //                           ),
                      //                         ),
                      //                         Expanded(
                      //                           flex: 1,
                      //                           child: Text(
                      //                             'รวมรายจ่าย ${f.SeperateNumber(result['Money_paytotal'])} บาท',
                      //                             style: _baseFontStyle,
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //               DotsIndicator(
                      //                 dotsCount: showMoney.length,
                      //                 position: i.toDouble(),
                      //                 decorator: DotsDecorator(
                      //                   spacing: const EdgeInsets.only(left: 2,right: 2),
                      //                   activeColor: kPrimaryLightColor,
                      //                 ),
                      //               )
                      //             ],
                      //           )),
                      //         ),
                      //       );
                      //     }),
                      ),
                  // if(showMoney.length >1)
                ],
              ),
            );
            // return Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16),
            //   child: Container(
            //     width: size.width,
            //     child: Card(
            //       elevation: 2.0,
            //       child: Container(
            //           // padding: EdgeInsets.all(16),
            //           child: Column(
            //             children: [
            //               HeaderText(text:'รายการเงินคงเหลือ',textSize: 20,gHeight: 26,),
            //               Padding(
            //                 padding: const EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 8),
            //                 child: Column(
            //                   children: [
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                             'ทะเบียนรถ ${result['Plate_number']}-${result['PROVINCE_NAME']}',style: _baseFontStyle,),
            //                       ],
            //                     ),
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       children: [
            //                         Expanded(
            //                           flex: 1,
            //                           child: Text(
            //                               'ยอดคงเหลือ ${f.SeperateNumber(result['Money'])} บาท',style: _baseFontStyle,),
            //                         ),
            //                         Expanded(
            //                           flex: 1,
            //                           child: Text(
            //                               'รวมรายจ่าย ${f.SeperateNumber(result['Money_paytotal'])} บาท',style: _baseFontStyle,),
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           )),
            //     ),
            //   ),
            // );
          } else {
            return Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ShimmerLoading(),
            ));
            // return Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16),
            //   child: Container(
            //     width: size.width,
            //     child: Card(
            //       elevation: 2.0,
            //       child: Container(
            //           // padding: EdgeInsets.all(16),
            //           child: Column(
            //             children: [
            //               HeaderText(text:'รายการเงินคงเหลือ',textSize: 20,gHeight: 26,),
            //               Padding(
            //                 padding: const EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 8),
            //                 child: Column(
            //                   children: [
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       children: [
            //                         Text('ทะเบียนรถ -',style: _baseFontStyle,),
            //                       ],
            //                     ),
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       children: [
            //                         Expanded(
            //                           flex:1,
            //                           child: Text('ยอดคงเหลือ 0 บาท',style: _baseFontStyle,),
            //                         ),
            //                         Expanded(
            //                           flex: 1,
            //                             child: Text('รวมรายจ่าย 0 บาท',style: _baseFontStyle,),
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           )),
            //     ),
            //   ),
            // );
          }
        });
  }
}

class EditFormCarPay extends StatefulWidget {
  final List<DropdownMenuItem<String>> expenseList;
  final List typePay;
  final items;
  final int userId;

  const EditFormCarPay(
      {Key key, this.expenseList, this.typePay, this.items, this.userId})
      : super(key: key);

  @override
  _EditFormCarPayState createState() => _EditFormCarPayState();
}

class _EditFormCarPayState extends State<EditFormCarPay> {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  var selectedDateText = TextEditingController();
  var _money = TextEditingController();
  var _detail = TextEditingController();
  var _selectImage = TextEditingController();
  var selectedType;
  File image;

  FormatMethod f = FormatMethod();

  final picker = ImagePicker();

  var client = http.Client();

  var result;

  Future<Null> _showDatePicker(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        initialDate: selectedDate,
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(data: Theme.of(context).copyWith(), child: child);
        });
    if (picked != null) {
      selectedDateText.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      selectedDate = picked;
      setState(() {});
    }
  }

  Future imgPicker(bool isFromCamera) async {
    var picked;
    if (isFromCamera) {
      picked = await picker.getImage(
          source: ImageSource.camera, imageQuality: 80, maxWidth: 700);
    } else {
      picked = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 700);
    }

    if (picked != null) {
      image = File(picked.path);
      _selectImage.text = '1/1';
      setState(() {});
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    imgPicker(true);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () {
                    imgPicker(false);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ));
        });
  }

  Future<Null> submit() async {
    FTPConnect ftpConnect =
        FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
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
    var postUri =
        Uri.parse('https://thanyakit.com/systemv2/public/api/recordCarPayDay');
    var req = new http.MultipartRequest('POST', postUri);

    req.fields['Type'] = 'insert';
    req.fields['Car_id'] = '${result['Car_id']}';
    req.fields['Type_pay_day'] = '$selectedType';
    req.fields['Date_slip'] = '${selectedDate.toString().split(' ')[0]}';
    req.fields['Money_pay'] = '${_money.text}';
    req.fields['Detail'] = '${_detail.text}';
    req.fields['Status'] = '0';
    req.fields['Edit_user_id'] = '${widget.userId}';

    req.fields['ID'] = '${result['ID']}';
    req.fields['Image_slip'] = '${result['Image_slip']}';

    bool isUpload = false;
    if (image != null) {
      await ftpConnect.connect();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      DateTime now = DateTime.now();
      String folderName = now.year.toString();
      String subFolderName = now.month.toString();
      String subFolderName2 = now.day.toString();
      String mainFolder =
          '/domains/thanyakit.com/public_html/systemv2/storage/app/faarunApp/slip_car_pay_day/';
      String uploadPath =
          '$mainFolder$folderName/$subFolderName/$subFolderName2';
      await ftpConnect.createFolderIfNotExist(mainFolder);
      await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
      await ftpConnect
          .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
      await ftpConnect.createFolderIfNotExist(
          '$mainFolder$folderName/$subFolderName/$subFolderName2');
      await ftpConnect.changeDirectory(uploadPath);
      String name =
          '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
      File file = await image.copy('$appDocPath/$name.jpeg');
      String imageName =
          'faarunApp/slip_car_pay_day/$folderName/$subFolderName/$subFolderName2/$name.jpeg';
      req.fields['image_ref_Edit'] = '$imageName';
      isUpload = await ftpConnect.uploadFileWithRetry(file, pRetryCount: 2);
      await ftpConnect.disconnect();
    }

    if (isUpload) {
      req.send().then((response) {
        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");
        http.Response.fromStream(response).then((val) async {
          if (val.statusCode == 200) {
            var res = await jsonDecode(val.body);
            print(res);
          } else {
            print(val.body);
          }

          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
            pr.hide().then((value) {
              // Navigator.of(context).pop();
              Navigator.pop(context, 'บันทึกรายจ่ายเรียบร้อย');
            });
          });

          percentage = 0.0;
        });
      });
    }
  }

  @override
  void initState() {
    // DateTime selectedDate = DateTime.now();
    // var selectedDateText = TextEditingController();
    // var _money = TextEditingController();
    // var _detail = TextEditingController();
    // var _selectImage = TextEditingController();
    // var selectedType;
    result = widget.items;
    selectedDate = DateTime.parse(result['Date_slip']);
    selectedDateText.text = f.ThaiFormat(result['Date_slip']);
    _money.text = f.SeperateNumber(result['Money_pay']);
    _detail.text = result['Detail'];
    selectedType = result['Type_pay_day'].toString();
    _selectImage.text = '0/1';
    print(result);
    print(selectedType);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('แก้ไขบันทึก'),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text('ทะเบียนรถ : ')),
              Expanded(
                  flex: 7,
                  child: DropDown(
                    items: widget.expenseList,
                    hintText: 'เลือกประเภทค่าใช้จ่าย',
                    value: selectedType,
                    validator: (val) =>
                        val == null ? 'กรุณาเลือกประเภทค่าใช้จ่าย' : null,
                    onChange: (val) {
                      selectedType = val;
                      setState(() {});
                    },
                  )),
            ],
          ),
          Text(
              'ทะเบียนรถ : ${result['Plate_number']}-${result['PROVINCE_NAME']}'),
          Row(
            children: [
              Expanded(flex: 3, child: Text('ค่าใช้จ่าย : ')),
              Expanded(
                  flex: 7,
                  child: DropDown(
                    items: widget.expenseList,
                    hintText: 'เลือกประเภทค่าใช้จ่าย',
                    value: selectedType,
                    validator: (val) =>
                        val == null ? 'กรุณาเลือกประเภทค่าใช้จ่าย' : null,
                    onChange: (val) {
                      selectedType = val;
                      setState(() {});
                    },
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text('จำนวนเงิน : ')),
              Expanded(
                  flex: 7,
                  child: SquareInput(
                    hintText: 'จำนวนเงิน',
                    textController: _money,
                    inputType: TextInputType.number,
                    validate: (val) =>
                        val.isEmpty ? 'กรุณาระบุจำนวนเงิน' : null,
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text('วันที่ตามใบเสร็จ : ')),
              Expanded(
                  flex: 7,
                  child: GestureDetector(
                    onTap: () => _showDatePicker(context),
                    child: AbsorbPointer(
                      child: SquareInput(
                        textController: selectedDateText,
                        hintText: 'เลือกวันที่',
                        validate: (val) =>
                            val.isEmpty ? 'กรุณาเลือกวันที่' : null,
                      ),
                    ),
                  ))
            ],
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text('รายละเอียดค่าใช้จ่าย : ')),
              Expanded(
                  flex: 7,
                  child: SquareInput(
                    hintText: 'รายละเอียดค่าใช้จ่าย',
                    textController: _detail,
                  ))
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: Text('แนบไฟล์ใบเสร็จ : ')),
                  Expanded(
                    flex: 7,
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 0, right: 10, bottom: 0),
                      child: TextFormField(
                        controller: _selectImage,
                        readOnly: true,
                        validator: (val) =>
                            val == '0/1' ? 'กรุณาแนบไฟล์ใบเสร็จ' : null,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            border: InputBorder.none),
                      ),
                    ),
                  )
                  // Expanded(
                  //     flex: 7,
                  //     child: image != null
                  //         ? Text('1/1')
                  //         : Text('0/1'))
                ],
              ),
              image != null
                  ? GestureDetector(
                      //onTap: () => _showPicker(context),
                      child: SizedBox(
                        height: 200,
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(8),
                      color: backgroundColor,
                      child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _showPicker(context)),
                    ),
              CustomButton(
                text: 'บันทึกรายจ่าย',
                onPress: () async {
                  if (_formKey.currentState.validate() && image != null) {
                    var callBackSubmit = await submit();
                    callBackSubmit.then((val) {
                      print('${val}');
                      locator<NavigationService>().moveWithArgsTo(
                          'carPayDay', ScreenArguments(userId: widget.userId));
                    });
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
