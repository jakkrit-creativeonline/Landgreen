import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;


class CEOReportTrail extends StatefulWidget {
  @override
  _CEOReportTrailState createState() => _CEOReportTrailState();
}

class _CEOReportTrailState extends State<CEOReportTrail> {
  FormatMethod f = FormatMethod();
  Future<List> _listReportTrial;

  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  String selectedMonth = '';
  String startDate ='';
  String endDate='';

  int sumItem=0;
  var test;

  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();


  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async{

    selectedMonth = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
    var year = '${initDate.toString().split('-')[0]}';
    var month = '${initDate.toString().split('-')[1]}';

    var res = await Sqlite().getJson('CEO_REPORT_TRAIL', selectedMonth);
    _listReportTrial = Future.value();

    if (res != null) {
      // test = res['JSON_VALUE'];
      // print(res['JSON_VALUE']);
      List data = await jsonDecode(res['JSON_VALUE']);
      _listReportTrial = Future.value(data);

    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-accounts',
              body: {
                'func': 'getTrialHistory_forapp',
                'year': year,
                'month': month
              }
          );
          if (res.statusCode == 200) {
            print('online');
            // Sqlite().insertJson('CEO_REPORT_TRAIL', selectedMonth, res.body);
            List data = jsonDecode(res.body);
            await CalculateData(data);
            // return data;
          }
        } catch (e) {
          print('error $e');
          _listReportTrial = Future.value([]);
          Navigator.pop(context);
        }

      }
    }
    if(mounted)setState(() {});

  }

  CalculateData(List data) async{
    sumItem =0;
    print('CalculateData');
    List carList =[];
    //แยกผลรวมของแต่ละคันรถ
     data.forEach((row) {
      var indexFindCar = carList.indexWhere((ele) => ele['car_id']==row['car_id']);
      if(indexFindCar == -1){
        List orderDetail = jsonDecode(row['trail_orderdetail']);

        carList.add({
          'car_id':row['car_id'],
          'car_name':'${row['car_number']}  ${row['car_province']}',
          'team_name':'${row['team_name']}',
          'orderDetail':orderDetail
        });
      }else{
        List oldOrderDetail = carList[indexFindCar]['orderDetail'];
        List newOrderDetail = jsonDecode(row['trail_orderdetail']);
        var i=0;
        newOrderDetail.forEach((eleN) {
          int indexO = oldOrderDetail.indexWhere((eleO) => eleN['name'].toString().trim() == eleO['name'].toString().trim() );
          if(indexO == -1){
            oldOrderDetail.add(newOrderDetail[i]);
          }else{
            if(eleN['qty'] !='' && eleN['qty']!='null')
              // print('${eleN['qty']} ===  ${oldOrderDetail[indexO]['qty']}');
              oldOrderDetail[indexO]['qty']+= int.parse(eleN['qty'].toString());
          }
          i++;
        });
        carList[indexFindCar]['orderDetail'] = oldOrderDetail;
      }
    });

    // print('carList =${carList.toString()}');
    var saveData = jsonEncode(carList);
    // print('saveData ${saveData}');
    print('คำนวนเสร็จ');
    Sqlite().insertJson('CEO_REPORT_TRAIL', selectedMonth, saveData);
    _listReportTrial = Future.value(carList);

    if(mounted)setState(() {
      Navigator.pop(context);
    });



  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      _listReportTrial = Future.value();
      var year = '${initDate.toString().split('-')[0]}';
      var month = '${initDate.toString().split('-')[1]}';
      try {

        var res = await http.post('$apiPath-accounts',
            body: {
              'func': 'getTrialHistory_forapp',
              'year': year,
              'month': month
            }
        );
        if (res.statusCode == 200) {
          print('online');
          // Sqlite().insertJson('CEO_REPORT_TRAIL', selectedMonth, res.body);
          List data = jsonDecode(res.body);

          await CalculateData(data);
          // return data;
        }
      } catch (e) {
        print('error $e');
        _listReportTrial = Future.value([]);
      }


      setState(() {});
    }
  }

  Future _showMonthPicker() async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(2020, 6),
      // lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: initDate,
      locale: Locale("th"),
    ).then((date) {
      if (date != null) {
        initDate = date;
        selectedMonth =
        '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        getData();
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
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
                  titleSpacing:0.00,
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
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 5),
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
                                child: Icon(FontAwesomeIcons.fileAlt,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายงานแจกสินค้าทดลอง',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('หน้านี้สรุปข้อมูลจากวันที่ลูกค้ารับสินค้าทดลอง',style: TextStyle(fontSize: 16.0,height: 1),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SliverToBoxAdapter(
                    //   child: Center(
                    //     child: Text('$test'),
                    //   ),
                    // ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () {
                                  // _showDateTimeRange(context);
                                  _showMonthPicker();
                                },
                                child: AbsorbPointer(
                                  child: ClipRRect(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                                    child: TextField(
                                                      controller: monthSelectText,
                                                      textAlign: TextAlign.center,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        // labelText:'ข้อมูล ณ วันที่',
                                                        hintText: 'ข้อมูลประจำเดือนนี้ /',
                                                        contentPadding: EdgeInsets.all(5),
                                                        border: InputBorder.none,
                                                        isDense: true,

                                                      ),

                                                      style: TextStyle(fontSize: 18,),
                                                    ),
                                                  ),

                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(width: 2,color: subFontColor),
                                                      bottom: BorderSide(width: 2,color: subFontColor),
                                                    ),
                                                    color: bgInputColor,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 5,
                                                  child: Container(
                                                    child: Icon(Icons.arrow_drop_down_outlined,color: Colors.black,size: 28,),
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: _listReportTrial,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              List data = snapshot.data.toList();
                              return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var obj = data[index];
                                  List objItem = obj['orderDetail'];
                                  return Card(
                                    child: Column(
                                      children: [
                                        HeaderText(text:'${index+1}. ทีม${obj['team_name']}',textSize: 20,gHeight: 26,),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              ListView.builder(
                                                primary: false,
                                                shrinkWrap: true,
                                                  itemBuilder: (context, i) {
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                          Text('${objItem[i]['name']}',style: _baseFontStyle,),
                                                          Text('${objItem[i]['qty']}',style: _baseFontStyle,),
                                                      ],
                                                    );
                                                      // Text('${objItem[i]['name']}',style: _baseFontStyle,);
                                                  },
                                                itemCount: objItem.length,
                                              ),
                                              // Text('${objItem.length}')
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  );
                                },
                              );
                            }else{
                              return ShimmerLoading(type: 'boxText',);
                            }
                          },
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
          ),
        )
    );
  }
}
