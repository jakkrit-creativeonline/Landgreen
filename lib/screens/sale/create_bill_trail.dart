import 'dart:convert';
import 'dart:io';
import 'dart:io' as IO;

import 'package:alert_dialog/alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/drop_down.dart';
import 'package:system/components/form_card.dart';
import 'package:system/components/show_sign.dart';
import 'package:system/components/sign_part.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:signature/signature.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CreateBillTrail extends StatefulWidget {
  final int userId;
  final int trailId;
  final int editStatus;

  const CreateBillTrail({
    Key key,
    this.userId,
    this.editStatus,
    this.trailId,
  }) : super(key: key);
  @override
  _CreateBillTrailState createState() => _CreateBillTrailState();
}

class _CreateBillTrailState extends State<CreateBillTrail> {
  final _formKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> _customerTypeData = [];
  List<DropdownMenuItem<String>> _provinceData = [];
  List<DropdownMenuItem<String>> _districtData = [];
  List<DropdownMenuItem<String>> _subDistrictData = [];
  List<DropdownMenuItem<String>> _productData = [];
  // List<SearchLand> _provinceData = [];
  // List<SearchLand> _districtData = [];
  // List<SearchLand> _subDistrictData = [];

  //List<Province> _provinceDataTest = [];
  //Province selectProvince;

  // final _provinceKey = GlobalKey<DropdownSearchState<SearchLand>>();
  // final _districtKey = GlobalKey<DropdownSearchState<SearchLand>>();
  // final _subDistrictKey = GlobalKey<DropdownSearchState<SearchLand>>();

  final picker = ImagePicker();

  File _image;
  File _tmpImage;

  // DateTime selectDate = DateTime.now();
  DateTime selectDate = DateTime.utc(1988);

  var _name = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  var _surname = TextEditingController();
  final FocusNode _surnameFocus = FocusNode();
  var _birthday = TextEditingController();
  var _idcard = TextEditingController();
  var _tel = TextEditingController();
  var _zipcode = TextEditingController();
  var _location = TextEditingController();
  var _address = TextEditingController();

  FormatMethod f = FormatMethod();

  var _sex;

  var _customerType;

  var _district;

  var _subDistrict;

  var _province;

  var amount;

  var _product;

  var client = http.Client();

  var _user;

  var chkImgRcvNet = false;

  String docNumber = '';

  Map productImage = {};

  Widget productImageWidget;

  List _listProduct;

  List _selectedProduct = [];

  List tmpSubDistrict;

  List _orderDetail = [];

  List<File> imageList = [];
  List imageFromOnline = [];

  List<Widget> rowsWidget = [];

  // final DocumentTextRecognizer cloudDocumentTextRecognizer =
  //     FirebaseVision.instance.cloudDocumentTextRecognizer();
  final DocumentTextRecognizer cloudDocumentTextRecognizer =
      FirebaseVision.instance.cloudDocumentTextRecognizer(
          CloudDocumentRecognizerOptions(hintedLanguages: ["en", "th"]));

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

  String customerSign, customerSignDate;
  final SignatureController _customerSign = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<Null> getUser() async {
    var res = await Sqlite()
        .query('USER', firstRow: true, where: 'ID = ${widget.userId}');
    if (mounted)
      setState(() {
        _user = res;
      });
  }

