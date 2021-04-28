import 'dart:convert';
import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/horizontal_bar_chart.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:system/screens/submanager/components/chart_ranking.dart';
import 'package:system/screens/submanager/components/manager_team_detail.dart';
import 'package:system/screens/submanager/components/submanager_head_card.dart';

class ManagerDashboard extends StatefulWidget {
  final int userId;

  const ManagerDashboard({Key key, this.userId}) : super(key: key);

  @override
  _ManagerDashboardState createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int carCount = 0;
  int teamCount = 0;
  int salesCount = 0;
  var ds = new Map();
  FormatMethod f = FormatMethod();
  int teamGoal = 0;
  var userData = new Map();
  Future<bool> isLoaded;
  Future<bool> isChartLoaded;
  Future<bool> isBarChartLoaded;
  Map<String, TeamGoal> chartData;
  Map<String, SaleRanking> chartDataRanking;
  List legendData = [];
  var series;
  var barSeries;
  List teamData = [];
  List teamDataRank = [];
  var client = Client();
  Widget imageAvatar;
  TextStyle _baseFontStyle = TextStyle(fontSize: 18);

      Future<Null> getData() async {
    initDataSet();
    getCarCount();
    getUserData();
    getTeamCount();
    getSalesCount();
    getBillDataThisMonthForTeamSorkRank();
    await getAllBillDataThisMonth();
    await getTeamGoal();
    if(mounted) setState(() {});
  }

  Future<Null> initDataSet() async {
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
    // ds['credit_product_cat1_receive'] = 0;
  }

