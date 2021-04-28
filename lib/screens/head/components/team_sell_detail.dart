import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/head_team_lead_widget.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/components/sell_team_lead_widget.dart';
import 'package:system/components/sub_menager_team_lead_widget.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TeamSellDetail extends StatefulWidget {
  final int saleId;

  const TeamSellDetail({Key key, this.saleId}) : super(key: key);

  @override
  _TeamSellDetailState createState() => _TeamSellDetailState();
}

class _TeamSellDetailState extends State<TeamSellDetail> {
  var userData = new Map();
  var ds = new Map();

  Future<bool> isLoaded;

  Future<bool> isChartLoaded;

  FormatMethod f = FormatMethod();

  Map<String, TeamGoal> chartData;

  var series;

  String lastDate;

  int sumTrail = 0;

  var client = Client();

  Future<Null> getData() async {
    await getUserData();
    await getCarNumber(userData['Work_car_id']);
    await getHeader();
    await getManager();
    await getSubManager();
    //await getTrail(client);
    isLoaded = Future.value(true);
    setState(() {});
    await getCache();
    print(ds);
  }

  void initDataSet() {
    ds['cashProductCat1'] = 0;
    ds['creditProductCat1'] = 0;
    ds['cashProductCat2'] = 0;
    ds['creditProductCat2'] = 0;
    ds['moneyTotal'] = 0;
    ds['commission_total'] = 0;
    ds['recommend_money'] = 0;
    ds['recommend_people'] = 0;
    ds['total_money_share'] = 0;
    ds['total_money_share_cat1'] = 0;
    ds['cash_sumCat1_590'] = 0;
    ds['cash_sumCat1_690'] = 0;
    ds['cash_sumCat2'] = 0;
    ds['cash_sumMoneyTotal'] = 0;
    ds['credit_sumCat1_590'] = 0;
    ds['credit_sumCat1_690'] = 0;
    ds['credit_sumCat2'] = 0;
    ds['credit_sumMoneyTotal'] = 0;
    ds['credit_wait_sumCat1_590'] = 0;
    ds['credit_wait_sumCat1_690'] = 0;
    ds['credit_wait_sumCat2'] = 0;
    ds['credit_wait_sumMoneyTotal'] = 0;
    ds['sale_money_before_net'] = 0;
    DateTime now = DateTime.now();
    lastDate =
        '${now.year}-${now.month}-${DateTime(now.year, now.month + 1, 0).day}';
  }