  Future<Null> getPosition() async {
    if (widget.editStatus == 0 || widget.editStatus == null) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _location.text = '${position.latitude},${position.longitude}';
    }
  }

  // Future<Null> getCurrPosition() async {
  //   if (widget.editStatus == 0) {
  //     try {
  //       print('get current location');
  //       Position position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high);
  //       setState(() {
  //         _location.text = position.toString();
  //         print(position);
  //       });
  //     } catch (e) {
  //       bool gotoSetting = await _locationDenied();
  //       if (gotoSetting) {
  //         await Geolocator.openAppSettings();
  //       } else {
  //         Navigator.of(context).pop();
  //       }
  //       print('get location failed');
  //     }
  //   }
  // }

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

  Future<Null> delProduct(var index) async {
    _selectedProduct.removeAt(index);
    await updateOrderDetail();
    setState(() {});
    await genRows();
  }

  Future<Null> addProductFromBill(String orderDetail) async {
    List orderDetails = jsonDecode(orderDetail);

    orderDetails.forEach((order) {
      amount = order['qty'].toString();
      _product = order['product_id'].toString();
      addProduct();
    });
  }

  Future<Null> addProduct() async {
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
      _selectedProduct.add({
        'items': _listProduct
            .where((map) => _product.contains(map['ID'].toString()))
            .toList(),
        'amount': amount,
      });
      genRows();
    }
    await updateOrderDetail();
    setState(() {});
  }

  Future<Null> genRows() async {
    var _pathProduct = (await getApplicationDocumentsDirectory()).path;
    Size size = MediaQuery.of(context).size;
    setState(() {
      var _imageProduct;
      rowsWidget = [];
      int sumQty = 0;
      _selectedProduct.asMap().forEach((i, map) {
        sumQty += int.parse(map['amount']);
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
              Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: _imageProduct,
                    width: size.width * 0.30,
                    height: size.height * 0.12,
                  )),
              Expanded(
                flex: 3,
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
                      ],
                    ),
                    if (widget.editStatus == 0 || widget.editStatus == 1)
                      Positioned(
                        right: 15,
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
      });

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

  Future<Null> updateOrderDetail() {
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
    });
  }

  Future<Null> onProductChange(var val) async {
    if (File(
            "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png")
        .existsSync()) {
      productImageWidget = Image.file(File(
          "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png"));
    } else {
      productImageWidget = Image.asset('assets/no_image.png');
    }
    setState(() {
      _product = val;
    });
  }

  Future<Null> getProduct() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var res =
        await Sqlite().rawQuery('SELECT * FROM PRODUCT WHERE Category_id = 4');
    res
        .map((e) => DropDown().getDropDownWidget(e, 'ID', 'Name'))
        .forEach((element) {
      _productData.add(element);
    });
    res.asMap().forEach((key, value) async {
      if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
        if (value['Image'] != null && value['Image'] != '') {
          print('Image : ' + value['Image']);
          final url = 'https://landgreen.ml/system/public/api/downloadImage';
          File file = File('$appDocPath/product_image_${value['ID']}.png');
          var res = await client
              .post(url, body: {'path': value['Image']}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
          });
        }
      }
    });
    _listProduct = res;
  }

  Future<Null> getProvince() async {
    var res = await Sqlite().rawQuery(
        'SELECT PROVINCE_ID,PROVINCE_NAME FROM PROVINCE ORDER BY PROVINCE_NAME');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'PROVINCE_ID', 'PROVINCE_NAME');
    }).forEach((element) {
      _provinceData.add(element);
    });
    // var result = res.toList();
    // _provinceDataTest =
    //     result.map<Province>((json) => Province.fromJson(json)).toList();

    // res.map((e) {
    //   return SearchLand(
    //       value: e['PROVINCE_ID'].toString(), text: e['PROVINCE_NAME']);
    // }).forEach((element) {
    //   _provinceData.add(element);
    // });
    //print(_provinceData);
    // res.map((e) {
    //   return DropDown().getSearchableDropDownWidget(e, 'PROVINCE_ID', 'PROVINCE_NAME');
    // }).forEach((element) {
    //   _provinceDataTest.add(element);
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

  Future<Null> getCustomerType() async {
    var res = await Sqlite().rawQuery('SELECT * FROM CUSTOMER_TYPE');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name');
    }).forEach((element) {
      _customerTypeData.add(element);
    });
  }

  Future<void> getData() async {
    await getCustomerType();
    await getProvince();
    await getProduct();
    await getPosition();
    await getUser();
    // print('trailId ${widget.trailId}');
    if (widget.trailId != null) {
      await getTrailData();
    }
    if (mounted) setState(() {});
  }

  Future<void> getTrailData() async {
    var dataSet = await Sqlite().getTrailById(widget.trailId);
    // print('getTrailData');
    // print(dataSet);

    dataSet.forEach((data) async {
      docNumber = data['Trial_number'];
      _name.text = data['Name'];
      _surname.text = data['Surname'];
      _idcard.text = data['Id_card'];
      _sex = data['Sex'].toString();

      if (data['Birthday'] != "null" && data['Birthday'] != null) {
        var birthday = data['Birthday'].toString().split('-');
        selectDate = DateTime(int.parse(birthday[0]), int.parse(birthday[1]),
            int.parse(birthday[2]));
        _birthday.text = f.ThaiDateFormat(data['Birthday']);
      }
      _tel.text = data['Phone'];
      _address.text = data['Address'];
      _province = data['Province_id'].toString();

      await getDistrict(data['Province_id'])
          .whenComplete(() => _district = data['Amphur_id'].toString());
      await getSubDistrict(data['Amphur_id'])
          .whenComplete(() => _subDistrict = data['District_id'].toString());
      _zipcode.text = data['Zipcode'];
      if (data['Image'] != null && data['Image'] != 'null') {
        _image = File(data['Image']);
      }

      var objImage_receive = jsonDecode(data['Image_receive']);
      print("------------------");

      objImage_receive.forEach((item) {
        if (item.toString().split('sales_trail/').length > 1) {
          chkImgRcvNet = true;
        }
        imageFromOnline.add(item);
        imageList.add(File(item));
      });
      // print(data['Image_signature']);
      if (data['Image_signature'] != null &&
          data['Image_signature'] != 'null') {
        var tmpSplitFromOnline =
            data['Image_signature'].toString().split("data:image/png;base64,");
        if (tmpSplitFromOnline.length > 1) {
          customerSign = tmpSplitFromOnline[1].toString();
        } else {
          customerSign = data['Image_signature'];
        }

      }
      _customerType = data['Type_id'].toString();

      String orderDetail = data['Order_detail'];
      await addProductFromBill(orderDetail);
    });
  }

  // Future<Null> getCustomerFromTrail() async {
  //   var res = await Sqlite()
  //       .rawQuery('SELECT * FROM CUSTOMER WHERE ID = ${widget.customerId}');
  //   res.forEach((val) async {
  //     imageIdCard = val['Image_id_card'];
  //     imageCustomer = val['Image'];
  //     _name.text = val['Name'];
  //     _surname.text = val['Surname'];
  //     _idcard.text = val['Id_card'];
  //     _sex = val['Sex'].toString();
  //     selectDate = DateTime.parse(val['Birthday']);
  //     _birthday.text = f.ThaiDateFormat(val['Birthday']);
  //     _tel.text = val['Phone'];
  //     _customerType = val['Type_id'].toString();
  //     _address.text = val['Address'];
  //     _province = val['Province_id'].toString();
  //     await getDistrict(val['Province_id'])
  //         .whenComplete(() => _district = val['Amphur_id'].toString());
  //     await getSubDistrict(val['Amphur_id'])
  //         .whenComplete(() => _subDistrict = val['District_id'].toString());
  //     _zipcode.text = val['Zipcode'];
  //     _image = File(val['Image']);
  //     setState(() {});
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    getData();

    // selectProvince = Province();
    // selectProvince = new Province();
    // selectProvince.pROVINCEID = 28;
    // selectProvince.pROVINCEID = 28;
    // selectProvince.speak();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _name.dispose();
    // _surname.dispose();
    // _birthday.dispose();
    // _idcard.dispose();
    // _tel.dispose();
    // _zipcode.dispose();
    // _location.dispose();
    // _address.dispose();
    cloudDocumentTextRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
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
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.ac_unit),
            //   onPressed: () async {
            //     //Set ค่า DropdownSearch
            //     //await readTextList(textMap);
            //     // SearchLand select =
            //     //     _provinceData.firstWhere((element) => element.value == '28');
            //     // _provinceKey.currentState.changeSelectedItem(select);
            //     // setState(() {});
            //   },
            // ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Container(
                width: size.width,
                height: size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18, right: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ShimmerLoading(type: 'colorgold',),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Center(
                                //       child: Text(
                                //     'ใบบันทึกลูกค้ารับสินค้าทดลอง',
                                //     style: TextStyle(fontSize: 24.0),
                                //   )),
                                // ),
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
                                            FontAwesomeIcons.tasks,
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
                                              'ใบบันทึกลูกค้ารับสินค้าทดลอง',
                                              style: TextStyle(
                                                  fontSize: 24.0, height: 1),
                                            ),
                                            Text(
                                              'กรอกข้อมูลให้ครบถ้วนเพื่อเวลาสร้างใบสั่งจองจะได้ใช้ข้อมูลลูกค้าได้เลย',
                                              style: TextStyle(
                                                  fontSize: 16.0, height: 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                customerInfo(node),
                                if (widget.editStatus == 0) pickProduct(size),
                                selectedProduct(),
                                imageCustomer(size),
                                confirmOrder(size, context),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.editStatus == 0)
                                      CustomButton(
                                        onPress: () async {
                                          if (_formKey.currentState
                                                  .validate() &&
                                              _orderDetail != null &&
                                              _orderDetail.isNotEmpty) {
                                            await submitAll(context);
                                          } else {
                                            alert(
                                              context,
                                              title: Text('แจ้งเตือน !!!'),
                                              content: Text(
                                                  'ช่วยกรอกข้อมูลให้ครบหน่อยนะค่ะ'),
                                              textOK: Text('ok'),
                                            );
                                            // Widget okButton = FlatButton(
                                            //   child: Text("ok"),
                                            //   onPressed:  () {},
                                            // );
                                            // AlertDialog(
                                            //   title: Text("! แจ้งเตือน"),
                                            //   content: Text("ช่วยกรอกข้อมูลให้ครบหน่อยนะค่ะ"),
                                            //   actions: [
                                            //     okButton,
                                            //   ],
                                            // );
                                          }
                                        },
                                        text: 'บันทึก',
                                      ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    CustomButton(
                                      text: 'กลับ',
                                      onPress: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Footer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> submitAll(context) async {
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
      await getPosition();
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    DateTime now = DateTime.now();
    if (docNumber == '') {
      docNumber =
          ('T${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}');
    }
//show loading
    Map<String, dynamic> trail = {};
    trail['DocNumber'] = docNumber;
    trail['User_id'] = widget.userId;
    trail['Edit_user_id'] = widget.userId;

    trail['Order_detail'] = jsonEncode(_orderDetail);

    trail['Customer_name'] = _name.text;
    trail['Customer_surname'] = _surname.text;
    trail['Customer_sex'] = _sex;
    trail['Customer_id_card'] = _idcard.text;
    trail['Customer_phone'] = _tel.text;
    trail['Customer_address'] = _address.text;
    trail['Customer_province_id'] = _province;
    trail['Customer_amphur_id'] = _district;
    trail['Customer_district_id'] = _subDistrict;
    trail['Customer_zipcode'] = _zipcode.text;
    trail['Customer_type'] = _customerType;
    trail['Customer_birthday'] = f.DateFormat(selectDate); //date only
    print("----------> trail ${trail}");
    File ImageCustomer;
    File ImageIdCard;
    if (_tmpImage != null) {
      ImageCustomer =
          await _image.copy('$appDocPath/image_customer_$docNumber.jpeg');
      ImageIdCard =
          await _tmpImage.copy('$appDocPath/image_id_card_$docNumber.jpeg');
      trail['Image_id_card'] = ImageIdCard.path; //xxxxxx
      trail['Image_customer'] = ImageCustomer.path; //xxxxxx
    }

    List imageListCopy = [];
    File tmp;
    var filename =
        '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
    if (imageList.length > 0) {
      imageList.asMap().forEach((i, val) {
        tmp = val.copySync('$appDocPath/${filename}_$i.jpeg');
        imageListCopy.add(tmp.path);
      });
      trail['Image_receive'] = jsonEncode(imageListCopy);
    }
    // print('xxxxxx');
    // print(trail['Image_receive']);
    trail['Image_signature'] = customerSign;
    trail['user'] = _user;
    trail['location'] = _location.text;

    percentage = percentage + 30.0;
    pr.update(progress: percentage, message: "ส่งข้อมูล...");

    await Sqlite().trailRecord(trail).then((value) {
      Future.delayed(Duration(seconds: 2)).then((value) {
        pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
        pr.hide().then((value) {
          percentage = 0.0;
          // Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);
        });
      });
    });
  }

  FormCard confirmOrder(Size size, BuildContext context) {
    return FormCard(
      title: 'ยืนยันรับสินค้าทดลอง',
      child: Column(
        children: [
          Center(
            child: Container(
                child: customerSign == null
                    ? SignPart(
                        size: size,
                        controller: _customerSign,
                        text: '',
                        rear: Text(
                            'วันที่ีรับสินค้า ${f.ThaiDateFormat(DateTime.now().toString().split(' ')[0])}'),
                        clear: _clearSign,
                        cancel: () => _cancelSign(context),
                        confirm: () => _confirmSign(context),
                      )
                    : ShowSign(
                        sign: customerSign,
                        text: '',
                        rear: Text(
                            'วันที่ีรับสินค้า ${f.ThaiDateFormat(DateTime.now().toString().split(' ')[0])}'),
                      )),
          ),
        ],
      ),
    );
  }

  void _clearSign() {
    _customerSign.clear();
    setState(() {});
  }

  void _cancelSign(context) {
    _customerSign.clear();
    Navigator.of(context).pop();
    setState(() {});
  }

  void _confirmSign(context) async {
    if (_customerSign.isNotEmpty) {
      customerSign = base64Encode(await _customerSign.toPngBytes());
      customerSignDate = DateTime.now().toString().split('.')[0];
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  Widget imageCustomer(Size size) {
    return FormCard(
      title: 'รูปภาพผู้รับสินค้าทดลอง',
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10),
        child: Column(
          children: [
            imageList.isEmpty && widget.editStatus == 0
                ? uploadImage(true)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: size.height * 0.5,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: imageList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  (chkImgRcvNet)
                                      ? CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              ShimmerLoading(
                                            type: 'imageSquare',
                                          ),
                                          imageUrl:
                                              'https://landgreen.ml/system/storage/app/${imageFromOnline[index]}',
                                          errorWidget: (context, url, error) {
                                            return Image.asset(
                                                'assets/no_image.png');
                                          },
                                        )
                                      : Image.file(imageList[index]),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              );
                            }),
                      ),
                      widget.editStatus == 0 ? uploadImage(true) : Container()
                    ],
                  )
          ],
        ),
      ),
    );
  }

  // Future<List<SearchLand>> filterProvince(filter) async {

  // }

  Widget customerInfo(FocusScopeNode node) {
    return FormCard(
      title: 'ข้อมูลลูกค้า',
      child: Padding(
        padding: EdgeInsets.only(left: 16, top: 8),
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
            _image == null ? uploadImage(false) : showPickedImage(),

            SizedBox(
              height: 20,
            ),
            // Text('ชื่อลูกค้า'),
            Text(
              '2) ใส่ข้อมูลลูกค้าให้ครบทุกช่องดังนี้',
              style: TextStyle(fontSize: 21),
            ),
            SquareInput(
              hintText: 'ชื่อลูกค้า',
              labelText: 'ชื่อลูกค้า',
              enable: widget.editStatus == 1 || widget.editStatus == 0,
              validate: (val) => val.isEmpty ? '' : null,
              textController: _name,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
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
              inputType: TextInputType.number,
              enable: widget.editStatus == 1 || widget.editStatus == 0,
              textController: _idcard,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
            ),
            // Text('เพศ'),
            IgnorePointer(
              ignoring: widget.editStatus != 1 && widget.editStatus != 0,
              child: DropDown(
                items: {'1': 'ชาย', '2': 'หญิง'}
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
                onTap: () => node.unfocus(),
                value: _sex,
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
                    node.unfocus();
                  }
                },
                child: AbsorbPointer(
                  child: SquareInput(
                    hintText: 'วันเดือนปีเกิดลูกค้า',
                    labelText: 'วันเดือนปีเกิดลูกค้า',
                    textController: _birthday,
                    validate: (val) => val.isEmpty ? '' : null,
                  ),
                )),
            // Text('เบอร์โทรลูกค้า'),
            SquareInput(
              hintText: 'เบอร์โทรลูกค้า',
              labelText: 'เบอร์โทรลูกค้า',
              inputType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
              enable: widget.editStatus == 1 || widget.editStatus == 0,
              textController: _tel,
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
              textInputAction: TextInputAction.next,
              onEditingComplete: () => node.nextFocus(),
              validate: (val) => val.isEmpty ? '' : null,
            ),
            // Text('จังหวัด'),
            IgnorePointer(
              ignoring: widget.editStatus != 1 && widget.editStatus != 0,
              child: DropDown(
                items: _provinceData,
                hintText: 'เลือกจังหวัด',
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
            //     padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
            //     child: DropdownSearch<SearchLand>(
            //       key: _provinceKey,
            //       items: _provinceData,
            //       maxHeight: 300,
            //       label: 'เลือกจังหวัด',
            //       mode: Mode.BOTTOM_SHEET,
            //       dropdownSearchDecoration: InputDecoration(
            //           enabledBorder: const OutlineInputBorder(
            //             borderSide:
            //                 const BorderSide(color: Colors.grey, width: 0.0),
            //           ),
            //           border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(5)),
            //           contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            //           filled: true,
            //           fillColor: Colors.white),
            //       validator: (val) => val == null ? '' : null,
            //       onChanged: (value) {
            //         _province = value.value;
            //         //selectDistrict = null;
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
                  //   ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                  //   child: Container(
                  //     padding:
                  //         const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                  //     child: DropdownSearch<SearchLand>(
                  //       key: _districtKey,
                  //       items: _districtData,
                  //       maxHeight: 300,
                  //       label: 'เลือกอำเภอ',
                  //       mode: Mode.BOTTOM_SHEET,
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
                    ignoring: widget.editStatus != 1 && widget.editStatus != 0,
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
                  //   ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                  //   child: Container(
                  //     padding:
                  //         const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                  //     child: DropdownSearch<SearchLand>(
                  //       key: _subDistrictKey,
                  //       items: _subDistrictData,
                  //       maxHeight: 300,
                  //       label: 'เลือกตำบล',
                  //       mode: Mode.BOTTOM_SHEET,
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
                    ignoring: widget.editStatus != 1 && widget.editStatus != 0,
                    child: DropDown(
                      items: _subDistrictData,
                      hintText: 'เลือกตำบล',
                      value: _subDistrict,
                      onTap: () => node.unfocus(),
                      onChange: (val) {
                        setState(() {
                          //print(val);
                          _subDistrict = val;
                          var tmp = tmpSubDistrict.firstWhere((element) =>
                              element['DISTRICT_ID'].toString() == val);
                          _zipcode.text = tmp['ZIP_CODE'].toString();
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
              validate: (val) => val.isEmpty ? '' : null,
              onEditingComplete: () => node.unfocus(),
            ),
            // Text('ลิงค์ที่อยู่โลเคชั่น'),
            SquareInput(
              enable: widget.editStatus == 1 || widget.editStatus == 0,
              hintText: 'โลเคชั่นลูกค้า',
              labelText: 'โลเคชั่นลูกค้า',
              textController: _location,
              validate: (val) => val.isEmpty ? '' : null,
            ),
            Text(
                '*โลเคชั่นลูกค้า (ระบบดึงอัตโนมัติ รบกวนเปิด GPS ไว้ด้วยขณะสร้างใบบันทึกลูกค้ารับสินค้าทดลอง)'),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  Widget selectedProduct() {
    return FormCard(
      title: 'สรุปรายการสินค้าทดลอง',
      child: _selectedProduct.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                'ยังไม่ได้เลือกรายการสินค้า\nเพิ่มสินค้าด้านบนก่อน',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: rowsWidget,
            ),
      // : Column(
      //     children: [
      //       Container(
      //         padding: EdgeInsets.only(top: 16),
      //         height: 130,
      //         child: ListView.builder(
      //             itemCount: _selectedProduct.length,
      //             itemBuilder: (context, index) {
      //               var result = _selectedProduct[index];
      //               var item = result['items'][0];
      //               return Card(
      //                 elevation: 4,
      //                 child: Padding(
      //                   padding: const EdgeInsets.all(2),
      //                   child: Row(
      //                     mainAxisAlignment:
      //                         MainAxisAlignment.spaceEvenly,
      //                     children: [
      //                       Expanded(
      //                         child: Text(
      //                           '${item['Name']}',
      //                           style: TextStyle(fontSize: 18.0),
      //                         ),
      //                       ),
      //                       Expanded(
      //                         child: Text('จำนวน : ${result['amount']}',
      //                             style: TextStyle(fontSize: 18.0)),
      //                       ),
      //                       IconButton(
      //                           icon: Icon(Icons.delete),
      //                           onPressed: () {
      //                             delProduct(index);
      //                           })
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             }),
      //       ),
      //       Text('รวม : ',
      //           style: TextStyle(
      //             fontSize: 18,
      //           ))
      //     ],
      //   ),
    );
  }

  Widget pickProduct(Size size) {
    return FormCard(
      title: 'เลือกสินค้าทดลอง',
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_product != null)
              Center(
                  child: SizedBox(
                child: productImageWidget,
                width: size.width * 0.8,
                height: size.height * 0.2,
              )),
            SizedBox(
              height: 10,
            ),
            Text('เลือกสินค้าทดลอง'),
            DropDown(
              items: _productData,
              hintText: '--เลือกสินค้าทดลอง--',
              value: _product,
              onChange: (val) => onProductChange(val),
              validator: (val) => val == null ? '' : null,
            ),
            Text('จำนวน'),
            SquareInput(
              hintText: '1',
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
        _birthday.text = f.ThaiFormat(picked.toString().split(' ')[0]);
        selectDate = picked;
      });
  }

  void _cropImage() async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: _tmpImage.path,
        maxWidth: 720,
        maxHeight: 720,
        compressQuality: 80,
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
            toolbarTitle: 'แก้ไขรูปภาพ',
            toolbarColor: darkColor,
            toolbarWidgetColor: kPrimaryColor,
            activeControlsWidgetColor: kPrimaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'แก้ไขรูปภาพ',
        ));
    if (croppedImage != null) {
      _image = croppedImage;
      setState(() {});
    }
  }

  Future<List> textRecog(File file) async {
    try {
      // print("-------------------> file ${file.runtimeType}");
      final FirebaseVisionImage visionImage =
          await FirebaseVisionImage.fromFile(file);
      // print("-------------------> 1");
      // print("-------------------> visionImage ${visionImage}");
      final VisionDocumentText visionDocumentText =
          await cloudDocumentTextRecognizer.processImage(visionImage);
      // print("-------------------> 2");
      List<String> textList = new List();
      // print('textRecog => ${textList}');
      // print("-------------------> 3");

      for (DocumentTextBlock block in visionDocumentText.blocks) {
        for (DocumentTextParagraph paragraph in block.paragraphs) {
          // Same getters as DocumentTextBlock
          textList.add(paragraph.text);
        }
      }
      // print("-------------------> 4");

      return textList;
    } catch (e) {
      //show error dialog

      return [];
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
    print("--------------->textList ${textList}");
    textList.asMap().forEach((k, v) {
      tmp = v.replaceAll('\n', ' ');
      tmpArr = tmp.split(' ');
      tmpArr.asMap().forEach((i, val) {
        result.add(val);
      });
    });
    result.removeWhere((element) => element == '');
    // print("------------> result.asMap().forEach((k, v) {");
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

      print(textMap);

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

  Future imgPicker(bool isFromCamera, bool isForImageList) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
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

    var pickedFile;
    if (isFromCamera) {
      pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 85, maxWidth: 720);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 85, maxWidth: 720);
    }

    if (pickedFile != null) {
      if (isForImageList) {
        imageList.add(File(pickedFile.path));
        setState(() {});
      } else {
        await pr.show();

        Future.delayed(Duration(seconds: 2)).then((value) {
          percentage += 30.0;
          pr.update(
            progress: percentage,
            message: "กำลังอ่านบัตรประชาชน...",
            progressWidget: Container(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator()),
            maxProgress: 100.0,
            progressTextStyle: TextStyle(
                color: Colors.green,
                fontSize: 13.0,
                fontWeight: FontWeight.w400),
            messageTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.w600),
          );
        });

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "กำลังอ่านบัตรประชาชน...");
        _tmpImage = File(pickedFile.path);
        List textList;
        // print("----------------> 1");
        if (isConnect) {
          // print("----------------> 2");
          if (IO.Platform.isIOS) {
            // print("----------------> 3");
            // print("----------------> ${textList}");
            print('ios คร้าบบบ ต้องหมุนภาพก่อน');
            Directory tempDir = await getTemporaryDirectory();
            final targetPath = tempDir.absolute.path + "/temp.jpg";
            File _tmpImageRotate =
                await FlutterImageCompress.compressAndGetFile(
                    pickedFile.path, targetPath,
                    quality: 95, rotate: 90);
            // print("----------------> _tmpImageRotate ${_tmpImageRotate}");
            textList = await textRecog(_tmpImageRotate);
          } else {
            // print("---------------->_tmpImage ${_tmpImage}");
            textList = await textRecog(_tmpImage);
          }
        } else {
          textList = [];
        }

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "กำลังอ่านบัตรประชาชน...");

        await readTextList(textList).then((value) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.update(
                progress: percentage, message: "อ่านบัตรประชาชนเสร็จแล้ว...");
            pr.hide().then((value) {
              percentage = 0.0;
            });
          });
        });
        _cropImage();
      }
    }
  }

  void _showPicker(context, bool forImageList) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('รูปภาพในเครื่อง'),
                      onTap: () {
                        imgPicker(false, forImageList);
                        Navigator.of(context).pop();
                        // _showLoading(context);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('กล้อง'),
                    onTap: () {
                      imgPicker(true, forImageList);
                      Navigator.of(context).pop();
                      // _showLoading(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _clearImg() {
    _image = null;
    _tmpImage = null;
    setState(() {});

  }

  Widget showPickedImage() {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => _showPicker(context, false),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: size.width * 0.7,
              height: 200,
              child: Image.file(
                _image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Container(
          //   height: 200,
          //   child: Image.file(
          //     _image,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned(
              top: 0,
              right: -40,
              child: GestureDetector(
                onTap: _clearImg,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
              )),
          Positioned(
              bottom: 0,
              right: -40,
              child: GestureDetector(
                onTap: _cropImage,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.crop,
                      size: 20,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget uploadImage(bool forImageList) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Center(
        child: GestureDetector(
          onTap: () {
            _showPicker(context, forImageList);
          },
          child: forImageList
              ? Container(
                  width: size.width * 0.7,
                  height: 80,
                  color: Color(0xFFFFFFFF),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        size: 48,
                      ),
                      Center(
                        child: Text('คลิ๊กอัพโหลดรูปลูกค้ารับสินค้า'),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: size.width * 0.7,
                  height: 200,
                  color: Color(0xFFFFFFFF),
                  child:
                      Center(child: Text('คลิ๊กอัพโหลดรูปบัตรประชาชนที่นี่')),
                ),
          // Container(
          //   color: Colors.white,
          //   padding: EdgeInsets.all(8),
          //   child: Column(
          //     children: [
          //       Icon(
          //         Icons.cloud_upload_rounded,
          //         size: 48,
          //       ),
          //       forImageList
          //           ? Text('อัพโหลดรูปลูกค้า')
          //           : Text('คลิ๊กอัพโหลดรูปบัตรประชาชนที่นี่')
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
