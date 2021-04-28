import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';

import 'package:system/screens/ceo/components/ceo_car_rank_detail.dart';
import 'package:system/screens/submanager/components/chart_ranking.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CeoTeamRank extends StatefulWidget {
  @override
  _CeoTeamRankState createState() => _CeoTeamRankState();
}

class _CeoTeamRankState extends State<CeoTeamRank> {
  String selectedReport;
  var client = Client();
  int lastRank;
  List managerRank = [];
  Map<String, SaleRanking> chartDataRanking;
  Future<bool> isBarChartLoaded;
  var barSeries;
  FormatMethod f = FormatMethod();
  List<DropdownMenuItem> optionReport = [];
  GetReport s = GetReport();

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

  Future getCache(selectedReport) async {
    print('getData CeoTeamRank');
    managerRank = [];
    var res = await Sqlite().getJson('CEO_TEAM_RANK', selectedReport);
    if (res != null) {
      var data = jsonDecode(res['JSON_VALUE']);
      managerRank.addAll(data);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        try{
          managerRank = await s.getCeoTeamRanking(selectedReport: selectedReport);
        }catch(e){
          managerRank = [];
        }

      }
    }

    List chartBarColor = [
      dangerColor,
      greenColor,
      cyanColor,
      indigoColor,
      orangeColor,
      grayDarkColor
    ];

    for (int i = 0; i < managerRank.length; i++) {
      if (i == 0) {
        chartDataRanking = {
          'rank ${i + 1}': SaleRanking(
              managerRank[i]['rank'],
              managerRank[i]['car_sum_cat1'],
              managerRank[i]['car_team_name'],
              charts.ColorUtil.fromDartColor(chartBarColor[i]),
              legendColor: chartBarColor[i],
              imgAvatar: managerRank[i]['car_team_img'])
        };
      } else {
        chartDataRanking['rank ${i + 1}'] = SaleRanking(
            managerRank[i]['rank'],
            managerRank[i]['car_sum_cat1'],
            managerRank[i]['car_team_name'],
            charts.ColorUtil.fromDartColor(chartBarColor[i]),
            legendColor: chartBarColor[i],
            imgAvatar: managerRank[i]['car_team_img']);
      }
    }

    if (managerRank.length == 0) {
      isBarChartLoaded = Future.value(false);
    } else {
      barSeries = [
        charts.Series<SaleRanking, String>(
          id: 'Sales',
          domainFn: (SaleRanking sales, _) => sales.rank.toString(),
          measureFn: (SaleRanking sales, _) => sales.total,
          colorFn: (SaleRanking sales, _) => sales.color,
          data: chartDataRanking.values.toList(),
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (SaleRanking sales, _) =>
              '${f.SeperateNumber(sales.total.toString())} กระสอบ',
          insideLabelStyleAccessorFn: (SaleRanking sales, _) {
            final color = charts.MaterialPalette.black;
            return new charts.TextStyleSpec(color: color, fontFamily: 'DB');
          },
          outsideLabelStyleAccessorFn: (SaleRanking sales, _) {
            final color = charts.MaterialPalette.black;
            return new charts.TextStyleSpec(color: color, fontFamily: 'DB');
          },
        )
      ];
      isBarChartLoaded = Future.value(true);
    }
    setState(() {});
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
        onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CeoCarRankDetail()));
        },
        child: Card(
          child: Column(
            children: [
              Stack(
                children: [
                  HeaderText(text: 'Top 5 ยอดขายตามคันรถ ประจำเดือนนี้',textSize: 20,gHeight: 26,),
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
              // Container(
              //   width: size.width * 0.9,
              //   child: RaisedButton(
              //       child: Text('ดูเพิ่มเติม'),
              //       onPressed: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => CeoCarRankDetail()));
              //       }),
              // ),
              SizedBox(height: 18,),
              FutureBuilder(
                  future: isBarChartLoaded,
                  builder: (ctx, snap) {
                    if (snap.hasData) {
                      if (snap.data == true) {
                        return ChartRanking(
                          series: barSeries,
                          legenData: chartDataRanking,
                        );
                      } else {
                        return Container(child: Text('ไม่มีข้อมูล'));
                      }
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
              SizedBox(height: 3,)
            ],
          ),
        ),
      ),
    );
  }
}
