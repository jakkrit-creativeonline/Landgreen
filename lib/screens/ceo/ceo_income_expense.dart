import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:system/configs/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

class CEOIncomeExpense extends StatefulWidget {
  @override
  _CEOIncomeExpenseState createState() => _CEOIncomeExpenseState();
}

class _CEOIncomeExpenseState extends State<CEOIncomeExpense> {
  FormatMethod f = FormatMethod();
  Future<List> _listReport;

  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  String selectedMonth = '';
  String startDate = '';
  String endDate = '';

  int sumItem = 0;
  var test;

  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    selectedMonth =
        '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
    var year = '${initDate.toString().split('-')[0]}';
    var month = '${initDate.toString().split('-')[1]}';

    var res =
        await Sqlite().getJson('CEO_REPORT_INCOME_EXPENSEALL', selectedMonth);
    _listReport = Future.value();

    if (res != null) {
      // test = res['JSON_VALUE'];
      // print(res['JSON_VALUE']);
      List data = await jsonDecode(res['JSON_VALUE']);
      _listReport = Future.value(data);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context, MediaQuery.of(context).size);
        try {
          var res = await http.post('$apiPath-ceo', body: {
            'func': 'getIncomeExpenseForApp',
            'year': year,
            'month': month
          });
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson(
                'CEO_REPORT_INCOME_EXPENSEALL', selectedMonth, res.body);
            List data = jsonDecode(res.body);
            await CalculateData(data);
            // return data;
          }
          Navigator.pop(context);
        } catch (e) {
          print('error $e');
          Navigator.pop(context);
          _listReport = Future.value([]);
        }
      }
    }
    setState(() {});
  }

  CalculateData(List data) async {
    // sumItem =0;
    // print('CalculateData');
    // List carList =[];
    // //แยกผลรวมของแต่ละคันรถ
    // data.forEach((row) {
    //   var indexFindCar = carList.indexWhere((ele) => ele['car_id']==row['car_id']);
    //   if(indexFindCar == -1){
    //     List orderDetail = jsonDecode(row['trail_orderdetail']);
    //
    //     carList.add({
    //       'car_id':row['car_id'],
    //       'car_name':'${row['car_number']}  ${row['car_province']}',
    //       'team_name':'${row['team_name']}',
    //       'orderDetail':orderDetail
    //     });
    //   }else{
    //     List oldOrderDetail = carList[indexFindCar]['orderDetail'];
    //     List newOrderDetail = jsonDecode(row['trail_orderdetail']);
    //     var i=0;
    //     newOrderDetail.forEach((eleN) {
    //       int indexO = oldOrderDetail.indexWhere((eleO) => eleN['name'].toString().trim() == eleO['name'].toString().trim() );
    //       if(indexO == -1){
    //         oldOrderDetail.add(newOrderDetail[i]);
    //       }else{
    //         if(eleN['qty'] !='' && eleN['qty']!='null')
    //           // print('${eleN['qty']} ===  ${oldOrderDetail[indexO]['qty']}');
    //           oldOrderDetail[indexO]['qty']+= int.parse(eleN['qty'].toString());
    //       }
    //       i++;
    //     });
    //     carList[indexFindCar]['orderDetail'] = oldOrderDetail;
    //   }
    // });
    //
    // // print('carList =${carList.toString()}');
    // var saveData = jsonEncode(carList);
    // // print('saveData ${saveData}');
    // print('คำนวนเสร็จ');
    // Sqlite().insertJson('CEO_REPORT_TRAIL', selectedMonth, saveData);
    _listReport = Future.value(data);
    setState(() {});
  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      AlertNewDesign().showLoading(context, MediaQuery.of(context).size);
      _listReport = Future.value();
      var year = '${initDate.toString().split('-')[0]}';
      var month = '${initDate.toString().split('-')[1]}';
      try {
        var res = await http.post('$apiPath-ceo', body: {
          'func': 'getIncomeExpenseForApp',
          'year': year,
          'month': month
        });
        if (res.statusCode == 200) {
          print('online');
          Sqlite().insertJson(
              'CEO_REPORT_INCOME_EXPENSEALL', selectedMonth, res.body);
          List data = jsonDecode(res.body);

          await CalculateData(data);
          Navigator.pop(context);
          // return data;
        }
      } catch (e) {
        print('error $e');
        _listReport = Future.value([]);
        Navigator.pop(context);
      }

      setState(() {});
    }
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
            '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
        var _str =
            '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text = "ข้อมูลเดือน " + f.ThaiMonthFormat(_str);
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
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
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
                                  FontAwesomeIcons.calculator,
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
                                    'รายงานรับ-จ่าย',
                                    style: TextStyle(fontSize: 24.0, height: 1),
                                  ),
                                  Text(
                                    'หน้านี้สรุปข้อมูลจากวันที่ลูกค้าเซ็นรับสินค้า',
                                    style: TextStyle(fontSize: 16.0, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
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
                                          child: Stack(children: [
                                            Container(
                                              height: 40,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 1, 8, 1),
                                                child: TextField(
                                                  controller: monthSelectText,
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    // labelText:'ข้อมูล ณ วันที่',
                                                    hintText:
                                                        'ข้อมูลประจำเดือนนี้',
                                                    contentPadding:
                                                        EdgeInsets.all(5),
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 2,
                                                      color: subFontColor),
                                                  bottom: BorderSide(
                                                      width: 2,
                                                      color: subFontColor),
                                                ),
                                                color: bgInputColor,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 5,
                                              child: Container(
                                                child: Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Colors.black,
                                                  size: 28,
                                                ),
                                              ),
                                            )
                                          ]),
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
                      child: showChart(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: _listReport,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print('snapshot.data ${snapshot.data.toList()}');
                              List data = snapshot.data.toList();
                              var sumIncome = 0;
                              var sumExpense = 0;
                              var sumNet = sumIncome - sumExpense;
                              var sumNetPercent = '0';
                              if (data.length > 0) {
                                sumIncome = data[0]
                                            ['income_sum_cash_cat1_money']
                                        .toInt() +
                                    data[0]['income_sum_cash_cat2_money']
                                        .toInt() +
                                    data[0]['income_sum_credit_money_earnest']
                                        .toInt() +
                                    data[0]['income_sum_credit_cus_pay']
                                        .toInt();

                                sumExpense = ((data[0]['expense_sum_cash_cat1_cost'] == null) ? 0 : data[0]['expense_sum_cash_cat1_cost'].toInt()) +
                                    ((data[0]['expense_sum_cash_cat2_cost'] == null)
                                        ? 0
                                        : data[0]['expense_sum_cash_cat2_cost']
                                            .toInt()) +
                                    ((data[0]['expense_sum_credit_cat1_cost'] == null)
                                        ? 0
                                        : data[0]['expense_sum_credit_cat1_cost']
                                            .toInt()) +
                                    ((data[0]['expense_sum_credit_cat2_cost'] == null)
                                        ? 0
                                        : data[0]['expense_sum_credit_cat2_cost']
                                            .toInt()) +
                                    ((data[0]['expense_sum_commision'] == null)
                                        ? 0
                                        : data[0]['expense_sum_commision']
                                            .toInt()) +
                                    ((data[0]['expense_sum_money_share_red'] == null)
                                        ? 0
                                        : data[0]['expense_sum_money_share_red']
                                            .toInt()) +
                                    ((data[0]['expense_sum_money_share_yellow'] == null)
                                        ? 0
                                        : data[0]['expense_sum_money_share_yellow']
                                            .toInt()) +
                                    ((data[0]['expense_sum_money_share_orange'] == null)
                                        ? 0
                                        : data[0]['expense_sum_money_share_orange']
                                            .toInt()) +
                                    ((data[0]['expense_sum_money_share_ceo'] == null)
                                        ? 0
                                        : data[0]['expense_sum_money_share_ceo'].toInt()) +
                                    ((data[0]['expense_sum_money_recomend'] == null) ? 0 : data[0]['expense_sum_money_recomend'].toInt()) +
                                    ((data[0]['expense_sum_money_sendteam'] == null) ? 0 : data[0]['expense_sum_money_sendteam'].toInt()) +
                                    ((data[0]['expense_sum_money_carpayday'] == null) ? 0 : data[0]['expense_sum_money_carpayday'].toInt()) +
                                    ((data[0]['expense_sum_money_creditpay'] == null) ? 0 : data[0]['expense_sum_money_creditpay'].toInt());

                                sumNet = sumIncome - sumExpense;
                                if (sumIncome > 0) {
                                  sumNetPercent = ((sumNet / sumIncome) * 100)
                                      .toStringAsFixed(0);
                                } else {
                                  sumNetPercent = '0';
                                }
                              }

                              return Column(
                                children: [
                                  Consumer<ShowDetail>(
                                      builder: (context, show, child) {
                                    return GestureDetector(
                                      onTap: () => show.changeIncome(),
                                      child: Card(
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 8),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'รวมรายรับ',
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  Text(
                                                    '${f.SeperateNumber(sumIncome)} บาท',
                                                    style: TextStyle(
                                                        color: kPrimaryColor,
                                                        fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                              if (show.showIncome)
                                                Column(
                                                  children: [
                                                    HeaderText(
                                                      text: 'รายละเอียดรายรับ',
                                                      textSize: 20,
                                                      gHeight: 26,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ขายปุ๋ยเงินสด ${f.SeperateNumber(data[0]['income_sum_cash_cat1'])} กระสอบ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['income_sum_cash_cat1_money'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'เงินมัดจำปุ๋ยเครดิต ${f.SeperateNumber(data[0]['income_sum_credit_cat1'])} กระสอบ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['income_sum_credit_money_earnest'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    if (data[0][
                                                            'income_sum_cash_cat2'] !=
                                                        0)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 14,
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              'ขายฮอร์โมน ${f.SeperateNumber(data[0]['income_sum_cash_cat2'] + data[0]['income_sum_credit_cat2'])} ขวด',
                                                              style:
                                                                  _baseFontStyle,
                                                            )),
                                                            Text(
                                                              '${f.SeperateNumber(data[0]['income_sum_cash_cat2_money'])} บาท',
                                                              style:
                                                                  _baseFontStyle,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    if (data[0][
                                                            'income_sum_credit_cus_pay'] !=
                                                        0)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 14,
                                                                vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              'ลูกค้าชำระเครดิต',
                                                              style:
                                                                  _baseFontStyle,
                                                            )),
                                                            Text(
                                                              '${f.SeperateNumber(data[0]['income_sum_credit_cus_pay'])} บาท',
                                                              style:
                                                                  _baseFontStyle,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Consumer<ShowDetail>(
                                      builder: (context, show, child) {
                                    return GestureDetector(
                                      onTap: () => show.changeExpense(),
                                      child: Card(
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 8),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'รวมรายจ่าย',
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  Text(
                                                    '${f.SeperateNumber(sumExpense)} บาท',
                                                    style: TextStyle(
                                                        color: dangerColor,
                                                        fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                              if (show.showExpense)
                                                Column(
                                                  children: [
                                                    HeaderText(
                                                      text: 'รายละเอียดรายจ่าย',
                                                      textSize: 20,
                                                      gHeight: 26,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าต้นทุนปุ๋ย ${f.SeperateNumber(data[0]['income_sum_cash_cat1'])} กระสอบ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_cash_cat1_cost'] + data[0]['expense_sum_credit_cat1_cost'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าต้นทุนฮอร์โมน ${f.SeperateNumber(data[0]['income_sum_cash_cat2'] + data[0]['income_sum_credit_cat2'])} ขวด',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_cash_cat2_cost'] + data[0]['expense_sum_credit_cat2_cost'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าส่วนต่างหัวหน้าทีม',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_share_red'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าส่วนต่างผู้จัดการ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_share_yellow'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าส่วนต่างผู้อำนวยการ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_share_orange'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าส่วนต่างCEO',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_share_ceo'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าแนะนำ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_recomend'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าขนส่งปุ๋ย',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_sendteam'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าใช้จ่ายรายวันหัวหน้าทีมบันทึก',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_carpayday'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 14,
                                                          vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            'ค่าใช้จ่ายรายวันฝ่ายติดตามหนี้และสินเชื่อ',
                                                            style:
                                                                _baseFontStyle,
                                                          )),
                                                          Text(
                                                            '${f.SeperateNumber(data[0]['expense_sum_money_creditpay'])} บาท',
                                                            style:
                                                                _baseFontStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Card(
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'กำไรสุทธิ (${sumNetPercent}%)',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            '${f.SeperateNumber(sumNet)} บาท',
                                            style: TextStyle(
                                                color: (sumNet > 0)
                                                    ? kPrimaryColor
                                                    : dangerColor,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return ShimmerLoading(
                                type: 'boxText',
                              );
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
        ));
  }

  Widget showChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 300,
        child: FutureBuilder(
          future: _listReport,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List data = snapshot.data.toList();

              var sumCash = 0;
              var sumCredit = 0;
              var sumMoneyShare = 0;
              var sumCost = 0;
              var sumOther = 0;
              var expense_sum_commision = 0;
              if (data.length > 0) {
                sumCash = data[0]['income_sum_cash_cat1_money'] +
                    data[0]['income_sum_cash_cat2_money'];
                sumCredit = data[0]['income_sum_credit_cat1_money'] +
                    data[0]['income_sum_credit_cat2_money'];
                sumMoneyShare =
                    ((data[0]['expense_sum_money_share_red'] == null)
                            ? 0
                            : data[0]['expense_sum_money_share_red']) +
                        ((data[0]['expense_sum_money_share_yellow'] == null)
                            ? 0
                            : data[0]['expense_sum_money_share_yellow']) +
                        ((data[0]['expense_sum_money_share_orange'] == null)
                            ? 0
                            : data[0]['expense_sum_money_share_orange']) +
                        ((data[0]['expense_sum_money_share_ceo'] == null)
                            ? 0
                            : data[0]['expense_sum_money_share_ceo']);
                sumCost = ((data[0]['expense_sum_cash_cat1_cost'] == null)
                        ? 0
                        : data[0]['expense_sum_cash_cat1_cost']) +
                    ((data[0]['expense_sum_cash_cat2_cost'] == null)
                        ? 0
                        : data[0]['expense_sum_cash_cat2_cost']) +
                    ((data[0]['expense_sum_credit_cat1_cost'] == null)
                        ? 0
                        : data[0]['expense_sum_credit_cat1_cost']) +
                    ((data[0]['expense_sum_credit_cat2_cost'] == null)
                        ? 0
                        : data[0]['expense_sum_credit_cat2_cost']);
                sumOther = ((data[0]['expense_sum_money_recomend'] == null)
                        ? 0
                        : data[0]['expense_sum_money_recomend']) +
                    ((data[0]['expense_sum_money_sendteam'] == null)
                        ? 0
                        : data[0]['expense_sum_money_sendteam']);
                expense_sum_commision =
                    (data[0]['expense_sum_commision'] == null)
                        ? 0
                        : data[0]['expense_sum_commision'];
              }

              return Row(
                children: [
                  Expanded(
                    child: renderChart(
                        id: 'product',
                        total: [sumCash, sumCredit],
                        isHorizon: false),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: renderChart(id: 'income_expense', color: [
                    grayDarkColor,
                    brownColor,
                    cyanColor,
                    greenColor
                  ], legend: [
                    'ค่าคอมมิชชั่น',
                    'ค่าส่วนต่าง',
                    'ต้นทุนการผลิต',
                    'อื่น ๆ'
                  ], total: [
                    expense_sum_commision,
                    sumMoneyShare,
                    sumCost,
                    sumOther
                  ])),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget renderChart(
      {isHorizon = false,
      id = 'sale',
      List color = const [grayDarkColor, cyanColor],
      List legend = const ['เงินสด', 'เครดิต'],
      List total = const [50, 50]}) {
    assert(color.length == legend.length,
        '\'Color\' length should equal to \'Legend\' length');
    assert(color.length == total.length,
        '\'Color\' length should equal to \'Total\' length');
    assert(legend.length == total.length,
        '\'Legend\' length should equal to \'Total\' length');

    final data = List.generate(
      color.length,
      (index) => TeamGoal(charts.ColorUtil.fromDartColor(color[index]),
          legend[index], total[index]),
    );

    int sum = total.fold(0, (pv, e) => pv + e);
    if (sum == 0) {
      print('case sum 0 : $sum');
      List<charts.Series<TeamGoal, String>> series = [
        new charts.Series(
          id: id,
          data: data,
          domainFn: (TeamGoal sale, _) => sale.text,
          measureFn: (TeamGoal sale, _) => 50,
          colorFn: (TeamGoal sale, _) => sale.color,
        )
      ];
      return CeoPieChart(
        series,
        animate: true,
        enableLabel: false,
        horizontalFirst: isHorizon,
      );
    } else {
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
      return CeoPieChart(
        series,
        animate: true,
        enableLabel: true,
        horizontalFirst: isHorizon,
      );
    }
  }
}
