import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart';
import 'package:system/configs/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CeoIncome extends StatefulWidget {
  final Function(String) testCallBack;

  CeoIncome(this.testCallBack);

  @override
  CeoIncomeState createState() => CeoIncomeState();
}

class CeoIncomeState extends State<CeoIncome> {
  var client = Client();

  GetReport s = GetReport();

  String selectedReport = '13';
  String selectedText ='ข้อมูลประจำเดือนนี้';

  static const Map<String, String> optionReport = {
    '99': 'ข้อมูลประจำวันนี้',
    '98': 'ข้อมูลเมื่อวานนี้',
    '97': 'ข้อมูลสัปดาห์นี้',
    '96': 'ข้อมูลสัปดาห์ที่แล้ว',
    '13': 'ข้อมูลประจำเดือนนี้',
    '14': 'ข้อมูลเดือนที่แล้ว',
    '15': 'ข้อมูลประจำปีนี้',
    '16': 'ข้อมูลปีทีแล้ว'
  };

  int cash_count_product_cat1 = 0;
  int cash_count_product_cat2 = 0;
  int cash_count_moneytotal = 0;
  int cash_count_commission = 0;
  int cash_count_commission_pay_success = 0;
  int cash_count_customer_old = 0;
  int cash_count_customer_new = 0;

  int credit_count_product_cat1 = 0;
  int credit_count_product_cat2 = 0;
  int credit_count_moneytotal = 0;
  int credit_count_commission = 0;
  int credit_count_commission_pay_success = 0;
  int credit_count_moneytotal_pay_success = 0;
  int credit_count_moneytotal_pay_success_number = 0;
  int credit_count_money_due = 0;
  int credit_count_money_due_number = 0;
  int credit_count_customer_old = 0;
  int credit_count_customer_new = 0;
  int credit_count_money_earnest = 0;

  int before_cash_count_product_cat1 = 0;
  int before_cash_count_product_cat2 = 0;
  int before_cash_count_moneytotal = 0;
  int before_cash_count_commission = 0;
  int before_cash_count_commission_pay_success = 0;
  int before_cash_count_customer_old = 0;
  int before_cash_count_customer_new = 0;

  int temp_cash_customer_id = 0;
  List temp_cash_customer_count = [];

  int before_credit_count_product_cat1 = 0;
  int before_credit_count_product_cat2 = 0;
  int before_credit_count_moneytotal = 0;
  int before_credit_count_commission = 0;
  int before_credit_count_commission_pay_success = 0;
  int before_credit_count_moneytotal_pay_success = 0;
  int before_credit_count_moneytotal_pay_success_number = 0;
  int before_credit_count_money_due = 0;
  int before_credit_count_money_due_number = 0;
  int before_credit_count_customer_old = 0;
  int before_credit_count_customer_new = 0;
  int before_credit_count_money_earnest = 0;

  var percent_total = 0;
  var percent_cash = 0;
  var percent_credit = 0;

  int temp_credit_customer_id = 0;
  List temp_credit_customer_count = [];

  Future<bool> isLoaded;

  FormatMethod f = FormatMethod();

  resetDataThisMonth() {
    cash_count_product_cat1 = 0;
    cash_count_product_cat2 = 0;
    cash_count_moneytotal = 0;
    cash_count_commission = 0;
    cash_count_commission_pay_success = 0;
    cash_count_customer_old = 0;
    cash_count_customer_new = 0;

    credit_count_product_cat1 = 0;
    credit_count_product_cat2 = 0;
    credit_count_moneytotal = 0;
    credit_count_commission = 0;
    credit_count_commission_pay_success = 0;
    credit_count_moneytotal_pay_success = 0;
    credit_count_moneytotal_pay_success_number = 0;
    credit_count_money_due = 0;
    credit_count_money_due_number = 0;
    credit_count_customer_old = 0;
    credit_count_customer_new = 0;
    credit_count_money_earnest = 0;
  }

  resetDataBeforeMonth() {
    before_cash_count_product_cat1 = 0;
    before_cash_count_product_cat2 = 0;
    before_cash_count_moneytotal = 0;
    before_cash_count_commission = 0;
    before_cash_count_commission_pay_success = 0;

    temp_cash_customer_id = 0;
    temp_cash_customer_count = [];

    before_credit_count_product_cat1 = 0;
    before_credit_count_product_cat2 = 0;
    before_credit_count_moneytotal = 0;
    before_credit_count_commission = 0;
    before_credit_count_commission_pay_success = 0;
    before_credit_count_moneytotal_pay_success = 0;
    before_credit_count_moneytotal_pay_success_number = 0;
    before_credit_count_money_due = 0;
    before_credit_count_money_due_number = 0;

    temp_credit_customer_id = 0;
    temp_credit_customer_count = [];
  }