  Future loadImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    if (File('$appDocPath/user_avatar_${widget.userId}.jpeg').existsSync()) {
      imageAvatar = Image.file(File('$appDocPath/user_avatar_${widget.userId}.jpeg'));
    } else {
      imageAvatar = Image.asset('assets/avatar.png');
    }
    setState(() {});
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
    // carCount = jsonDecode(res.body).length;
  }

  Future<Null> getTeamCount() async {
    print('getTeamCount');
    var res = await Sqlite().getTeamForManager(widget.userId);
    if (res != null) {
      teamCount = res.length;
    }
    // var res = await client.post('$apiPath-manager', body: {
    //   'func': 'get_team_for_manager',
    //   'manager_id': '${widget.userId}'
    // });
    // teamCount = jsonDecode(res.body).length;
  }

  Future<Null> getSalesCount() async {
    print('getSalesCount');
    var res = await Sqlite().getSaleForManager(widget.userId);
    salesCount = res[0]['Count'];
    // var res = await client.post('$apiPath-manager', body: {
    //   'func': 'get_sales_count_for_manager',
    //   'manager_id': '${widget.userId}'
    // });
    // salesCount = int.parse(res.body);
    // print('saleCount $salesCount');
  }

  Future<Null> getAllBillDataThisMonth() async {
    print('getAllBillDataThisMonth');
    var res = await Sqlite()
        .getJson('MANAGER_ALL_BILL_DATA_THIS_MONTH', '${widget.userId}');
    if (res != null) {
      List data = jsonDecode(res.body);
      data.forEach((element) {
        forEachBill(element);
      });
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        var res = await client.post('$apiPath-manager', body: {
          'func': 'get_all_bill_data_this_month_test',
          'manager_id': '${widget.userId}'
        });
        List data = jsonDecode(res.body);
        data.forEach((element) {
          forEachBill(element);
        });
        print('ds $ds');
        Navigator.pop(context);
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
        if (item['Status'] == 10) {
          ds['cash_commission_pay_success'] += item['Comission_sum'];
        }
      } else {
        obj.forEach((element) {
          subCountAllCredit(element);
        });
        ds['credit_moneytotal'] += item['Money_total'];
        ds['credit_commission'] += item['Commission_sum'];

        if (item['Status'] == 10) {
          ds['credit_commission_pay_success'] += item['Commission_sum'];
          ds['credit_moneytotal_pay_success'] += item['Money_total'];
          ds['credit_moneytotal_pay_success_number'] += 1;
        }

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
    // var res = await client.post('$apiPath-manager',
    //     body: {'func': 'get_manager_goal', 'manager_id': '${widget.userId}'});
    // List data = jsonDecode(res.body);
    // var teamGoalList = data.where((element) => element['Goal'] != null);
    // teamGoal = teamGoalList.fold(0, (pv, ele) => pv + ele['Goal']);

    var res = await Sqlite().headTeamGoal(widget.userId);
    teamGoal = res[0]['Goal'];

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
          data: chartData.values.toList())
    ];
    isChartLoaded = Future.value(true);
    //setState(() {});
  }

  Future<Null> getBillDataThisMonthForTeamSorkRank() async {
    var res = await Sqlite()
        .getJson('MANAGER_BILL_DATA_THIS_MONTH', '${widget.userId}');
    if (res != null) {
      teamData = jsonDecode(res['JSON_VALUE']);
    } else {
      var data = {
        'func': 'get_bill_data_this_month_test',
        'manager_id': '${widget.userId}'
      };
      var res = await client.post('$apiPath-manager', body: data);
      Sqlite().insertJson(
          'MANAGER_BILL_DATA_THIS_MONTH', '${widget.userId}', res.body);
      teamData = jsonDecode(res.body);
    }
    //sort
    teamData.sort((a, b) =>
        b['Head_sum_count_product_cat1'] - a['Head_sum_count_product_cat1']);
    //create series for sale ranking chart
    List chartBarColor = [
      goldColor,
      greenColor,
      cyanColor,
      indigoColor,
      orangeColor,
      dangerColor
    ];
    for (int i = 0; i < teamData.length; i++) {
      if (i < 5) {
        if (i == 0) {
          chartDataRanking = {
            'rank ${i + 1}': SaleRanking(
                i + 1,
                teamData[i]['Head_sum_count_product_cat1'],
                teamData[i]['Head_name'],
                charts.ColorUtil.fromDartColor(chartBarColor[i]),
                legendColor: chartBarColor[i],
                imgAvatar: teamData[i]['Head_image'])
          };
        } else {
          chartDataRanking['rank ${i + 1}'] = SaleRanking(
              i + 1,
              teamData[i]['Head_sum_count_product_cat1'],
              teamData[i]['Head_name'],
              charts.ColorUtil.fromDartColor(chartBarColor[i]),
              legendColor: chartBarColor[i],
              imgAvatar: teamData[i]['Head_image']);
        }
      } else {
        chartDataRanking['rank ${i + 1}'] = SaleRanking(
            teamData.length,
            teamData[teamData.length - 1]['Head_sum_count_product_cat1'],
            teamData[teamData.length - 1]['Head_name'],
            charts.ColorUtil.fromDartColor(chartBarColor[5]),
            legendColor: chartBarColor[5],
            imgAvatar: teamData[teamData.length - 1]['Head_image']);
        break;
      }
    }
    barSeries = [
      charts.Series<SaleRanking, String>(
        id: 'Sales',
        domainFn: (SaleRanking sales, _) => sales.rank.toString(),
        measureFn: (SaleRanking sales, _) => sales.total,
        colorFn: (SaleRanking sales, _) => sales.color,
        data: chartDataRanking.values.toList(),
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (SaleRanking sales, _) =>
            '${sales.total.toString()} กระสอบ',
        insideLabelStyleAccessorFn: (SaleRanking sales, _) {
          final color = charts.MaterialPalette.black;
          return new charts.TextStyleSpec(color: color, fontFamily: 'DB',fontSize: 14);
        },
      )
    ];
    isBarChartLoaded = Future.value(true);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    loadImage();
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
                title: Text('ข้อมูลภายใต้สายบริหาร'),
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
                // leading: Builder(
                //   builder: (context) => IconButton(
                //     icon: Icon(Icons.menu, size: 40),
                //     onPressed: () => Scaffold.of(context).openDrawer(),
                //   ),
                // ),

              ),
            ),
            body: CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      showOwner(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5,right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex:1,
                                child: goalChart()
                            ),
                            Expanded(
                                flex:1,
                                child: showTeamGoal()
                            ),
                          ],
                        ),
                      ),
                      showTeamGoalCash(),
                      showTeamGoalCredit(),
                      showChartRaking(size),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22,right: 22,top: 5,bottom: 0),
                    child: HeaderText(text: 'สรุปข้อมูลยอดขายแต่ละคันรถ',),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: showTeamData(),
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
          ),
        ),
      ),
    );
  }

  Widget goalChart() {
    return Container(
      height: 200,
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
                    formPage: 'margin0',
                  );
                } else {
                  return HalfDonut.simpleData();
                }
              }),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: teamGoal > 0
                ? Text(
                    '${(((ds['cash_product_cat1'] + ds['credit_product_cat1']) / teamGoal) * 100).floor()} %',
                    style: TextStyle(fontSize: 24),
                  )
                : Text('0 %'),
          ),
          Container(
            padding: const EdgeInsets.only(top: 70),
            child: Card(
              elevation: 2,
              color: Color(0xFFf1f1f1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      width: 160,
                      color: darkColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ขายได้แล้ว',
                            style: TextStyle(color: backgroundColor,fontSize: 18,height: 1),
                          ),
                          Text(
                            '${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กระสอบ',
                            style: TextStyle(color: kSecondaryColor,fontSize: 20,height: 1),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text('เขตการขาย : ${userData['PROVINCE_NAME']}',style: TextStyle(fontSize: 18),),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<GestureDetector> showTeamData() {
    return List.generate(teamData.length, (index) {
      var res = teamData[index];
      return GestureDetector(
        onTap: () {
          print('carId => ${res['Head_car_ID']}');
          Navigator.push(
              context,
              MaterialPageRoute(
                  settings: RouteSettings(name: 'สีส้มดูข้อมูลภายใต้สายงาน'),
                  builder: (context) => ManagerTeamDetail(
                        userId: res['Head_id'],
                        carId: res['Head_car_ID'],
                      )));
        },
        child: SubmanagerHeadCard(
          imgAvatar: res['Head_image'],
          username: res['Head_username'],
          name: res['Head_name'],
          surname: res['Head_surname'],
          plateNumber: res['Head_car_count'], // ทะเบียนรถ
          headId: res['Head_id'],
          teamGoal: res['Head_team_goal'],
          cashProductCat1: res['Head_cash_count_product_cat1'],
          cashMoneyTotal: res['Head_cash_money_total'],
          creditProductCat1: res['Head_credit_count_product_cat1'],
          creditMoneyTotal: res['Head_credit_money_total'],
          saleProvince: res['Head_sell_province'],
          saleCount: res['Head_sale_count'],
        ),
      );
    });
  }

  Widget showChartRaking(Size size) {
    return FutureBuilder(
        future: isBarChartLoaded,
        builder: (context, snap) {
          if (snap.hasData) {
          // if(false){
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderText(text: 'Top 5 ยอดขายแต่ละคันรถ',textSize: 20,gHeight: 26,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 5),
                      child: Text('สินค้าที่นำมาจัดอันดับยอดขายจะเป็นเฉพาะสินค้าประเภทปุ๋ยเม็ดเท่านั้น',style: _baseFontStyle,),
                    ),
                    SizedBox(height: 10),
                    ChartRanking(
                      series: barSeries,
                      legenData: chartDataRanking,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ShimmerLoading(type: 'boxGraph1row',);
            // return Container();
          }
        });
  }

  Widget showOwner() {
    Size size = MediaQuery.of(context).size;
    TextStyle _headFontStyle = TextStyle(fontSize: 20);
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HeaderText(text: 'ทีม ${userData['Name']}',textSize: 20,gHeight: 26,),
                    SizedBox(height: 5,),
                    Text('     ทีมรับผิดชอบ : $teamCount ทีม', style: _headFontStyle),
                    Text('     จำนวนรถยนต์ : $carCount คัน', style: _headFontStyle),
                    Text('     จำนวนพนักงานขาย : $salesCount คน', style: _headFontStyle),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: imageAvatar),
                  width: size.width * 0.27,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget showTeamGoalCredit() {
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
      child: Card(
        child: Column(
          children: [
            HeaderText(text:'สรุปยอดขาย เครดิต ประจำเดือนนี้',textSize: 20,gHeight: 26,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ยอดขายเครดิตรวม ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['credit_moneytotal'])} บาท (${f.SeperateNumber(ds['credit_product_cat1'])} กระสอบ)',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_590'])} กระสอบ',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_690'])} กระสอบ',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ลูกค้าชำระแล้ว ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_wait'])} กระสอบ',style: _baseFontStyle,),
                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget showTeamGoalCash() {
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20),
      child: Card(
        child: Column(
          children: [
            HeaderText(text:'สรุปยอดขาย เงินสด ประจำเดือนนี้',textSize: 20,gHeight: 26,),
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 8,top: 5,bottom: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ยอดขายเงินสดรวม ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_moneytotal'])} บาท (${f.SeperateNumber(ds['cash_product_cat1'])} กระสอบ)',style: _baseFontStyle)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_590'])} กระสอบ',style: _baseFontStyle)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_690'])} กระสอบ',style: _baseFontStyle)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ขายฮอร์โมนได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat2'])} ขวด',style: _baseFontStyle)
                    ],
                  ),
                ],
              ),
            ),
            // Divider()
          ],
        ),
      ),
    );
  }

  Widget showTeamGoal() {

    return Card(
      child: Column(
        children: [
          HeaderText(text:'เป้ายอดขายทีม',textSize: 20,gHeight: 26,),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 10,top: 5,bottom: 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('เป้ายอดขาย ',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(teamGoal)} กส.',style: _baseFontStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายได้แล้ว ',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กส.',style: _baseFontStyle,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขาดอีก ',style: _baseFontStyle),
                    teamGoal > (ds['cash_product_cat1'] + ds['credit_product_cat1'])
                        ? Text(
                        '${f.SeperateNumber(teamGoal - (ds['cash_product_cat1'] + ds['credit_product_cat1']))} กส.',style: _baseFontStyle)
                        : Text('0 กระสอบ',style: _baseFontStyle),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(ds['cash_product_cat1_590'] + ds['credit_product_cat1_590'])} กส.',style: _baseFontStyle,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(ds['cash_product_cat1_690'] + ds['credit_product_cat1_690'])} กส.',style: _baseFontStyle,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายฮอร์โมนได้ ',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(ds['cash_product_cat2'] + ds['credit_product_cat2'])} กส.',style: _baseFontStyle,),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
