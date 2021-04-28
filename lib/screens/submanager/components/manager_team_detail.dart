import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/screens/head/components/overdue_report.dart';
import 'package:system/screens/head/components/team_sell_detail.dart';
import 'package:system/screens/submanager/components/submanager_head_card.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ManagerTeamDetail extends StatefulWidget {
  final int userId;
  final int carId;

  const ManagerTeamDetail({Key key, this.userId, this.carId}) : super(key: key);

  @override
  _ManagerTeamDetailState createState() => _ManagerTeamDetailState();
}

class _ManagerTeamDetailState extends State<ManagerTeamDetail> {
  var userData = new Map();
  var userWorkCar = new Map();

  List reportSale = [];

  int teamGoal = 0;

  var ds = new Map();

  FormatMethod f = FormatMethod();

  Future<bool> isLoaded;

  Future<bool> isChartLoaded;

  var series;

  Map<String, TeamGoal> chartData;

  var client = Client();

  void initDataSet() async {
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

  Future<Null> getData() async {
    initDataSet();
    getDataHead();
    await getReportSale();
    await getTeamBillData();
    await getTeamGoal();
    if(mounted) setState(() {});
  }

  Future<Null> getDataHead() async {
    // var body = {
    //   'func': 'get_head_detail',
    //   'head_id': '${widget.userId}',
    //   'Head_car_ID': '${widget.carId}'
    // };
    // var res = await client.post('$apiPath-manager', body: body);
    // userData = jsonDecode(res.body);
    userData = await Sqlite().getHeadDetail(widget.userId);
    userWorkCar = await Sqlite().getWorkCar(widget.carId);

    isLoaded = Future.value(true);
    setState(() {});
  }

  Future getReportSale({String start = '', String end = ''}) async {
    var body = {
      'func': 'get_sale_in_team_test',
      'startDate': start,
      'endDate': end,
      'head_id': '${widget.userId}',
      'Head_car_ID': '${widget.carId}'
    };
    var res = await client.post('$apiPath-manager', body: body);
    reportSale = jsonDecode(res.body);
    print('reportSale $reportSale');
  }

  Future getTeamGoal() async {
    // var body = {
    //   'func': 'get_team_goal',
    //   'head_id': '${widget.userId}',
    //   'head_car_id': '${widget.carId}'
    // };
    // var res = await client.post('$apiPath-manager', body: body);
    // List data = jsonDecode(res.body);
    // teamGoal = data.fold(0, (pv, ele) => pv + ele['Goal']);
    var res = await Sqlite().managerTeamGoal(widget.userId, widget.carId);
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
  }

  Future getTeamBillData({String start = '', String end = ''}) async {
    AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
    var body = {
      'func': 'get_team_bill_data_in_manager',
      'startDate': start,
      'endDate': end,
      'head_id': '${widget.userId}',
      'head_car_id': '${widget.carId}'
    };
    var res = await client.post('$apiPath-heads', body: body);
    List data = jsonDecode(res.body);
    data.forEach((item) {
      forEachBillAll(item);
    });
    Navigator.pop(context);
  }

  void forEachBillAll(item) {
    if (item['Order_detail'] != '[]') {
      var obj = jsonDecode(item['Order_detail']);
      if (item['Pay_type'] == 1) {
        obj.forEach((element) {
          subCountAllCash(element);
        });
        ds['cash_moneytotal'] += item['Money_total'];
        ds['cash_commission'] += item['Commission_sum'];
        if (item['Status'] == 10) {
          ds['cash_commission_pay_success'] += item['Commission_sum'];
        }
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

  @override
  void initState() {
    // TODO: implement initState
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


              ),
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 5,),
                      showOwner(size),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: goalChart()),
                            Expanded(child: showTeamGoal()),
                          ],
                        ),
                      ),
                      showTeamGoalCash(),
                      showTeamGoalCredit(),
                      if (userData['Work_car_id'] != null)
                        OverDueReport(
                          workCarId: userData['Work_car_id'],
                        )
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 8,),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<GestureDetector> showTeamData() {
    return List.generate(reportSale.length, (index) {
      var res = reportSale[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TeamSellDetail(
                        saleId: res['ID'],
                      )));
        },
        child: SubmanagerHeadCard(
          imgAvatar: res['Image'],
          username: res['Username'],
          name: res['Name'],
          surname: res['Surname'],
          plateNumber: res['Plate_number'], // ทะเบียนรถ
          headId: res['ID'],
          teamGoal: res['Goal'],
          cashProductCat1: res['cash_count_product_cat1'],
          cashMoneyTotal: res['cash_money_total'],
          creditProductCat1: res['credit_count_product_cat1'],
          creditMoneyTotal: res['credit_money_total'],
          saleProvince: res['PROVINCE_NAME'],
          //saleCount: res['Head_sale_count'],
        ),
      );
    });
  }

  Widget showTeamGoalCredit() {
    TextStyle _baseFontstyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
      child: Card(
        child: Column(
          children: [
            HeaderText(text: 'สรุปยอดขาย เครดิต ประจำเดือนนี้',textSize: 20,gHeight: 26,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยอดขายเครดิตรวม',style: _baseFontstyle,),
                      Text('${f.SeperateNumber(ds['credit_moneytotal'])} บาท (${f.SeperateNumber(ds['credit_product_cat1'])} กระสอบ)',style: _baseFontstyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 590 ได้',style: _baseFontstyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_590'])} กระสอบ',style: _baseFontstyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 690 ได้',style: _baseFontstyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_690'])} กระสอบ',style: _baseFontstyle),
                    ],
                  ),
                  if (ds['credit_product_cat1_receive'] > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ลูกค้าชำระแล้ว',style: _baseFontstyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_receive'])}  กระสอบ',style: _baseFontstyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ลูกค้าค้างชำระ',style: _baseFontstyle,),
                      Text('${f.SeperateNumber(ds['credit_product_cat1_wait'])}  กระสอบ',style: _baseFontstyle),
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

  Widget goalChart() {
    return Container(
      height: 160,
      child: Stack(
        alignment: Alignment.topCenter,
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
                  return Container();
                  return HalfDonut.simpleData();
                }
              }),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: teamGoal > 0
                ? Text(
                    '${(((ds['cash_product_cat1'] + ds['credit_product_cat1']) / teamGoal) * 100).floor()} %',
                    style: TextStyle(fontSize: 28),
                  )
                : Text('0 %',style: TextStyle(fontSize: 28)),
          ),
          Container(
            padding: const EdgeInsets.only(top: 80),
            child: Card(
              elevation: 2,
              color: Color(0xFFf1f1f1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      width: 160,
                      color: darkColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ขายได้แล้ว',
                            style: TextStyle(color: backgroundColor,fontSize: 15),
                          ),
                          Text(
                            '${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กระสอบ',
                            style: TextStyle(color: kSecondaryColor,fontSize: 20,height: 1),
                          ),
                        ],
                      )),
                  Text('เขตการขาย : ${userData['PROVINCE_NAME']}',style: TextStyle(fontSize: 16,height: 1.5),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget showOwner(Size size) {
    return FutureBuilder(
        future: isLoaded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 20,right: 21,top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeaderText(text: 'ยอดขายทีม',textSize: 20,gHeight: 26,),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('สีแดง : ${userData['Name']}',style: TextStyle(fontSize: 20,),),
                                      Text('ทะเบียนรถ : ${userWorkCar['Plate_number']}',style: TextStyle(fontSize: 20,)),
                                      Text(
                                          'จำนวนพนักงานขาย : ${userData['team_count']} คน',style: TextStyle(fontSize: 20,)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          width: size.width * 0.29,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: '$storagePath/${userData['Image']}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return ShimmerLoading(type:'userInfo',);

          }
        });
  }

  Widget showTeamGoalCash() {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
      child: Card(
        child: Column(
          children: [
            HeaderText(text: 'สรุปยอดขาย เงินสด ประจำเดือนนี้',textSize: 20,gHeight: 26,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยอดขายเงินสดรวม',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_moneytotal'])} บาท (${f.SeperateNumber(ds['cash_product_cat1'])} กระสอบ)',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_590'])} กระสอบ',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_690'])} กระสอบ',style: _baseFontStyle,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายฮอร์โมนได้ ',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat2'])} ขวด',style: _baseFontStyle,),
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

  Widget showTeamGoal() {
    TextStyle  _baseFontStyle = TextStyle(fontSize: 18,height: 1);
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Card(
        child: Column(
          children: [
            HeaderText(text:'เป้ายอดขายทีม',textSize: 20,gHeight: 26,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ยอดขาย',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(teamGoal)} กส.',style: _baseFontStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายได้แล้ว',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1'] + ds['credit_product_cat1'])} กส.',style: _baseFontStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขาดอีก',style: _baseFontStyle,),
                      teamGoal > (ds['cash_product_cat1'] + ds['credit_product_cat1'])
                      ? Text('${f.SeperateNumber(teamGoal - (ds['cash_product_cat1'] + ds['credit_product_cat1']))} กส.',style: _baseFontStyle)
                      : Text('0 กระสอบ',style: _baseFontStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 590 ได้',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_590'] + ds['credit_product_cat1_590'])} กส.',style: _baseFontStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายปุ๋ยราคา 690 ได้',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat1_690'] + ds['credit_product_cat1_690'])} กส.',style: _baseFontStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขายฮอร์โมนได้',style: _baseFontStyle,),
                      Text('${f.SeperateNumber(ds['cash_product_cat2'] + ds['credit_product_cat2'])} ขวด',style: _baseFontStyle),
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
}
