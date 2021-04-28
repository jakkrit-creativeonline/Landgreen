import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

class UserSetting extends StatefulWidget {
  final String title;
  final int userId;
  final int editId;

  const UserSetting(
      {Key key, this.title = 'ระบบแลนด์กรีน', this.userId, this.editId})
      : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  Future<Map<String, dynamic>> userData;
  final _formKey = GlobalKey<FormState>();
  var _name = TextEditingController();
  var _surname = TextEditingController();
  var _username = TextEditingController();
  var _password = TextEditingController();
  var _idcard = TextEditingController();
  var _dob = TextEditingController();
  var _address = TextEditingController();
  var _bank = TextEditingController();

  var client = http.Client();
  bool isHide = true;

  List<DropdownMenuItem> bankOption = [];
  List<DropdownMenuItem> levelOption = [];
  List<DropdownMenuItem> provinceOption = [];
  List<DropdownMenuItem> districtOption = [];
  List<DropdownMenuItem> subdistrictOption = [];

  List<DropdownMenuItem> sexOption = [
    DropdownMenuItem(value: '1', child: Text('ชาย')),
    DropdownMenuItem(value: '2', child: Text('หญิง')),
  ];

  List districtTemp;
  List subdistrictTemp;

  final picker = ImagePicker();
  File newImage;
  File newImageTemp;

  String imageName;

  DateTime selectedDob = DateTime.now();

  FormatMethod f = FormatMethod();

  var selectedProvince,
      selectedDistrict,
      selectedSubDistrict,
      selectedBank,
      selectedSex;

  Future<Map<String, dynamic>> getEditData() async {
    var body = {'func': 'get_userdata', 'User_id': '${widget.userId}'};
    var res = await client.post('$apiPath-setting_employee', body: body);
    var data = jsonDecode(res.body);
    Map<String, dynamic> map = Map.from(data[0]);
    _name.text = map['Name'];
    _surname.text = map['Surname'];
    _username.text = map['Username'];
    _password.text = map['Password'];
    _idcard.text = map['Id_card'];
    if (map['Birthday'] != null) {
      _dob.text = f.ThaiFormat(map['Birthday']);
      selectedDob = DateTime.parse(map['Birthday']);
      print('selectedDob =>${selectedDob}');
    }
    _address.text = map['Address'];
    _bank.text = map['Bank_account'];

    selectedSex = map['Sex'] == null ? '1' : map['Sex'].toString();

    imageName = map['Image'];

    if (map['Province_id'] != null) {
      selectedProvince = map['Province_id'].toString();
      setDistrict(selectedProvince);

      if (map['Amphur_id'] != null) {
        selectedDistrict = map['Amphur_id'].toString();
        setSubDistrict(selectedDistrict);

        if (map['District_id'] != null) {
          selectedSubDistrict = map['District_id'].toString();
        }
      }
    }

    selectedBank = map['Bank_id'] == null ? null : map['Bank_id'].toString();

    return map;
  }

  setDistrict(val) {
    districtOption = [];
    subdistrictOption = [];
    List district = districtTemp
        .where((element) => element['PROVINCE_ID'].toString() == val)
        .toList();
    district.forEach((element) {
      districtOption.add(DropdownMenuItem(
          value: element['AMPHUR_ID'].toString(),
          child: Text(element['AMPHUR_NAME'])));
    });
  }

  setSubDistrict(val) {
    subdistrictOption = [];
    List subdistrict = subdistrictTemp
        .where((element) => element['AMPHUR_ID'].toString() == val)
        .toList();
    subdistrict.forEach((element) {
      subdistrictOption.add(DropdownMenuItem(
          value: element['DISTRICT_ID'].toString(),
          child: Text(element['DISTRICT_NAME'])));
    });
  }

  Future getAllSelect() async {
    var bank = await client.get('$apiPath-setting_employee/sel_bank');
    List province = await Sqlite().query('PROVINCE');
    districtTemp = await Sqlite().query('AMPHUR');
    subdistrictTemp = await Sqlite().query('DISTRICT');
    print(subdistrictTemp);
    List bankData = jsonDecode(bank.body);
    bankData.forEach((element) {
      bankOption.add(DropdownMenuItem(
          value: element['ID'].toString(), child: Text(element['Name'])));
    });
    province.forEach((element) {
      provinceOption.add(DropdownMenuItem(
          value: element['PROVINCE_ID'].toString(),
          child: Text(element['PROVINCE_NAME'])));
    });
  }

