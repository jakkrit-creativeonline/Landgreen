import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as IO;
import 'dart:wasm';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/drop_down.dart';
import 'package:system/components/form_card.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/square_button.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:signature/signature.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:provider/provider.dart';

class CreateBill extends StatefulWidget {
  final int userId;
  final int editStatus;
  final int billId;
  final bool isBillOnline;
  final int customerId;

  const CreateBill(
      {Key key,
      this.userId,
      this.editStatus,
      this.billId,
      this.isBillOnline,
      this.customerId})
      : super(key: key);

  @override
  _CreateBillState createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  FocusNode myFocusNode;

  Map _optionCredit = {
    '77': '7 วัน',
    '1': '1 เดือน',
    '2': '2 เดือน',
    '3': '3 เดือน',
    '4': '4 เดือน',
    '5': '5 เดือน',
    '6': '6 เดือน',
    '7': '7 เดือน',
    '8': '8 เดือน',
    '9': '9 เดือน',
    '10': '10 เดือน',
    '11': '11 เดือน',
    '12': '12 เดือน'
  };
  Map textMap = {
    'idcard': '',
    'sex': '',
    'name': '',
    'surname': '',
    'day': '',
    'month': '',
    'year': '',
    'birthday': '',
    'address': '',
    'subdist': '',
    'dist': '',
    'province': '',
    'province_id': '',
    'dist_id': '',
    'subdist_id': ''
  };
  Map productImage = {};
  Map productGiftImage = {};

  List<DropdownMenuItem<String>> _provinceData;
  List<DropdownMenuItem<String>> _productData;
  List<DropdownMenuItem<String>> _customerTypeData;
  List<DropdownMenuItem<String>> _productGiftData;
  List<DropdownMenuItem<String>> _districtData;
  List<DropdownMenuItem<String>> _subDistrictData;
  List<DropdownMenuItem<String>> _oldCustomer;
  List<OldCustomer> _oldCustomerTest = [];
  List<DataRow> rows = [];
  List<Widget> rowsWidget = [];
  List _selectedProduct = [];
  List _listProduct;
  List _listProductGift;
  List _orderDetail;
  List _customerList;
  List textList;
  List tmpSubDistrict; //เก็บข้อมูลตำบล
  List reportCreditPrevious;
  List conditionCredit;
  List saleData;

  var _name = TextEditingController();
  var _surname = TextEditingController();
  var _birthday = TextEditingController();
  var _dueDate = TextEditingController();
  var _sendDate = TextEditingController();
  var _idcard = TextEditingController();
  var _tel = TextEditingController();
  var _zipcode = TextEditingController();
  var _location = TextEditingController();
  var _dueMoney = TextEditingController();
  var _earnMoney = TextEditingController();
  var _address = TextEditingController();

  File _image; //รูปครอป
  File _tmpImage; //รูปบัตรประชาชนเต็ม

  final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final DocumentTextRecognizer cloudDocumentTextRecognizer =
      FirebaseVision.instance.cloudDocumentTextRecognizer(
          CloudDocumentRecognizerOptions(hintedLanguages: ["en", "th"]));

  DateTime _selectSendDate = DateTime.now();
  DateTime selectDate = DateTime.utc(1988);
  DateTime _selectDueDate = DateTime.now();

  //Variable for dropdown
  var _sex,
      _province,
      _district,
      _subDistrict,
      _creditType,
      _product,
      _customer,
      _productGift,
      _customerType;

  var user_id,
      amount,
      amountGift,
      sumQty,
      sumMoney,
      totalCommission,
      saleUserId,
      _user;

  int _earnestFixedBath = 0;
  int _percentCreditPrevious = 0;

  var client = http.Client();

  Widget ProductImage;
  Widget ProductGiftImage;
  Widget SignatureImage;

  int _payMethod = 1;

  Position location;

  String SignatureBase64;
  String SignatureDate;
  String imageCustomerBase64 = '';
  String imageIdCard = '';
  String imageCustomer = '';
  String reserveDate = '';
  String docNumber = '';

  FormatMethod f = new FormatMethod();

  // Timer _timer;

  bool loading = false;
  bool hasSign = false;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

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

