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


class HrOverTime extends StatefulWidget {
  final int editStatus;

  const HrOverTime({Key key,

    this.editStatus,

  })
      : super(key: key);

  @override
  _HrOverTimeState createState() => _HrOverTimeState();
}

class _HrOverTimeState extends State<HrOverTime> {
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
  var starttime = TextEditingController();
  var endtime = TextEditingController();
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
      setState(() {});
    }
  }
  Future<void> _openTimePicker(BuildContext context) async {
    final TimeOfDay result = await showTimePicker(
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // change the border color
                primary: kPrimaryColor,
                // change the text color
                onSurface: kPrimaryColor,
              ),
              // button colors
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: Colors.green,
                ),
              ),
            ),
            child: child,
          );
        },
        context: context, initialTime: TimeOfDay.now() );
    if (result != null) {
      setState(() {
        starttime.text= result.format(context);
        endtime.text= result.format(context);
      });
    }
  }
  Future<void> _openendTimePicker(BuildContext context) async {
    final TimeOfDay result = await showTimePicker(
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // change the border color
                primary: kPrimaryColor,
                // change the text color
                onSurface: kPrimaryColor,
              ),
              // button colors
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: Colors.green,
                ),
              ),
            ),
            child: child,
          );
        },
        context: context, initialTime: TimeOfDay.now() );
    if (result != null) {
      setState(() {
        endtime.text= result.format(context);
      });
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
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  child: Icon(FontAwesomeIcons.businessTime,
                                    color: btTextColor,),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('บันทึกโอที', style: TextStyle(
                                        fontSize: 24.0, height: 1),),
                                    Text('กรอกรายละเอียดข้อมูลบันทึกโอที',
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
                              title: 'บันทึกโอที',

                              child: Padding(
                                padding: EdgeInsets.only(left: 7, top: 0,right: 7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(
                                      height: 15,
                                    ),
                                    GestureDetector(
                                        onTap: () => _showDatePicker(context),
                                        child: AbsorbPointer(
                                          child: SquareInput(
                                            hintText: 'เลือกวันที่ี่',
                                            labelText: 'เลือกวันที่ี่',
                                            textController: selectedDateText,
                                            validate: (val) => val.isEmpty ? '' : null,
                                          ),
                                        )),
                                    GestureDetector(
                                        onTap: () => _openTimePicker(context),
                                        child: AbsorbPointer(
                                          child: SquareInput(
                                            hintText: 'เวลาเริ่มต้น',
                                            labelText: 'เวลาเริ่มต้น',
                                            textController: starttime,
                                            validate: (val) => val.isEmpty ? '' : null,
                                          ),
                                        )),
                                    GestureDetector(
                                        onTap: () => _openendTimePicker(context),
                                        child: AbsorbPointer(
                                          child: SquareInput(
                                            hintText: 'เวลาสิ้นสุด',
                                            labelText: 'เวลาสิ้นสุด',
                                            textController: endtime,
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
                                    SizedBox(
                                      height: 8,
                                    ),

                                  ],
                                ),



                              ),


                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Footer(),
                  ),
                )
              ],
            )
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