import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/screens/head/components/overdue_report.dart';
import 'package:system/screens/head/components/team_sell_card.dart';
import 'package:system/screens/head/components/team_sell_detail.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HeadDashboard extends StatefulWidget {
  final int userId;

  const HeadDashboard({Key key, this.userId}) : super(key: key);

  @override
  _HeadDashboardState createState() => _HeadDashboardState();
}

class _HeadDashboardState extends State<HeadDashboard> {
  int carCount = 0;
  int teamGoal = 0;
  var userData = new Map();
  var ds = new Map();
  FormatMethod f = FormatMethod();
  Future<bool> isLoaded;
  Future<bool> isChartLoaded;
  Map<String, TeamGoal> chartData;
  var series;
  List teamData = [];
  var client = Client();
  Size size;

  Future<Null> getTeamSellData() async {
    print('getTeamSellData');
    var res = await Sqlite().getJson('GET_TEAM_SALE', '${widget.userId}');
    if (res != null) {
      teamData = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var data = {
          'func': 'get_team_sales_test2',
          'head_id': '${widget.userId}'
        };
        var res = await post('$apiPath-heads', body: data);
        teamData = jsonDecode(res.body);
        Sqlite().insertJson('GET_TEAM_SALE', '${widget.userId}', res.body);
      }
    }
  }

  Future<Null> getData() async {
    initDataSet();
    getCarCount();
    await getUserData()
        .then((value) => getTeamBillData().then((value) => getTeamGoal()));
    getTeamCreditData();
    await getTeamSellData();
    setState(() {});
  }

  Future<Null> getOnlineData() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      AlertNewDesign().showLoading(context, MediaQuery.of(context).size);
      //getTeamBillData
      var teamBillData = await client.post('$apiPath-heads', body: {
        'func': 'get_team_bill_data_this_month',
        'head_id': '${widget.userId}',
        'head_work_car_id': '${userData['Work_car_id']}'
      });
      Sqlite().insertJson(
          'HEAD_TEAM_BILL_DATA', '${widget.userId}', teamBillData.body);
      //getTeamBillData

      //getTeamCreditData
      var teamCreditData = await client.post('$apiPath/getCreditReceived',
          body: {'head_id': '${widget.userId}'});
      Sqlite().insertJson('HEAD_TEAM_BILL_DATA_CREDIT_RECEIPT',
          '${widget.userId}', teamCreditData.body);
      //getTeamCreditData

      //getTeamSellData
      var data = {
        'func': 'get_team_sales_test2',
        'head_id': '${widget.userId}'
      };
      var teamSellData = await post('$apiPath-heads', body: data);
      Sqlite()
          .insertJson('GET_TEAM_SALE', '${widget.userId}', teamSellData.body);
      //getTeamSellData
      Navigator.pop(context);
    }
  }

  Future<Null> _refresh() async {
    await getOnlineData();
    await getData();
  }

  Future<Null> initDataSet() async {
    isChartLoaded = Future.value();
    ds['cash_product_cat1'] = 0;
    ds['cash_product_cat2'] = 0;
    ds['cash_product_cat1_590'] = 0;
    ds['cash_product_cat1_690'] = 0;
    ds['cash_moneytotal'] = 0;
    ds['cash_commission'] = 0;
    ds['cash_commission_pay_success'] = 0;

    ds['credit_product_cat1'] = 0;
    ds['credit_product_cat2'] = 0;
    ds['credit_product_cat1_590'] = 0;
    ds['credit_product_cat1_690'] = 0;
    ds['credit_moneytotal'] = 0;
    ds['credit_commission'] = 0;
    ds['credit_commission_pay_success'] = 0;
    ds['credit_moneytotal_pay_success'] = 0;
    ds['credit_moneytotal_pay_success_number'] = 0;
    ds['credit_money_due'] = 0;
    ds['credit_money_due_number'] = 0;
    ds['credit_product_cat1_wait'] = 0;
    ds['credit_product_cat1_receive'] = 0;
  }

  Future<Null> getUserData() async {
    print('getUserData');
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_userdata', 'User_id': '${widget.userId}'});
    // userData = jsonDecode(res.body)[0];
    var res = await Sqlite().getUserDataById(widget.userId);
    userData = res[0];
    isLoaded = Future.value(true);
    setState(() {});
  }

  Future<Null> getCarCount() async {
    print('getCarCount');
    var res = await Sqlite().headCarCount(widget.userId);
    if (res != null) {
      carCount = res.length;
    }
    // var res = await client.post('$apiPath-heads',
    //     body: {'func': 'get_car_for_head', 'head_id': '${widget.userId}'});
    // print(jsonDecode(res.body));
    //carCount = jsonDecode(res.body).length;
  }

  Future<Null> getTeamBillData() async {
    var res = await Sqlite().getJson('HEAD_TEAM_BILL_DATA', '${widget.userId}');
    if (res != null) {
      List teamBillDataList = jsonDecode(res['JSON_VALUE']);
      ds['credit_moneytotal'] = 0;
      ds['credit_product_cat1'] = 0;
      ds['credit_product_cat1_590'] = 0;
      ds['credit_product_cat1_690'] = 0;

      teamBillDataList.forEach((item) {
        forEachBill(item);
      });
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        print('getTeamBillData');
        var res = await client.post('$apiPath-heads', body: {
          'func': 'get_team_bill_data_this_month',
          'head_id': '${widget.userId}',
          'head_work_car_id': '${userData['Work_car_id']}'
        });
        List teamBillDataList = jsonDecode(res.body);
        Sqlite()
            .insertJson('HEAD_TEAM_BILL_DATA', '${widget.userId}', res.body);
        ds['credit_moneytotal'] = 0;
        ds['credit_product_cat1'] = 0;
        ds['credit_product_cat1_590'] = 0;
        ds['credit_product_cat1_690'] = 0;

        teamBillDataList.forEach((item) {
          forEachBill(item);
        });
      }
    }
  }

  void forEachBill(item) {
    if (item['Order_detail'] != '[]') {
      var obj = jsonDecode(item['Order_detail']);
      if (item['Pay_type'] == 1) {
        obj.forEach((element) {
          subCountAllCash(element);
        });
        ds['cash_moneytotal'] += item['Money_total'];
        ds['cash_commission'] += item['Commission_sum'];
      } else {
        obj.forEach((element) {
          subCountAllCredit(element);
        });
        ds['credit_moneytotal'] += item['Money_total'];
        ds['credit_commission'] += item['Commission_sum'];

        if (item['Status'] == 9) {
          ds['credit_money_due'] += item['Money_due'];
          ds['credit_money_due_number'] += 1;
          obj.forEach((element) {
            subCountAllCreditStatus9(element);
          });
        }
      }
    }
  }

  void subCountAllCash(item) {
    if (item['cat_id'] == 1) {
      ds['cash_product_cat1'] += item['qty'];
      if (item['price_sell'] == 590) {
        ds['cash_product_cat1_590'] += item['qty'];
      } else if (item['price_sell'] == 690) {
        ds['cash_product_cat1_690'] += item['qty'];
      }
    }
    if (item['cat_id'] == 2) {
      ds['cash_product_cat2'] += item['qty'];
    }
  }

  void subCountAllCredit(item) {
    if (item['cat_id'] == 1) {
      ds['credit_product_cat1'] += item['qty'];
      if (item['price_sell'] == 590) {
        ds['credit_product_cat1_590'] += item['qty'];
      } else if (item['price_sell'] == 690) {
        ds['credit_product_cat1_690'] += item['qty'];
      }
    }
    if (item['cat_id'] == 2) {
      ds['credit_product_cat2'] += item['qty'];
    }
  }

  void subCountAllCreditStatus9(item) {
    if (item['cat_id'] == 1) {
      ds['credit_product_cat1_wait'] += item['qty'];
    }
  }

  void subCountAllCreditStatus7(item) {
    if (item['cat_id'] == 1) {
      ds['credit_product_cat1_receive'] += item['qty'];
    }
  }

  Future<Null> getTeamGoal() async {
    print('getTeamGoal');
    var res = await Sqlite().headTeamGoal(widget.userId);
    teamGoal = res[0]['Goal'];
    // print('teamGoal = ${ress[0]['Goal'].runtimeType}');
    // var res = await client.post('$apiPath-heads',
    //     body: {'func': 'get_team_goal', 'head_id': '${widget.userId}'});
    // List teamGoalList = jsonDecode(res.body);
    // teamGoal = teamGoalList.fold(0, (pv, ele) => pv + ele['Goal']);
    int sell = ds['cash_product_cat1'] + ds['credit_product_cat1'];
    chartData = {
      'sell':
          TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sell)
    };
    if (teamGoal - sell < 0) {
      chartData['goal'] = TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 0);
    } else {
      chartData['goal'] = TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)),
          'goal',
          teamGoal - sell);
    }
    series = [
      charts.Series(
          domainFn: (TeamGoal data, i) => data.text,
          measureFn: (TeamGoal data, i) => data.total,
          colorFn: (TeamGoal data, i) => data.color,
          labelAccessorFn: (TeamGoal data, i) => data.text,
          id: 'TeamGoal',
          data: chartData.values.toList()),
    ];
    isChartLoaded = Future.value(true);
    //setState(() {});
  }

  Future<Null> getTeamCreditData() async {
    print('getTeamCreditData');
    var res = await Sqlite()
        .getJson('HEAD_TEAM_BILL_DATA_CREDIT_RECEIPT', '${widget.userId}');
    if (res != null) {
      List teamCreditData = jsonDecode(res['JSON_VALUE']);
      teamCreditData.forEach((element) {
        forEachBillAllCreditReceived(element);
      });
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var res = await client.post('$apiPath/getCreditReceived',
            body: {'head_id': '${widget.userId}'});
        List teamCreditData = jsonDecode(res.body);
        print('teamCreditData $teamCreditData');
        Sqlite().insertJson(
            'HEAD_TEAM_BILL_DATA_CREDIT_RECEIPT', '${widget.userId}', res.body);
        teamCreditData.forEach((element) {
          forEachBillAllCreditReceived(element);
        });
      }
    }
  }

  void forEachBillAllCreditReceived(item) {
    if (item['Order_detaill'] != '[]') {
      var obj = jsonDecode(item['Order_detail']);

      if (item['Status'] == 7 || item['Status'] == 15) {
        obj.forEach((ele) {
          subCountAllCreditStatus7(ele);
        });
      }
    }
  }

  List<GestureDetector> showTeamData() {
    return List.generate(teamData.length, (index) {
      var res = teamData[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  settings: RouteSettings(name: 'Sup.ดูข้อมูลลูกทีม'),
                  builder: (context) => TeamSellDetail(
                        saleId: res['ID'],
                      )));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TeamSellCard(
            saleId: res['ID'],
            imgAvatar: res['Image'],
            userName: res['Username'],
            name: res['Name'],
            surname: res['Surname'],
            workCarId: res['Work_car_id'],
            goal: res['Goal'],
            workCar: res['Work_car'],
            cashProductCat1: res['cash_count_product_cat1'],
            creditProductCat1: res['credit_count_product_cat1'],
            cashMoneyTotal: res['cash_money_total'],
            creditMoneyTotal: res['credit_money_total'],
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
                title: Text('ข้อมูลภายใต้สายบริหาร'),
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
            body: Container(
                child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                shrinkWrap: false,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: showOwner(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(flex: 1, child: goalChart()),
                          Expanded(flex: 1, child: showTeamGoal()),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          showTeamGoalCash(),
                          showTeamGoalCredit(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FutureBuilder(
                        future: isLoaded,
                        builder: (bc, snap) {
                          if (snap.hasData) {
                            return OverDueReport(
                                workCarId: userData['Work_car_id']);
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 2),
                      child: Column(
                        children: showTeamData(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Footer(),
                    ),
                  )
                ],
              ),
            )),
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.ac_unit, color: Colors.white),
            //   onPressed: () {
            //     getData();
            //   },
            // ),
          ),
        ),
      ),
    );
  }

  Widget goalChart() {
    return Container(
      // color: Colors.amberAccent,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
              future: isChartLoaded,
              builder: (context, snap) {
                if (snap.hasData) {
                  return HalfDonut(
                    series,
                    animate: true,
                    formPage: 'margin5',
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: HalfDonut.simpleData(),
                  );
                }
              }),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, right: 0),
            child: teamGoal > 0
                ? Text(
                    '${(((ds['cash_product_cat1'] + ds['credit_product_cat1']) / teamGoal) * 100).floor()} %',
                    style: TextStyle(fontSize: 24),
                  )
                : Text('0 %'),
          ),
          Container(
            padding: const EdgeInsets.only(top: 74),
            child: Card(
              elevation: 2,
              color: Color(0xFFf1f1f1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      width: 172,
                      color: darkColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ขายได้แล้ว',
                            style:
                                TextStyle(color: backgroundColor, fontSize: 16),
                          ),
                          Text(
                            '${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กระสอบ',
                            style: TextStyle(
                                color: kSecondaryColor,
                                fontSize: 20,
                                height: 1),
                          ),
                        ],
                      )),
                  Text(
                    'เขตการขาย : ${userData['PROVINCE_NAME']}',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showTeamGoalCredit() {
    TextStyle baseFontStyle = TextStyle(
      fontSize: 18,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderText(
              text: 'สรุปยอดขาย เครดิต ประจำเดือนนี้',
              textSize: 20,
              gHeight: 26,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 5, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ยอดขายเครดิตรวม ',
                          style: baseFontStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${f.SeperateNumber(ds['credit_moneytotal'])} บาท (${f.SeperateNumber(ds['credit_product_cat1'])} กระสอบ)',
                          style: baseFontStyle,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ขายปุ๋ยราคา 590 ได้',
                          style: baseFontStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${f.SeperateNumber(ds['credit_product_cat1_590'])} กระสอบ',
                          style: baseFontStyle,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ขายปุ๋ยราคา 690 ได้',
                          style: baseFontStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${f.SeperateNumber(ds['credit_product_cat1_690'])} กระสอบ',
                          style: baseFontStyle,
                        ),
                      ),
                    ],
                  ),
                  if (ds['credit_product_cat1_receive'] > 0)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ลูกค้าชำระแล้ว',
                            style: baseFontStyle,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${f.SeperateNumber(ds['credit_product_cat1_receive'])} กระสอบ',
                            style: baseFontStyle,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'รอลูกค้าชำระ',
                          style: baseFontStyle,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${f.SeperateNumber(ds['credit_product_cat1_wait'])} กระสอบ',
                          style: baseFontStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )

            // Divider()
          ],
        ),
      ),
    );
  }

  Widget showOwner() {
    return Center(
        child: RichText(
      text: TextSpan(
          text: "ทีม",
          style: TextStyle(
              color: mainFontColor,
              fontFamily: 'DB',
              fontSize: 25,
              fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
                text: ' ${userData['Name']}',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            TextSpan(
                text: ' (จำนวนรถที่ดูแล $carCount คัน)',
                style: TextStyle(
                  fontSize: 20,
                )),
          ]),
    ));
  }

  Widget showTeamGoalCash() {
    TextStyle baseFontStyle = TextStyle(
      fontSize: 18,
    );
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderText(
            text: 'สรุปยอดขาย เงินสด ประจำเดือนนี้',
            textSize: 20,
            gHeight: 26,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ยอดขายเงินสดรวม',
                        style: baseFontStyle,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${f.SeperateNumber(ds['cash_moneytotal'])} บาท (${f.SeperateNumber(ds['cash_product_cat1'])} กระสอบ)',
                        style: baseFontStyle,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ขายปุ๋ยราคา 590 ได้',
                        style: baseFontStyle,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${f.SeperateNumber(ds['cash_product_cat1_590'])} กระสอบ',
                        style: baseFontStyle,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ขายปุ๋ยราคา 690 ได้',
                        style: baseFontStyle,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${f.SeperateNumber(ds['cash_product_cat1_690'])} กระสอบ',
                        style: baseFontStyle,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ขายฮอร์โมนได้ ',
                        style: baseFontStyle,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${f.SeperateNumber(ds['cash_product_cat2'])} ขวด',
                        style: baseFontStyle,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Divider()
        ],
      ),
    );
  }

  Widget showTeamGoal() {
    TextStyle baseStyle = new TextStyle(fontSize: 18);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderText(
          text: 'เป้ายอดขายทีม',
          textSize: 20,
          gHeight: 26,
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ยอดขาย',
                  style: baseStyle,
                ),
                Text(
                  '${f.SeperateNumber(teamGoal)} กระสอบ',
                  style: baseStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ขายได้แล้ว',
                  style: baseStyle,
                ),
                Text(
                  '${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กระสอบ',
                  style: baseStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ขาดอีก',
                  style: baseStyle,
                ),
                (teamGoal >
                        (ds['cash_product_cat1'] + ds['credit_product_cat1']))
                    ? Text(
                        '${f.SeperateNumber(teamGoal - (ds['cash_product_cat1'] + ds['credit_product_cat1']))} กระสอบ',
                        style: baseStyle)
                    : Text(' 0 กระสอบ', style: baseStyle),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ขายปุ๋ยราคา 590 ได้',
                  style: baseStyle,
                ),
                Text(
                  '${f.SeperateNumber(ds['cash_product_cat1_590'] + ds['credit_product_cat1_590'])} กระสอบ',
                  style: baseStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ขายปุ๋ยราคา 690 ได้',
                  style: baseStyle,
                ),
                Text(
                  '${f.SeperateNumber(ds['cash_product_cat1_690'] + ds['credit_product_cat1_690'])} กระสอบ',
                  style: baseStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ขายฮอร์โมนได้',
                  style: baseStyle,
                ),
                Text(
                  '${f.SeperateNumber(ds['cash_product_cat2'] + ds['credit_product_cat2'])} ขวด',
                  style: baseStyle,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
