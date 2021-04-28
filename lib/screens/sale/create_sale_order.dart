import 'dart:convert';
import 'dart:io';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/image_picker_box.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;

class CreateSaleOrder extends StatefulWidget {
  final int userId;
  final int editStatus;
  final int docId;
  const CreateSaleOrder({Key key, this.userId, this.editStatus, this.docId})
      : super(key: key);
  @override
  _CreateSaleOrderState createState() => _CreateSaleOrderState();
}

class _CreateSaleOrderState extends State<CreateSaleOrder> {
  List userData = [];

  List _catListData = [];
  List _productListData = [];
  List _attributeListData = [];
  List<File> imageStockList = [];
  List<File> imageCarList = [];
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  TextStyle _baseFontStyle = TextStyle(
    fontSize: 18,
  );
  TextEditingController TECDetailSaleOrder = TextEditingController();
  TextEditingController TECQtySaleOrder = TextEditingController();
  TextEditingController TECUnitSaleOrder = TextEditingController();
  TextEditingController TECUnitSendTanSaleOrder = TextEditingController();
  var node;
  FocusNode myFocusNode;
  var _editStatus,
      _userId,
      _teamCode,
      _catSel,
      _catSelName,
      _product,
      _attribute,
      _userCarData,
      _docId;
  var client = http.Client();
  Size _size;
  Sqlite _sqlite = Sqlite();
  Future<bool> loadDetailTeam;

  List _listProductSel = [];

  var appDirPath;

  List<DropdownMenuItem<String>> _catData = [];
  List<DropdownMenuItem<String>> _productData = [];
  List<DropdownMenuItem<String>> _attributeData;
  Widget widgetProductImgSel;

  FTPConnect ftpConnect;

  @override
  void initState() {
    setStart();
    getCarDetail();
    super.initState();
  }

  setStart() async {
    _editStatus = widget.editStatus;
    _userId = widget.userId;
    _docId = widget.docId;

    appDirPath = (await getApplicationDocumentsDirectory()).path;
  }

  // getDataForEdit() async{
  //   var res = await client.post('https://landgreen.ml/system/public/api-store',
  //       body: {
  //         'func': 'get_stock_team_doc_edit',
  //         'doc_id': '${_docId}'
  //       });
  //   var stockTeamDoc = jsonDecode(res.body);
  //   print('stockTeamDoc=>${stockTeamDoc}');
  //
  // }