  calPercentBillAll() {
    var moneytotal_now = credit_count_moneytotal + cash_count_moneytotal;
    var moneytotal_before =
        before_credit_count_moneytotal + before_cash_count_moneytotal;
    percent_total = 0;
    var result = 0;
    if (moneytotal_before == 0 && moneytotal_now != 0) {
      result = 100;
    } else if (moneytotal_before == 0 && moneytotal_now == 0) {
      result = 0;
    } else if (moneytotal_before != 0 && moneytotal_now == 0) {
      result = 0;
    } else {
      result = (((moneytotal_now / moneytotal_before) * 100) - 100).ceil();
    }
    percent_total = result;
  }

  calPercentBillCash() {
    var moneytotal_now = cash_count_moneytotal;
    var moneytotal_before = before_cash_count_moneytotal;
    percent_cash = 0;
    var result = 0;
    if (moneytotal_before == 0 && moneytotal_now != 0) {
      result = 100;
    } else if (moneytotal_before == 0 && moneytotal_now == 0) {
      result = 0;
    } else if (moneytotal_before != 0 && moneytotal_now == 0) {
      result = 0;
    } else {
      result = (((moneytotal_now / moneytotal_before) * 100) - 100).ceil();
    }
    percent_cash = result;
  }

  calPercentBillCredit() {
    var moneytotal_now = credit_count_moneytotal;
    var moneytotal_before = before_credit_count_moneytotal;
    percent_credit = 0;
    var result = 0;
    if (moneytotal_before == 0 && moneytotal_now != 0) {
      result = 100;
    } else if (moneytotal_before == 0 && moneytotal_now == 0) {
      result = 0;
    } else if (moneytotal_before != 0 && moneytotal_now == 0) {
      result = 0;
    } else {
      result = (((moneytotal_now / moneytotal_before) * 100) - 100).ceil();
    }
    percent_credit = result;
  }

  Future setDataThisMonth(item) async {
    resetDataThisMonth();
    if (item.values.length > 0) {
      cash_count_product_cat1 = item['cash_count_product_cat1'];
      cash_count_product_cat2 = item['cash_count_product_cat2'];
      cash_count_moneytotal = item['cash_count_moneytotal'];
      cash_count_customer_old = item['cash_count_customer_old'];
      cash_count_customer_new = item['cash_count_customer_new'];
      credit_count_product_cat1 = item['credit_count_product_cat1'];
      credit_count_product_cat2 = item['credit_count_product_cat2'];
      credit_count_moneytotal = item['credit_count_moneytotal'];
      credit_count_money_due = item['credit_count_money_due'];
      credit_count_money_due_number = item['credit_count_money_due_number'];
      credit_count_customer_old = item['credit_count_customer_old'];
      credit_count_customer_new = item['credit_count_customer_new'];
      credit_count_money_earnest = item['credit_count_money_earnest'];
    }
  }

  Future setDataBeforeMonth(item) async {
    resetDataBeforeMonth();
    if (item.values.length > 0) {
      before_cash_count_product_cat1 = item['cash_count_product_cat1'];
      before_cash_count_product_cat2 = item['cash_count_product_cat2'];
      before_cash_count_moneytotal = item['cash_count_moneytotal'];
      before_cash_count_customer_old = item['cash_count_customer_old'];
      before_cash_count_customer_new = item['cash_count_customer_new'];
      before_credit_count_product_cat1 = item['credit_count_product_cat1'];
      before_credit_count_product_cat2 = item['credit_count_product_cat2'];
      before_credit_count_moneytotal = item['credit_count_moneytotal'];
      before_credit_count_money_due = item['credit_count_money_due'];
      before_credit_count_money_due_number =
          item['credit_count_money_due_number'];
      before_credit_count_customer_old = item['credit_count_customer_old'];
      before_credit_count_customer_new = item['credit_count_customer_new'];
      before_credit_count_money_earnest = item['credit_count_money_earnest'];
    }
    calPercentBillAll();
    calPercentBillCash();
    calPercentBillCredit();
  }

