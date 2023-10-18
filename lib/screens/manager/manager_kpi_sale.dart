import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;
import 'package:system/screens/head/components/head_kpi_sale_detail.dart';
import 'package:system/screens/head/head_kpi_sale.dart';

class ManagerKPISale extends StatefulWidget {
  final int manager_id;
  final DateTime selectedMonth;

  const ManagerKPISale({Key key, this.manager_id, this.selectedMonth})
      : super(key: key);
  @override
  _ManagerKPISaleState createState() => _ManagerKPISaleState();
}

class _ManagerKPISaleState extends State<ManagerKPISale> {
  Future<Map<String, dynamic>> carDetail;

  Future<List> showData;

  String firstBillDue = '';
  String lastBillDue = '';
  String selectedMonth = '';
  int sumBill = 0;
  int sumCat1 = 0;
  int sumMoney = 0;
  int sumWaitBill = 0;
  int sumWaitCat1 = 0;
  int sumWaitMoney = 0;
  int sumSuccessBill = 0;
  int sumSuccessCat1 = 0;
  int sumSuccessCat17day = 0;
  int sumSuccessMoney = 0;
  int sumSuccessPercent = 0;
  int sumPaySomeMoney = 0;

  DateTime initDate = DateTime.now();

  FormatMethod f = FormatMethod();
  var monthSelectText = TextEditingController();


  resetData() {
    sumBill = 0;
    sumCat1 = 0;
    sumWaitBill = 0;
    sumWaitCat1 = 0;
    sumSuccessBill = 0;
    sumSuccessCat1 = 0;
    sumSuccessPercent = 0;
    sumPaySomeMoney = 0;
  }

  Future<Null> calculateShowData(showData) async {
    showData.forEach((element) {
      sumBill += element['car_sum_bill'];
      sumCat1 += element['car_sum_cat1'];
      sumWaitBill += element['car_book_bill'];
      sumWaitCat1 += element['car_book_cat1'];
      sumSuccessBill += element['car_sended_bill'];
      sumSuccessCat1 += element['car_sended_cat1'];
    });
    sumPaySomeMoney = sumCat1 - (sumSuccessCat1 + sumWaitCat1);
    if(sumCat1>0){
      sumSuccessPercent = ((sumSuccessCat1 / sumCat1) * 100).round();
    }else{
      sumSuccessPercent = 0;
    }

    DateTime now;
    if (selectedMonth == '') {
      now = DateTime.now();
    } else {
      now = DateTime.parse(selectedMonth.split('/')[0] +
          '-' +
          selectedMonth.split('/')[1] +
          '-01');
    }
    String lastDayOfMonth =
    DateTime(now.year, now.month + 1, 0).toString().split(' ')[0];
    String firstDayOfMonth =
    DateTime(now.year, now.month).toString().split(' ')[0];
    print('firstDayOfMonth => $firstDayOfMonth');
    print('lastDayOfMonth => $lastDayOfMonth');
    firstBillDue = '${f.ThaiFormat(firstDayOfMonth)}';
    lastBillDue = '${f.ThaiFormat(lastDayOfMonth)}';
    print('calculateShowData');
    if (mounted) setState(() {});
  }

  Future<Map<String, dynamic>> getCarDetail() async {
    return Sqlite().getDetailCar(widget.manager_id);
  }

  Future<List> fetchShowData({bool isRefresh = false}) async {
    resetData();
    var res = await Sqlite()
        .getJson('KPI_SALE_MANAGER_${widget.manager_id}', selectedMonth);
    if (!isRefresh && res != null) {
      print('offline');
      List temp = jsonDecode(res['JSON_VALUE'],);
      await calculateShowData(temp);
      temp.sort((a, b) => b['car_book_cat1'] - a['car_book_cat1']);
      return temp;
    } else {
      print('online');
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      final body = {
        'func': 'reportSaleKPIManager',
        'manager_id': '${widget.manager_id}',
        'changeMonthSelect': selectedMonth
      };
      final response = await http.post('$apiPath-accounts', body: body);
      Navigator.pop(context);
      if (response.statusCode == 200) {
        print('response.body');
        print(response.body.runtimeType);
        if(response.body != '{"nofile":"nofile"}'){
          List temp = jsonDecode(response.body);

          Sqlite().insertJson('KPI_SALE_MANAGER_${widget.manager_id}',
              selectedMonth, response.body);
          await calculateShowData(temp);
          temp.sort((a, b) => b['car_book_cat1'] - a['car_book_cat1']);
          return temp;
        }else{
          AlertNewDesign().showNoData(context,MediaQuery.of(context).size);
        }

      } else
        throw Exception('ไม่มีข้อมูล กรุณาลองใหม่ในภายหลัง');
    }
  }

  Future refresh() async {
    showData =  fetchShowData(isRefresh: true);
  }

