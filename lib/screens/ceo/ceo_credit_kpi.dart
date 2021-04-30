import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;

class CeoCreditKPI extends StatefulWidget {
  @override
  _CeoCreditKPIState createState() => _CeoCreditKPIState();
}

class _CeoCreditKPIState extends State<CeoCreditKPI> {
  DateTime selectedMonth = DateTime.now();
  String selectedText = '';
  Future<List> creditPerUser;
  Future<List> creditPerUserDebt;
  String dayGen = '';
  String timeGen = '';

  FormatMethod f = FormatMethod();
  var monthSelectText = TextEditingController();

  String formatMonth(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}';
  }

  String thaiMonth(String string) {
    DateTime date = DateTime.parse(string);
    List thMonth = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return '${thMonth[date.month]} ${date.year + 543}';
  }

  _setGenTime(List data) {
    dayGen = '${f.ThaiFormat(data[0]['day_gen'])}';
    timeGen = '${data[0]['time_gen']}';
    if(mounted)setState(() {});
  }

  Future<List> getCreditPerUser({String select, bool online = false}) async {
    if (!online) {
      var res = await Sqlite().getJson('CEO_REPORT_CREDIT_PER_USER', select);
      print('res=>${res}');
      // print("res=>${res['JSON_VALUE'] != '""'}  ==> ${(res != null && res['JSON_VALUE'] != '""')}");

      if (res != null && res['JSON_VALUE'] != '""') {
        print('offline per user');
        _setGenTime(json.decode(res['JSON_VALUE']));
        return json.decode(res['JSON_VALUE']);
      }
    }
    try {
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      var body = {'func': 'report_credit_per_user', 'fileselect': select};
      var res = await http.post('$apiPath-commission', body: body);
      if (res.statusCode == 200 && res.body != '""') {
        Navigator.pop(context);
        print('online per user ${res}');
        Sqlite().insertJson('CEO_REPORT_CREDIT_PER_USER', select, res.body);

        _setGenTime(json.decode(res.body));
        return json.decode(res.body);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<List> getCreditPerUserDebt(
      {String select, bool online = false}) async {
    if (!online) {
      var res =
          await Sqlite().getJson('CEO_REPORT_CREDIT_PER_USER_DEBT', select);
      if (res != null && res['JSON_VALUE'] != '""') {
        print('offline per user debt');
        return json.decode(res['JSON_VALUE']);
      }
    }
    try {
      var body = {'func': 'report_credit_per_user_debt', 'fileselect': select};
      var res = await http.post('$apiPath-commission', body: body);
      if (res.statusCode == 200 && res.body != '""') {
        print('online per user debt');
        Sqlite()
            .insertJson('CEO_REPORT_CREDIT_PER_USER_DEBT', select, res.body);
        return json.decode(res.body);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future getShowData({String select, bool online = false}) async {
    creditPerUser = getCreditPerUser(select: select, online: online);
    creditPerUserDebt = getCreditPerUserDebt(select: select, online: online);
  }

  Future _refresh() async {
    await getShowData(online: true, select: formatMonth(selectedMonth));
  }

  double calPercent(int one, int two) {
    if (two == 0) return 0;
    return double.parse(((one / two) * 100).toStringAsFixed(2));
  }

  @override
  void initState() {
    var today = DateTime.now();
    if(today.day >= 1 && today.day <= 5){
      var y = (today.month==0)?today.year-1:today.year;
      selectedMonth = DateTime(y,today.month-1,1);
      print(selectedMonth);
      var _str = '${selectedMonth.toString().split('-')[0]}-${selectedMonth.toString().split('-')[1]}-01';
      monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
    }else{
      var _str = '${selectedMonth.toString().split('-')[0]}-${selectedMonth.toString().split('-')[1]}-01';
      monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
    }

    getShowData(select: formatMonth(selectedMonth), online: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,height: 1);
    TextStyle _baseFontWhiteStyle = TextStyle(fontSize: 18,color: whiteColor,height: 1);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        color:kPrimaryColor,
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
                                      Text('รายงานเครดิต KPI ',style: TextStyle(fontSize: 24.0,height: 1),),
                                      Text('ข้อมูลนับจากวันที่กำหนดชำระบิล',style: TextStyle(fontSize: 16.0,height: 1),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Text('รายงานเครดิต KPI รายบุคคล'),
                          // Text('ข้อมูลอัพเดทล่าสุด $dayGen เวลา $timeGen น.'),
                          // RaisedButton(
                          //     child: Text('เลือกเดือน'),
                          //     onPressed: () => _showMonthPicker()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
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
                                                      hintText: monthSelectText.text,
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
                    FutureBuilder<List>(
                        future: creditPerUser,
                        builder: (_, snap) {
                          if (snap.hasData) {
                            return SliverList(
                                delegate: SliverChildBuilderDelegate((bc, i) {
                              var data = snap.data[i];
                              List showCreditDefault = data['summaryBillWait'];
                              double percentAll = calPercent(
                                  showCreditDefault.fold(
                                      0,
                                      (pv, ele) =>
                                          pv + ele['success_inMonth_sumDueMoney']),
                                  showCreditDefault.fold(
                                      0,
                                      (pv, ele) =>
                                          pv +
                                          ele['inMonth_sumDueMoney'] +
                                          ele['success_inMonth_sumDueMoney']));
                              List showCredit = showCreditDefault
                                  .where((element) =>
                                      element['inMonth_sumDueMoney'] > 0)
                                  .toList();

                              return Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HeaderText(text:'${data['credit_name']}',gHeight: 26,textSize: 20,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'บิลที่อนุมัติแล้ว ${data['bill_total']} บิล / ${f.SeperateNumber(data['sumCat1_590'] + data['sumCat1_690'])} กระสอบ',
                                              style: _baseFontStyle,
                                            ),
                                            Text(
                                                'บิลที่ลูกค้าจ่ายครบ ${data['receive_bill_total']} บิล / ${f.SeperateNumber(data['receive_sumCat1_590'] + data['receive_sumCat1_690'])} กระสอบ / ${f.SeperateNumber(data['receive_sumCusMoneyPay'])} บาท',
                                                style: _baseFontStyle
                                            ),
                                            Text(
                                                'บิลที่ลูกค้าจ่ายไม่ครบ ${data['receiveNotComplete_bill_total']} บิล / ${f.SeperateNumber(data['receiveNotComplete_sumCat1_590'] + data['receiveNotComplete_sumCat1_690'])} กระสอบ / ${f.SeperateNumber(data['receiveNotComplete_sumCusMoneyPay'])} บาท',
                                                style: _baseFontStyle
                                            ),
                                            Text(
                                                'รวมเงินที่ลูกค้าจ่ายทั้งหมด ${f.SeperateNumber(data['receive_sumCusMoneyPay'] + data['receiveNotComplete_sumCusMoneyPay'])} บาท',
                                                style: _baseFontStyle
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Row(
                                          crossAxisAlignment:CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              flex:4,
                                                child: Column(
                                                  crossAxisAlignment:CrossAxisAlignment.start,
                                                  children: [
                                                    Text('บิลค้างชำระ',style:TextStyle(fontSize: 20)),
                                                    Text(
                                                        'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount'] + ele['success_inMonth_billCount']))} บิล',style: _baseFontStyle,),
                                                    Text(
                                                        'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690'] + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ',
                                                        style: _baseFontStyle
                                                    ),
                                                    Text(
                                                        'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney'] + ele['success_inMonth_sumDueMoney']))}  บาท',
                                                        style: _baseFontStyle
                                                    ),
                                                  ],
                                                ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Card(
                                                    color: percentAll == 0
                                                        ? dangerColor
                                                        : percentAll < 50
                                                        ? dangerColor
                                                        : percentAll < 80
                                                        ? orangeColor
                                                        : kPrimaryColor,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        minWidth: 100
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(height: 5,),
                                                          Text(
                                                            '${percentAll.toStringAsFixed(0)}%',
                                                            style: TextStyle(fontSize: 20,color: whiteColor),
                                                          ),
                                                          Text('เก็บครบ',style: TextStyle(fontSize: 15,color: whiteColor),),
                                                          SizedBox(height: 5,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Card(
                                                      color:dangerColor,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount']))} บิล',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690']))} กระสอบ',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney']))} บาท',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Card(
                                                      color:kPrimaryColor,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_billCount']))} บิล',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)

                                                            ),
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)
                                                            ),
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumDueMoney']))} บาท',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Container(
                                          height: 170,
                                          child: ListView.builder(
                                              itemCount: showCredit.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (_, index) {
                                                var res = showCredit[index];
                                                double percent = calPercent(
                                                    res['success_inMonth_sumDueMoney'],
                                                    res['inMonth_sumDueMoney'] +
                                                        res['success_inMonth_sumDueMoney']);

                                                return Container(
                                                  width: size.width*0.57,
                                                  child: Card(
                                                    color: darkColor,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(3.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'กำหนดชำระ ${thaiMonth(res['Date'])}',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: whiteColor),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex:2,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                            'ทั้งหมด ${f.SeperateNumber(res['inMonth_billCount'] + res['success_inMonth_billCount'])} บิล',
                                                                            style: _baseFontWhiteStyle,
                                                                        ),
                                                                        Text(
                                                                            'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'] + res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ',
                                                                          style: _baseFontWhiteStyle,

                                                                        ),
                                                                        Text(
                                                                            'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumDueMoney'] + res['success_inMonth_sumDueMoney'])} บาท',
                                                                          style: _baseFontWhiteStyle,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Card(
                                                                      color: percent == 0
                                                                          ? dangerColor
                                                                          : percent < 50
                                                                          ? dangerColor
                                                                          : percent < 80
                                                                          ? orangeColor
                                                                          : kPrimaryColor,
                                                                      child: ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                            minWidth: 100
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(height: 5,),
                                                                            Text(
                                                                              '${percent.toStringAsFixed(0)}%',
                                                                              style: TextStyle(fontSize: 20,color: whiteColor),
                                                                            ),
                                                                            Text('เก็บครบ',style: TextStyle(fontSize: 15,color: whiteColor),),
                                                                            SizedBox(height: 5,),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Card(
                                                                    color:dangerColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(3.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          'ค้างจ่าย ',
                                                                          style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                          ),
                                                                      ),
                                                                      Text(
                                                                          '${f.SeperateNumber(res['inMonth_billCount'])} บิล / ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'])} กระสอบ',
                                                                        style: TextStyle(
                                                                            color:whiteColor,
                                                                            fontSize: 15,
                                                                            height: 1,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          '${f.SeperateNumber(res['inMonth_sumDueMoney'])} บาท',
                                                                        style: TextStyle(
                                                                            color:whiteColor,
                                                                            fontSize: 15,
                                                                            height: 1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                              Expanded(
                                                                  child: Card(
                                                                    color:kPrimaryColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(3.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          'เก็บครบ ',
                                                                        style: TextStyle(
                                                                          color:whiteColor,
                                                                          fontSize: 15,
                                                                          height: 1,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          '${f.SeperateNumber(res['success_inMonth_billCount'])} บิล / ${f.SeperateNumber(res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ',
                                                                        style: TextStyle(
                                                                          color:whiteColor,
                                                                          fontSize: 15,
                                                                          height: 1,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          '${f.SeperateNumber(res['success_inMonth_sumDueMoney'])} บาท',
                                                                        style: TextStyle(
                                                                          color:whiteColor,
                                                                          fontSize: 15,
                                                                          height: 1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                      SizedBox(height: 10,)

                                    ],
                                  ),
                                ),
                              );
                            }, childCount: snap.data.length));
                          } else {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                                child: Center(
                                  child: Container(
                                    width: size.width * 0.98,
                                    height: size.height * 0.42,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/img/bgAlert.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.28,
                                          child: Image.asset(
                                              "assets/icons/icon_alert.png"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 15),
                                          child: Text(
                                            "ไม่มีข้อมูลที่ท่านเรียก",
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5),
                                          child: Text(
                                            "เดือนที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะทีมยังไม่ได้บิลเครดิตและไม่มีบิลเรียกเก็บจากลูกค้า \nในวันเวลา ดังกล่าวที่คุณเลือกมานี้",
                                            style: TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                height: 1),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                    FutureBuilder<List>(
                        future: creditPerUserDebt,
                        builder: (_, snap) {
                          if (snap.hasData) {
                            return SliverList(
                                delegate: SliverChildBuilderDelegate((bc, i) {
                              var data = snap.data[i];
                              List showCreditDefault = data['summaryBillWait'];
                              double percentAll = calPercent(
                                  showCreditDefault.fold(
                                      0,
                                      (pv, ele) =>
                                          pv + ele['success_inMonth_sumDueMoney']),
                                  showCreditDefault.fold(
                                      0,
                                      (pv, ele) =>
                                          pv +
                                          ele['inMonth_sumDueMoney'] +
                                          ele['success_inMonth_sumDueMoney']));
                              List showCredit = showCreditDefault
                                  .where((element) =>
                                      element['inMonth_sumDueMoney'] > 0)
                                  .toList();
                              return Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 5),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      HeaderText(text:'${data['credit_name']} (ฝ่ายติดตามหนี้)',textSize: 20,gHeight: 26,),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'บิลที่ต้องตามเก็บ ${data['bill_total']} บิล / ${f.SeperateNumber(data['sumCat1_590'] + data['sumCat1_690'])} กระสอบ',
                                              style: _baseFontStyle,
                                            ),
                                            Text(
                                                'บิลที่ลูกค้าจ่ายครบ ${data['receive_bill_total']} บิล / ${f.SeperateNumber(data['receive_sumCat1_590'] + data['receive_sumCat1_690'])} กระสอบ / ${f.SeperateNumber(data['receive_sumCusMoneyPay'])} บาท',
                                              style: _baseFontStyle,
                                            ),
                                            Text(
                                                'บิลที่ลูกค้าจ่ายไม่ครบ ${data['receiveNotComplete_bill_total']} บิล / ${f.SeperateNumber(data['receiveNotComplete_sumCat1_590'] + data['receiveNotComplete_sumCat1_690'])} กระสอบ / ${f.SeperateNumber(data['receiveNotComplete_sumCusMoneyPay'])} บาท',
                                              style: _baseFontStyle,
                                            ),
                                            Text(
                                                'รวมเงินที่ลูกค้าจ่ายทั้งหมด ${f.SeperateNumber(data['receive_sumCusMoneyPay'] + data['receiveNotComplete_sumCusMoneyPay'])} บาท',
                                              style: _baseFontStyle,
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      ),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text('บิลค้างชำระ',style: TextStyle(fontSize: 20),),
                                      //     Text(
                                      //       'เก็บครบ : $percentAll %',
                                      //       style: TextStyle(
                                      //           color: percentAll == 0
                                      //               ? redColor
                                      //               : percentAll < 50
                                      //               ? redColor
                                      //               : percentAll < 80
                                      //               ? orangeColor
                                      //               : kPrimaryColor),
                                      //     ),
                                      //   ],
                                      // ),
                                      //
                                      // Container(
                                      //   width: size.width,
                                      //   child: Column(
                                      //     children: [
                                      //       Text('รวม'),
                                      //
                                      //       Row(
                                      //         children: [
                                      //           Expanded(
                                      //               child: Card(
                                      //                 child: Column(
                                      //                   crossAxisAlignment:
                                      //                   CrossAxisAlignment.start,
                                      //                   children: [
                                      //                     Text(
                                      //                         'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount'] + ele['success_inMonth_billCount']))} บิล'),
                                      //                     Text(
                                      //                         'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690'] + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ'),
                                      //                     Text(
                                      //                         'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney'] + ele['success_inMonth_sumDueMoney']))}  บาท'),
                                      //                   ],
                                      //                 ),
                                      //               )),
                                      //           Expanded(
                                      //               child: Card(
                                      //                 child: Column(
                                      //                   crossAxisAlignment:
                                      //                   CrossAxisAlignment.start,
                                      //                   children: [
                                      //                     Text(
                                      //                         'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount']))} บิล',
                                      //                         style: TextStyle(
                                      //                             color: redColor)),
                                      //                     Text(
                                      //                         'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690']))} กระสอบ',
                                      //                         style: TextStyle(
                                      //                             color: redColor)),
                                      //                     Text(
                                      //                         'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney']))} บาท',
                                      //                         style: TextStyle(
                                      //                             color: redColor)),
                                      //                   ],
                                      //                 ),
                                      //               )),
                                      //           Expanded(
                                      //               child: Card(
                                      //                 child: Column(
                                      //                   crossAxisAlignment:
                                      //                   CrossAxisAlignment.start,
                                      //                   children: [
                                      //                     Text(
                                      //                         'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_billCount']))} บิล'),
                                      //                     Text(
                                      //                         'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ'),
                                      //                     Text(
                                      //                         'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumDueMoney']))} บาท'),
                                      //                   ],
                                      //                 ),
                                      //               )),
                                      //         ],
                                      //       )
                                      //     ],
                                      //   ),
                                      // ),
                                      // Container(
                                      //   height: 110,
                                      //   child: ListView.builder(
                                      //       itemCount: showCredit.length,
                                      //       shrinkWrap: true,
                                      //       scrollDirection: Axis.horizontal,
                                      //       itemBuilder: (_, index) {
                                      //         var res = showCredit[index];
                                      //         double percent = calPercent(
                                      //             res['success_inMonth_sumDueMoney'],
                                      //             res['inMonth_sumDueMoney'] +
                                      //                 res['success_inMonth_sumDueMoney']);
                                      //
                                      //         return Container(
                                      //           width: size.width,
                                      //           child: Card(
                                      //             color: darkColor,
                                      //             child: Column(
                                      //               children: [
                                      //                 Text(
                                      //                   'กำหนดชำระ ${thaiMonth(res['Date'])}',
                                      //                   style: TextStyle(
                                      //                       color: whiteColor),
                                      //                 ),
                                      //                 Text(
                                      //                   'เก็บครบ : $percent %',
                                      //                   style: TextStyle(
                                      //                       color: percent == 0
                                      //                           ? redColor
                                      //                           : percent < 50
                                      //                               ? redColor
                                      //                               : percent < 80
                                      //                                   ? orangeColor
                                      //                                   : kPrimaryColor),
                                      //                 ),
                                      //                 Row(
                                      //                   children: [
                                      //                     Expanded(
                                      //                         child: Card(
                                      //                       child: Column(
                                      //                         crossAxisAlignment:
                                      //                             CrossAxisAlignment
                                      //                                 .start,
                                      //                         children: [
                                      //                           Text(
                                      //                               'ทั้งหมด ${f.SeperateNumber(res['inMonth_billCount'] + res['success_inMonth_billCount'])} บิล'),
                                      //                           Text(
                                      //                               'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'] + res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ'),
                                      //                           Text(
                                      //                               'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumDueMoney'] + res['success_inMonth_sumDueMoney'])} บาท'),
                                      //                         ],
                                      //                       ),
                                      //                     )),
                                      //                     Expanded(
                                      //                         child: Card(
                                      //                       child: Column(
                                      //                         crossAxisAlignment:
                                      //                             CrossAxisAlignment
                                      //                                 .start,
                                      //                         children: [
                                      //                           Text(
                                      //                               'ค้างจ่าย ${f.SeperateNumber(res['inMonth_billCount'])} บิล',
                                      //                               style: TextStyle(
                                      //                                   color:
                                      //                                       redColor)),
                                      //                           Text(
                                      //                               'ค้างจ่าย ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'])} กระสอบ',
                                      //                               style: TextStyle(
                                      //                                   color:
                                      //                                       redColor)),
                                      //                           Text(
                                      //                               'ค้างจ่าย ${f.SeperateNumber(res['inMonth_sumDueMoney'])} บาท',
                                      //                               style: TextStyle(
                                      //                                   color:
                                      //                                       redColor)),
                                      //                         ],
                                      //                       ),
                                      //                     )),
                                      //                     Expanded(
                                      //                         child: Card(
                                      //                       child: Column(
                                      //                         crossAxisAlignment:
                                      //                             CrossAxisAlignment
                                      //                                 .start,
                                      //                         children: [
                                      //                           Text(
                                      //                               'เก็บครบ ${f.SeperateNumber(res['success_inMonth_billCount'])} บิล'),
                                      //                           Text(
                                      //                               'เก็บครบ ${f.SeperateNumber(res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ'),
                                      //                           Text(
                                      //                               'เก็บครบ ${f.SeperateNumber(res['success_inMonth_sumDueMoney'])} บาท'),
                                      //                         ],
                                      //                       ),
                                      //                     )),
                                      //                   ],
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //         );
                                      //       }),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Row(
                                          crossAxisAlignment:CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              flex:4,
                                              child: Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  Text('บิลค้างชำระ',style:TextStyle(fontSize: 20)),
                                                  Text(
                                                    'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount'] + ele['success_inMonth_billCount']))} บิล',style: _baseFontStyle,),
                                                  Text(
                                                      'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690'] + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ',
                                                      style: _baseFontStyle
                                                  ),
                                                  Text(
                                                      'ทั้งหมด ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney'] + ele['success_inMonth_sumDueMoney']))}  บาท',
                                                      style: _baseFontStyle
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Card(
                                                    color: percentAll == 0
                                                        ? dangerColor
                                                        : percentAll < 50
                                                        ? dangerColor
                                                        : percentAll < 80
                                                        ? orangeColor
                                                        : kPrimaryColor,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          minWidth: 100
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(height: 5,),
                                                          Text(
                                                            '${percentAll.toStringAsFixed(0)}%',
                                                            style: TextStyle(fontSize: 20,color: whiteColor),
                                                          ),
                                                          Text('เก็บครบ',style: TextStyle(fontSize: 15,color: whiteColor),),
                                                          SizedBox(height: 5,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Card(
                                                      color:dangerColor,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_billCount']))} บิล',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumCat1_590'] + ele['inMonth_sumCat1_690']))} กระสอบ',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                            Text(
                                                                'ค้างจ่าย ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['inMonth_sumDueMoney']))} บาท',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Card(
                                                      color:kPrimaryColor,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_billCount']))} บิล',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)

                                                            ),
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumCat1_590'] + ele['success_inMonth_sumCat1_690']))} กระสอบ',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)
                                                            ),
                                                            Text(
                                                                'เก็บครบ ${f.SeperateNumber(showCreditDefault.fold(0, (pv, ele) => pv + ele['success_inMonth_sumDueMoney']))} บาท',
                                                                style: TextStyle(
                                                                    color: whiteColor,fontSize: 18)
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Container(
                                          height: 170,
                                          child: ListView.builder(
                                              itemCount: showCredit.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (_, index) {
                                                var res = showCredit[index];
                                                double percent = calPercent(
                                                    res['success_inMonth_sumDueMoney'],
                                                    res['inMonth_sumDueMoney'] +
                                                        res['success_inMonth_sumDueMoney']);

                                                return Container(
                                                  width: size.width*0.57,
                                                  child: Card(
                                                    color: darkColor,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(3.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'กำหนดชำระ ${thaiMonth(res['Date'])}',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: whiteColor),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex:2,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      Text(
                                                                        'ทั้งหมด ${f.SeperateNumber(res['inMonth_billCount'] + res['success_inMonth_billCount'])} บิล',
                                                                        style: _baseFontWhiteStyle,
                                                                      ),
                                                                      Text(
                                                                        'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'] + res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ',
                                                                        style: _baseFontWhiteStyle,

                                                                      ),
                                                                      Text(
                                                                        'ทั้งหมด ${f.SeperateNumber(res['inMonth_sumDueMoney'] + res['success_inMonth_sumDueMoney'])} บาท',
                                                                        style: _baseFontWhiteStyle,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Card(
                                                                      color: percent == 0
                                                                          ? dangerColor
                                                                          : percent < 50
                                                                          ? dangerColor
                                                                          : percent < 80
                                                                          ? orangeColor
                                                                          : kPrimaryColor,
                                                                      child: ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                            minWidth: 100
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(height: 5,),
                                                                            Text(
                                                                              '${percent.toStringAsFixed(0)}%',
                                                                              style: TextStyle(fontSize: 20,color: whiteColor),
                                                                            ),
                                                                            Text('เก็บครบ',style: TextStyle(fontSize: 15,color: whiteColor),),
                                                                            SizedBox(height: 5,),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Card(
                                                                    color:dangerColor,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(3.0),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          Text(
                                                                            'ค้างจ่าย ',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${f.SeperateNumber(res['inMonth_billCount'])} บิล / ${f.SeperateNumber(res['inMonth_sumCat1_590'] + res['inMonth_sumCat1_690'])} กระสอบ',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${f.SeperateNumber(res['inMonth_sumDueMoney'])} บาท',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                  child: Card(
                                                                    color:kPrimaryColor,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(3.0),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: [
                                                                          Text(
                                                                            'เก็บครบ ',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${f.SeperateNumber(res['success_inMonth_billCount'])} บิล / ${f.SeperateNumber(res['success_inMonth_sumCat1_590'] + res['success_inMonth_sumCat1_690'])} กระสอบ',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${f.SeperateNumber(res['success_inMonth_sumDueMoney'])} บาท',
                                                                            style: TextStyle(
                                                                              color:whiteColor,
                                                                              fontSize: 15,
                                                                              height: 1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                      SizedBox(height: 10,)

                                    ],
                                  ),
                                ),
                              );
                            }, childCount: snap.data.length));
                          } else {
                            return SliverToBoxAdapter(
                              child: Container(),
                            );
                          }
                        }),
                    SliverFillRemaining(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Footer(),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future _showMonthPicker() async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: selectedMonth,
      locale: Locale("th"),
    ).then((date) {
      if (date != null) {
        selectedMonth = date;
        var _str = '${selectedMonth.toString().split('-')[0]}-${selectedMonth.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        getShowData(select: formatMonth(date));
      }
    });
  }
}
