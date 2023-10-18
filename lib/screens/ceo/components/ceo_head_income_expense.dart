import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class CeoHeadIncomeExpense extends StatefulWidget {
  final int headId;

  const CeoHeadIncomeExpense({Key key, this.headId}) : super(key: key);

  @override
  _CeoHeadIncomeExpenseState createState() => _CeoHeadIncomeExpenseState();
}

class _CeoHeadIncomeExpenseState extends State<CeoHeadIncomeExpense> {
  var userData;
  Map<String, dynamic> incomeData;
  List expenseData = [];
  Map<String, dynamic> expenseMoneyShare = {};
  Map<String, dynamic> expenseMoneyRecommend = {};
  Map<String, dynamic> transferTeam = {};
  String timeGen = '';
  String dayGen = '';
  int sumExpense = 0;
  int sumIncome = 0;
  int sumExpenseChart = 0;
  Future<bool> isLoaded;
  FormatMethod f = FormatMethod();
  String selectedMonth = '';
  DateTime initDate = DateTime.now();
  var monthSelectText = TextEditingController();

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

        getReport();
      }
    });
  }

  Future getData() async {
    getHeadData();

    await getReport();
  }

  Future getHeadData() async {
    userData = await Sqlite().getHeadDetail(widget.headId);
    setState(() {});
  }

  Future refresh() async {
    await getReport(isRefresh: true);
  }

  Future getReport({bool isRefresh = false}) async {
    print('getReport');
    print(initDate);
    Map<String, dynamic> reportData;
    var res = await Sqlite().getJson(
        'CEO_INCOME_EXPENSE_REPORT_${initDate.year}_${initDate.month}',
        '${widget.headId}');
    if (!isRefresh && res != null) {
      print('offline');
      reportData = jsonDecode(res['JSON_VALUE']);
    } else {
      print('online');
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context, MediaQuery.of(context).size);
        var client = Client();
        var res = await client.get(
            '$apiPath/getIncomeExpenseCeoReport/$selectedMonth/${widget.headId}');
        if (res.statusCode == 200) {
          Sqlite().insertJson(
              'CEO_INCOME_EXPENSE_REPORT_${initDate.year}_${initDate.month}',
              '${widget.headId}',
              res.body);
          reportData = jsonDecode(res.body);
        } else {
          print(
              '$apiPath/getIncomeExpenseCeoReport/$selectedMonth/${widget.headId}');
          print(res.body);
        }
        Navigator.pop(context);
      }
    }
    if (reportData != null) {
      incomeData = reportData['income_data'];
      expenseData = reportData['expense_data'];
      expenseMoneyShare = reportData['expense_money_share'];
      expenseMoneyRecommend = reportData['expense_money_recommend'];
      transferTeam = reportData['transfer_team'];
      timeGen = reportData['time_gen'];
      dayGen = reportData['day_gen'];
      var expense = expenseData.fold(0, (pv, ele) => pv + ele['car_pay_money']);
      sumExpenseChart = expense + transferTeam['sum'];
      sumIncome = incomeData['cash_money_total_cat1'] +
          incomeData['credit_money_earnest'] +
          incomeData['cash_money_total_cat2'] +
          incomeData['credit_count_product_cat2'];
      sumExpense = sumExpenseChart +
          incomeData['SumUserMoneyRecommend'] +
          expenseMoneyShare['SumUserMoneyShareHead'] +
          expenseMoneyRecommend['SumUserMoneyRecommend'] +
          incomeData['cash_count_commission_cat1'] +
          incomeData['cash_count_commission_cat2'] +
          incomeData['cash_count_cost_cat1'] +
          incomeData['cash_count_cost_cat2'];
      isLoaded = Future.value(true);
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    if (initDate.day >= 1 && initDate.day <= 5) {
      initDate = new DateTime(initDate.year, initDate.month - 1, initDate.day);
      selectedMonth =
          '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
    } else {
      selectedMonth =
          '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
    }
    getData();
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
                // title: Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     MyNoti(
                //       userId: user_id,
                //     )
                //   ],
                // ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bgTop2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                // leading: Builder(
                //   builder: (context) => IconButton(
                //     icon: Icon(Icons.menu, size: 40),
                //     onPressed: () => Scaffold.of(context).openDrawer(),
                //   ),
                // ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: saleDetail(),
                  ),
                  SliverToBoxAdapter(
                    child: showChart(),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      FutureBuilder(
                          future: isLoaded,
                          builder: (context, snapshot) {
                            TextStyle _baseFontStyle = TextStyle(fontSize: 18);
                            if (snapshot.hasData) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                                      style: TextStyle(
                                                          fontSize: 20),
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
                                                        text:
                                                            'รายละเอียดรายรับ',
                                                        textSize: 20,
                                                        gHeight: 26,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                              'ขายปุ๋ยเงินสด ${f.SeperateNumber(incomeData['cash_count_product_cat1'])} กระสอบ',
                                                              style:
                                                                  _baseFontStyle,
                                                            )),
                                                            Text(
                                                              '${f.SeperateNumber(incomeData['cash_money_total_cat1'])} บาท',
                                                              style:
                                                                  _baseFontStyle,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                              'เงินมัดจำปุ๋ยเครดิต ${f.SeperateNumber(incomeData['credit_count_product_cat1'])} กระสอบ',
                                                              style:
                                                                  _baseFontStyle,
                                                            )),
                                                            Text(
                                                              '${f.SeperateNumber(incomeData['credit_money_earnest'])} บาท',
                                                              style:
                                                                  _baseFontStyle,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      if (incomeData[
                                                              'sum_count_product_cat2'] !=
                                                          0)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 4),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                'รับเงินขายฮอร์โมน ${f.SeperateNumber(incomeData['sum_count_product_cat2'])} ขวด',
                                                                style:
                                                                    _baseFontStyle,
                                                              )),
                                                              Text(
                                                                '${f.SeperateNumber(incomeData['cash_money_total_cat2'] + incomeData['credit_count_product_cat2'])} บาท',
                                                                style:
                                                                    _baseFontStyle,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      // Padding(
                                                      //   padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 4),
                                                      //   child: Row(
                                                      //     children: [
                                                      //       Expanded(
                                                      //           child: Text('ค่าแนะนำ',
                                                      //               style: _baseFontStyle)),
                                                      //       Text(
                                                      //           '${f.SeperateNumber(incomeData['SumUserMoneyRecommend'])} บาท',
                                                      //           style: _baseFontStyle)
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                    ],
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name:
                                                      'CEOดูข้อมูลรายจ่ายทีม'),
                                              builder: (context) =>
                                                  ExpenseDetail(
                                                    expense: expenseData,
                                                    expenseMoneyRecommend:
                                                        expenseMoneyRecommend,
                                                    expenseMoneyShare:
                                                        expenseMoneyShare,
                                                    income: incomeData,
                                                    transferTeam: transferTeam,
                                                  ))),
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
                                                        color: danger,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          HeaderText(
                                            text: 'ยอดขายเครดิต',
                                            textSize: 20,
                                            gHeight: 26,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'ยอดขายเครดิต ${f.SeperateNumber(incomeData['credit_count_product_cat1'])} กระสอบ',
                                                      style: _baseFontStyle,
                                                    ),
                                                    Text(
                                                        '${f.SeperateNumber(incomeData['credit_money_total_cat1'])} บาท',
                                                        style: _baseFontStyle),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        'เงินมัดจำ ${f.SeperateNumber(incomeData['credit_count_product_cat1'])} กระสอบ',
                                                        style: _baseFontStyle),
                                                    Text(
                                                        '${f.SeperateNumber(incomeData['credit_money_earnest'])} บาท',
                                                        style: _baseFontStyle),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        'จำนวนเงิน ${f.SeperateNumber(incomeData['credit_money_total_cat1'])} บาท',
                                                        style: _baseFontStyle),
                                                    Text(
                                                        'ค้างชำระ ${f.SeperateNumber(incomeData['credit_money_total_cat1'] + incomeData['credit_money_earnest'])} บาท',
                                                        style: _baseFontStyle),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return ShimmerLoading(
                                type: 'boxItem1Row',
                              );
                            }
                          })
                    ]),
                  ),
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

  Widget showChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 300,
        child: FutureBuilder(
          future: isLoaded,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                children: [
                  Expanded(
                      child: renderChart(id: 'product', total: [
                    incomeData['cash_money_total'],
                    incomeData['credit_money_total']
                  ])),
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
                    incomeData['cash_count_commission_cat1'] +
                        incomeData['cash_count_commission_cat2'],
                    expenseMoneyShare['SumUserMoneyShareHead'] +
                        expenseMoneyRecommend['SumUserMoneyRecommend'],
                    incomeData['cash_count_cost_cat1'] +
                        incomeData['cash_count_cost_cat2'],
                    sumExpenseChart
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

  Widget saleDetail() {
    Size size = MediaQuery.of(context).size;
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Container(
      child: userData != null
          ? Column(
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
                              'รายรับ - รายจ่าย',
                              style: TextStyle(fontSize: 24.0, height: 1),
                            ),
                            Text(
                              'สรุปข้อมูลจากวันที่ลูกค้าเซ็นรับสินค้า',
                              style: TextStyle(fontSize: 16.0, height: 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          width: size.width * 0.28,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: '$storagePath/${userData['Image']}',
                              errorWidget: (context, url, error) {
                                return Image.asset('assets/avatar.png');
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeaderText(
                              textSize: 20,
                              gHeight: 26,
                              text: 'ทีม : ${userData['Name']}',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'พนักงานขาย',
                                        style: _baseFontStyle,
                                      ),
                                      Text(
                                        '${userData['team_count']} คน',
                                        style: _baseFontStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ทะเบียน', style: _baseFontStyle),
                                      Text(
                                          '${userData['car_platenumber'].trim()}',
                                          style: _baseFontStyle),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('เขตพื้นที่การขาย',
                                          style: _baseFontStyle),
                                      Text(
                                          '${userData['PROVINCE_NAME'].trim()}',
                                          style: _baseFontStyle)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                // RaisedButton(
                //     child: Text('เลือกรายงาน'),
                //     onPressed: () => _showMonthPicker())
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
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
                                        const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                    child: TextField(
                                      controller: monthSelectText,
                                      textAlign: TextAlign.center,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        // labelText:'ข้อมูล ณ วันที่',
                                        hintText: 'ข้อมูลประจำเดือนนี้',
                                        contentPadding: EdgeInsets.all(5),
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
                                          width: 2, color: subFontColor),
                                      bottom: BorderSide(
                                          width: 2, color: subFontColor),
                                    ),
                                    color: bgInputColor,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 5,
                                  child: Container(
                                    child: Icon(
                                      Icons.arrow_drop_down_outlined,
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
            )
          : ShimmerLoading(
              type: 'boxItem1Row',
            ),
    );
  }
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
          legend[index], total[index]));
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
    );
  }
}

class ExpenseDetail extends StatelessWidget {
  final List expense;
  final Map<String, dynamic> expenseMoneyShare;
  final Map<String, dynamic> expenseMoneyRecommend;
  final Map<String, dynamic> income;
  final Map<String, dynamic> transferTeam;

  const ExpenseDetail(
      {Key key,
      this.expense,
      this.expenseMoneyShare,
      this.expenseMoneyRecommend,
      this.income,
      this.transferTeam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    FormatMethod f = FormatMethod();
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: SafeArea(
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
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                padding: const EdgeInsets.only(
                                    left: 5, right: 12, top: 8, bottom: 8),
                                child: Icon(
                                  FontAwesomeIcons.amazonPay,
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
                                    'รายละเอียดค่าใช้จ่าย',
                                    style: TextStyle(fontSize: 24.0, height: 1),
                                  ),
                                  Text(
                                    'ข้อมูลรายการค่าใช้จ่ายทั้งหมดภายในคันรถ',
                                    style: TextStyle(fontSize: 16.0, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ค่าส่วนต่างSup. เงินสด',
                            style: _baseFontStyle,
                          ),
                          Text(
                            '${f.SeperateNumber(expenseMoneyShare['SumUserMoneyShareHead_cat1'])} บาท',
                            style: _baseFontStyle,
                          )
                        ],
                      ),
                      Divider(),
                      if (expenseMoneyRecommend['SumUserMoneyRecommend'] != 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'ค่าแนะนำ เงินสด ${f.SeperateNumber(expenseMoneyRecommend['SumUserMoneyRecommend_cat1'])} กระสอบ',
                                style: _baseFontStyle),
                            Text(
                                '${f.SeperateNumber(expenseMoneyRecommend['SumUserMoneyRecommend'])} บาท',
                                style: _baseFontStyle)
                          ],
                        ),
                      if (expenseMoneyRecommend['SumUserMoneyRecommend'] != 0)
                        Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'ค่าคอมมิชชั่นปุ๋ย ${f.SeperateNumber(income['cash_count_product_cat1'])} กระสอบ',
                              style: _baseFontStyle),
                          Text(
                              '${f.SeperateNumber(income['cash_count_commission_cat1'])} บาท',
                              style: _baseFontStyle)
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'ต้นทุนปุ๋ย ${f.SeperateNumber(income['cash_count_product_cat1'])} กระสอบ',
                              style: _baseFontStyle),
                          Text(
                              '${f.SeperateNumber(income['cash_count_cost_cat1'])} บาท',
                              style: _baseFontStyle)
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'ต้นทุนยา ${f.SeperateNumber(income['cash_count_product_cat2'])} กระสอบ',
                              style: _baseFontStyle),
                          Text(
                              '${f.SeperateNumber(income['cash_count_cost_cat2'])} บาท',
                              style: _baseFontStyle)
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'ค่าขนส่ง ${f.SeperateNumber(transferTeam['sum_cat1'])} กระสอบ',
                              style: _baseFontStyle),
                          Text('${f.SeperateNumber(transferTeam['sum'])} บาท',
                              style: _baseFontStyle)
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((bc, i) {
                var res = expense[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                '${res['car_pay_name']} (${res['car_pay_detail'] ?? ''} รถทะเบียน ${res['car_number']})',
                                style: _baseFontStyle),
                          ),
                          Text('${f.SeperateNumber(res['car_pay_money'])} บาท',
                              style: _baseFontStyle)
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              }, childCount: expense.length)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Footer(),
                ),
              )
            ],
          ),
          // body: Column(
          //   children: [
          //     Text('รายละเอียดค่าใช้จ่าย'),
          //     Container(
          //       height: size.height * 0.4,
          //       child: ListView.builder(
          //           itemCount: expense.length,
          //           shrinkWrap: true,
          //           itemBuilder: (bc, i) {
          //             var res = expense[i];
          //             return Card(
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text(
          //                       '${res['car_pay_name']} (${res['car_pay_detail'] ?? ''} รถทะเบียน ${res['car_number']})'),
          //                   Text('${f.SeperateNumber(res['car_pay_money'])} บาท')
          //                 ],
          //               ),
          //             );
          //           }),
          //     )
          //   ],
          // ),
        ),
      ),
    );
  }
}
