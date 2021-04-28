import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:system/components/form_card.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:system/components/drop_down.dart';


class HrPersonal extends StatefulWidget {
  final int editStatus;

  const HrPersonal({Key key,

    this.editStatus,

  })
      : super(key: key);

  @override
  _HrPersonalState createState() => _HrPersonalState();
}

class _HrPersonalState extends State<HrPersonal> {
  var _day;


  File image;

  final picker = ImagePicker();
  File _image;
  var _selectImage = TextEditingController();
  var _detail = TextEditingController();

  bool forImageList;

  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  var selectedDateText = TextEditingController();
  var enddate = TextEditingController();
  FormatMethod f = FormatMethod();

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
      selectedDate2 = picked;
      enddate.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      setState(() {});
    }
  }
  Future<Null> enddatePicker(context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('th', 'TH'),
        initialDate: selectedDate2,
        firstDate: DateTime(1917),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(data: Theme.of(context).copyWith(), child: child);
        });
    if (picked != null) {
      enddate.text = f.ThaiFormat(picked.toString().split(' ')[0]);
      selectedDate2 = picked;
      setState(() {});
    }
  }
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
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
                  decoration:
                  BoxDecoration(
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
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Container(
                width: size.width,
                height: size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
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
                                child: Icon(FontAwesomeIcons.solidEnvelopeOpen,
                                  color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('บันทึกลากิจ', style: TextStyle(
                                      fontSize: 24.0, height: 1),),
                                  Text('กรอกรายละเอียดข้อมูลบันทึกลากิจ',
                                    style: TextStyle(
                                        fontSize: 16.0, height: 1),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          FormCard(
                            title: 'บันทึกลากิจ',

                            child: Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
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
                                      : Center(
                                    child: Container(
                                      padding: EdgeInsets.all(90),
                                      color: backgroundColor,
                                      child: IconButton(
                                          icon: Icon(Icons.add_photo_alternate_outlined),
                                          iconSize: 100,
                                          onPressed: () => _showPicker(context)),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  IgnorePointer(
                                    ignoring: false,
                                    child: DropDown(
                                      items: {'1': 'เต็มวัน', '2': 'ครึ่งวัน'}
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
                                      hintText: 'เลือกประเภท',
                                      onTap: () => node.unfocus(),
                                      value: _day,
                                      onChange: (val) {
                                        setState(() {
                                          _day = val;
                                          print(val);
                                        });
                                      },
                                      validator: (val) => val == null ? '' : null,
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () => _showDatePicker(context),
                                      child: AbsorbPointer(
                                        child: SquareInput(
                                          hintText: 'วันที่เริ่มต้น',
                                          labelText: 'วันที่เริ่มต้น',
                                          textController: selectedDateText,
                                          validate: (val) => val.isEmpty ? '' : null,
                                        ),
                                      )),
                                  GestureDetector(
                                      onTap: () => enddatePicker(context),
                                      child: AbsorbPointer(
                                        child: SquareInput(
                                          hintText: 'วันที่สิ้นสุด',
                                          labelText: 'วันที่สิ้นสุด',
                                          textController: enddate,
                                          validate: (val) => val.isEmpty ? '' : null,
                                        ),
                                      )),
                                  SquareInput(
                                    hintText: 'รายละเอียด',
                                    labelText: 'รายละเอียด',
                                    textController: _detail,
                                    maxLine: 3,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: RoundedButton(text: 'ส่ง',
                                        widthFactor: 0.9,
                                        press: (){
                                          Navigator.of(context).pop();

                                        }),
                                  ),

                                ],
                              ),



                            ),


                          ),
                          Footer(),
                        ],
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




}