  Future onRefresh(selectedReport) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      isLoaded = Future.value();
      var resultThisMonth = await s.getCeoIncome(
          isThisMonth: true, selectedReport: selectedReport);
      var resultBeforemonth = await s.getCeoIncome(
          isThisMonth: false, selectedReport: selectedReport);
      var dataThisMonth = jsonDecode(resultThisMonth);
      var dataBeforeMonth = jsonDecode(resultBeforemonth);
      await setDataThisMonth(dataThisMonth);
      await setDataBeforeMonth(dataBeforeMonth);
      isLoaded = Future.value(true);
      setState(() {});
    }
  }

  Future getCache(selectedReport) async {
    var resultThisMonth =
        await Sqlite().getJson('CEO_INCOME_THIS_MONTH', selectedReport);
    var resultBeforemonth =
        await Sqlite().getJson('CEO_INCOME_BEFORE_MONTH', selectedReport);
    if (resultThisMonth != null && resultBeforemonth != null) {
      var dataThisMonth = jsonDecode(resultThisMonth['JSON_VALUE']);
      var dataBeforeMonth = jsonDecode(resultBeforemonth['JSON_VALUE']);
      await setDataThisMonth(dataThisMonth);
      await setDataBeforeMonth(dataBeforeMonth);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var resultThisMonth = await s.getCeoIncome(
            isThisMonth: true, selectedReport: selectedReport);
        var resultBeforemonth = await s.getCeoIncome(
            isThisMonth: false, selectedReport: selectedReport);
        var dataThisMonth = jsonDecode(resultThisMonth);
        var dataBeforeMonth = jsonDecode(resultBeforemonth);
        await setDataThisMonth(dataThisMonth);
        await setDataBeforeMonth(dataBeforeMonth);
      }
    }
    isLoaded = Future.value(true);
    setState(() {});
  }

  onSelectReportChange(val) async {
    await getCache(val);
  }

  Future getData() async {
    DateTime now = DateTime.now();
    var day = now.day;
    if(day>=1&&day<=5){
      selectedReport = '14';
      selectedText ='ข้อมูลเดือนที่แล้ว';
    }
    await getCache(selectedReport);
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  Widget showPercent({String text, int percent, int moneyTotal, int cat2, int cat1}) {
    Size size = MediaQuery.of(context).size;
    return Card(
      color: subFontColor,
      child: Column(
        children: [
          Container(
            color: mainFontColor,
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
              child: Text('ยอดขายทั้งหมดรวมทั้งสิ้น',style: TextStyle(fontSize: 20,color: whiteFontColor),),
            )
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Column 1
                Expanded(
                  flex: 2,
                  child: Container(
                    color: kPrimaryLightColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          percent == 0
                              ? Icons.remove
                              : percent > 0
                                  ? FontAwesomeIcons.caretUp
                                  : FontAwesomeIcons.caretDown,
                          color: whiteColor,
                          size: 60,
                        ),
                        percent == 0
                            ? Text('')
                            : percent > 0
                                ? Text('เพิ่มขึ้น',
                                    style: TextStyle(
                                        fontSize: 20, color: whiteColor,height: 0.7))
                                : Text('ลดลง',
                                    style: TextStyle(
                                        fontSize: 20, color: whiteColor,height: 0.7)),
                        Text(
                          '${percent.abs()} %',
                          style: TextStyle(fontSize: 50, color: whiteColor,height: 1),
                        ),
                        SizedBox(height: 8,)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(text,style: TextStyle(fontSize: 18,color: whiteFontColor,height: 1),),
                        Text('${f.SeperateNumber(moneyTotal)} บาท',
                            style: TextStyle(fontSize: 32, color: whiteFontColor,height: 1),),
                        Text("สินค้าที่ขายได้ทั้งหมด",style: TextStyle(fontSize: 18,color: whiteFontColor,height: 1),),
                        Text(
                            '${f.SeperateNumber(cat2)} ขวด / ${f.SeperateNumber(cat1)} กระสอบ'
                            ,style: TextStyle(fontSize: 18,color: whiteFontColor,height: 1),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderChart(
      {id = 'sale',
      color = const [grayDarkColor, cyanColor],
      legend = const ['เงินสด', 'เครดิต'],
      total = const [50, 50]}) {
    final data = [
      new TeamGoal(
          charts.ColorUtil.fromDartColor(color[0]), legend[0], total[0]),
      new TeamGoal(
          charts.ColorUtil.fromDartColor(color[1]), legend[1], total[1]),
    ];
    int sum = total[0] + total[1];
    if (sum == 0) {
      List<charts.Series<TeamGoal, String>> series = [
        new charts.Series(
          id: id,
          data: data,
          domainFn: (TeamGoal sale, _) => sale.text,
          measureFn: (TeamGoal sale, _) => 50,
          colorFn: (TeamGoal sale, _) => sale.color,
        )
      ];
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: CeoPieChart(
          series,
          animate: true,
          enableLabel: true,
          horizontalFirst: true,
        ),
      );
    } else {
      //print('cas sum not 0 : $sum');
      List<charts.Series<TeamGoal, String>> series = [
        new charts.Series(
          id: id,
          data: data,
          domainFn: (TeamGoal sale, _) => sale.text,
          measureFn: (TeamGoal sale, _) => sale.total,
          colorFn: (TeamGoal sale, _) => sale.color,
          labelAccessorFn: (TeamGoal sale, _) =>
              '${(sale.total / sum * 100).round()} %',
        )
      ];
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: CeoPieChart(
          series,
          animate: true,
          enableLabel: true,
          horizontalFirst: true,
        ),
      );
    }
  }

  void testCallFromParent() {
    print('call child method');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isLoaded,
        builder: (bc, snap) {
          if (snap.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropDown(
                  items: optionReport
                      .map((key, value) {
                        return MapEntry(
                                key,
                                DropdownMenuItem<String>(value: key, child: Center(child: Text(value,style: TextStyle(fontSize: 18,height: 1),),))
                            );
                      })
                      .values
                      .toList(),
                  hintText: 'รายงานข้อมูลยอดขาย',
                  value: selectedReport,
                  onChange: (val) {
                    selectedText = optionReport[val];
                    selectedReport = val;
                    widget.testCallBack(val);
                    onSelectReportChange(val);
                  },
                  validator: (val) => val == null ? '' : null,
                  fromPage: 'ceo_dashboard',
                ),
                // RaisedButton(
                //     child: Text('ทดสอบดึงข้อมูล'),
                //     onPressed: () => onRefresh(selectedReport)),
                Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5,bottom: 10,top: 5),
                  child: Container(
                    color: Color(0xFF00A99D),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ยอดขายเครดิต',style: TextStyle(fontSize: 30,color: whiteFontColor,height: 1),),
                              Text('ที่ปล่อยไปแล้วตาม${selectedText}',style: TextStyle(fontSize: 24,color: whiteFontColor,height: 1),)
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${f.ConvertToThaiBath(credit_count_moneytotal)[0]}',style: TextStyle(fontSize: 50,color: whiteFontColor,height: 0.9),),
                              Text('${f.ConvertToThaiBath(credit_count_moneytotal)[1]}',style: TextStyle(fontSize: 20,color: whiteFontColor,height: 0.8),)
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                ),

                showPercent(
                    text: 'ยอดขายทั้งหมด',
                    percent: percent_total,
                    moneyTotal: credit_count_moneytotal + cash_count_moneytotal,
                    cat1: credit_count_product_cat1 + cash_count_product_cat1,
                    cat2: credit_count_product_cat2 + cash_count_product_cat2),
                Container(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: renderChart(id: 'chart_total_pay_type', total: [
                          cash_count_moneytotal,
                          credit_count_moneytotal
                        ]),
                      ),
                      Expanded(
                        child: renderChart(
                            id: 'chart_total_customer_type',
                            legend: [
                              'ลูกค้าใหม่',
                              'ลูกค้าเก่า'
                            ],
                            color: [
                              grayDarkColor,
                              brownColor
                            ],
                            total: [
                              cash_count_customer_new +
                                  credit_count_customer_new,
                              cash_count_customer_old +
                                  credit_count_customer_old
                            ]),
                      ),
                    ],
                  ),
                ),
                // Divider(),
                // showPercent(
                //     text: 'ยอดขายเงินสด',
                //     percent: percent_cash,
                //     moneyTotal: cash_count_moneytotal,
                //     cat1: cash_count_product_cat1,
                //     cat2: cash_count_product_cat2),
                // Container(
                //   height: 200,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: renderChart(
                //             id: 'chart_cash_product_cat',
                //             legend: [
                //               'ปุ๋ยเม็ด',
                //               'ปุ๋ยน้ำ'
                //             ],
                //             total: [
                //               cash_count_product_cat1,
                //               cash_count_product_cat2
                //             ]),
                //       ),
                //       Expanded(
                //         child: renderChart(
                //             id: 'chart_cash_customer_type',
                //             legend: [
                //               'ลูกค้าใหม่',
                //               'ลูกค้าเก่า'
                //             ],
                //             color: [
                //               grayDarkColor,
                //               brownColor
                //             ],
                //             total: [
                //               cash_count_customer_new,
                //               cash_count_customer_old
                //             ]),
                //       ),
                //     ],
                //   ),
                // ),
                // Divider(),
                // showPercent(
                //     text: 'ยอดขายเครดิต',
                //     percent: percent_credit,
                //     moneyTotal: credit_count_moneytotal,
                //     cat1: credit_count_product_cat1,
                //     cat2: credit_count_product_cat2),
                // Container(
                //   height: 200,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: renderChart(id: 'chart_credit_money', legend: [
                //           'ค้างชำระ',
                //           'มัดจำ'
                //         ], total: [
                //           credit_count_money_due,
                //           credit_count_money_earnest
                //         ]),
                //       ),
                //       Expanded(
                //         child: renderChart(
                //             id: 'chart_credit_customer_type',
                //             legend: [
                //               'ลูกค้าใหม่',
                //               'ลูกค้าเก่า'
                //             ],
                //             color: [
                //               grayDarkColor,
                //               brownColor
                //             ],
                //             total: [
                //               credit_count_customer_new,
                //               credit_count_customer_old
                //             ]),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            );
          } else {
            return ShimmerLoading(type: 'boxItem1Row',);
            // return Center(child: CircularProgressIndicator());
          }
        });
  }
}