  getCarDetail() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print('isConnect ${isConnect}');
    if (isConnect) {
      print('_docId =>${_docId}');
      if (_docId != null) {
        // await getDataForEdit();
      }
      await getTeamName();
      await getTeamCode();
      await getAttribuild();
      await getCatagory();

      loadDetailTeam = Future.value(true);
      if (mounted) setState(() {});
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
                  'หน้านี้เป็นหน้าสร้างใบสั่งขาย ระบบต้องลิงค์ข้อมูลกับเซิฟเวอร์ทันที ต้องใช้อินเทอร์เน็ตนะครับ รบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตนะครับ ถึงจะใช้งานหน้านี้ได้',
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

  getTeamName() async {
    userData = await _sqlite.getUserById(_userId);
    _userCarData = await _sqlite.getDetailCar(userData[0]['Work_car_id']);
  }

  getTeamCode() async {
    var res = await client.post('$urlPath/api-store',
        body: {'func': 'get_stock_team_code', 'team_id': '${_userId}'});

    _teamCode = res.body.replaceAll('"', '');
  }

  getCatagory() async {
    var res = await Sqlite().rawQuery('SELECT ID,Name FROM CATEGORY ');
    _catListData = res;
    print('res=>${res}');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name');
    }).forEach((element) {
      _catData.add(element);
    });
  }

  Future<Null> getProduct(cat_id) async {
    _productData = [];
    _product = await null;

    var res;
    if (cat_id == '1' || cat_id == '2') {
      res = await Sqlite().rawQuery(
          '''SELECT PRODUCT.ID,PRODUCT.Name,PRODUCT.Image,PRODUCT.Category_id
        FROM PRODUCT INNER JOIN USER_PRODUCT_CAN_SELL ON PRODUCT.ID = USER_PRODUCT_CAN_SELL.Product_id 
        WHERE PRODUCT.Category_id = ${cat_id} AND PRODUCT.Status = 1 AND USER_PRODUCT_CAN_SELL.User_id = "$_userId"
        AND USER_PRODUCT_CAN_SELL.Status = 1 ORDER BY Category_id ASC
        ''');
    } else {
      res = await Sqlite().rawQuery(
          'SELECT ID,Name,Image FROM PRODUCT WHERE Category_id = ${cat_id} and Status=1');
    }
    _productListData = res;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    res.asMap().forEach((key, value) async {
      if (!File('$appDocPath/product_image_${value['ID']}.png').existsSync()) {
        if (value['Image'] != null && value['Image'] != '') {
          print('Image : ' + value['Image']);
          final url = 'https://landgreen.ml/system/public/api/downloadImage';
          File file = File('$appDocPath/product_image_${value['ID']}.png');
          await client.post(url, body: {'path': value['Image']}).then((val) {
            file.writeAsBytesSync(val.bodyBytes);
          });
        }
      }
    });

    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name');
    }).forEach((element) {
      _productData.add(element);
    });
    setState(() {});
  }

  getAttribuild() async {
    _attributeData = [];
    var res = await Sqlite()
        .rawQuery('SELECT ID,Name FROM STOCK_NOT_PRICE WHERE Status=1');
    _attributeListData = res;
    print('getAttribuild=>${res}');
    res.map((e) {
      return DropDown().getDropDownWidget(e, 'ID', 'Name');
    }).forEach((element) {
      _attributeData.add(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    node = FocusScope.of(context);

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
              body: CustomScrollView(
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
                                FontAwesomeIcons.clipboard,
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
                                  'สร้างใบสั่งขาย(ส่งของให้คลังหัวหน้าทีม)',
                                  style: TextStyle(fontSize: 24.0, height: 1),
                                ),
                                Text(
                                  'กรอกข้อมูลให้ครบถ้วนเพื่อพิจารณาการส่งปุ๋ยให้',
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
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          detailTeam(),
                          SizedBox(
                            height: 5,
                          ),
                          addImageStockAndCar(),
                          SizedBox(
                            height: 5,
                          ),
                          addItem(),
                          SizedBox(
                            height: 5,
                          ),
                          detailItem(),
                          SizedBox(
                            height: 5,
                          ),
                          if (_listProductSel.length > 0)
                            Center(
                              child: CustomButton(
                                text: 'สร้างและส่งให้ธุรการ',
                                onPress: () {
                                  checkDataComplete();
                                },
                              ),
                            )
                        ],
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
        ));
  }

  Widget addImageStockAndCar() {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText(
            text: 'แนบเอกสารเพื่อขอสั่งปุ๋ยดังนี้',
            textSize: 20,
            gHeight: 26,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 10, top: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. ภาพถ่ายสต็อกสินค้า แนบได้สูงสุด 10 ภาพ',
                  style: _baseFontStyle,
                ),
                (imageStockList.isEmpty)
                    ? Center(
                        child: ImagePickerBox(
                          onTap: () {
                            showPicker(context, 'stock');
                          },
                          showText: 'คลิ๊กแนบภาพสต็อกสินค้าที่นี่',
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Container(
                                width: _size.width * 0.9,
                                height: _size.height * 0.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageStockList.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        children: [
                                          Image.file(imageStockList[index]),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      );
                                    })),
                            Center(
                              child: ImagePickerBox(
                                onTap: () {
                                  showPicker(context, 'stock');
                                },
                                showText: 'คลิ๊กแนบภาพสต็อกสินค้าที่นี่',
                              ),
                            ),
                          ]),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Divider(),
                ),
                Text(
                  '2. ภาพถ่ายรูปรถ แนบได้สูงสุด 10 ภาพ',
                  style: _baseFontStyle,
                ),
                (imageCarList.isEmpty)
                    ? Center(
                        child: ImagePickerBox(
                          onTap: () {
                            showPicker(context, 'car');
                          },
                          showText: 'คลิ๊กแนบภาพรูปรถที่นี่',
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Container(
                                width: _size.width * 0.9,
                                height: _size.height * 0.3,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageCarList.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        children: [
                                          Image.file(imageCarList[index]),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      );
                                    })),
                            Center(
                              child: ImagePickerBox(
                                onTap: () {
                                  showPicker(context, 'car');
                                },
                                showText: 'คลิ๊กแนบภาพรูปรถที่นี่',
                              ),
                            ),
                          ]),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Divider(),
                ),
                Text(
                  '3. บันทึกรายละเอียดรถครั้งล่าสุดที่เข้าศูนย์',
                  style: _baseFontStyle,
                ),
                SquareInput(
                  hintText: '',
                  labelText: 'ใส่ข้อความด้วย',
                  enable: _editStatus == 1 || _editStatus == 0,
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: TECDetailSaleOrder,
                  // textInputAction: TextInputAction.next,
                  inputType: TextInputType.multiline,
                  maxLine: 5,
                  onEditingComplete: () => node.unfocus(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showPicker(context, type) {
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
                        (type == 'stock') ? pickImg(true) : pickImgCar(true);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('กล้อง'),
                    onTap: () {
                      (type == 'stock') ? pickImg(false) : pickImgCar(false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future pickImg(bool isFromGallary) async {
    if (isFromGallary) {
      //Pick from gallary
      final pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageStockList.add(File(pickedFile.path));
        setState(() {});
      }
    } else {
      //Pick from camera
      final pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageStockList.add(File(pickedFile.path));
        setState(() {});
      }
    }
  }

  Future pickImgCar(bool isFromGallary) async {
    if (isFromGallary) {
      //Pick from gallary
      final pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageCarList.add(File(pickedFile.path));
        setState(() {});
      }
    } else {
      //Pick from camera
      final pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageCarList.add(File(pickedFile.path));
        setState(() {});
      }
    }
  }

  Widget detailTeam() {
    return Card(
      child: Column(
        children: [
          HeaderText(
            text: 'รายละเอียดทีม',
            textSize: 20,
            gHeight: 26,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'คลังสินค้าทีม ${userData[0]['Name']} ${userData[0]['Surname']}',
                          style: _baseFontStyle,
                        ),
                        Text(
                          'รหัสคลัง $_teamCode',
                          style: _baseFontStyle,
                        ),
                      ],
                    );
                  } else {
                    return ShimmerLoading(
                      type: 'boxInput1Row',
                    );
                  }
                },
                future: loadDetailTeam,
              ))
        ],
      ),
    );
  }

  Widget addItem() {
    return Form(
      key: _formKey,
      child: Card(
        child: Column(
          children: [
            HeaderText(
              text: 'เลือกรายการที่จะสั่ง',
              textSize: 20,
              gHeight: 26,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                children: [
                  DropDown(
                    items: _catData,
                    hintText: '',
                    labelText: 'ประเภทสินค้า',
                    value: _catSel,
                    onChange: (val) {
                      var index =
                          _catData.indexWhere((ele) => ele.value == val);
                      print('index=>${_catListData[index]['Name']}');
                      setState(() {
                        _catSel = val;
                        _catSelName = _catListData[index]['Name'];

                        getProduct(_catSel);
                      });
                    },
                    validator: (val) => val == null ? '' : null,
                  ),
                  if (_product != null)
                    Center(
                        child: SizedBox(
                      child: widgetProductImgSel,
                      width: _size.width * 0.35,
                      height: _size.height * 0.2,
                    )),
                  if (_productData.isNotEmpty)
                    DropDown(
                      items: _productData,
                      hintText: '',
                      labelText: 'รายการสินค้า',
                      value: _product,
                      onChange: (val) async {
                        if (File(
                                "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png")
                            .existsSync()) {
                          //ProductImage = CachedNetworkImage(imageUrl: null);
                          widgetProductImgSel = Image.file(File(
                              "${(await getApplicationDocumentsDirectory()).path}/product_image_$val.png"));
                        } else {
                          widgetProductImgSel =
                              Image.asset('assets/no_image.png');
                        }

                        setState(() {
                          _product = val;
                          // _attribute = null;
                          print('_product ==>${_product} _catSel=>${_catSel}');
                          print('_attributeData =>${_attributeData}');
                          switch (_catSel) {
                            case '1':
                              TECUnitSaleOrder.text = 'กระสอบ';
                              break;
                            case '2':
                              TECUnitSaleOrder.text = 'ขวด';
                              break;
                            default:
                              TECUnitSaleOrder.text = '';
                              break;
                          }
                        });
                      },
                      validator: (val) => val == null ? '' : null,
                    ),
                  if (_catSel == '1')
                    DropDown(
                      items: _attributeData,
                      hintText: '',
                      labelText: 'เนื้อสินค้า',
                      value: _attribute,
                      onChange: (val) async {
                        setState(() {
                          _attribute = val;
                        });
                      },
                      validator: (val) => val == null ? '' : null,
                    ),
                  SquareInput(
                    hintText: '',
                    labelText: 'จำนวน',
                    enable: _editStatus == 1 || _editStatus == 0,
                    validate: (val) => val.isEmpty ? '' : null,
                    textController: TECQtySaleOrder,
                    textInputAction: TextInputAction.next,
                    inputType: TextInputType.number,
                    onEditingComplete: () {
                      switch (_catSel) {
                        case '1':
                          var tan =
                              (int.parse(TECQtySaleOrder.text) * 50) / 1000;
                          TECUnitSendTanSaleOrder.text = tan.toStringAsFixed(2);
                          break;
                        case '2':
                          var tan = (int.parse(TECQtySaleOrder.text) / 12);
                          TECUnitSendTanSaleOrder.text = tan.toStringAsFixed(2);
                          break;
                        case '4':
                          var tan = (int.parse(TECQtySaleOrder.text) / 12);
                          TECUnitSendTanSaleOrder.text = tan.toStringAsFixed(2);
                          break;
                        default:
                          TECUnitSendTanSaleOrder.text = '';
                          break;
                      }

                      node.nextFocus();
                    },
                  ),
                  SquareInput(
                    hintText: '',
                    labelText: 'หน่วย',
                    enable: _editStatus == 1 || _editStatus == 0,
                    validate: (val) => val.isEmpty ? '' : null,
                    textController: TECUnitSaleOrder,
                    textInputAction: TextInputAction.next,
                    inputType: TextInputType.text,
                    onEditingComplete: () => node.nextFocus(),
                  ),
                  SquareInput(
                    hintText: '',
                    labelText: 'จำนวนขนส่ง(ตัน)',
                    enable: _editStatus == 1 || _editStatus == 0,
                    // validate: (val) => val.isEmpty ? '' : null,
                    textController: TECUnitSendTanSaleOrder,
                    // textInputAction: TextInputAction.next,
                    inputType: TextInputType.number,
                    onEditingComplete: () => node.unfocus(),
                  ),
                  Center(
                      child: RaisedButton.icon(
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              addProduct();

                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.add),
                          label: Text('เพิ่มสินค้า'))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  addProduct() async {
    var index = _productData.indexWhere((ele) => ele.value == _product);
    var productDataAtIndex = _productListData[index];
    var attributeName = '';
    if (_attribute != null) {
      var indexAttribute =
          _attributeData.indexWhere((ele) => ele.value == _attribute);
      attributeName = _attributeListData[indexAttribute]['Name'];
    }

    var addItem = {
      'Product_id': _product,
      'Product_name': productDataAtIndex['Name'],
      'Product_img': productDataAtIndex['Image'],
      'Cat_id': _catSel,
      'Cat_name': _catSelName,
      'Qty': TECQtySaleOrder.text,
      'Unit_type': TECUnitSaleOrder.text,
      'Unit_send_tan': TECUnitSendTanSaleOrder.text,
      'Product_addtribuild': _attribute,
      'Product_addtribuild_name': attributeName,
    };
    _listProductSel.add(addItem);
    setState(() {});
    _catSel = null;
    _productData = [];
    _product = null;
    _attribute = null;
    TECQtySaleOrder.text = '';
    TECUnitSaleOrder.text = '';
    TECUnitSendTanSaleOrder.text = '';
  }

  Widget detailItem() {
    return Card(
      child: Column(
        children: [
          HeaderText(
            text: 'รายการที่สั่ง',
            textSize: 20,
            gHeight: 26,
          ),
          (_listProductSel.length > 0)
              ? ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var obj = _listProductSel[index];
                    print('obj=>${obj}');
                    var imgProduct;
                    if (File(
                            "${appDirPath}/product_image_${obj['Product_id']}.png")
                        .existsSync()) {
                      imgProduct = Image.file(File(
                          "${appDirPath}/product_image_${obj['Product_id']}.png"));
                    } else {
                      imgProduct = Image.asset('assets/no_image.png');
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SizedBox(
                                child: imgProduct,
                                width: _size.width * 0.30,
                                height: _size.height * 0.2,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${obj['Product_name']}',
                                        style: _baseFontStyle,
                                      ),
                                      if (obj['Product_addtribuild_name'] != '')
                                        Text(
                                          '(${obj['Product_addtribuild_name']})',
                                          style: _baseFontStyle,
                                        ),
                                      Text(
                                        'จำนวน ${obj['Qty']} ${obj['Unit_type']}',
                                        style: _baseFontStyle,
                                      ),
                                      Text(
                                        'จำนวนขนส่ง ${obj['Unit_send_tan']} ตัน',
                                        style: _baseFontStyle,
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    right: 20,
                                    bottom: 0,
                                    child: SizedBox(
                                      width: 50,
                                      child: RaisedButton(
                                        onPressed: () {
                                          delProduct(index);
                                        },
                                        color: kPrimaryColor,
                                        textColor: Colors.white,
                                        child: Text('ลบ'),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        if (index != (_listProductSel.length - 1)) Divider(),
                      ],
                    );
                  },
                  itemCount: _listProductSel.length,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '--ยังไม่มีรายการที่สั่ง--',
                      style: _baseFontStyle,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  delProduct(var index) async {
    _listProductSel.removeAt(index);
    setState(() {});
  }

  alertBox(text) {
    alert(
      context,
      title: Icon(
        Icons.warning_rounded,
        color: dangerColor,
        size: 30,
      ),
      content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: _size.width * 0.5,
            maxHeight: _size.height * 0.03,
          ),
          child: Center(
              child: Text(
            '$text',
            style: TextStyle(fontSize: 18),
          ))),
    );
  }

  checkDataComplete() async {
    if (imageStockList.length == 0) {
      alertBox('แนบภาพถ่ายสต็อกสินค้าด้วยครับ');
    } else if (imageCarList.length == 0) {
      alertBox('แนบภาพถ่ายรูปรถด้วยครับ');
    } else if (TECDetailSaleOrder.text.isEmpty ||
        TECDetailSaleOrder.text.trim() == "") {
      alertBox('ใส่รายละเอียดรถครั้งล่าสุดที่เข้าศูนย์ด้วยครับ');
    } else {
      print('ผ่านใส่รายการทั้งหมดครบแล้ว');
      ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        print('มีอินเทอร์เน็ตแล้ว อัพโหลดได้');
        double percentage = 0.0;

        ProgressDialog pr = ProgressDialog(
          context,
          type: ProgressDialogType.Download,
          isDismissible: true,
        );
        pr.style(
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          message:
              'กรุณาอย่ากดออกจากหน้านี้ \nระบบกำส่งข้อมูลให้ธุรการรอแปปนะครับ',
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

        await ftpConnect.connect();
        //อัพโหลดimage ก่อน
        DateTime now = DateTime.now();
        String folderName = now.year.toString();
        String subFolderName = now.month.toString();
        String mainFolder =
            '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/saleOrder/';
        String uploadPath = '$mainFolder$folderName/$subFolderName';
        await ftpConnect.createFolderIfNotExist(mainFolder);
        await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
        await ftpConnect
            .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
        await ftpConnect.changeDirectory(uploadPath);
        bool isImageStockUpload = true;
        bool isImageCarUpload = true;
        List<String> stockImg = [];
        List<String> carImgList = [];
        for (File img in imageStockList) {
          String imgPath = img.path;
          String imgName = imgPath.split('/')[imgPath.split('/').length - 1];
          stockImg
              .add('faarunApp/saleOrder/$folderName/$subFolderName/$imgName');
          isImageStockUpload =
              await ftpConnect.uploadFileWithRetry(img, pRetryCount: 2);
        }
        pr.update(
          progress: 30,
          message: "กรุณาอย่ากดออกจากหน้านี้\nส่งข้อมูลรูปภาพ...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 13.0,
              fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );

        for (File img in imageCarList) {
          String imgPath = img.path;
          String imgName = imgPath.split('/')[imgPath.split('/').length - 1];
          carImgList
              .add('faarunApp/saleOrder/$folderName/$subFolderName/$imgName');
          isImageCarUpload =
              await ftpConnect.uploadFileWithRetry(img, pRetryCount: 2);
        }
        pr.update(
          progress: 60,
          message: "กรุณาอย่ากดออกจากหน้านี้\nส่งข้อมูลรูปภาพ...",
          progressWidget: Container(
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 13.0,
              fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );

        var postUri = Uri.parse('https://landgreen.ml/system/public/api-store');
        var req = new http.MultipartRequest('POST', postUri);
        http.MultipartFile multipartFile;
        //req ของ record_doc_stock_team_save
        req.fields['func'] = 'record_doc_stock_team_head_create_fromapp';
        // req.fields['car_plate_number'] = '${_userCarData['car_name']}';
        req.fields['sel_team_id'] = '$_userId';
        req.fields['sel_team_name'] =
            '${userData[0]['Name']} ${userData[0]['Surname']} ';
        req.fields['code'] = '$_teamCode';
        req.fields['data_detail'] = jsonEncode(_listProductSel);
        req.fields['Edit_user_id'] = '$_userId';
        req.fields['doc_id'] = '0';
        req.fields['Status'] = '3';
        req.fields['car_maintenance'] = TECDetailSaleOrder.text;
        req.fields['carImgList'] = jsonEncode(carImgList);
        req.fields['stockImg'] = jsonEncode(stockImg);

        print('send fromapp =>${req.fields}');
        if (isImageStockUpload && isImageCarUpload) {
          pr.update(
            progress: 80,
            message: "กรุณาอย่ากดออกจากหน้านี้\nส่งข้อมูลข้อความ...",
            progressWidget: Container(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator()),
            maxProgress: 100.0,
            progressTextStyle: TextStyle(
                color: kPrimaryColor,
                fontSize: 13.0,
                fontWeight: FontWeight.w400),
            messageTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.w600),
          );
          await req.send().then((response) {
            http.Response.fromStream(response).then((val) async {
              if (val.statusCode == 200) {
                var res = await jsonDecode(val.body);
                print(res);
                Future.delayed(Duration(seconds: 2)).then((value) {
                  pr.update(progress: 100.00, message: "ส่งข้อมูลเสร็จแล้ว...");
                  pr.hide().whenComplete(() {
                    alert(context,
                        title: Icon(
                          Icons.check_circle,
                          color: kPrimaryColor,
                          size: 40,
                        ),
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: _size.width * 0.5,
                            maxHeight: _size.height * 0.05,
                          ),
                          child: Center(
                            child: Text(
                              'ส่งข้อมูลให้ธุรการเรียบร้อยแล้ว\nหากต้องการแก้ไขให้ติดต่อธุรการดำเนินการแก้ไขได้เลย',
                              style: _baseFontStyle,
                            ),
                          ),
                        ),
                        textOK: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text('OK')));
                  });
                });
              } else {
                //print(val.body);
              }
            });
          });
        }

        await ftpConnect.disconnect();
      }
    }
  }
}