  Future<Null> getCurrPosition() async {
    if (widget.editStatus == 0) {
      try {
        print('get current location');
        //await Geolocator.checkPermission();
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _location.text = '${position.latitude},${position.longitude}';
          print(position);
        });
      } catch (e) {
        // bool gotoSetting = await _locationDenied();
        // if (gotoSetting) {
        //   await Geolocator.openAppSettings();
        // } else {
        //   Navigator.of(context).pop();
        // }
        print('get location failed');
      }
    }
  }

  Future<Null> readTextList(List textList) async {
    _district = null;
    _subDistrict = null;
    List result = new List();
    List arMonth = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    var tmp;
    var tmpArr;
    textList.asMap().forEach((k, v) {
      tmp = v.replaceAll('\n', ' ');
      tmpArr = tmp.split(' ');
      tmpArr.asMap().forEach((i, val) {
        result.add(val);
      });
    });
    result.removeWhere((element) => element == '');
    print(result);
    try {
      result.asMap().forEach((k, v) {
        if ((v.endsWith('ber') ||
                v.endsWith('er') ||
                v.startsWith('เล') ||
                v.endsWith('าชน')) &&
            f.isNumeric(result[k + 1])) {
          textMap['idcard'] = result[k + 1] +
              result[k + 2] +
              result[k + 3] +
              result[k + 4] +
              result[k + 5];
        } else if (v.startsWith('ชื่อ') ||
            v.startsWith('ชือ') ||
            v.endsWith('สกุล') ||
            v.endsWith('กุล') ||
            v.endsWith('กล')) {
          if (result[k + 1] == 'นาย') {
            textMap['sex'] = 1;
          } else {
            textMap['sex'] = 2;
          }
          textMap['name'] = result[k + 2];
          textMap['surname'] = result[k + 3];
        } else if (v.startsWith('เกิด') ||
            v.startsWith('เก') ||
            v.endsWith('นที่') ||
            v.endsWith('วนี') ||
            v.endsWith('นท่')) {
          textMap['day'] = int.parse(result[k + 1]);
          arMonth.asMap().forEach((key, value) {
            if (value == result[k + 2]) {
              textMap['month'] = key;
            }
          });
          textMap['year'] = int.parse(result[k + 3]) - 543;
          textMap['birthday'] = textMap['year'].toString() +
              '-' +
              textMap['month'].toString().padLeft(2, '0') +
              '-' +
              textMap['day'].toString().padLeft(2, '0');
        } else if (v.startsWith('ที่อ') ||
            v.startsWith('ทีอ') ||
            v.endsWith('อยู่')) {
          textMap['address'] =
              '${result[k + 1]} ${result[k + 2]} ${result[k + 3]}';
        } else if (v.startsWith('ต.') || v.startsWith('แขวง')) {
          textMap['subdist'] = v.startsWith('ต.') ? v.split('.')[1] : v;
        } else if (v.startsWith('อ.') || v.startsWith('เขต')) {
          textMap['dist'] = v.startsWith('อ.') ? v.split('.')[1] : v;
        } else if (v.startsWith('จ.')) {
          textMap['province'] = v.split('.')[1];
        }
      });
      if (textMap['province'] == null) textMap['province'] = 'กรุงเทพมหานคร';
      var res = await Sqlite().query('PROVINCE',
          firstRow: true,
          where: 'PROVINCE_NAME LIKE "%${textMap['province']}%"');
      textMap['province_id'] = res != null ? res['PROVINCE_ID'] : null;
      res = await Sqlite().query('Amphur',
          firstRow: true,
          where:
              'AMPHUR_NAME LIKE "%${textMap['dist']}%" AND PROVINCE_ID = "${textMap['province_id']}"');
      textMap['dist_id'] = res != null ? res['AMPHUR_ID'] : null;
      res = await Sqlite().query('DISTRICT',
          firstRow: true,
          where:
              'DISTRICT_NAME LIKE "%${textMap['subdist']}%" AND AMPHUR_ID  = "${textMap['dist_id']}"');
      textMap['subdist_id'] = res != null ? res['DISTRICT_ID'] : null;
      _name.text = '${textMap['name']}';
      _surname.text = '${textMap['surname']}';
      _idcard.text = '${textMap['idcard']}';
      _sex = textMap['sex'].toString();
      _province = textMap['province_id'].toString();
      await getDistrict(textMap['province_id'])
          .whenComplete(() => _district = textMap['dist_id'].toString());
      await getSubDistrict(textMap['dist_id']).whenComplete(() {
        _subDistrict = textMap['subdist_id'].toString();
        var tmp = tmpSubDistrict.firstWhere(
            (element) => element['DISTRICT_ID'].toString() == _subDistrict);
        _zipcode.text = tmp['ZIP_CODE'].toString();
      });
      selectDate = DateTime(textMap['year'], textMap['month'], textMap['day']);
      _birthday.text = f.ThaiDateFormat(textMap['birthday']);
      _address.text = textMap['address'];
      // _timer = new Timer(const Duration(seconds: 2), (){
      //   _district = textMap['dist_id'];
      //   _subDistrict = textMap['subdist_id'];
      // });
      setState(() {});
    } catch (e) {
      //show error dialog
      setState(() {
        _sex = null;
        _province = null;
        _district = null;
        _subDistrict = null;
        _zipcode.clear();
      });
      print('create textMap ERROR :: ${e.toString()}');
    }
  }

  Future<List> textRecog(File file) async {
    try {
      print('file ${file}');
      final FirebaseVisionImage visionImage =
          await FirebaseVisionImage.fromFile(file);

      final VisionDocumentText visionDocumentText =
          await cloudDocumentTextRecognizer.processImage(visionImage);

      List<String> textList = new List();
      print('textRecog => ${textList}');

      for (DocumentTextBlock block in visionDocumentText.blocks) {
        for (DocumentTextParagraph paragraph in block.paragraphs) {
          // Same getters as DocumentTextBlock
          textList.add(paragraph.text);
        }
      }
      return textList;
    } catch (e) {
      //show error dialog
      return [];
    }
  }

  Future imgPicker(bool isCamera) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
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

    var pickedFile;
    if (isCamera) {
      pickedFile = await picker.getImage(
          source: ImageSource.camera,
          imageQuality: 100,
          maxWidth: 1000,
          maxHeight: 1000);
      // source: ImageSource.camera);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          imageQuality: 100,
          maxWidth: 1000,
          maxHeight: 1000);
      // source: ImageSource.gallery);
    }
    if (pickedFile != null) {
      await pr.show();

      Future.delayed(Duration(seconds: 2)).then((value) {
        percentage += 30.0;
        pr.update(
          progress: percentage,
          message: "กำลังอ่านบัตรประชาชน...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.green, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );
      });

      percentage = percentage + 30.0;
      pr.update(progress: percentage, message: "กำลังอ่านบัตรประชาชน...");

      print('pickedFile.path =>${pickedFile.path}');
      _tmpImage = File(pickedFile.path);
      if (isConnect) {
        if (IO.Platform.isIOS) {
          print('ios คร้าบบบ ต้องหมุนภาพก่อน');
          Directory tempDir = await getTemporaryDirectory();
          final targetPath = tempDir.absolute.path + "/temp.jpg";
          File _tmpImageRotate = await FlutterImageCompress.compressAndGetFile(
              pickedFile.path, targetPath,
              quality: 90, rotate: 90);
          textList = await textRecog(_tmpImageRotate);
        } else {
          textList = await textRecog(_tmpImage);
        }
      } else {
        textList = [];
      }
      percentage = percentage + 30.0;
      pr.update(progress: percentage, message: "กำลังอ่านบัตรประชาชน...");

      await readTextList(textList).then((val) {
        Future.delayed(Duration(seconds: 2)).then((value) {
          pr.update(
              progress: percentage, message: "อ่านบัตรประชาชนเสร็จแล้ว...");
          pr.hide().then((value) {
            percentage = 0.0;
          });
        });
      });
      loading = false;
      _cropImage();
    }
  }

  // Future imgFromCamera() async {
  //   final pickedFile = await picker.getImage(
  //       source: ImageSource.camera, imageQuality: 70, maxWidth: 700);
  //   if (pickedFile != null) {
  //     //_showLoading(context);
  //     _tmpImage = File(pickedFile.path);
  //     textList = await textRecog(_tmpImage);
  //     await readTextList(textList);
  //     loading = false;
  //     _cropImage();
  //   } else {
  //     print('No image selected.');
  //   }
  //   Navigator.of(context).pop();
  // }

  // Future imgFromGallary() async {
  //   final pickedFile = await picker.getImage(
  //       source: ImageSource.gallery, imageQuality: 70, maxWidth: 700);
  //   if (pickedFile != null) {
  //     //_showLoading(context);
  //     _tmpImage = File(pickedFile.path);
  //     textList = await textRecog(_tmpImage);
  //     await readTextList(textList);
  //     _cropImage();
  //     setState(() {});
  //   } else {
  //     print('No image selected.');
  //   }
  //   Navigator.of(context).pop();
  // }

  void _cropImage() async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: _tmpImage.path,
        maxWidth: 720,
        maxHeight: 720,
        compressQuality: 90,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: darkColor,
            toolbarWidgetColor: kPrimaryColor,
            activeControlsWidgetColor: kPrimaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedImage != null) {
      _image = croppedImage;
      setState(() {});
    }
  }

  void _clearImage() {
    _tmpImage = null;
    _image = null;
    setState(() {});
  }

  Future<Null> _showDatePicker(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        initialDate: selectDate,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        selectDate = picked;
        _birthday.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      });
  }

  Future<Null> _showDatePickerSendDate(context) async {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        initialDate: _selectSendDate,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        _selectSendDate = picked;
        _sendDate.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      });
  }

  Future<Null> _showDatePickerDueDate(context) async {
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        firstDate: firstDate,
        lastDate: DateTime(2030),
        initialDate: _selectDueDate,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: Theme.of(context).copyWith(),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        _selectDueDate = picked;
        _dueDate.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      });
  }

  void _showLoading(context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 500),
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, _, __) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Card(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text('ระบบกำลังประมวลผล รอสักครู่')
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ).drive(Tween<Offset>(
            begin: Offset(0, -1.0),
            end: Offset.zero,
          )),
          child: child,
        );
      },
    );
  }

  void _showSignature(context) {
    Size size = MediaQuery.of(context).size;

    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: subFontColor,
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Text(
                      'ให้ลูกค้าเซ็นยืนยันบริเวณพื้นที่สีขาวนี้ได้เลย',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  Signature(
                    controller: _controller,
                    width: size.width * 0.9,
                    height: 300,
                    backgroundColor: Colors.white,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        onPress: () {
                          _controller.clear();
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        color: dangerColor,
                        text: 'ยกเลิก',
                      ),
                      CustomButton(
                        color: warningColor,
                        onPress: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                        text: 'ลบ',
                      ),
                      CustomButton(
                        onPress: () async {
                          if (_controller.isNotEmpty) {
                            var data = await _controller.toPngBytes();
                            setState(() {
                              SignatureBase64 = base64Encode(data);
                              SignatureImage = Image.memory(data);
                              SignatureDate = DateTime.now().toString();
                              hasSign = true;
                              Navigator.of(context).pop();
                            });
                          }
                        },
                        text: 'ยืนยัน',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          );
        });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('คลังภาพในเครื่อง'),
                      onTap: () {
                        imgPicker(false);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('กล้อง'),
                    onTap: () {
                      imgPicker(true);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Center(
                child: Text('คุณต้องการออกจากหน้าสร้างใบสั่งจองหรือไม่ ?')),
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
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "ยืนยันออก",
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

  Future<Null> calOrder() async {
    sumQty = 0;
    sumMoney = 0;
    totalCommission = 0;
    _orderDetail.asMap().forEach((key, value) {
      sumQty += value['qty'];
      sumMoney += value['qty'] *
          int.parse(value['price_sell'].toString().split('.')[0]);
      if (value['cat_id'] == 1) {
        totalCommission += value['qty'] * _user['Setting_commission'];
      } else {
        totalCommission += value['qty'] *
            int.parse(value['price_commission'].toString().split('.')[0]);
      }
    });
    setState(() {});
  }

  Future<Null> genRows() async {
    var _pathProduct = (await getApplicationDocumentsDirectory()).path;
    Size size = MediaQuery.of(context).size;
    setState(() {
      var _imageProduct;
      rowsWidget = [];
      rows = [];
      _orderDetail = [];
      _selectedProduct.asMap().forEach((i, map) {
        _orderDetail.add({
          'product_id': map['items'][0]['ID'],
          'qty': int.parse(map['amount']),
          'name': '${map['items'][0]['Name']}',
          'price_sell':
              int.parse(map['items'][0]['Price_sell'].toString().split('.')[0]),
          'cat_id': map['items'][0]['Category_id'],
          'price_commission': int.parse(
              map['items'][0]['Price_commission'].toString().split('.')[0])
        });

        if (File("${_pathProduct}/product_image_${map['items'][0]['ID']}.png")
            .existsSync()) {
          //ProductImage = CachedNetworkImage(imageUrl: null);
          _imageProduct = Image.file(File(
              "${_pathProduct}/product_image_${map['items'][0]['ID']}.png"));
        } else {
          _imageProduct = Image.asset('assets/no_image.png');
        }

        rowsWidget.add(Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  child: SizedBox(
                child: _imageProduct,
                width: size.width * 0.35,
                height: size.height * 0.2,
              )),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'รายการที่ : ${(i + 1)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'ชื่อสินค้า : ${map['items'][0]['Name']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'จำนวน : ${map['amount']}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'ราคาต่อหน่วย : ${map['items'][0]['Price_sell'].toString().split('.')[0]}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'รวมเป็นเงิน : ${(map['items'][0]['Price_sell'] * int.parse(map['amount'])).toString().split('.')[0]}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    if (widget.editStatus == 0 || widget.editStatus == 1)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 50,
                          child: RaisedButton(
                            onPressed: () {
                              delProduct(i);
                            },
                            color: kPrimaryColor,
                            textColor: Colors.white,
                            child: Text('ลบ'),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
            //
          ),
        ));
        rows.add(DataRow(cells: [
          DataCell(Text('${(i + 1)}')),
          DataCell(Text('${map['items'][0]['Name']}')),
          DataCell(Text('${map['amount']}')),
          DataCell(Text(
              '${map['items'][0]['Price_sell'].toString().split('.')[0]}')),
          DataCell(Text(
              '${(map['items'][0]['Price_sell'] * int.parse(map['amount'])).toString().split('.')[0]}')),
          DataCell(widget.editStatus == 0 || widget.editStatus == 1
              ? RaisedButton(
                  onPressed: () {
                    delProduct(i);
                  },
                  color: kPrimaryColor,
                  textColor: Colors.white,
                  child: Text('ลบ'),
                )
              : Container()),
        ]));
      });
      calOrder();
      rows.add(DataRow(cells: [
        DataCell(Text('รวมทั้งสิ้น')),
        DataCell(Text('')),
        DataCell(Text('$sumQty')),
        DataCell(Text('')),
        DataCell(Text('$sumMoney')),
        DataCell(Text('')),
      ]));
      rowsWidget.add(Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 25, top: 10, bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'รวมทั้งสิ้น',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'จำนวน : ${sumQty} ชิิ้น',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'เป็นเงิน : ${sumMoney} บาท',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
          //
        ),
      ));
    });
  }

  Future<Null> delProduct(var index) async {
    _selectedProduct.removeAt(index);
    await genRows();
  }

  Future<Null> getCustomerFromTrail() async {
    var res = await Sqlite()
        .rawQuery('SELECT * FROM CUSTOMER WHERE ID = ${widget.customerId}');
    res.forEach((val) async {
      imageIdCard = val['Image_id_card'];
      imageCustomer = val['Image'];
      _name.text = val['Name'];
      _surname.text = val['Surname'];
      _idcard.text = val['Id_card'];
      _sex = val['Sex'].toString();
      selectDate = DateTime.parse(val['Birthday']);
      _birthday.text = f.ThaiDateFormat(val['Birthday']);
      _tel.text = val['Phone'];
      _customerType = val['Type_id'].toString();
      _address.text = val['Address'];
      _province = val['Province_id'].toString();
      await getDistrict(val['Province_id'])
          .whenComplete(() => _district = val['Amphur_id'].toString());
      await getSubDistrict(val['Amphur_id'])
          .whenComplete(() => _subDistrict = val['District_id'].toString());
      _zipcode.text = val['Zipcode'];
      _image = File(val['Image']);
      setState(() {});
    });
  }

  Future<Null> selectCustomer() async {
    print('SELECT CUSTOMER => ${_customer}');
    if (_customer != null) {
      var customerName = _customer.toString().split(' ')[0];
      var customerSurname = _customer.toString().split(' ')[1];
      _customerList.forEach((val) async {
        if (val['Name'] == customerName && val['Surname'] == customerSurname) {
          print('READ CUSTOMER');
          print(val['ID']);
          imageIdCard = val['Image_id_card'];
          imageCustomer = val['Image'];
          _name.text = val['Name'];
          _surname.text = val['Surname'];
          _idcard.text = val['Id_card'];
          _sex = val['Sex'].toString();
          var birthday = val['Birthday'].toString().split('-');
          selectDate = DateTime(int.parse(birthday[0]), int.parse(birthday[1]),
              int.parse(birthday[2]));
          _birthday.text = f.ThaiDateFormat(val['Birthday']);
          _tel.text = val['Phone'];
          _customerType = val['Type_id'].toString();
          _address.text = val['Address'];
          _province = val['Province_id'].toString();
          await getDistrict(val['Province_id'])
              .whenComplete(() => _district = val['Amphur_id'].toString());
          await getSubDistrict(val['Amphur_id'])
              .whenComplete(() => _subDistrict = val['District_id'].toString());
          _zipcode.text = val['Zipcode'];
          if (val['Image'] != null && val['Image'] != 'null') {
            _image = File(val['Image']);
          }

          // var res = await client.post(
          //     'https://thanyakit.com/systemv2/public/api/test',
          //     body: {'path': '${val['Image']}'});
          // if (res.body == null) {
          // } else {
          //   setState(() {
          //     imageCustomerBase64 = res.body;
          //   });
          // }
        } else {
          print('NO CUSTOMER MATCH');
        }
      });
      setState(() {});
    }
  }

  Future<Null> addProduct() async {
    setState(() {
      if (amount == null) {
        amount = '1';
      }
      if (_selectedProduct.isNotEmpty &&
          _selectedProduct.any(
              (element) => element['items'][0]['ID'].toString() == _product)) {
        var _selectedProductMap = _selectedProduct.asMap();
        _selectedProduct.asMap().forEach((key, value) {
          if (value['items'][0]['ID'].toString() == _product) {
            _selectedProductMap[key]['amount'] =
                (int.parse(value['amount']) + int.parse(amount)).toString();
          }
        });
        _selectedProduct = _selectedProductMap.values.toList();
        genRows();
      } else {
        // _selectedProduct.add({
        //   'items': _listProduct
        //       .where((map) => _product.contains(map['ID'].toString()))
        //       .toList(),
        //   'amount': amount,
        // });
        _selectedProduct.add({
          'items': _listProduct
              .where((map) => _product.toString() == map['ID'].toString())
              .toList(),
          'amount': amount,
        });
        genRows();
      }
    });
  }

  Future<Null> addProductGift() async {
    setState(() {
      if (amountGift == null) {
        amountGift = '1';
      }
      if (_selectedProduct.isNotEmpty &&
          _selectedProduct.any((element) =>
              element['items'][0]['ID'].toString() == _productGift)) {
        var _selectedProductMap = _selectedProduct.asMap();
        _selectedProduct.asMap().forEach((key, value) {
          if (value['items'][0]['ID'].toString() == _productGift) {
            _selectedProductMap[key]['amount'] =
                (int.parse(value['amount']) + int.parse(amountGift)).toString();
          }
        });
        _selectedProduct = _selectedProductMap.values.toList();
        genRows();
      } else {
        // _selectedProduct.add({
        //   'items': _listProductGift
        //       .where((map) => _productGift.contains(map['ID'].toString()))
        //       .toList(),
        //   'amount': amountGift,
        // });
        _selectedProduct.add({
          'items': _listProductGift
              .where((map) => _productGift.toString()==map['ID'].toString())
              .toList(),
          'amount': amountGift,
        });
        genRows();
      }
    });
  }

  Future<Null> getProductCanSell(int userId) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var res = await Sqlite().rawQuery(
        '''SELECT PRODUCT.ID,PRODUCT.Name,PRODUCT.Price_sell,PRODUCT.Price_commission,PRODUCT.Image,PRODUCT.Category_id
        FROM PRODUCT INNER JOIN USER_PRODUCT_CAN_SELL ON PRODUCT.ID = USER_PRODUCT_CAN_SELL.Product_id 
        WHERE PRODUCT.Category_id IN (1,2) AND PRODUCT.Status = 1 AND USER_PRODUCT_CAN_SELL.User_id = "$userId"
        AND USER_PRODUCT_CAN_SELL.Status = 1 ORDER BY Category_id ASC
        ''');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name',
          normalText: "ราคา", price: "Price_sell");
    }).forEach((element) {
      _productData.add(element);
    });
    // res.asMap().forEach((key, value) async {
    //   if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
    //     if (value['Image'] != null && value['Image'] != '') {
    //       print('Image : ' + value['Image']);
    //       final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
    //       File file = File('$appDocPath/product_image_${value['ID']}.png');
    //       var res = await client
    //           .post(url, body: {'path': value['Image']}).then((val) {
    //         file.writeAsBytesSync(val.bodyBytes);
    //       });
    //     }
    //   }
    // });
    _listProduct = res;
    String nowDate = f.DateFormat(DateTime.now());
    res = await Sqlite().rawQuery('''SELECT * FROM PRODUCT
        WHERE Category_id = 3 AND Status = 1 AND End_date > "${nowDate}"
        ORDER BY Category_id
        ''');
    res.map((e) {
      return DropDown().getDropDownWidget(
        e,
        'ID',
        'Name',
      );
    }).forEach((element) {
      _productGiftData.add(element);
    });
    // res.asMap().forEach((key, value) async {
    //   if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
    //     if (value['Image'] != null && value['Image'] != '') {
    //       print('Image : ' + value['Image']);
    //       final url = 'https://thanyakit.com/systemv2/public/api/downloadImage';
    //       File file = File('$appDocPath/product_image_${value['ID']}.png');
    //       var res = await client
    //           .post(url, body: {'path': value['Image']}).then((val) {
    //         file.writeAsBytesSync(val.bodyBytes);
    //       });
    //     }
    //   }
    // });
    _listProductGift = res;
    setState(() {});
  }

  Future<Null> getOldCustomer() async {
    var res = await Sqlite().rawQuery('SELECT * FROM CUSTOMER');
    res.map((e) {
      return DropDown()
          .getSearchableDropDown(e, 'Name', 'Surname', 'Name', 'Surname');
    }).forEach((element) {
      _oldCustomer.add(element);
    });
    res.map((e) {
      return OldCustomer(name: e['Name'], surname: e['Surname']);
    }).forEach((element) {
      _oldCustomerTest.add(element);
    });
    _customerList = res;
    setState(() {});
  }

  Future<Null> getProvince() async {
    var res = await Sqlite().rawQuery(
        'SELECT PROVINCE_ID,PROVINCE_NAME FROM PROVINCE ORDER BY PROVINCE_NAME');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'PROVINCE_ID', 'PROVINCE_NAME');
    }).forEach((element) {
      _provinceData.add(element);
    });
    // res.map((e) {
    //   return SearchLand(
    //       value: e['PROVINCE_ID'].toString(), text: e['PROVINCE_NAME']);
    // }).forEach((element) {
    //   _provinceData.add(element);
    // });
    setState(() {});
  }

  Future<bool> getDistrict(var provinceId) async {
    _district = await null;
    _subDistrict = await null;
    _districtData = [];
    _subDistrictData = [];
    var res = await Sqlite().rawQuery(
        'SELECT AMPHUR_ID,AMPHUR_NAME FROM AMPHUR WHERE PROVINCE_ID = $provinceId');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'AMPHUR_ID', 'AMPHUR_NAME');
    }).forEach((element) {
      _districtData.add(element);
    });
    // res.map((e) {
    //   return SearchLand(
    //       value: e['AMPHUR_ID'].toString(), text: e['AMPHUR_NAME']);
    // }).forEach((element) {
    //   _districtData.add(element);
    // });
    setState(() {});
    return true;
  }

  Future<bool> getSubDistrict(var districtId) async {
    _subDistrict = await null;
    _subDistrictData = [];
    _zipcode.clear();
    var res = await Sqlite().rawQuery(
        'SELECT DISTRICT_ID,DISTRICT_NAME,ZIP_CODE FROM DISTRICT WHERE AMPHUR_ID = $districtId');
    tmpSubDistrict = res;
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'DISTRICT_ID', 'DISTRICT_NAME');
    }).forEach((element) {
      _subDistrictData.add(element);
    });
    // res.map((e) {
    //   return SearchLand(
    //       value: e['DISTRICT_ID'].toString(), text: e['DISTRICT_NAME']);
    // }).forEach((element) {
    //   _subDistrictData.add(element);
    // });
    setState(() {});
    return true;
  }

  Future<Null> getUser() async {
    var res = await Sqlite()
        .query('USER', firstRow: true, where: 'ID = ${widget.userId}');
    setState(() {
      _user = res;
    });
  }

  Future<Null> addProductFromBill(String orderDetail) async {
    List orderDetails = jsonDecode(orderDetail);
    orderDetails.forEach((order) {
      // print(order['product_id']);
      if (order['cat_id'] == 3) {
        //ของแถม
        amountGift = order['qty'].toString();
        _productGift = order['product_id'].toString();
        addProductGift();
      } else {
        amount = order['qty'].toString();
        _product = order['product_id'].toString();
        addProduct();
      }
    });
  }

  Future<Null> getBill() async {
    print('FUNC getBill');
    if (widget.customerId != null) {
      await getCustomerFromTrail();
    }
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (widget.billId != null) {
      String orderDetail;
      var tmp;
      var dataSet;
      if (widget.isBillOnline) {
        if (isConnect) {
          print('get online bill');
          var res = await client.post(
              'https://thanyakit.com/systemv2/public/api/getDocBillOnline',
              body: {'Docbill_id': '${widget.billId}'});
          dataSet = jsonDecode(res.body);
          for (var bill in dataSet) {
            saleUserId = bill['User_id'];
            //customer
            imageIdCard = bill['Image_id_card'];
            imageCustomer = bill['Image'];
            _name.text = bill['Name'];
            _surname.text = bill['Surname'];
            _idcard.text = bill['Id_card'];
            _sex = bill['Sex'].toString();
            var birthday = bill['Birthday'].toString().split('-');
            selectDate = DateTime(int.parse(birthday[0]),
                int.parse(birthday[1]), int.parse(birthday[2]));
            _birthday.text = f.ThaiDateFormat(bill['Birthday']);
            _tel.text = bill['Phone'];
            _customerType = bill['Type_id'].toString();
            _address.text = bill['Address'];
            _province = bill['Province_id'].toString();
            await getDistrict(bill['Province_id'])
                .whenComplete(() => _district = bill['Amphur_id'].toString());
            await getSubDistrict(bill['Amphur_id']).whenComplete(
                () => _subDistrict = bill['District_id'].toString());
            _zipcode.text = bill['Zipcode'];
            //endCustomer
            _location.text = bill['bill_location'];
            _payMethod = bill['Pay_type'];
            if (bill['Image_signature'] != null &&
                bill['Image_signature'] != '') {
              SignatureImage = Image.memory(base64Decode(
                  bill['Image_signature'].toString().split('base64,')[1]));
              reserveDate = bill['Signature_date'];
              hasSign = true;
            }
            if (bill['Pay_type'] == 2) {
              _earnMoney.text = bill['Money_earnest'].toString();
              _dueMoney.text = bill['Money_due'].toString();
              _creditType = bill['Credit_term_id'].toString();
              tmp = bill['Date_due'].toString().split('-');
              _selectDueDate = DateTime(
                  int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
              _dueDate.text = f.ThaiDateFormat(bill['Date_due']);
            }
            tmp = bill['Date_send'].toString().split('-');
            _selectSendDate = DateTime(
                int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
            _sendDate.text = f.ThaiDateFormat(bill['Date_send']);
            orderDetail = await bill['Order_detail'];
            var resImage = await client.post(
                'https://thanyakit.com/systemv2/public/api/test',
                body: {'path': '${bill['Image']}'});
            imageCustomerBase64 = resImage.body;
          }
          setState(() {});
        }
      } else {
        dataSet = await Sqlite().getBillById(widget.billId);
        dataSet.forEach((bill) {
          saleUserId = bill['Bill_user_id'];
          docNumber = bill['Bill_number'];
          _customer = '${bill['Customer_name']} ${bill['Customer_surname']}';
          _location.text = bill['bill_location'];
          _payMethod = bill['Pay_type'];
          orderDetail = bill['Order_detail'];
          print(bill);
          if (bill['Image_signature'] != null &&
              bill['Image_signature'] != '') {
            SignatureImage = Image.memory(base64Decode(
                bill['Image_signature'].toString().split('base64,')[1]));
            reserveDate = bill['Signature_date'];
            hasSign = true;
          }
          if (bill['Pay_type'] == 2) {
            _earnMoney.text = bill['Money_earnest'].toString();
            _dueMoney.text = bill['Money_due'].toString();
            _creditType = bill['Credit_term_id'].toString();
            tmp = bill['Date_due'].toString().split('-');
            _selectDueDate = DateTime(
                int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
            _dueDate.text = f.ThaiDateFormat(bill['Date_due']);
          }
          tmp = bill['Date_send'].toString().split('-');
          _selectSendDate =
              DateTime(int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
          _sendDate.text = f.ThaiDateFormat(bill['Date_send']);
        });
        await selectCustomer();
        setState(() {});
      }
      await getProductCanSell(
          saleUserId); //เพ่ิมให้ดาวน์โหลดรูปที่หน้า dashboard sale แล้ว
      await addProductFromBill(orderDetail);
    } else {
      await getProductCanSell(
          widget.userId); //เพ่ิมให้ดาวน์โหลดรูปที่หน้า dashboard sale แล้ว
    }
  }

  Future<Null> getCustomerType() async {
    var res = await Sqlite().rawQuery('SELECT * FROM CUSTOMER_TYPE');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name');
    }).forEach((element) {
      _customerTypeData.add(element);
    });
    setState(() {});
  }

  Future<Null> SubmitAll() async {
    double percentage = 0.0;
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: true);

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

    pr.show();

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

    percentage = percentage + 30.0;
    pr.update(progress: percentage, message: "ส่งข้อมูล...");

    if (!_location.text.startsWith('L')) {
      await getCurrPosition();
    }
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    DateTime now = DateTime.now();
    if (docNumber == '') {
      docNumber =
          ('B${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}');
    }
    Map<String, dynamic> bill = {};
    bill['user'] = _user;
    if (widget.billId != null) {
      bill['Bill_id'] = '${widget.billId}'; //Primary
    } else {
      bill['Bill_id'] = ''; //Primary
    }
    bill['DocNumber'] = docNumber;
    bill['Customer_name'] = _name.text;
    bill['Customer_surname'] = _surname.text;
    bill['Customer_sex'] = _sex;
    bill['Customer_id_card'] = _idcard.text;
    bill['Customer_phone'] = _tel.text;
    bill['Customer_address'] = _address.text;
    bill['Customer_province_id'] = _province;
    bill['Customer_amphur_id'] = _district;
    bill['Customer_district_id'] = _subDistrict;
    bill['Customer_zipcode'] = _zipcode.text;
    bill['Customer_type'] = _customerType;
    bill['Customer_birthday'] = f.DateFormat(selectDate); //date only
    bill['bill_location'] = _location.text;

    bill['Pay_type'] = _payMethod;
    bill['Commission_sum'] = totalCommission;

    bill['Money_due'] = _dueMoney.text;
    bill['Money_earnest'] = _earnMoney.text;
    bill['Credit_term_id'] = _creditType;
    bill['Date_due'] = f.DateFormat(_selectDueDate);

    bill['Date_send'] = f.DateFormat(_selectSendDate); //date only
    bill['Money_total'] = sumMoney;

    bill['Table_data'] = jsonEncode(_orderDetail);

    if (SignatureBase64 != null) {
      bill['Images_sign'] = 'data:image/png;base64,$SignatureBase64';
      bill['Signature_date'] = f.DateTimeFormat(SignatureDate);
    }

    bill['User_id'] = widget.userId;
    bill['Edit_user_id'] = widget.userId;

    File ImageCustomer;
    File ImageIdCard;
    if (_tmpImage != null) {
      ImageCustomer =
          await _image.copy('$appDocPath/image_customer_$docNumber.jpeg');
      ImageIdCard =
          await _tmpImage.copy('$appDocPath/image_id_card_$docNumber.jpeg');
      bill['Image_id_card'] = ImageIdCard.path; //xxxxxx
      bill['Image_customer'] = ImageCustomer.path; //xxxxxx
    } else {
      bill['Image_id_card'] = imageIdCard;
      bill['Image_customer'] = imageCustomer;
    }

    bill['edit_status'] = widget.editStatus;

    // print('edit status : ${widget.editStatus}');

    percentage = percentage + 30.0;
    pr.update(progress: percentage, message: "ส่งข้อมูล...");

    await Sqlite().billRecord(bill).then((val) {
        Future.delayed(Duration(seconds: 2)).then((value) {
          pr.update(progress: percentage, message: 'ส่งข้อมูลสำเร็จ...');
          // Future.delayed(Duration(seconds: 2)).then((value) {
            pr.hide().then((value) {
              Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);
            // });
          });
        });

    });
  }

  getConditionCredit() async {
    print('getConditionCredit');
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1, now.day);
    var selectedMonth =
        '${previousMonth.toString().split('-')[0]}/${previousMonth.toString().split('-')[1]}';
    var res = await Sqlite()
        .getJson('CEO_CREDIT_REPORT_CAR_SALE_${widget.userId}', selectedMonth);
    if (res != null) {
      reportCreditPrevious = jsonDecode(res['JSON_VALUE']);
    } else {
      reportCreditPrevious = [];
    }
    var resConditionCredit = await Sqlite()
        .rawQuery('''SELECT * FROM CONDITION_OPEN_BILL_CREDIT ''');
    if (resConditionCredit != null) {
      conditionCredit = resConditionCredit;
    } else {
      conditionCredit = [];
    }
    var resSaleData =
        await Sqlite().rawQuery('SELECT * FROM USER WHERE ID=${widget.userId}');
    if (resSaleData != null) {
      saleData = resSaleData;
    } else {
      saleData = [];
    }
    checkConditionCredit();
  }

  checkConditionCredit() async {
    if (conditionCredit.length > 0) {
      print("เช็คเงื่อนไข เครดิต");
      String workDateStart = saleData[0]['Work_date_start'];
      DateTime toDay = DateTime.now();
      DateTime saleWorkDateStart = DateTime.parse(workDateStart);
      int workTimeDay = toDay.difference(saleWorkDateStart).inDays;
      print('workTimeDay ${workTimeDay}');

      _percentCreditPrevious = 0;

      if (reportCreditPrevious.length > 0) {
        //คำนวนว่าเก็บได้กี่เปอร์เซ็นต์
        int sum_money_total = 0;
        int sum_money_paysuccess = 0;
        reportCreditPrevious.forEach((ele) {
          sum_money_total += (ele['bill_data']['Money_total'] -
              ele['bill_data']['Money_earnest']);
          if (ele['bill_data']['Status'] == 7 ||
              ele['bill_data']['Status'] == 10 ||
              ele['bill_data']['Status'] == 12 ||
              ele['bill_data']['Status'] == 15) {
            sum_money_paysuccess += (ele['bill_data']['Money_total'] -
                ele['bill_data']['Money_earnest']);
          }
        });
        _percentCreditPrevious =
            ((sum_money_paysuccess / sum_money_total) * 100).toInt();
      }
      print('_percentCreditPrevious ${_percentCreditPrevious}');
      for (var ele in conditionCredit) {
        if (workTimeDay < ele['Work_day_limit']) {
          //เช็คเงื่อนไขวัน
          _earnestFixedBath = ele['Fixed_earnest'];
          if (reportCreditPrevious.length > 0 && ele['Have_bill'] == 1) {
            //เช็คเงื่อนไขเดือนที่แล้วมีบิลเก็บไหมถ้ามี
            if (_percentCreditPrevious >= ele['Rate_start'] &&
                _percentCreditPrevious <= ele['Rate_end']) {
              _earnestFixedBath = ele['Fixed_earnest'];
              break;
            }
          }
          if (reportCreditPrevious.length == 0 && ele['Have_bill'] == 0) {
            //เดือนที่แล้วไม่มีบิลเก็บ
            _earnestFixedBath = ele['Fixed_earnest'];
            break;
          }
        }
      }

      print('_earnestFixedBath ${_earnestFixedBath}');
    }
  }

  bool checkEarnestCondition() {
    print('_earnMoney ${_earnMoney.text}');
    //เช็คว่าต้องเก็บเงินมัดจำเท่าไหร่
    double earnMoney = double.parse(_earnMoney.text);
    int sumCat1 = 0;
    _orderDetail.forEach((ele) {
      if (ele['cat_id'] == 1) {
        sumCat1 += ele['qty'];
      }
    });
    // เงินมัดจำที่ใส่ในช่องต้องมากกว่าเงินมัดจำที่บังคับเก็บ
    int moneyFixedBath = (sumCat1 * _earnestFixedBath);
    if (_earnestFixedBath == -1) {
      alert(
        context,
        title: Text(
          'เครดิตเดือนที่แล้วเก็บได้ ${_percentCreditPrevious} %',
          style: TextStyle(fontSize: 20),
        ),
        content: Text(
          'ระบบไม่อนุญาติให้ขายเครดิต',
          style: TextStyle(fontSize: 18),
        ),
      );
      return false;
    } else if (earnMoney >= moneyFixedBath) {
      return true;
    } else {
      alert(
        context,
        title: Text(
          'เครดิตเดือนที่แล้วเก็บได้ ${_percentCreditPrevious} %',
          style: TextStyle(fontSize: 20),
        ),
        content: Text(
          'คุณต้องใส่ช่องเงินมัดจำลูกค้าขั้นต่ำจำนวน ${f.SeperateNumber(moneyFixedBath)} บาท',
          style: TextStyle(fontSize: 18),
        ),
      );
      return false;
    }
  }

  @override
  void initState() {
    // print('USER ID : ${widget.userId}');
    _provinceData = [];
    _districtData = [];
    _subDistrictData = [];
    _productData = [];
    _productGiftData = [];
    _customerTypeData = [];
    _oldCustomer = [];
    getConditionCredit();
    getUser();
    getProvince();
    getCustomerType();
    getCurrPosition();
    getOldCustomer();
    getBill();



    myFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _birthday.dispose();
    _dueDate.dispose();
    _sendDate.dispose();
    _idcard.dispose();
    _tel.dispose();
    _zipcode.dispose();
    _location.dispose();
    _dueMoney.dispose();
    _earnMoney.dispose();
    _address.dispose();
    client.close();
    cloudDocumentTextRecognizer.close();
    // if (_timer != null) {
    //   _timer.cancel();
    // }
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: WillPopScope(
        onWillPop: _onBackPressed,
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
                body: GestureDetector(
                  onTap: () {
                    print('unfocus');
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    width: double.infinity,
                    height: size.height,
                    child: SingleChildScrollView(
                        child: Form(
                      key: _formKey,
                      // autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // FlatButton(
                                //     onPressed: () async {
                                //       _customer = 'อนุชิต คังดงเค็ง';
                                //       await selectCustomer();
                                //       _product = '69';
                                //       amount = '10';
                                //       await addProduct();
                                //       _selectSendDate = DateTime.now();
                                //       _sendDate.text = f.ThaiFormat(
                                //           DateTime.now().toString().split(' ')[0]);
                                //       setState(() {});
                                //     },
                                //     child: Text('MOCK CASH')),
                                // FlatButton(
                                //     onPressed: () async {
                                //       _customer = 'อนุชิต คังดงเค็ง';
                                //       await selectCustomer();
                                //       _product = '69';
                                //       amount = '20';
                                //       await addProduct();
                                //       _selectSendDate = DateTime.now();
                                //       _sendDate.text = f.ThaiFormat(
                                //           DateTime.now().toString().split(' ')[0]);
                                //       _payMethod = 2;
                                //       _selectDueDate = DateTime.now();
                                //       _creditType = '77';
                                //       _dueDate.text = f.ThaiFormat(
                                //           DateTime.now().toString().split(' ')[0]);
                                //       _earnMoney.text = '2000';
                                //       _dueMoney.text = '9800';
                                //       setState(() {});
                                //     },
                                //     child: Text('MOCK CREDIT')),
                                // FlatButton(
                                //     onPressed: () async {
                                //       //await readTextList(textList);
                                //       // _orderDetail = [];
                                //       // print(_orderDetail != null && _orderDetail.isNotEmpty);
                                //     },
                                //     child: Text('READ TEXT LIST')),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: kPrimaryColor,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            FontAwesomeIcons.edit,
                                            color: btTextColor,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'สร้างใบสั่งจองสินค้า',
                                              style: TextStyle(
                                                  fontSize: 24.0, height: 1),
                                            ),
                                            Text(
                                              'กรอกข้อมูลให้ครบถ้วนเพื่อการคิดค่าคอมที่ถูกต้อง',
                                              style: TextStyle(
                                                  fontSize: 16.0, height: 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                CustomerInfo(context, size, node),

                                if (widget.editStatus == 1 ||
                                    widget.editStatus == 0)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: AddProduct(size, node)),
                                      Expanded(
                                          flex: 1,
                                          child: AddProductGift(size, node))
                                      // AddProductGift(size, node),
                                    ],
                                  ),
                                ProductRequire(),
                                PayMethod(context, node),
                                ConfirmOrder(size, context),
                                Visibility(
                                  visible: widget.editStatus == 1 ||
                                      widget.editStatus == 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomButton(
                                        onPress: () async {
                                          if (_formKey.currentState
                                                  .validate() &&
                                              _orderDetail != null &&
                                              _orderDetail.isNotEmpty) {
                                            print('_payMethod ${_payMethod}');
                                            print('_creditType ${_creditType}');
                                            if (_payMethod == 2 &&
                                                _creditType != '77') {
                                              //เช็คเงินมัดจำก่อน
                                              // print('checkEarnestCondition ${checkEarnestCondition()}');
                                              if (checkEarnestCondition()) {
                                                await SubmitAll();
                                              }
                                            } else {
                                              await SubmitAll();
                                            }
                                          } else {
                                            alert(context,
                                                title: Text('แจ้งเตือน !!!'),
                                                content: Text(
                                                  'กรอกข้อมูลให้ครบถ้วน\nแล้วค่อยกดบันทึกอีกครั้งนะครับ',
                                                  textAlign: TextAlign.center,
                                                ));
                                          }
                                        },
                                        text: 'บันทึก',
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      CustomButton(
                                        onPress: () {
                                          Navigator.of(context).pop();
                                        },
                                        text: 'ยกเลิก',
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                    visible: widget.editStatus != 1 &&
                                        widget.editStatus != 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomButton(
                                          onPress: () {
                                            Navigator.of(context).pop();
                                          },
                                          text: 'กลับ',
                                        )
                                      ],
                                    )),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          Footer(),
                        ],
                      ),
                    )),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  FormCard CustomerInfo(BuildContext context, Size size, FocusScopeNode node) {
    return FormCard(
      title: 'ข้อมูลลูกค้า',
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1) อัพโหลดรูปบัตรประชาชนเข้ามาที่นี่ ระบบจะทำการอ่านชื่อ เลขที่บัตร โดยอัตโนมัติให้ (ถ้าลูกค้าไม่ได้นำบัตรประชาชนมาไม่ต้องอัพโหลด)',
              style: TextStyle(fontSize: 21),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: GestureDetector(
                  onTap: () {
                    if (widget.editStatus == 0 || widget.editStatus == 1) {
                      _showPicker(context);
                    }
                  },
                  child: _image != null || imageCustomerBase64 != ''
                      ? Stack(children: <Widget>[
                          SizedBox(
                            width: size.width * 0.8,
                          ),
                          _image != null
                              ? Container(
                                  width: size.width * 0.7,
                                  height: 200,
                                  child: Image.file(
                                    _image,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: size.width * 0.7,
                                  height: 200,
                                  child: Image.memory(
                                    base64Decode(imageCustomerBase64),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Positioned(
                            child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.times,
                                ),
                                onPressed: _clearImage),
                            top: 0,
                            right: 0,
                          ),
                          Positioned(
                            child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.cropAlt,
                                  color: darkColor,
                                ),
                                onPressed: _cropImage),
                            bottom: 0,
                            right: 0,
                          )
                        ])
                      : Container(
                          width: size.width * 0.7,
                          height: 200,
                          color: Color(0xFFFFFFFF),
                          child: Center(
                              child: Text('คลิ๊กอัพโหลดรูปบัตรประชาชนที่นี่')),
                        )),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '2) ใส่ข้อมูลลูกค้าให้ครบทุกช่องดังนี้',
              style: TextStyle(fontSize: 21),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('ลูกค้าเก่า',style: TextStyle(fontSize: 18,height: 1),),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.0, color: Colors.grey)),
                              child: SearchableDropdown.single(
                                  items: _oldCustomer,
                                  value: _customer,
                                  hint: 'ลูกค้าเก่า',
                                  isExpanded: true,
                                  searchHint: 'ค้นหา',
                                  onChanged: (val) {
                                    setState(() {
                                      print(val);
                                      _customer = val;
                                    });
                                  }),
                            ),
                            //     Container(
                            //   padding: const EdgeInsets.only(
                            //       top: 10, right: 10, bottom: 10),
                            //   child: DropdownSearch<OldCustomer>(
                            //     items: _oldCustomerTest,
                            //     maxHeight: 300,
                            //     label: 'ลูกค้าเก่า',
                            //     mode: Mode.BOTTOM_SHEET,
                            //     dropdownSearchDecoration: InputDecoration(
                            //         enabledBorder: const OutlineInputBorder(
                            //           borderSide: const BorderSide(
                            //               color: Colors.grey, width: 0.0),
                            //         ),
                            //         border: OutlineInputBorder(
                            //             borderRadius: BorderRadius.circular(5)),
                            //         contentPadding: EdgeInsets.fromLTRB(
                            //             10.0, 0.0, 10.0, 0.0),
                            //         filled: true,
                            //         fillColor: Colors.white),
                            //     // validator: (val) => val == null ? '' : null,
                            //     onChanged: (value) {
                            //       print('DropdownSearch');
                            //       print(value);
                            //     },
                            //     showSearchBox: true,
                            //   ),
                            // ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: CustomButton(
                              onPress: selectCustomer,
                              text: 'ดึงข้อมูลลูกค้าเก่า',
                              textColor: btTextColor,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  visible: widget.editStatus == 0,
                ),
                // Text('ชื่อลูกค้า',style: TextStyle(fontSize: 18,height: 1),),
                SquareInput(
                  hintText: 'ชื่อลูกค้า',
                  labelText: 'ชื่อลูกค้า',
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: _name,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                  // autofocus: true,
                ),
                // Text('นามสกุล'),
                SquareInput(
                  hintText: 'นามสกุลลูกค้า',
                  labelText: 'นามสกุลลูกค้า',
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: _surname,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                ),
                // Text('เลขบัตรประจำตัวประชาชน'),
                SquareInput(
                  hintText: 'เลขบัตรประจำตัวประชาชน',
                  labelText: 'เลขบัตรประจำตัวประชาชน',
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  textController: _idcard,
                  inputType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                  validate: (val) {
                    // if (widget.billId != null) {
                    //   if (val == null ||
                    //       val.toString().length < 13 ||
                    //       !f.isNumeric(val)) {
                    //     return '';
                    //   }
                    // }
                    // return null;
                  },
                ),
                // Text('เพศ'),
                IgnorePointer(
                  ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                  child: DropDown(
                    items: {'1': 'ชาย', '2': 'หญิง', '0': 'เลือกเพศ'}
                        .map((i, v) {
                          return MapEntry(
                              i,
                              DropdownMenuItem(
                                value: i,
                                child: Text(v),
                              ));
                        })
                        .values
                        .toList(),
                    hintText: 'เลือกเพศ',
                    value: _sex,
                    onTap: () => node.unfocus(),
                    onChange: (val) {
                      setState(() {
                        _sex = val;
                        print(val);
                      });
                    },
                    validator: (val) => val == null ? '' : null,
                  ),
                ),
                // Text('วันเดือนปีเกิด'),
                GestureDetector(
                    onTap: () {
                      if (widget.editStatus == 1 || widget.editStatus == 0) {
                        _showDatePicker(context);
                      }
                    },
                    child: AbsorbPointer(
                      child: SquareInput(
                        hintText: 'วันเกิดลูกค้า',
                        labelText: 'วันเกิดลูกค้า',
                        textController: _birthday,
                        validate: (val) => val.isEmpty ? '' : null,
                      ),
                    )),
                // Text('เบอร์โทรลูกค้า'),
                SquareInput(
                  hintText: 'เบอร์โทรลูกค้า',
                  labelText: 'เบอร์โทรลูกค้า',
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  textController: _tel,
                  //onFieldSubmitted: (val) => node.unfocus(),
                  textInputAction: TextInputAction.next,
                  inputType: TextInputType.number,
                  onEditingComplete: () => node.nextFocus(),
                  // validate: (val) {
                  //   if (val == null ||
                  //       val.toString().length < 9 ||
                  //       !f.isNumeric(val)) {
                  //     return '';
                  //   }
                  //   return null;
                  // },
                ),
                // Text('ประเภท'),
                IgnorePointer(
                  ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                  child: DropDown(
                    items: _customerTypeData,
                    hintText: 'เลือกประเภทลูกค้า',
                    value: _customerType,
                    onTap: () => node.unfocus(),
                    onChange: (val) {
                      setState(() {
                        _customerType = val;
                      });
                    },
                    validator: (val) => val == null ? '' : null,
                  ),
                ),
                // Text('ที่อยู่ลูกค้า'),
                SquareInput(
                  hintText: 'ที่อยู่ลูกค้า',
                  labelText: 'ที่อยู่ลูกค้า',
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  textController: _address,
                  validate: (val) => val.isEmpty ? '' : null,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => node.nextFocus(),
                ),
                // Text('จังหวัด'),
                IgnorePointer(
                  ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                  child: DropDown(
                    items: _provinceData,
                    hintText: 'เลือกจังหวัดลูกค้า',
                    onTap: () => node.unfocus(),
                    value: _province,
                    onChange: (val) {
                      setState(() {
                        _province = val;
                        print(val);
                        getDistrict(val);
                      });
                    },
                    validator: (val) => val == null ? '' : null,
                  ),
                ),
                // IgnorePointer(
                //   ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                //   child: Container(
                //     padding:
                //         const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                //     child: DropdownSearch<SearchLand>(
                //       items: _provinceData,
                //       maxHeight: 300,
                //       label: 'เลือกจังหวัด',
                //       dropdownSearchDecoration: InputDecoration(
                //           enabledBorder: const OutlineInputBorder(
                //             borderSide: const BorderSide(
                //                 color: Colors.grey, width: 0.0),
                //           ),
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5)),
                //           contentPadding:
                //               EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                //           filled: true,
                //           fillColor: Colors.white),
                //       validator: (val) => val == null ? '' : null,
                //       onChanged: (value) {
                //         _province = value.value;
                //         getDistrict(value.value);
                //       },
                //       showSearchBox: true,
                //     ),
                //   ),
                // ),
                if (_districtData.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('อำเภอ'),
                      // IgnorePointer(
                      //   ignoring:
                      //       widget.editStatus != 1 && widget.editStatus != 0,
                      //   child: Container(
                      //     padding: const EdgeInsets.only(
                      //         top: 10, right: 10, bottom: 10),
                      //     child: DropdownSearch<SearchLand>(
                      //       items: _districtData,
                      //       maxHeight: 300,
                      //       label: 'เลือกอำเภอ',
                      //       dropdownSearchDecoration: InputDecoration(
                      //           enabledBorder: const OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: Colors.grey, width: 0.0),
                      //           ),
                      //           border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(5)),
                      //           contentPadding:
                      //               EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      //           filled: true,
                      //           fillColor: Colors.white),
                      //       validator: (val) => val == null ? '' : null,
                      //       onChanged: (value) {
                      //         _district = value.value;
                      //         getSubDistrict(value.value);
                      //       },
                      //       showSearchBox: true,
                      //     ),
                      //   ),
                      // ),
                      IgnorePointer(
                        ignoring:
                            widget.editStatus != 1 && widget.editStatus != 0,
                        child: DropDown(
                          items: _districtData,
                          hintText: 'เลือกอำเภอ',
                          onTap: () => node.unfocus(),
                          value: _district,
                          onChange: (val) {
                            setState(() {
                              _district = val;
                              print(val);
                              getSubDistrict(val);
                            });
                          },
                          validator: (val) => val == null ? '' : null,
                        ),
                      ),
                    ],
                  ),
                if (_subDistrictData.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('ตำบล'),
                      // IgnorePointer(
                      //   ignoring:
                      //       widget.editStatus != 1 && widget.editStatus != 0,
                      //   child: Container(
                      //     padding: const EdgeInsets.only(
                      //         top: 10, right: 10, bottom: 10),
                      //     child: DropdownSearch<SearchLand>(
                      //       items: _subDistrictData,
                      //       maxHeight: 300,
                      //       label: 'เลือกตำบล',
                      //       dropdownSearchDecoration: InputDecoration(
                      //           enabledBorder: const OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: Colors.grey, width: 0.0),
                      //           ),
                      //           border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(5)),
                      //           contentPadding:
                      //               EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      //           filled: true,
                      //           fillColor: Colors.white),
                      //       validator: (val) => val == null ? '' : null,
                      //       onChanged: (value) {
                      //         _subDistrict = value.value;
                      //       },
                      //       showSearchBox: true,
                      //     ),
                      //   ),
                      // ),
                      IgnorePointer(
                        ignoring:
                            widget.editStatus != 1 && widget.editStatus != 0,
                        child: DropDown(
                          items: _subDistrictData,
                          hintText: 'เลือกตำบล',
                          value: _subDistrict,
                          onTap: () => node.unfocus(),
                          onChange: (val) {
                            setState(() {
                              _subDistrict = val;
                              var tmp = tmpSubDistrict.firstWhere((element) =>
                                  element['DISTRICT_ID'].toString() == val);
                              _zipcode.text = tmp['ZIP_CODE'].toString();
                              // print(tmpSubDistrict.firstWhere(
                              //     (element) => element['DISTRICT_ID'] == val));
                            });
                          },
                          validator: (val) => val == null ? '' : null,
                        ),
                      ),
                    ],
                  ),
                // Text('รหัสไปรษณีย์'),
                SquareInput(
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  hintText: 'รหัสไปรษณีย์',
                  labelText: 'รหัสไปรษณีย์',
                  textController: _zipcode,
                  onFieldSubmitted: (val) => node.unfocus(),
                  validate: (val) => val.isEmpty ? '' : null,
                ),

                SquareInput(
                  enable: widget.editStatus == 1 || widget.editStatus == 0,
                  hintText: 'โลเคชั่นลูกค้า',
                  labelText: 'โลเคชั่นลูกค้า',
                  // onFieldSubmitted: (val) => node.unfocus(),
                  textController: _location,
                  // validate: (val) => val.isEmpty ? '' : null,
                ),
                Text(
                    '*โลเคชั่นลูกค้า (ระบบดึงอัตโนมัติ รบกวนเปิด GPS ไว้ด้วยขณะสร้างใบสั่งจองสินค้า)'),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  FormCard ProductRequire() {
    return FormCard(
      title: 'สรุปรายการสินค้าที่ลูกค้าต้องการสั่งจอง',
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: (_selectedProduct.isNotEmpty)
              ? rowsWidget
              : [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text('ยังไม่ได้เลือกรายการสินค้า'),
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );

    // return FormCard(
    //   title: 'สรุปรายการสินค้าที่ลูกค้าต้องการสั่งจอง',
    //   child: Padding(
    //     padding: const EdgeInsets.only(left: 16.0, top: 8.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         (_selectedProduct.isNotEmpty)?
    //           SingleChildScrollView(
    //             scrollDirection: Axis.vertical,
    //             child: SingleChildScrollView(
    //                 scrollDirection: Axis.horizontal,
    //                 child: DataTable(
    //
    //                   columns: [
    //                     DataColumn(label: Text('#'), numeric: true),
    //                     DataColumn(label: Text('รายการสินค้า')),
    //                     DataColumn(label: Text('จำนวน'), numeric: true),
    //                     DataColumn(label: Text('ราคาต่อหน่วย'), numeric: true),
    //                     DataColumn(label: Text('รวมเป็นเงิน'), numeric: true),
    //                     DataColumn(label: Text('แก้ไข')),
    //                   ],
    //                   rows: rows,
    //                 ),
    //             ),
    //           ):Container(
    //           child: Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Center(
    //               child: Text('ยังไม่ได้เลือกรายการสินค้า'),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  FormCard AddProduct(Size size, FocusScopeNode node) {
    return FormCard(
      title: 'เลือกสินค้า',
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, top: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_product != null)
              Center(
                  child: SizedBox(
                child: ProductImage,
                width: size.width * 0.35,
                height: size.height * 0.2,
              )),
            SizedBox(
              width: 20,
              height: 10,
            ),
            Text('เลือกสินค้า'),
            DropDown(
              items: _productData,
              hintText: '--เลือกสินค้า--',
              value: _product,
              onChange: (val) async {
                if (File(
                        "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png")
                    .existsSync()) {
                  //ProductImage = CachedNetworkImage(imageUrl: null);
                  ProductImage = Image.file(File(
                      "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png"));
                } else {
                  ProductImage = Image.asset('assets/no_image.png');
                }
                setState(() {
                  _product = val;
                });
              },
              validator: (val) => val == null ? '' : null,
            ),
            Text('จำนวน'),
            SquareInput(
              hintText: '1',
              onEditingComplete: () => node.unfocus(),
              inputType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  amount = val;
                });
              },
            ),
            Center(
                child: RaisedButton.icon(
                    color: kPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      addProduct();
                    },
                    icon: Icon(Icons.add),
                    label: Text('เพิ่มสินค้า')))
          ],
        ),
      ),
    );
  }

  FormCard AddProductGift(Size size, FocusScopeNode node) {
    return FormCard(
      title: 'เลือกของแถม',
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_productGift != null)
              Center(
                  child: SizedBox(
                child: ProductGiftImage,
                width: size.width * 0.5,
                height: size.height * 0.2,
              )),
            SizedBox(
              height: 10,
            ),
            Text('เลือกของแถม'),
            DropDown(
              items: _productGiftData,
              hintText: '--เลือกสินค้าแถม--',
              onChange: (val) async {
                if (File(
                        "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png")
                    .existsSync()) {
                  ProductGiftImage = Image.file(File(
                      "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png"));
                } else {
                  ProductGiftImage = Image.asset('assets/no_image.png');
                }
                setState(() {
                  _productGift = val;
                });
              },
            ),
            Text('จำนวน'),
            SquareInput(
              hintText: '1',
              onEditingComplete: () => node.unfocus(),
              inputType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  amountGift = val;
                });
              },
            ),
            Center(
                child: RaisedButton.icon(
                    color: kPrimaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      addProductGift();
                    },
                    icon: Icon(Icons.add),
                    label: Text('เพิ่มของแถม')))
          ],
        ),
      ),
    );
  }

  FormCard PayMethod(BuildContext context, FocusScopeNode node) {
    return FormCard(
      title: 'วิธีการชำระเงิน',
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IgnorePointer(
              ignoring: widget.editStatus != 1 && widget.editStatus != 0,
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('เงินสด'),
                      leading: Radio(
                          value: 1,
                          groupValue: _payMethod,
                          onChanged: (val) {
                            setState(() {
                              _payMethod = val;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('เครดิต'),
                      leading: Radio(
                          value: 2,
                          groupValue: _payMethod,
                          onChanged: (val) {
                            setState(() {
                              _payMethod = val;
                            });
                          }),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _payMethod == 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    ignoring: widget.editStatus != 0 && widget.editStatus != 1,
                    child: DropDown(
                      items: _optionCredit
                          .map((i, v) {
                            return MapEntry(
                                i,
                                DropdownMenuItem(
                                  value: i,
                                  child: Text(v),
                                ));
                          })
                          .values
                          .toList(),
                      hintText: 'เลือกเครดิต',
                      onTap: () => node.unfocus(),
                      value: _creditType,
                      onChange: (val) {
                        setState(() {
                          _creditType = val;
                          var today = new DateTime.now();
                          if (val != '77') {
                            _selectDueDate = today
                                .add(new Duration(days: (30 * int.parse(val))));
                          } else {
                            _selectDueDate = today.add(new Duration(days: 7));
                          }
                          _dueDate.text = f.ThaiFormat(
                              _selectDueDate.toString().split(' ')[0]);

                          // print('เลือกเครดิต');
                          // print(val);
                        });
                      },
                      validator: (val) =>
                          _payMethod == 2 && val == null ? '' : null,
                    ),
                  ),
                  Text('เงินมัดจำ'),
                  SquareInput(
                    hintText: '',
                    enable: widget.editStatus == 1 || widget.editStatus == 0,
                    textController: _earnMoney,
                    inputType: TextInputType.number,
                    onEditingComplete: () => node.unfocus(),
                    validate: (val) =>
                        _payMethod == 2 && val.isEmpty ? '' : null,
                    onChanged: (val) {
                      setState(() {
                        if (val.isNotEmpty) {
                          if (int.parse(val) > sumMoney) {
                            _dueMoney.text = '0';
                          } else {
                            _dueMoney.text =
                                (sumMoney - int.parse(val)).toString();
                          }
                        } else {
                          _dueMoney.text = (sumMoney).toString();
                        }
                      });
                    },
                  ),
                  Text('นัดชำระ'),
                  GestureDetector(
                      onTap: () {
                        if (widget.editStatus == 0 || widget.editStatus == 1) {
                          _showDatePickerDueDate(context);
                          node.unfocus();
                        }
                      },
                      child: AbsorbPointer(
                        child: SquareInput(
                          textController: _dueDate,
                          validate: (val) =>
                              _payMethod == 2 && val.isEmpty ? '' : null,
                        ),
                      )),
                  Text('ค้างชำระ'),
                  SquareInput(
                    hintText: '',
                    enable: widget.editStatus == 1 || widget.editStatus == 0,
                    textController: _dueMoney,
                    inputType: TextInputType.number,
                    onEditingComplete: () => node.unfocus(),
                    validate: (val) =>
                        _payMethod == 2 && val.isEmpty ? '' : null,
                  ),
                ],
              ),
            ),
            Text('วันที่จัดส่ง'),
            GestureDetector(
                onTap: () {
                  if (widget.editStatus == 0 || widget.editStatus == 1) {
                    _showDatePickerSendDate(context);
                    node.unfocus();
                  }
                },
                child: AbsorbPointer(
                  child: SquareInput(
                    textController: _sendDate,
                    validate: (val) => val.isEmpty ? '' : null,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  FormCard ConfirmOrder(Size size, BuildContext context) {
    return FormCard(
      title: 'ยืนยันการจองสินค้า',
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (hasSign)
              SizedBox(
                child: SignatureImage,
                width: size.width * 0.8,
                height: size.height * 0.2,
              ),
            Visibility(
              visible: !hasSign,
              child: CustomButton(
                onPress: () {
                  _showSignature(context);
                },
                text: 'เซ็นยืนยัน',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: reserveDate == '' || reserveDate == null
                    ? Text(
                        'วันที่สั่งจอง ${f.ThaiDateFormat(DateTime.now().toString().split(' ')[0])}')
                    : Text(
                        'วันที่สั่งจอง ${f.ThaiDateFormat(reserveDate.split(' ')[0])}'))
          ],
        ),
      ),
    );
  }
}

class OldCustomer {
  String name;
  String surname;

  OldCustomer({this.name, this.surname});

  @override
  String toString() => '$name $surname';
}