  _showDatePicker() async {
    final DateTime picked = await showDatePicker(
      context: context,
      locale: const Locale('th', 'TH'),
      initialDate: selectedDob,
      firstDate: DateTime(1910),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: Theme.of(context).copyWith(),
          child: child,
        );
      },
    );

    if (picked != null) {
      selectedDob = picked;
      _dob.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      setState(() {});
    }
  }

  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        Navigator.of(context).pop();
                        imgPicker(false);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      Navigator.of(context).pop();
                      imgPicker(true);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future imgPicker(bool isCamera) async {
    var pickedFile;
    if (isCamera) {
      pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 70, maxWidth: 700);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 700);
    }
    if (pickedFile != null) {
      newImageTemp = File(pickedFile.path);
      newImage = await _cropImage(newImageTemp);
      setState(() {});
    }
  }

  Future<File> _cropImage(File file) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: file.path,
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
          toolbarTitle: 'Cropper',
          toolbarColor: darkColor,
          toolbarWidgetColor: kPrimaryColor,
          activeControlsWidgetColor: kPrimaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ),
    );
    if (croppedImage != null) {
      return croppedImage;
    } else {
      return file;
    }
  }

  Future getData() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (!isConnect) {
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
                  'หน้านี้เป็นการตั้งค่าข้อมูลส่วนตัว\nต้องทำการส่งข้อมูลขึ้นระบบทันทีต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนอยู่ในที่ ที่มีสัญญาณอินเทอร์เน็ต\nถึงจะใช้งานได้ครับ',
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                    color: kPrimaryColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      // Navigator.of(context).pushNamedAndRemoveUntil(contexts, 'dashboard',);
                      // Navigator.pushNamedAndRemoveUntil(context, 'dashboard', ModalRoute.withName('dashboard'));
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
    await getAllSelect();
    userData = getEditData();
    setState(() {});
  }

  Future validateData() async {
    if (_formKey.currentState.validate()) {
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

      if (isConnect) {
        pr.show();
        bool isUpload = true;
        String uploadName = '';
        if (newImage != null) {
          FTPConnect ftpConnect =
              FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
          await ftpConnect.connect();
          DateTime now = DateTime.now();
          String mainFolder =
              '/domains/landgreen.ml/public_html/system/storage/app/user/';
          await ftpConnect.createFolderIfNotExist(mainFolder);
          await ftpConnect.changeDirectory(mainFolder);
          String dir = (await getApplicationDocumentsDirectory()).path;
          imageName = dir +
              '/avatar_' +
              '${now.year}' +
              '${now.month}' +
              '${now.day}' +
              '${now.minute}' +
              '${now.second}' +
              '_${widget.userId}.jpeg';
          File image = newImage.copySync(imageName);
          isUpload =
              await ftpConnect.uploadFileWithRetry(image, pRetryCount: 2);
          ftpConnect.disconnect();
          uploadName = 'user/' + imageName.split('/')[6];
        } else {
          uploadName = imageName;
        }

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "กำลังบันทึกข้อมูล...");

        if (isUpload) {
          var body = {
            'Edit_User_id': '${widget.editId ?? widget.userId}',
            'EditID': '${widget.userId}',
            'Name': _name.text,
            'Surname': _surname.text,
            'Password': _password.text,
            'Id_card': _idcard.text,
            'Sex': selectedSex,
            'Birthday': f.DateFormat(selectedDob),
            'Province_id': selectedProvince,
            'Amphur_id': selectedDistrict,
            'District_id': selectedSubDistrict,
            'Address': _address.text,
            'Bank_account': _bank.text,
            'Bank_id': selectedBank,
            'Image': uploadName,
          };
          var res = await http.post('$apiPath/updateUser', body: body);
          percentage = percentage + 30.0;
          pr.update(progress: percentage, message: "กำลังบันทึกข้อมูล...");
          if (res.statusCode == 200) {
            Sqlite().updateUserData(widget.userId, body).then((value) {
              percentage = percentage + 30.0;
              pr.update(
                  progress: percentage, message: "บันทึกข้อมูลเสร็จสิ้น...");

              pr.hide();
              Navigator.of(context).pop();
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();

    super.initState();
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
                // title: Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     MyNoti(
                //       userId: user_id,
                //     )
                //   ],
                // ),
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
            //     child: Icon(Icons.add),
            //     onPressed: () async {
            //       var res = await Sqlite().getUserById(widget.userId);
            //       print(res[0]['Image']);
            //       //setSubDistrict('1000');
            //     }),
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
                              FontAwesomeIcons.userCog,
                              color: btTextColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตั้งค่าส่วนตัว',
                                style: TextStyle(fontSize: 24.0, height: 1),
                              ),
                              Text(
                                'เปลี่ยนภาพประจำตัวให้กดที่รูปได้เลย',
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
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: userData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return editForm(size, snapshot.data);
                        } else if (snapshot.hasError) {
                          return Center(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  child: ShimmerLoading(
                                    type: 'boxInput1Row',
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  child: ShimmerLoading(
                                    type: 'boxInput1Row',
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      }),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Footer(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget editForm(Size size, Map<String, dynamic> data) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Text('ตั้งค่า พนักงาน${widget.title}'),
          GestureDetector(
            onTap: () => _showPicker(),
            child: ClipRRect(
              child: Container(
                width: size.width * 0.4,
                child: newImage == null
                    ? CachedNetworkImage(
                        imageUrl: '$storagePath/${data['Image']}',
                        errorWidget: (context, error, child) {
                          return Image.asset('assets/avatar.png');
                        },
                      )
                    : Image.file(newImage),
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SquareInput(
                  hintText: 'ชื่อ',
                  labelText: 'ชื่อ',
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: _name,
                  textInputAction: TextInputAction.next,
                  //onEditingComplete: () => node.nextFocus(),
                ),
                SquareInput(
                  hintText: 'นามสกุล',
                  labelText: 'นามสกุล',
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: _surname,
                  textInputAction: TextInputAction.next,
                  //onEditingComplete: () => node.nextFocus(),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8, right: 10, bottom: 8),
                  child: TextFormField(
                    obscureText: isHide,
                    enabled: true,
                    autofocus: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      labelStyle: new TextStyle(color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      hintText: 'Password',
                      labelText: 'Password',
                      suffixIcon: InkWell(
                        child: Icon(Icons.visibility),
                        onTap: () {
                          setState(() {
                            isHide = !isHide;
                          });
                        },
                      ),
                    ),
                    validator: (val) => val.isEmpty ? '' : null,
                    controller: _password,
                  ),
                ),
                // SquareInput(
                //   hintText: 'Password',
                //   labelText: 'Password',
                //   isObscure: true,
                //   validate: (val) => val.isEmpty ? '' : null,
                //   textController: _password,
                //   textInputAction: TextInputAction.next,
                //   //onEditingComplete: () => node.nextFocus(),
                // ),
                SquareInput(
                  hintText: 'เลขบัตรประชาชน',
                  labelText: 'เลขบัตรประชาชน',
                  textController: _idcard,
                  textInputAction: TextInputAction.next,
                  //onEditingComplete: () => node.nextFocus(),
                ),
                DropDown(
                  items: sexOption,
                  hintText: 'เลือกเพศ',
                  labelText: 'เพศ',
                  value: selectedSex,
                  onChange: (val) {
                    selectedSex = val;
                  },
                ),
                GestureDetector(
                  onTap: () => _showDatePicker(),
                  child: AbsorbPointer(
                    child: SquareInput(
                      hintText: 'วันเกิด',
                      labelText: 'วันเกิด',
                      validate: (val) => val.isEmpty ? '' : null,
                      textController: _dob,
                      textInputAction: TextInputAction.next,
                      //onEditingComplete: () => node.nextFocus(),
                    ),
                  ),
                ),
                SquareInput(
                  hintText: 'ที่อยู่',
                  labelText: 'ที่อยู่',
                  textController: _address,
                  textInputAction: TextInputAction.next,
                  //onEditingComplete: () => node.nextFocus(),
                ),
                DropDown(
                  items: provinceOption,
                  hintText: '',
                  labelText: 'จังหวัด',
                  value: selectedProvince,
                  onChange: (val) {
                    selectedProvince = val;
                    selectedDistrict = null;
                    selectedSubDistrict = null;
                    setDistrict(val);
                    setState(() {});
                  },
                ),
                if (districtOption.isNotEmpty)
                  DropDown(
                    items: districtOption,
                    hintText: '',
                    labelText: 'อำเภอ/เขต',
                    value: selectedDistrict,
                    onChange: (val) {
                      selectedSubDistrict = null;
                      selectedDistrict = val;
                      setSubDistrict(val);
                      setState(() {});
                    },
                  ),
                if (subdistrictOption.isNotEmpty)
                  DropDown(
                    items: subdistrictOption,
                    hintText: '',
                    labelText: 'ตำบล/แขวง',
                    value: selectedSubDistrict,
                    onChange: (val) {
                      selectedSubDistrict = val;
                      setState(() {});
                    },
                  ),
                SquareInput(
                  hintText: 'เลขที่บัญชี',
                  labelText: 'เลขที่บัญชี',
                  validate: (val) => val.isEmpty ? '' : null,
                  textController: _bank,
                  textInputAction: TextInputAction.next,
                  //onEditingComplete: () => node.nextFocus(),
                ),
                DropDown(
                  items: bankOption,
                  hintText: '',
                  labelText: 'ธนาคาร',
                  value: selectedBank,
                  onChange: (val) {
                    selectedBank = val;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                        color: kPrimaryColor,
                        child: Text(
                          'บันทึก',
                          style: TextStyle(fontSize: 18, color: whiteFontColor),
                        ),
                        onPressed: () => validateData()),
                    // RaisedButton(
                    //     child: Text('ยกเลิก'),
                    //     onPressed: () {
                    //       Navigator.of(context).pop();
                    //     }),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
