import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class TeamStock extends StatefulWidget {
  final int userId;

  const TeamStock({Key key, this.userId}) : super(key: key);

  @override
  _TeamStockState createState() => _TeamStockState();
}

class _TeamStockState extends State<TeamStock> {
  var client = http.Client();
  List stockTeamDefault = [];
  List stockTeamSum = [];

  List receivedStock = [];
  List receivedStockDefault = [];
  Future<bool> isLoaded;
  Future<bool> isReceivedStockLoaded;

  var _search = TextEditingController();

  var _receivedSearch = TextEditingController();
  var _dateRange = TextEditingController();
  DateTimeRange initDateTimeRange;
  DateTimeRange defaultDateTimeRange;

  FormatMethod f = FormatMethod();

  Future<Null> getData() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print('isConnect ${isConnect}');
    if (isConnect) {
      getStockTeam();
      getReceivedStock();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext contexts) {
          return AlertDialog(
            title: Center(child: Text('แจ้งเตือน !!! ')),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'หน้านี้เป็นหน้าจัดการคลังสินค้า ระบบต้องลิงค์ข้อมูลกับเซิฟเวอร์ ต้องใช้อินเทอร์เน็ตนะครับ รบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตนะครับ ถึงจะใช้งานหน้านี้ได้',
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                    color: kPrimaryColor,
                    onPressed: () {
                      // Navigator.of(context).pop();
                      // Navigator.of(context).pushNamedAndRemoveUntil(contexts, 'dashboard',);
                      Navigator.pushNamedAndRemoveUntil(context, 'dashboard',
                          ModalRoute.withName('dashboard'));
                    },
                    child: Text(
                      'ok',
                      style: TextStyle(color: btTextColor),
                    ))
              ],
            ),
          );
        },
      );
    }
  }

  Future<Null> getStockTeam() async {
    var res = await client.post('https://landgreen.ml/system/public/api-store',
        body: {
          'func': 'get_stock_team_for_team',
          'head_id': '${widget.userId}'
        });
    List stockTeam = jsonDecode(res.body);
    stockTeamSum.clear();
    stockTeam.forEach((val) {
      var index =
      stockTeamSum.indexWhere((element) => element['Name'] == val['Name']);
      if (index != -1) {
        stockTeamSum[index]['Qty'] += val['Qty'];
      } else {
        stockTeamSum.add(val);
      }
    });
    stockTeamDefault.clear();
    stockTeamDefault.addAll(stockTeamSum);
    isLoaded = Future.value(true);
    setState(() {});
  }

  Future<Null> getReceivedStock(
      {String startDate = '', String endDate = ''}) async {
    var res = await client
        .post('https://landgreen.ml/system/public/api-store', body: {
      'func': 'get_stock_team_doc_for_team',
      'head_id': '${widget.userId}',
      'startDate': startDate,
      'endDate': endDate,
    });
    List tmp = jsonDecode(res.body);

    receivedStockDefault.clear();
    tmp.forEach((element) {
      element['showDetail'] = 0;
      element['isConfirm'] = 0;
      receivedStockDefault.add(element);
    });

    receivedStock.clear();
    receivedStock.addAll(receivedStockDefault);
    isReceivedStockLoaded = Future.value(true);
    setState(() {});
  }

  void filterStock({String query = ''}) {
    if (query != '') {
      stockTeamSum = stockTeamDefault
          .where((element) => element.toString().contains(query))
          .toList();
    } else {
      stockTeamSum.clear();
      stockTeamSum.addAll(stockTeamDefault);
    }
    setState(() {});
  }

  void showImageDetail(context, String tag, String url, Size size) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
              height: size.height * 0.4,
              child: Hero(
                  tag: tag,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    progressIndicatorBuilder:
                        (context, uri, downloadProgress) =>
                        LinearProgressIndicator(
                            value: downloadProgress.progress),
                    errorWidget: (context, uri, error) => Icon(Icons.error),
                  ))),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    DateTime n = DateTime.now();
    initDateTimeRange = DateTimeRange(
        start: DateTime(n.year, n.month),
        end: DateTime(n.year, n.month, n.day));
    defaultDateTimeRange = initDateTimeRange;
    _dateRange.text = 'รายการส่งของให้คลังประจำเดือนนี้';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
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
                // title: Text('สร้างใบสั่งจองสินค้า'),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bgTop2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                title: Text('คลังสินค้าทีม'),
              ),
            ),
            body: SafeArea(
                bottom: false,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: showStockTeam(size, context)),
                      SliverToBoxAdapter(
                          child: showReceivedStock(size, context)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 16,
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
                )),
          ),
        ),
      ),
    );
  }

  Widget _status(var status) {
    if (status == 1) {
      return Text(
        '( รอหัวหน้าทีมกดรับ )',
        style: TextStyle(color: danger),
      );
    } else if (status == 3) {
      return Text(
        '( รอธุรการตรวจสอบ )',
        style: TextStyle(color: warningColor),
      );
    } else {
      return Text(
        '( หัวหน้าทีมรับเรียบร้อย )',
        style: TextStyle(color: kPrimaryColor),
      );
    }
  }

  int calStock(List stockDetail) {
    return stockDetail.fold(
        0, (previousValue, element) => previousValue + element['Qty']);
  }

  Future<Null> _showDateTimeRange(context) async {
    var n = DateTime.now();
    final DateTimeRange picked = await showDateRangePicker(
      context: context,
      initialDateRange: initDateTimeRange,
      currentDate: DateTime.now(),
      firstDate: DateTime(1917),
      lastDate: DateTime(n.year, n.month + 1, 0),
    );
    if (picked != null) {
      initDateTimeRange = picked;
      //print(picked.toString());
      _dateRange.text = 'จาก ' +
          f.ThaiFormat(picked.start.toString().split(' ')[0]) +
          ' ถึง ' +
          f.ThaiFormat(picked.end.toString().split(' ')[0]);
      getReceivedStock(
          startDate: picked.start.toString().split(' ')[0],
          endDate: picked.end.toString().split(' ')[0]);
    }
  }

  Future<Null> confirmStock(id, teamCode) async {
    var res = await client
        .post('https://landgreen.ml/system/public/api-store', body: {
      'func': 'approve_stock_team',
      'doc_id': '$id',
      'head_id': '${widget.userId}',
      'team_code': '$teamCode'
    }).then((value) {
      getReceivedStock();
    });
  }

  void filterReceivedStock({String query = ''}) {
    if (query != '') {
      receivedStock = receivedStockDefault
          .where((element) => element.toString().contains(query))
          .toList();
    } else {
      receivedStock.clear();
      receivedStock.addAll(receivedStockDefault);
    }
    setState(() {});
  }

  Padding showReceivedStock(Size size, BuildContext context) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Container(
        width: size.width,
        child: Card(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // HeaderText(text:'ธุรการส่งของให้',textSize: 20,gHeight: 26,),
                GestureDetector(
                  onTap: () {
                    _showDateTimeRange(context);
                  },
                  child: AbsorbPointer(
                    child: ClipRRect(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            color: kPrimaryLightColor,
                            width: 6,
                            height: 26,
                          ),
                          Expanded(
                            child: Stack(children: [
                              Container(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: TextField(
                                    controller: _dateRange,
                                    decoration: InputDecoration(
                                      // labelText:'ข้อมูล ณ วันที่',
                                      hintText:
                                      'รายการส่งของให้คลังประจำเดือนนี้',
                                      contentPadding: EdgeInsets.all(0.0),
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                                color: backgroudBarColor,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  child: Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Colors.white,
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
                // SizedBox(height: 10),
                // GestureDetector(
                //     onTap: () {
                //       _showDateTimeRange(context);
                //     },
                //     child: AbsorbPointer(
                //       child: TextField(
                //           controller: _dateRange,
                //           decoration: InputDecoration(
                //               labelText: 'ข้อมูล ณ วันที่',
                //               hintText: 'ข้อมูลประจำวันที่',
                //               prefixIcon: Icon(Icons.search),
                //               filled: true,
                //               isDense: true,
                //               fillColor: Colors.white,
                //               border: OutlineInputBorder(
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(25))))),
                //     )),
                // SizedBox(height: 10),
                // TextField(
                //   controller: _receivedSearch,
                //   onChanged: (val) => filterReceivedStock(query: val),
                //   decoration: InputDecoration(
                //       labelText: 'ค้นหา',
                //       hintText: 'ค้นหา',
                //       prefixIcon: Icon(Icons.search),
                //       suffixIcon: IconButton(
                //           icon: Icon(Icons.close),
                //           onPressed: () {
                //             filterReceivedStock();
                //             _receivedSearch.clear();
                //             FocusScope.of(context).unfocus();
                //           }),
                //       isDense: true,
                //       filled: true,
                //       fillColor: Colors.white,
                //       border: OutlineInputBorder(
                //           borderRadius: BorderRadius.all(Radius.circular(25)))),
                // ),
                FutureBuilder(
                    future: isReceivedStockLoaded,
                    builder: (BuildContext bc, AsyncSnapshot snap) {
                      if (snap.hasData) {
                        if (receivedStock.length > 0) {
                          return Container(
                            // width: size.width * 0.8,
                              height: size.height * 0.40,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: receivedStock.length,
                                  itemBuilder: (bc, i) {
                                    var res = receivedStock[i];
                                    return Container(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: Icon(
                                                  Icons.arrow_right,
                                                  color: mainFontColor,
                                                  size: 20,
                                                ),
                                              ),
                                              Text(
                                                'รหัสคลัง ${res['Team_code']} ทีม ${res['Team_name']} ',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              _status(res['Status']),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'รถขนส่ง ${res['Car_send_detail']}',
                                                    style: _baseFontStyle,
                                                  ),
                                                ),
                                                Text(
                                                  'ทะเบียน ${res['Car_platenumber']}',
                                                  style: _baseFontStyle,
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'ค่าขนส่ง ${f
                                                        .SeperateNumber(
                                                        res['Money_car_send'])} บาท',
                                                    style: _baseFontStyle,
                                                  ),
                                                ),
                                                Text(
                                                  'กำหนดส่ง ${f.ThaiFormat(
                                                      res['Date_send'])}',
                                                  style: _baseFontStyle,
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          if (res['showDetail'] == 1)
                                            Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 200,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                        Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount:
                                                        res['stock_detail']
                                                            .length,
                                                        itemBuilder: (bc, i) {
                                                          var detail =
                                                          res['stock_detail']
                                                          [i];
                                                          return Card(
                                                            elevation: 2,
                                                            child: Container(
                                                              width: 200,
                                                              padding:
                                                              EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 100,
                                                                    child:
                                                                    CachedNetworkImage(
                                                                      imageUrl:
                                                                      '$storagePath${detail['Image']}',
                                                                      progressIndicatorBuilder: (
                                                                          context,
                                                                          url,
                                                                          downloadProgress) =>
                                                                          LinearProgressIndicator(
                                                                              value: downloadProgress
                                                                                  .progress),
                                                                      errorWidget: (
                                                                          context,
                                                                          url,
                                                                          error) =>
                                                                          Icon(
                                                                              Icons
                                                                                  .error),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                        '${detail['Product_name']}'),
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      'จำนวน ${detail['Qty']} ${detail['Unit_type']}',
                                                                      style:
                                                                      _baseFontStyle,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                  Text(
                                                    'รวม : ${calStock(
                                                        res['stock_detail'])} ชิ้น',
                                                    style: _baseFontStyle,
                                                  )
                                                ],
                                              ),
                                            ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              res['showDetail'] == 0
                                                  ? Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    res['showDetail'] = 1;
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons.zoom_in,
                                                          size: 28,
                                                          color:
                                                          kPrimaryColor,
                                                        ),
                                                        Text(
                                                            'ดูรายละเอียด')
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                                  : Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    res['showDetail'] = 0;
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .visibility_off,
                                                          size: 24,
                                                          color:
                                                          kPrimaryColor,
                                                        ),
                                                        Text(
                                                            'ซ่อนรายละเอียด')
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (res['Status'] == 1 &&
                                                  res['isConfirm'] == 0)
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      res['isConfirm'] = 1;
                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.check,
                                                            size: 28,
                                                            color:
                                                            kPrimaryColor,
                                                          ),
                                                          Text('รับสินค้า')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              if (res['isConfirm'] == 1)
                                                Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              height: 36,
                                                              child: IconButton(
                                                                  icon: Icon(
                                                                    Icons.check,
                                                                    size: 32,
                                                                  ),
                                                                  onPressed: () {
                                                                    res['isConfirm'] =
                                                                    0;
                                                                    confirmStock(
                                                                        res['ID'],
                                                                        res['Team_code']);
                                                                  }),
                                                            ),
                                                            Text(
                                                                'ยืนยันรับสินค้า'),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Container(
                                                              height: 36,
                                                              child: IconButton(
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    size: 32,
                                                                  ),
                                                                  onPressed: () {
                                                                    res['isConfirm'] =
                                                                    0;
                                                                    setState(() {});
                                                                  }),
                                                            ),
                                                            Text('ยังไม่รับ'),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                              if (res['Survey'] == null)
                                                Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Container(
                                                              height: 36,
                                                              child: IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .ballot_outlined,
                                                                    size: 30,
                                                                    color:
                                                                    kPrimaryColor,
                                                                  ),
                                                                  onPressed: () {
                                                                    locator<
                                                                        NavigationService>()
                                                                        .navigateTo(
                                                                        'survey_team_stock',
                                                                        ScreenArguments(
                                                                          userId:
                                                                          widget
                                                                              .userId,
                                                                          docId:
                                                                          res['ID'],
                                                                        ));
                                                                  }),
                                                            ),
                                                            Text(
                                                                'ประเมินการส่งสินค้า'),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                              // if(res['Status'] == 3)
                                              //   Expanded(
                                              //     child: InkWell(
                                              //       onTap: () {
                                              //         Navigator.pop(context);
                                              //         locator<NavigationService>()
                                              //             .navigateTo('createSaleOrder', ScreenArguments(userId: widget.userId,editStatus: 0,docId:res['ID']));
                                              //       },
                                              //       child: Container(
                                              //         child: Column(
                                              //           children: [
                                              //             Icon(
                                              //               Icons.edit,
                                              //               size: 28,
                                              //               color:
                                              //               kPrimaryColor,
                                              //             ),
                                              //             Text('แก้ไขใบสั่งขาย')
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    );
                                  }));
                        } else {
                          return Center(
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
                                      "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้ออกใบสั่งขาย \nในวันเวลา ดังกล่าวที่คุณเลือกมานี้",
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
                          );

                      }
                      } else {
                      return Container(
                      child: ShimmerLoading(),
                      );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showStockTeam(Size size, BuildContext context) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Container(
        width: size.width,
        child: Card(
          elevation: 2.0,
          child: Container(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                HeaderText(
                  text: 'ข้อมูลสินค้าคงเหลือภายในทีม',
                  textSize: 20,
                  gHeight: 26,
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Flexible(
                //       child: TextField(
                //         controller: _search,
                //         onChanged: (val) => filterStock(query: val),
                //         decoration: InputDecoration(
                //             labelText: 'ค้นหา',
                //             hintText: 'ค้นหา',
                //             prefixIcon: Icon(Icons.search),
                //             suffixIcon: IconButton(
                //                 icon: Icon(Icons.close),
                //                 onPressed: () {
                //                   filterStock();
                //                   _search.clear();
                //                   FocusScope.of(context).unfocus();
                //                 }),
                //             isDense: true,
                //             filled: true,
                //             fillColor: Colors.white,
                //             border: OutlineInputBorder(
                //                 borderRadius:
                //                     BorderRadius.all(Radius.circular(25)))),
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                FutureBuilder(
                    future: isLoaded,
                    builder: (BuildContext bc, AsyncSnapshot snap) {
                      if (snap.hasData) {
                        if (stockTeamSum.length > 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Container(
                                width: size.width,
                                height: size.height * 0.27,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: stockTeamSum.length,
                                    itemBuilder: (bc, i) {
                                      var result = stockTeamSum[i];
                                      return Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: SizedBox(
                                                    height: 70,
                                                    child: result['Image'] ==
                                                        null ||
                                                        result['Image'] ==
                                                            'null' ||
                                                        result['Image'] ==
                                                            ''
                                                        ? Image.asset(
                                                        'assets/no_image.png')
                                                        : GestureDetector(
                                                      onTap: () =>
                                                          showImageDetail(
                                                              context,
                                                              '${result['Product_id']}',
                                                              '$storagePath${result['Image']}',
                                                              size),
                                                      child: Hero(
                                                          tag:
                                                          '${result['Product_id']}',
                                                          child:
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                            '$storagePath${result['Image']}',
                                                            progressIndicatorBuilder: (
                                                                context,
                                                                url,
                                                                downloadProgress) =>
                                                                LinearProgressIndicator(
                                                                    value:
                                                                    downloadProgress
                                                                        .progress),
                                                            errorWidget: (
                                                                context,
                                                                url,
                                                                error) =>
                                                                Icon(Icons
                                                                    .error),
                                                          )
                                                        // child: Image.network(
                                                        //     '$storagePath${result['Image']}'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        '${result['Name']}',
                                                        style: _baseFontStyle,
                                                      ),
                                                      Text(
                                                          'คงเหลือจำนวน : ${result['Qty']} ${result['Unit'] ==
                                                              null
                                                              ? ''
                                                              : result['Unit']}',
                                                          style:
                                                          _baseFontStyle),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                        ],
                                      );
                                    })),
                          );
                        } else {
                          return Center(
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
                                      "ไม่มีข้อมูลแสดงผล",
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
                                      "ยังไม่มีข้อมูลสอนค้าคลังภายในทีม\nกรุณาติดต่อธุรการเพิ่มคลังสินค้าให้กับท่าน",
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
                          );
                        }
                      } else {
                        return ShimmerLoading(
                          type: 'boxItem',
                        );
                        // return Container(
                        //   child: CircularProgressIndicator(),
                        // );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
