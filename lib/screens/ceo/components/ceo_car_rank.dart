import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/ceo_car_rank_detail.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CeoCarRank extends StatefulWidget {
  @override
  _CeoCarRankState createState() => _CeoCarRankState();
}

class _CeoCarRankState extends State<CeoCarRank> {
  var client = Client();
  String selectedReport;
  List<DropdownMenuItem> optionReport = [];
  Future<bool> isLoaded;
  List showData = [];
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();

  String thai_date(int y, int m) {
    var monthTH = [
      null,
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค."
    ];
    return 'ประจำ ${monthTH[m]} ${(y + 543).toString().substring(2)}';
  }

  Future getAvaliable() async {
    print('getAvaliable');
    var res = await Sqlite().getJson('AVALIABLE_REPORT', '1');
    if (res != null) {
      List data = jsonDecode(res['JSON_VALUE']);
      data.sort((a, b) => b['ID'] - a['ID']);
      setAvaliableOption(data);
    } else {
      setOption(5);
    }
  }

  Future getData() async {
    await getAvaliable();
    await getCache(selectedReport);
    //setState(() {});
  }

  setAvaliableOption(List data) {
    var monthTH = [
      null,
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค."
    ];
    data.forEach((element) {
      var dateString = '${element['Year']}-${element['Month']}';
      optionReport.add(
        DropdownMenuItem(
          value: dateString,
          child: Text(
            thai_date(int.parse(element['Year']), int.parse(element['Month'])),
          ),
        ),
      );
    });
    selectedReport = '${data[0]['Year']}-${data[0]['Month']}';
    optionReport[0] =
        DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
  }

  setOption(int n) {
    DateTime now = DateTime.now();
    var y = now.year;
    var m = now.month;
    var d = now.day;
    for (int i = 0; i < n; i++) {
      DateTime date = DateTime(now.year, (now.month - i));
      var year = date.year;
      var month = date.month;
      var monthTH = [
        null,
        "ม.ค.",
        "ก.พ.",
        "มี.ค.",
        "เม.ย.",
        "พ.ค.",
        "มิ.ย.",
        "ก.ค.",
        "ส.ค.",
        "ก.ย.",
        "ต.ค.",
        "พ.ย.",
        "ธ.ค."
      ];
      var dateString = '${year.toString()}-${month.toString().padLeft(2, '0')}';
      optionReport.add(DropdownMenuItem(
          value: dateString, child: Text(thai_date(date.year, date.month))));
    }
    // (d >= 1 && d <= 5)
    if (d >= 1 && d <= 5) {
      m = (m - 1) == 0 ? 12 : (m - 1);
      // y = y - 1;
      y = (m==0)?(y - 1):y;
      selectedReport = '${y.toString()}-${m.toString().padLeft(2, '0')}';
      optionReport[1] =
          DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
    } else {
      selectedReport = '${y.toString()}-${m.toString().padLeft(2, '0')}';
      optionReport[0] =
          DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
    }
    //setState(() {});
  }

  Future<Null> getCache(selectedReport) async {
    print('getCache');

    showData = [];
    var res = await Sqlite().getJson('CEO_CAR_RANKING', selectedReport);
    print('getCache=>${res}');
    if (res != null) {
      showData = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var result = await s.getCeoCarRanking(selectedReport: selectedReport);
        showData = jsonDecode(result);
      }
    }
    showData.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
    isLoaded = Future.value(true);
    setState(() {});
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
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
                          MaterialPageRoute(
                              builder: (BuildContext bc) => CeoCarRankDetail()));
        },
        child: Card(
          child: Column(
            children: [
              Stack(
                children: [
                  HeaderText(text:'ข้อมูลสถิติยอดขายแบ่งตามทะเบียนรถ ประจำเดือนนี้',textSize: 20,gHeight: 26,),
                  Positioned(
                    top: 0,
                    right: 0,
                      child: Icon(Icons.arrow_right,color: whiteColor,))
                ],
              ),
              // DropDown(
              //   items: optionReport,
              //   hintText: '',
              //   value: selectedReport,
              //   onChange: (val) => getCache(val),
              // ),
              // if (showData.length > 0)
              //   Container(
              //       width: size.width,
              //       child: RaisedButton(
              //           child: Text('ดูเพิ่มเติม'),
              //           onPressed: () {
              //             Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                     builder: (BuildContext bc) => CeoCarRankDetail()));
              //           })),
              FutureBuilder(
                  future: isLoaded,
                  builder: (bc, snap) {
                    if (snap.hasData) {
                      TextStyle _baseFontStyle = TextStyle(fontSize: 18,height: 1);
                      return ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: (showData.length>5)?5:showData.length,
                          itemBuilder: (bc, i) {
                            var res = showData[i];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4,top: 5,right: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(Icons.arrow_right,size: 25,),
                                      Text('อันดับ ${i + 1}',style: _baseFontStyle,),
                                      Text(
                                          ' ทะเบียนรถ ${res['car_plate_number']} ${res['car_plate_province']}',style: _baseFontStyle),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 28,right: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ทีมขาย ${res['car_team_name']} เขตพื้นที่การขาย ${res['car_team_province_area']}',style: _baseFontStyle),
                                      Text('รวม : ${f.SeperateNumber(res['car_sum_cat1'])} กระสอบ',style: _baseFontStyle),
                                    ],

                                  ),
                                ),
                                Divider(indent: 28,endIndent: 30,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 28,right: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'เงิดสด 590 : ${res['car_bill_cash_cat1_590']} กระสอบ',style: _baseFontStyle),
                                          Text(
                                              'เงิดสด 690 : ${res['car_bill_cash_cat1_690']} กระสอบ',style: _baseFontStyle),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'เครดิต 590 : ${res['car_bill_credit_cat1_590']} กระสอบ',style: _baseFontStyle),
                                          Text(
                                              'เครดิต 690 : ${res['car_bill_credit_cat1_690']} กระสอบ',style: _baseFontStyle),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Divider(thickness: 1,),
                              ],
                            );
                          });
                    } else {
                      return Container();
                    }
                  }),
              Card(
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: grayFontColor,
                  ),
                  width: size.width*0.85,
                  height: 40,
                  child: Center(
                    child: Text('ดูข้อมูลเพิ่มเติมคลิ๊ก',style: TextStyle(fontSize: 24,color: whiteFontColor),),
                  ),
                ),
              ),
              SizedBox(height: 5,)
            ],
          ),
        ),
      ),
    );
  }
}
