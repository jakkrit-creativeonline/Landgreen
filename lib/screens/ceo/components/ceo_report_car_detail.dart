import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/report_car_detail_sale.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';

class CeoReportCarDetail extends StatefulWidget {
  final int carId;
  final DateTime selectedMonth;

  const CeoReportCarDetail({Key key, this.carId, this.selectedMonth})
      : super(key: key);

  @override
  _CeoReportCarDetailState createState() => _CeoReportCarDetailState();
}

class _CeoReportCarDetailState extends State<CeoReportCarDetail> {
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
  int sumSuccessMoney = 0;
  int sumSuccessPercent = 0;
  int sumPaySomeMoney = 0;

  DateTime initDate = DateTime.now();

  FormatMethod f = FormatMethod();
  var monthSelectText = TextEditingController();


  resetData() {
    sumBill = 0;
    sumCat1 = 0;
    sumMoney = 0;
    sumWaitBill = 0;
    sumWaitCat1 = 0;
    sumWaitMoney = 0;
    sumSuccessBill = 0;
    sumSuccessCat1 = 0;
    sumSuccessMoney = 0;
    sumSuccessPercent = 0;
    sumPaySomeMoney = 0;

  }

  Future<Null> calculateShowData(showData) async {
    showData.forEach((element) {
      sumBill += element['bill_total'];
      sumCat1 += element['bill_cat1'];
      sumMoney += element['bill_money_due'];
      sumWaitBill += element['waitPay_bill'];
      sumWaitCat1 += element['waitPay_cat1'];
      sumWaitMoney += element['waitPay_money_due'];
      sumSuccessBill += element['paySuccess_bill'];
      sumSuccessCat1 += element['paySuccess_cat1'];
      sumSuccessMoney += element['paySuccess_money'];
    });
    sumPaySomeMoney = sumMoney - (sumSuccessMoney + sumWaitMoney);
    if(sumMoney>0){
      sumSuccessPercent = ((sumSuccessMoney / sumMoney) * 100).round();
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

    firstBillDue = '${f.ThaiFormat(firstDayOfMonth)}';
    lastBillDue = '${f.ThaiFormat(lastDayOfMonth)}';
    print('calculateShowData');
    if (mounted) setState(() {});
  }

  Future<Map<String, dynamic>> getCarDetail() async {
    return Sqlite().getDetailCar(widget.carId);
  }

  Future<List> fetchShowData({bool isRefresh = false}) async {
    resetData();
    var res = await Sqlite()
        .getJson('CEO_CREDIT_REPORT_CAR_${widget.carId}', selectedMonth);
    if (!isRefresh && res != null) {
      print('offline');
      List temp = jsonDecode(res['JSON_VALUE']);
      await calculateShowData(temp);
      temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
      return temp;
    } else {
      print('online');
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      final body = {
        'func': 'reportCreditPerCarDetail',
        'car_id': '${widget.carId}',
        'changeMonthSelect': selectedMonth
      };
      final response = await http.post('$apiPath-credit', body: body);
      Navigator.pop(context);
      if (response.statusCode == 200) {
        List temp = jsonDecode(response.body);
        Sqlite().insertJson('CEO_CREDIT_REPORT_CAR_${widget.carId}',
            selectedMonth, response.body);
        await calculateShowData(temp);
        temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
        return temp;
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
        showData = Future.value();
        setState(() {});
        initDate = date;
        selectedMonth =
            '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        showData =  fetchShowData();
        setState(() {});
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
    carDetail = getCarDetail();
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
                titleSpacing:0.00,
                // title: Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     MyNoti(
                //       userId: user_id,
                //     )
                //   ],
                // ),
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
                print('has data');
                return ListView.builder(
                    itemCount: snap.data.length,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (bc, i) {
                      var res = snap.data[i];
                      var percent = 0;
                      if (res['bill_money_due'] > 0) {
                        percent =
                            ((res['paySuccess_money'] / res['bill_money_due']) *
                                    100)
                                .round();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          settings: RouteSettings(name: 'CEOรายงานเครดิตรายบุคคล'),
                                          builder: (context) => ReportCarDetailSale(
                                                saleId: res['sale_id'],
                                                selectedReport: initDate,
                                              )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Stack(
                                children: [
                                  HeaderText(text: 'เซล ${res['Sale_name']}',),
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                                              Text('บิลเครดิตทั้งหมด',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_total'])} บิล',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('จำนวนกระสอบ',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_cat1'])} กระสอบ',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('จำนวนเงินที่ต้องเก็บ',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_money_due'])} บาท',style: _baseFontStyle,),
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
                                          padding: const EdgeInsets.only(top: 10,left: 8,right: 8,bottom: 5),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'เก็บเงินแล้ว',
                                                style: TextStyle(color: Colors.white,fontSize: 18,height: 1),
                                              ),
                                              Text(
                                                '$percent%',
                                                style: TextStyle(color: Colors.white,fontSize: 40,height: 0.8),
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
                                                  Text('ค้างจ่าย',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_bill'])} บิล',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('จำนวน',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_cat1'] )} กระสอบ',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('เงินที่ต้องเก็บ',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_money_due'])} บาท',style: _baseFontStyleInCard,),
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
                                                  Text('เก็บครบ',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_bill'])} บิล',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('จำนวน',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_cat1'])} กระสอบ',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('เงินที่ต้องเก็บ',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_money'])} บาท',style: _baseFontStyleInCard,),
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
                'ข้อมูลบิลกำหนดชำระวันที่ $firstBillDue ถึง $lastBillDue (นับรวมยอดขายของคนที่ออกด้วย)',style: TextStyle(fontSize: 15),),
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
                            Text('บิลเครดิต ',style: _baseFontStyle,),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Container(
            //   width: size.width * 0.5,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('สรุปรวมทั้งหมด'),
            //           Text('บิลเครดิต : ${f.SeperateNumber(sumBill)} บิล'),
            //           Text('จำนวนกระสอบ : ${f.SeperateNumber(sumCat1)} กระสอบ'),
            //           Text(
            //               'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumMoney)} บาท'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'ค้างจ่ายรวม',textSize: 20,gHeight: 26,),
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
                            Text('บิลเครดิต ',style: _baseFontStyle,),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('เก็บได้บางส่วน(ลูกค้าทะยอยจ่าย) ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumPaySomeMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Container(
            //   width: size.width * 0.5,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('สรุปรวม ค้างจ่าย'),
            //           Text('บิลเครดิต : ${f.SeperateNumber(sumWaitBill)} บิล'),
            //           Text(
            //               'จำนวนกระสอบ : ${f.SeperateNumber(sumWaitCat1)} กระสอบ'),
            //           Text(
            //               'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumWaitMoney)} บาท'),
            //           Text(
            //               'เก็บได้บางส่วน(ลูกค้าทะยอยจ่าย) : ${f.SeperateNumber(sumPaySomeMoney)} บาท'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'เก็บครบรวม',textSize: 20,gHeight: 26,),
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
                            Text('บิลเครดิต ',style: _baseFontStyle,),
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
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('คิดเป็น%เงินที่เก็บได้ครบ',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),
                            ),
                            Text('${f.SeperateNumber(sumSuccessPercent)} %',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Container(
            //   width: size.width * 0.5,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('สรุปรวม เก็บครบ'),
            //           Text('บิลเครดิต : ${f.SeperateNumber(sumSuccessBill)} บิล'),
            //           Text(
            //               'จำนวนกระสอบ : ${f.SeperateNumber(sumSuccessCat1)} กระสอบ'),
            //           Text(
            //               'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumSuccessMoney)} บาท'),
            //           Text(
            //               'คิดเป็น%เงินที่เก็บได้ครบ : ${f.SeperateNumber(sumSuccessPercent)} %'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // RaisedButton(
            //     child: Text('TEST MONTH PICKER'),
            //     onPressed: () => _showMonthPicker())
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter showTeamName() {
    return SliverToBoxAdapter(
      child: FutureBuilder(
          future: carDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
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
                            child: Icon(FontAwesomeIcons.chartBar,color: btTextColor,),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ทะเบียน ${snapshot.data['car_name']} ',style: TextStyle(fontSize: 24.0,height: 1),),
                              Text('รายงาน เครดิต ทีม${snapshot.data['team_name']} ',style: TextStyle(fontSize: 18.0,height: 1),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text('รายงาน เครดิต ทะเบียน ${snapshot.data['car_name']}'),
                  // Text('ทีม${snapshot.data['team_name']}')
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
