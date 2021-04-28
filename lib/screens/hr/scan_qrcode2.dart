import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/image_picker_box.dart';
import 'package:system/components/rounded_button.dart';
import 'package:system/configs/constants.dart';
import 'package:system/screens/hr/camera_scan2.dart';
import 'package:system/services/hr_services.dart';

import 'camera_scan.dart';

class ScanQrCode2 extends StatefulWidget {
  @override
  _ScanQrCode2State createState() => _ScanQrCode2State();
}

class _ScanQrCode2State extends State<ScanQrCode2> {
  double distance;
  var _location = TextEditingController();
  var _timestamp;

  Size _size;
  List<File> imageStockList = [];

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location.text = '${position.latitude},${position.longitude}';
      distance = calculateDistance(
          position.latitude, position.longitude, 13.7120441, 100.7913766);
    });
    print(distance);
    print(position);
  }

  double calculateDistance(lat1, long1, lat2, long2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((long2 - long1) * p)) / 2;
    distance = 12742 * sin(sqrt(a));
    if (distance <= 0.2) {
      print("อยู่ในพื้นที่");
    } else {
      print("อยู่นอกพื้นที่");
    }
    return distance;
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
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
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
                                child: Icon(
                                  FontAwesomeIcons.camera,
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
                                    'สแกนคิวอาร์โค้ด',
                                    style: TextStyle(fontSize: 24.0, height: 1),
                                  ),
                                  Text(
                                    'สแกนข้อมูลเพื่อเข้า-ออกงาน',
                                    style: TextStyle(fontSize: 16.0, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                HeaderText(
                                  text: 'สแกนคิวอาร์โค้ด',
                                  textSize: 20,
                                  gHeight: 26,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 10, top: 8, bottom: 30),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        size: 200,
                                      ),
                                      // Center(
                                      //   child: Text('คลิ๊กสแกนคิวอาร์โค้ด',
                                      //     style: TextStyle(fontSize: 20.0,height: 1),),
                                      //   ),
                                      if (_timestamp != null)
                                        Center(
                                          child: Text(
                                            'สแตมป์ออกงานของคุณ \n${_timestamp}',
                                            style: TextStyle(
                                              fontSize: 22.0,
                                              height: 1,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_timestamp == null) Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, bottom: 20),
                                  child: RoundedButton(
                                      text: 'สแกน',
                                      widthFactor: 0.9,
                                      press: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CameraScan2(),
                                          ),
                                        );
                                        print('resultsssssss=>${result}');

                                        if (result != null) {
                                          _timestamp = await HrServices().getValue("currentCheckOut");
                                          print('_timestamp ${_timestamp.toString()}');
                                          setState(() {});
                                        }
                                      }),
                                ) else Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, bottom: 20),
                                  child: RoundedButton(
                                      text: 'กลับหน้าแดชบอร์ด',
                                      widthFactor: 0.9,
                                      press: ()  {
                                        Navigator.of(context).pop(_timestamp);

                                      }),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: Align(
                    alignment: Alignment.bottomCenter,
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
}