  Future<Null> getCache() async {
    var data;
    var res = await Sqlite().getJson('HEAD_CACHE_SALE', '${widget.saleId}');
    if (res != null) {
      data = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        var res = await client.post('$apiPath-sales',
            body: {'func': 'getcachesale', 'filename': '${widget.saleId}'});
        data = jsonDecode(res.body);
        Sqlite().insertJson('HEAD_CACHE_SALE', '${widget.saleId}', res.body);
        Navigator.pop(context);
      }
    }
    if (data != null) {
      ds['time_cache'] = data['time_gen'];
      ds['day_cache'] = f.ThaiDateFormat(data['day_gen']);

      List qtyOrder = data['Qtyordercat'].split(',');
      // ds['cashProductCat1'] = qtyOrder.take(2).fold(
      //     0, (previousValue, element) => previousValue + int.parse(element));
      ds['cashProductCat1'] = int.parse(qtyOrder[0]) + int.parse(qtyOrder[1]);
      ds['cashProductCat2'] = int.parse(qtyOrder[2]);
      List qtyCredit = data['Qtycredit'].split(',');
      // ds['creditProductCat1'] = qtyCredit.take(2).fold(
      //     0, (previousValue, element) => previousValue + int.parse(element));
      ds['creditProductCat1'] =
          int.parse(qtyCredit[0]) + int.parse(qtyCredit[1]);
      ds['creditProductCat2'] = int.parse(qtyCredit[2]);

      //create chart data
      int sell = ds['cashProductCat1'] + ds['creditProductCat1'];
      int goal = userData['Goal'];
      print(goal);
      chartData = {
        'sell': TeamGoal(
            charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sell)
      };
      if (goal > sell) {
        chartData['goal'] = TeamGoal(
            charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)),
            'goal',
            goal - sell);
      } else {
        chartData['goal'] = TeamGoal(
            charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 0);
      }
      series = [
        new charts.Series(
          id: 'SaleGoal',
          data: chartData.values.toList(),
          domainFn: (TeamGoal data, i) => data.text,
          measureFn: (TeamGoal data, _) => data.total,
          colorFn: (TeamGoal data, _) => data.color,
          labelAccessorFn: (TeamGoal data, _) => data.text,
        )
      ];
      isChartLoaded = Future.value(true);
      //rederchart here

      ds['moneyTotal'] = data['sumMoneyTotal'];
      List commission = data['sumcommission'].split(',');
      ds['commission_total'] =
          commission.fold(0, (pv, element) => pv + int.parse(element));

      ds['recommend_money'] = data['MoneyRecommend'];
      ds['recommend_people'] = data['namerecommend'].length;

      if (data['Level_id'] == 2) {
        ds['total_money_share'] = data['Sum_money_share_headmain'];
        ds['total_money_share_cat1'] =
            data['cat1forsale'].fold(0, (p, e) => p + e['sale_qty']);
      } else if (data['Level_id'] == 3 || data['Level_id'] == 12) {
        ds['total_money_share'] = data['sumusermoney2other'];
        int result =
            data['car1forsaleother'].fold(0, (p, e) => p + e['sale_qty']);
        int result2 = data['cat1forsale'].fold(0, (p, e) => p + e['sale_qty']);
        ds['total_money_share_cat1'] = result + result2;
      }

      ds['cash_sumCat1_590'] = data['cash_sumCat1_590'];
      ds['cash_sumCat1_690'] = data['cash_sumCat1_690'];
      ds['cash_sumCat2'] = data['cash_sumCat2'];
      ds['cash_sumMoneyTotal'] = data['cash_sumMoneyTotal'];
      ds['credit_sumCat1_590'] = data['credit_sumCat1_590'];
      ds['credit_sumCat1_690'] = data['credit_sumCat1_690'];
      ds['credit_sumCat2'] = data['credit_sumCat2'];
      ds['credit_sumMoneyTotal'] = data['credit_sumMoneyTotal'];
      ds['credit_wait_sumCat1_590'] = data['credit_wait_sumCat1_590'];
      ds['credit_wait_sumCat1_690'] = data['credit_wait_sumCat1_690'];
      ds['credit_wait_sumCat2'] = data['credit_wait_sumCat2'];
      ds['credit_wait_sumMoneyTotal'] = data['credit_wait_sumMoneyTotal'];
      calBeforeNet(data);
    }
    if(mounted)setState(() {});
  }

  void calBeforeNet(item) {
    var vat3 = 0;
    var result = 0;
    var tax = 0;
    var sumIncomeAll = 0;
    if (item['Level_id'] == 2 || item['Level_id'] == 1) {
      sumIncomeAll = (item['sumcommission']
              .split(',')
              .fold(0, (p, e) => p + int.parse(e))) +
          item['Sum_income'] +
          item['Sum_money_share_headmain'] +
          item['MoneyRecommend'];
      ds['sale_money_before_net'] = sumIncomeAll;
    } else if (item['Level_id'] == 3 || item['Level_id'] == 12) {
      sumIncomeAll = (item['sumcommission']
              .split(',')
              .fold(0, (p, e) => p + int.parse(e))) +
          item['Sum_income'] +
          item['sumusermoney2other'] +
          item['MoneyRecommend'];
      ds['sale_money_before_net'] = sumIncomeAll;
    }
  }

  Future<Null> getTrail() async {
    var res = await client.post('$apiPath-ceo',
        body: {'func': 'getTrailSale', 'sale_id': '${widget.saleId}'});
    List data = jsonDecode(res.body);
    sumTrail = data.fold(0, (previousValue, element) {
      var obj = jsonDecode(element['Order_detail']);
      int qty = 0;
      if (obj.length > 0) {
        qty = obj[0]['qty'];
      }
      return previousValue + qty;
    });
    setState(() {});
  }

  Future<Null> getUserData() async {
    print('getUserData');
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_userdata', 'User_id': '${widget.saleId}'});
    var res = await Sqlite().getUserDataById(widget.saleId);
    userData = Map.of(res[0]);
    //userData = res[0];
    //userData = jsonDecode(res.body)[0];
    isLoaded = Future.value(true);
    //print(userData['Level_id'] == 1);
    setState(() {});
  }

  Future<Null> getCarNumber(int workCarId) async {
    var res = await Sqlite().getWorkCar(workCarId);
    var data = res;
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_carnumber', 'work_car_id': '$workCarId'});
    // var data = jsonDecode(res.body);
    userData['Plate_number'] =
        '${data['Plate_number']} - ${data['PROVINCE_NAME']}';
  }

  Future<Null> getHeader() async {
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_header', 'sales_id': '${widget.saleId}'});
    // var data = jsonDecode(res.body);
    var res = await Sqlite().getHeader(widget.saleId);
    var data = res;
    userData['sales_header'] = '';
    for (int i = 0; i < data.length; i++) {
      if (i > 0) {
        userData['sales_header'] += ',';
      }
      userData['sales_header'] += 'คุณ' + data[i]['User_name'];
    }
  }

  Future<Null> getSubManager() async {
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_submanager', 'sales_id': '${widget.saleId}'});
    // var data = jsonDecode(res.body);
    var res = await Sqlite().getSubManager(widget.saleId);
    var data = res;
    userData['sales_submanager'] = '';
    for (int i = 0; i < data.length; i++) {
      if (i > 0) {
        userData['sales_submanager'] += ',';
      }
      userData['sales_submanager'] += 'คุณ' + data[i]['User_name'];
    }
  }

  Future<Null> getManager() async {
    // var res = await client.post('$apiPath-sales',
    //     body: {'func': 'get_manager', 'sales_id': '${widget.saleId}'});
    // var data = jsonDecode(res.body);
    var res = await Sqlite().getManager(widget.saleId);
    var data = res;
    userData['sales_manager'] = '';
    userData['sales_overmanger'] = '';
    for (int i = 0; i < data.length; i++) {
      if (i > 0) {
        userData['sales_manager'] += ',';
      }
      if (data[i]['To_user_id'] == 123 ||
          data[i]['To_user_id'] == 124 ||
          data[i]['To_user_id'] == 119 ||
          data[i]['To_user_id'] == 145) {
        userData['sales_overmanger'] +=
            'คุณ' + data[i]['User_name'].split(' ')[0];
      } else {
        userData['sales_manager'] += 'คุณ' + data[i]['User_name'];
      }
    }
  }

  Widget switchTeamLabel(level_id,
      {lv_red = '--', lv_yellow = '--', lv_orange = '--'}) {
    lv_red = (lv_red == null || lv_red == '') ? '--' : lv_red;
    lv_yellow = (lv_yellow == null || lv_yellow == '') ? '--' : lv_yellow;
    lv_orange = (lv_orange == null || lv_orange == '') ? '--' : lv_orange;
    switch (level_id) {
      case 1:
        return SellTeamLead(
            lv_red: lv_red, lv_yellow: lv_yellow, lv_orange: lv_orange);
        break;
      case 2:
        return HeadTeamLead(lv_yellow: lv_yellow, lv_orange: lv_orange);
        break;
      case 3:
        return Container();
        break;
      case 12:
        return SubMenagerTeamLead(lv_orange: lv_orange);
        break;
      default:
        return Container();
    }
  }

  calWorkTime(var date) {
    var listDate = date.split('-');
    var workTime = DateTime.parse(date);
    var now = new DateTime.now();
    var result = {'years': 0, 'months': 0, 'days': 0};
    result['months'] =
        now.year * 12 + now.month - workTime.year * 12 - workTime.month;
    result['days'] = now.day - workTime.day;
    if (0 > result['days']) {
      var y = now.year, m = now.month;
      //print('original month : $m');
      //m = (--m < 0) ? 11 : m;
      m = (--m == 0) ? 11 : m;
      //print('edit month : $m');
      result['days'] += [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m] +
          (((1 == m) && ((y % 4) == 0) && (((y % 100) > 0) || ((y % 400) == 0)))
              ? 1
              : 0);
      result['months'] = result['months'] - 1;
    }
    result['years'] = (result['months'] - (result['months'] % 12)) ~/ 12;
    result['months'] = (result['months'] % 12);
    var str = '';
    if (result['years'] != 0) {
      str = str + result['years'].toString() + ' ปี ';
    }
    if (result['months'] != 0) {
      str = str + result['months'].toString() + ' เดือน ';
    }
    if (result['days'] != 0) {
      str = str + result['days'].toString() + ' วัน';
    }
    return str;
  }

  @override
  void initState() {
    // TODO: implement initState
    initDataSet();
    getData();
    //getTrail(Client());
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
                  title: Text('ข้อมูลยอดขายรายบุคคล'),
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
                onRefresh: getCache,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: FutureBuilder(
                          future: isLoaded,
                          builder: (context, snap) {
                            if (snap.hasData) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 20,right: 16,top: 16,bottom: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    userInfo(size),
                                    // Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(top:15),
                                      child: userCommission(size),
                                    ),
                                    // Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(top:10,bottom: 10),
                                      child: cashSell(size),
                                    ),
                                    // Divider(),
                                    creditSell(size),
                                    // Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(top:10),
                                      child: trail(size),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: Column(
                                  children: [
                                    ShimmerLoading(type: 'userInfo',),
                                    ShimmerLoading(type: 'boxItem',),
                                    ShimmerLoading(type: 'boxItem',),
                                  ],
                                ),
                              );
                              // return Center(
                              //   child: CircularProgressIndicator(),
                              // );
                            }
                          }),
                    ),
                    SliverToBoxAdapter(
                      child: Footer(),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget cashSell(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderText(text:'สรุปยอดขาย เงินสด ประจำเดือนนี้'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ยอดขายเงินสดรวม',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(ds['cash_sumMoneyTotal'])} บาท',style: _baseFontStyle)
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      '(${f.SeperateNumber(ds['cash_sumCat1_590'] + ds['cash_sumCat1_690'])} กระสอบ)',style: _baseFontStyle),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 590 ได้',style: _baseFontStyle),
                    Text('${f.SeperateNumber(ds['cash_sumCat1_590'])} กระสอบ',style: _baseFontStyle)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 690 ได้',style: _baseFontStyle),
                    Text('${f.SeperateNumber(ds['cash_sumCat1_690'])} กระสอบ',style: _baseFontStyle)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายฮอร์โมนได้',style: _baseFontStyle),
                    Text('${f.SeperateNumber(ds['cash_sumCat2'])} ขวด',style: _baseFontStyle)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget trail(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderText(text:'สรุปยอดแจกสินค้าทดลอง ประจำเดือนนี้'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('แจกสินค้าทดลองรวม',style: _baseFontStyle,),
                Text('${f.SeperateNumber(sumTrail)} ขวด',style: _baseFontStyle,)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget creditSell(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderText(text:'สรุปยอดขาย เครดิต ประจำเดือนนี้'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ยอดขายเงินสดรวม',style: _baseFontStyle,),
                    Text(
                        '${f.SeperateNumber(ds['credit_sumMoneyTotal'] + ds['credit_wait_sumMoneyTotal'])} บาท',style: _baseFontStyle)
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      '(${f.SeperateNumber(ds['credit_sumCat1_590'] + ds['credit_sumCat1_690'] + ds['credit_wait_sumCat1_590'] + ds['credit_wait_sumCat1_690'])} กระสอบ)',
                      style: _baseFontStyle
                  ),

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 590 ได้',style: _baseFontStyle),
                    Text(
                        '${f.SeperateNumber(ds['credit_sumCat1_590'] + ds['credit_wait_sumCat1_590'])} กระสอบ',style: _baseFontStyle)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายปุ๋ยราคา 690 ได้',style: _baseFontStyle),
                    Text(
                        '${f.SeperateNumber(ds['credit_sumCat1_690'] + ds['credit_wait_sumCat1_690'])} กระสอบ',style: _baseFontStyle)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('รอลูกค้าชำระ',style: _baseFontStyle),
                    Text(
                        '${f.SeperateNumber(ds['credit_wait_sumCat1_590'] + ds['credit_wait_sumCat1_690'])} กระสอบ',style: _baseFontStyle)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userCommission(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 220,
                    // color: Colors.amber,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0,left: 0,right: 0),
                      child: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: [
                          FutureBuilder(
                              future: isChartLoaded,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Positioned(
                                    top: -20,
                                    right: 0,
                                    left: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: SizedBox(
                                        height: 200,
                                        width: 300,
                                        child: HalfDonut(
                                          series,
                                          animate: true,
                                          formPage: 'margin5',
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return ShimmerLoading(type: 'imageSquare',);
                                  // return Padding(
                                  //   padding: const EdgeInsets.only(right: 0),
                                  //   child: SizedBox(
                                  //     width: 200,
                                  //     height: 300,
                                  //     child: HalfDonut.simpleData(),
                                  //   ),
                                  // );
                                }
                              }),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 80,right: 10),
                            child: userData['Goal'] > 0
                                ? Text(
                                    '${(((ds['cashProductCat1'] + ds['creditProductCat1']) / userData['Goal']) * 100).floor()} %',
                                    style: TextStyle(fontSize: 30),
                                  )
                                : Text('0 %',style: TextStyle(fontSize: 30)),
                          ),
                          Container(
                            width: 180,
                            padding: const EdgeInsets.only(top: 50,right: 10,left:0),
                            child: Card(
                              elevation: 2,
                              color: Color(0xFFf1f1f1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      width: 200,
                                      color: darkColor,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'รายได้รวมทั้งหมด',
                                            style:
                                                TextStyle(color: backgroundColor,fontSize: 15,height: 1),
                                          ),
                                          Text(
                                            '${f.SeperateNumber(ds['sale_money_before_net'])} บาท',
                                            style: TextStyle(color: kSecondaryColor,fontSize: 22,height: 1),
                                          ),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                      'อายุงาน : ${calWorkTime(userData['Work_date_start'])}',
                                    style: TextStyle(fontSize: 15,height: 1),
                                  ),
                                  Text('เขตการขาย : ${userData['PROVINCE_NAME']}',
                                    style: TextStyle(fontSize: 15,height: 1),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: -2,
                              child: Column(
                                children: [
                                  Text('อัพเดทเมื่อ ${ds['time_cache']} น.',style: TextStyle(fontSize: 15,height: 1),),
                                  Text('วันที่ ${ds['day_cache']}',style: TextStyle(fontSize: 15,height: 1),),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeaderText(text:'ข้อมูลรายได้'),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ยอดขาย',style: _baseFontStyle,),
                        Text('${f.SeperateNumber(ds['moneyTotal'])} บาท',style: _baseFontStyle)
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          '(${f.SeperateNumber(ds['cashProductCat1'] + ds['creditProductCat1'])} กระสอบ / ${f.SeperateNumber(ds['cashProductCat2'] + ds['creditProductCat2'])} ขวด)',
                          style: TextStyle(fontSize: 14)
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('คอมมิชชั่น',style: _baseFontStyle),
                        Text('${f.SeperateNumber(ds['commission_total'])} บาท',style: _baseFontStyle)
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('(วันที่ ${f.ThaiDateFormat(lastDate)})',style: TextStyle(fontSize: 14)),
                    ),
                    if (userData['Setting_recommend'] != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ค่าแนะนำ',style: _baseFontStyle),
                          Text('${f.SeperateNumber(ds['recommend_money'])} บาท',style: _baseFontStyle)
                        ],
                      ),
                    if (userData['Setting_recommend'] != 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('(${ds['recommend_people']} คน)',style: TextStyle(fontSize: 14)),
                      ),

                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('เป้ายอดขาย',style: _baseFontStyle),
                        Text('${f.SeperateNumber(userData['Goal'])} กระสอบ',style: _baseFontStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ขายได้แล้ว',style: _baseFontStyle),
                        Text(
                            '${f.SeperateNumber(ds['cashProductCat1'] + ds['creditProductCat1'])} กระสอบ',style: _baseFontStyle)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ขาดอีก',style: _baseFontStyle),
                        userData['Goal'] >
                                ds['cashProductCat1'] + ds['creditProductCat1']
                            ? Text(
                                '${f.SeperateNumber(userData['Goal'] - (ds['cashProductCat1'] + ds['creditProductCat1']))} กระสอบ',style: _baseFontStyle)
                            : Text('0 กระสอบ',style: _baseFontStyle)
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),

        if (userData['Level_id'] == 2 || userData['Level_id'] == 3 || userData['Level_id'] == 12)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Card(
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: HeaderText(text:'รายได้อื่นๆเพิ่มเติม')),
                  Padding(
                    padding: const EdgeInsets.only(top: 8,left: 16,right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ค่าส่วนต่าง',style: _baseFontStyle,),
                        Text('${f.SeperateNumber(ds['total_money_share'])} บาท',style: _baseFontStyle,)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0,left: 16,right: 16,bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                          '(${f.SeperateNumber(ds['total_money_share_cat1'])} กระสอบ)',style: _baseFontStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),


      ],
    );
  }

  Widget userInfo(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.only(left: 5,right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รหัสพนักงาน : ${userData['Username']}',style: _baseFontStyle,),
                Text('คุณ ${userData['Name']} ${userData['Surname']}',style: _baseFontStyle,),
                switchTeamLabel(
                  userData['Level_id'],
                  lv_red: userData['sales_header'],
                  lv_yellow: userData['sales_submanager'],
                  lv_orange: userData['sales_manager'],
                ),
                Text('ทะเบียนรถ : ${userData['Plate_number']}',style: _baseFontStyle,)
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              // width: size.width * 0.35,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: (userData['Image'] != null)
                      ? CachedNetworkImage(
                    imageUrl: '$storagePath/${userData['Image']}',
                  )
                      : Image.asset('assets/avatar.png')),
            ),
          ),
        ],
      ),
    );
  }
}