  Future _showMonthPicker() async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(2020, 6),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: initDate,
      locale: Locale("th"),
    ).then((date) {
      if (date != null) {
        initDate = date;
        selectedMonth =
        '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        showData = fetchShowData();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print('widget.selectedMonth =>${widget.selectedMonth}');
    if (widget.selectedMonth != null) {
      initDate = widget.selectedMonth;
      selectedMonth =
      '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
      var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
      monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
    }
    // carDetail = getCarDetail();
    showData = fetchShowData();
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
            body: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                slivers: [
                  showTeamName(),
                  summaryInfo(size),
                  showDetail(size),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Footer(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  SliverToBoxAdapter showTeamName() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
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
                    child: Icon(FontAwesomeIcons.chartPie,color: btTextColor,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รายงาน KPI ยอดเปิดใบสั่งจอง',style: TextStyle(fontSize: 24.0,height: 1),),
                      Text('แยกข้อมูลรายคันรถ ',style: TextStyle(fontSize: 18.0,height: 1),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Text('รายงาน เครดิต ทะเบียน ${snapshot.data['car_name']}'),
          // Text('ทีม${snapshot.data['team_name']}')
        ],
      )
    );
  }

  SliverToBoxAdapter summaryInfo(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                'ข้อมูลลูกค้าเซ็นใบสั่งจองสินค้ากำหนดชำระวันที่ $firstBillDue ถึง $lastBillDue (นับรวมยอดขายของคนที่ออกด้วย)',style: TextStyle(fontSize: 15),),
            ),
            SizedBox(height: 5,),
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
                                        hintText: 'ข้อมูลประจำเดือนนี้',
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
            // Text('ข้อมูลเครดิต ตามวันที่กำหนดชำระบิล (ไม่รวมเครดิต 7 วัน)'),
            // Text(
            //     'ข้อมูลบิลกำหนดชำระวันที่ $firstBillDue ถึง $lastBillDue (นับรวมยอดขายของคนที่ออกด้วย)'),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'สรุปรวมทั้งหมด',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนบิล ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'จองแล้ว',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนบิล ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumWaitBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'ส่งลูกค้าแล้ว',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนบิล ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumSuccessBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('คิดเป็น%ที่ส่งลูกค้าแล้ว',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),
                            ),
                            Text('${f.SeperateNumber(sumSuccessPercent)} %',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),),
                          ],
                        ),
                        Text('(%คิดจาก จำนวนกระสอบที่ส่งแล้ว หารด้วย จำนวนกระสอบทั้งหมด)',style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget showDetail(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    TextStyle _baseFontStyleInCard = TextStyle(fontSize: 18,color: Colors.white);
    Size size = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
            future: showData,
            builder: (context, snap) {
              if (snap.hasData) {
                print('has data =>${snap.data}');
                return ListView.builder(
                    itemCount: snap.data.length,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (bc, i) {
                      var res = snap.data[i];

                      var percent = 0;
                      if (res['car_sum_cat1'] > 0) {
                        percent =
                            ((res['car_sended_cat1'] / res['car_sum_cat1']) *
                                100)
                                .round();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(name: '(${res['car_id']})ดูรายงานเปิดใบสั่งจองรายคันรถ'),
                                  builder: (context) => HeadKPISale(
                                    selectedMonth: initDate,
                                    carId: res['car_id'],
                                  )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Stack(
                                children: [
                                  HeaderText(text: 'ทะบียน ${res['car_name']} ทีม ${res['team_name']}',),
                                  Positioned(
                                    right: -1,
                                    top: -2,
                                    child: Container(
                                      child: Icon(Icons.arrow_right,color: Colors.white,size: 28,),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 7,top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,

                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('จำนวนบิลทั้งหมด',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['car_sum_bill'])} บิล',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('จำนวนกระสอบทั้งหมด',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['car_sum_cat1'])} กระสอบ',style: _baseFontStyle,),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Card(
                                        color: (percent == 0)
                                            ? darkColor
                                            : percent < 50
                                            ? redColor
                                            : percent < 80
                                            ? warningColor
                                            : kSecondaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 3),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'ส่งแล้ว',
                                                style: TextStyle(color: Colors.white,fontSize: 18,height: 1),
                                              ),
                                              Text(
                                                '$percent%',
                                                style: TextStyle(color: Colors.white,fontSize: 38,height: 0.8),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Divider(indent: 15,endIndent: 10,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 8,bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: dangerColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8,bottom: 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('จองแล้ว',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['car_book_bill'])} บิล',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('จำนวน',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['car_book_cat1'] )} กระสอบ',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: kSecondaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8,bottom: 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('ส่งแล้ว',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['car_sended_bill'])} บิล',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('จำนวน',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['car_sended_cat1'])} กระสอบ',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      );
                      // return GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => ReportCarDetailSale(
                      //                   saleId: res['sale_id'],
                      //                   selectedReport: initDate,
                      //                 )));
                      //   },
                      //   child: Card(
                      //     child: Row(
                      //       children: [
                      //         Expanded(
                      //           flex: 1,
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text('เซล : ${res['Sale_name']}'),
                      //               Text(
                      //                 'เก็บครบ : $percent %',
                      //                 style: TextStyle(
                      //                     color: percent == 0
                      //                         ? darkColor
                      //                         : percent < 50
                      //                             ? redColor
                      //                             : percent < 80
                      //                                 ? orangeColor
                      //                                 : kPrimaryColor),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text('ทั้งหมด'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_total'])} บิล'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_cat1'])} กระสอบ'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_money_due'])} บาท'),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text(
                      //                   'ค้างจ่าย',
                      //                   style: TextStyle(color: dangerColor),
                      //                 ),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_bill'])} บิล',
                      //                     style: TextStyle(color: dangerColor)),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_cat1'])} กระสอบ',
                      //                     style: TextStyle(color: dangerColor)),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_money_due'])} บาท',
                      //                     style: TextStyle(color: dangerColor)),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text('เก็บครบ'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_bill'])} บิล'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_cat1'])} กระสอบ'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_money'])} บาท'),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    });
              } else if (snap.hasError) {
                print('error ${snap.error}');
                return Align(
                    alignment: Alignment.topCenter,
                    child: Text('ไม่มีข้อมูล กรุณาลองใหม่ในภายหลัง'));
              } else {
                print('loading');
                return ShimmerLoading(type: 'boxText2row',);
              }
            }),
      ),
    );
  }
}
