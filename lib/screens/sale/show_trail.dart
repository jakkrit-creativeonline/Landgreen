import 'dart:convert';
import 'dart:io';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:system/main.dart';

class ShowTrail extends StatefulWidget {
  final int userId;

  const ShowTrail({Key key, this.userId}) : super(key: key);

  @override
  _ShowTrailState createState() => _ShowTrailState();
}

class _ShowTrailState extends State<ShowTrail> {
  List _result = [];
  List<OfflineTrail> _offlineResult;
  var _dateRange = TextEditingController();
  DateTimeRange initDateTimeRange;
  FormatMethod f = FormatMethod();
  int sumTrail = 0;
  int sumAmount = 0;
  Future<bool> boolSet;

  var _contextGolbal;
  var client = http.Client();

  Future<Null> getData({String startDate = '', String endDate = ''}) async {
    await getTrail(startDate: startDate, endDate: endDate);

    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      //ถ้าหน้านี้เปิดเน็ตให้ไปดึงบิลออนไลน์มาเก็บไว้ในเครื่อง
      getOnline(startDate: startDate, endDate: endDate);
    }

    setState(() {});
  }

  Future<Null> getTrail({String startDate = '', String endDate = ''}) async {
    var result = await Sqlite()
        .getTrail(widget.userId, selectStart: startDate, selectEnd: endDate);
    _result = result.toList();
    await genListOffline();

    setState(() {});
  }

  Future<Null> getOnline({String startDate = '', String endDate = ''}) async {
    AlertNewDesign()
        .showLoading(_contextGolbal, MediaQuery.of(_contextGolbal).size);
    // alert( _contextGolbal,
    //   title:Text("แจ้งเตือน!!!"),
    //   content:Text("หากรายการใบแจกสินค้าทดลองยังไม่แสดง\nให้เปิดหน้านี้ค้างไว้ประมาณ 2-5 นาที นะครับ\nระบบกำลังดึงข้อมูลมาเก็บไว้ในเครื่องให้อยู่ครับ"),
    // );
    print('getTrailOnline user_id => ${widget.userId}');
    print('getTrailOnline startDate => $startDate');
    print('getTrailOnline endDate => $endDate');
    final response = await client
        .post('https://landgreen.ml/system/public/api/getTrailOnline', body: {
      'User_id': '${widget.userId}',
      'startDate': startDate,
      'endDate': endDate
    });

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

    print("parsed.length =>${parsed.length}");

    if (parsed.length > 0) {
      for (var i = 0; i < parsed.length; i++) {
        // print('${parsed[i]}');
        await Sqlite().insertOrUpdateTrailFromOnline(parsed[i]);
      }
      boolSet = Future.value();
      await getTrail(startDate: startDate, endDate: endDate);
      if (mounted) setState(() {});
    }
    if (_contextGolbal != null) Navigator.pop(context);
  }

  Future<List<OfflineTrail>> parseResults(String resBody) async {
    final parsed = jsonDecode(resBody).cast<Map<String, dynamic>>();
    return await parsed
        .map<OfflineTrail>((json) => OfflineTrail.fromJson(json))
        .toList();
  }

  Future<Null> genListOffline() async {
    print('gen list offline');
    _offlineResult = await parseResults(jsonEncode(_result));
    sumTrail = _offlineResult.length;
    for (var i = 0; i < _offlineResult.length; i++) {
      var result = _offlineResult[i];
      var order = jsonDecode(result.orderDetail);
      sumAmount += order[0]['qty'];
    }

    boolSet = Future.value(true);
    setState(() {});
    print('genListOffline');
    print(_offlineResult);
  }

  Future _refresh({String startDate = '', String endDate = ''}) async {
    print('_refresh function');
    boolSet = Future.value();
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      ServiceUploadAll().uploadALL();
    }

    getData(startDate: startDate, endDate: endDate);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    DateTime n = DateTime.now();
    initDateTimeRange = DateTimeRange(
        start: DateTime(n.year, n.month),
        end: DateTime(n.year, n.month, n.day));
    _dateRange.text = 'ข้อมูลประจำสัปดาห์นี้';
    getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _contextGolbal = context;
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
                title: Text('ข้อมูลใบแจกสินค้าทดลอง'),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 18, right: 18, top: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          showSum(),
                          offlineTrailContainer(size),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showSum() {
    return Card(
      child: Column(
        children: [
          HeaderText(
            text: 'สรุปยอดขาย สินค้าแจก',
            textSize: 20,
            gHeight: 26,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'ลูกค้ารับสินค้าแล้ว',
                      style: TextStyle(fontSize: 20),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      '${sumTrail} บิล',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'ลูกค้ารับสินค้าแล้ว',
                      style: TextStyle(fontSize: 20),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      '${sumAmount} ชิ้น',
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _showDateTimeRange(context) async {
    // alert(
    //   _contextGolbal,
    //   title: Text("แจ้งเตือน!!!"),
    //   content: Text(
    //       "เพื่อความรวดเร็วในการแสดงผล\nรบกวนเลือกวันที่ไม่ควรเกิน 7 วันนะครับ\nระบบกำลังดึงข้อมูลมาเก็บไว้ในเครื่องได้เร็วขึ้นครับ"),
    // );
    final DateTimeRange picked = await showDateRangePicker(
      context: context,
      initialDateRange: initDateTimeRange,
      currentDate: DateTime.now(),
      firstDate: DateTime(1917),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      var c = DateTime.now().toString().split(' ')[0];
      var n = picked.start.toString().split(' ')[0];
      var d = n.toString().split('-');
      if (c == n) {
        initDateTimeRange = DateTimeRange(
            start: DateTime(int.parse(d[0]), int.parse(d[1]), 1, 0, 0, 0),
            end: DateTime(
                int.parse(d[0]), int.parse(d[1]), int.parse(d[2]), 23, 59, 59));
      } else {
        initDateTimeRange = picked;
      }

      _dateRange.text = 'ข้อมูลวันที่ ' +
          f.ThaiFormat(picked.start.toString().split(' ')[0]) +
          ' ถึง ' +
          f.ThaiFormat(picked.end.toString().split(' ')[0]);
      _refresh(
          startDate: picked.start.toString().split(' ')[0],
          endDate: picked.end.toString().split(' ')[0]);
    }
  }

  Widget offlineTrailContainer(Size size) {
    // print('offlineTrailContainer');
    // print(_offlineResult.runtimeType);
    // if(_offlineResult != null){
    //   _offlineResult.then((value) => {
    //     if(value.isNotEmpty)
    //       setState((){})
    //   });
    // }

    print('_offlineResult => $_offlineResult');

    return Card(
        child: FutureBuilder(
            future: boolSet,
            builder: (context, data) {
              if (data.hasData) {
                // sumAmount = 0;
                List<Widget> detailList = new List();

                for (var i = 0; i < _offlineResult.length; i++) {
                  var result = _offlineResult[i];
                  detailList.add(ShowTrailOfflineList(
                    result: result,
                    userId: widget.userId,
                  ));
                  var order = jsonDecode(result.orderDetail);
                  // sumAmount += order[0]['qty'];
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                          hintText: 'ข้อมูลประจำสัปดาห์นี้',
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
                    (_offlineResult.length != 0)
                        ? Container(
                            height: size.height * 0.64,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: detailList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return detailList[index];
                                // return ShowTrailOfflineList(
                                //   result: result,
                                //   userId: widget.userId,
                                // );
                              },
                            ),
                          )
                        : Center(
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
                                      "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้ออกแจกสินค้าทดลอง \nในวันเวลา ดังกล่าวที่คุณเลือกมานี้",
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
                  ],
                );
              } else if (data.hasError) {
                print(data.error);
                return Column(
                  children: [
                    ClipRRect(
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
                                      hintText: 'ข้อมูลประจำสัปดาห์นี้',
                                      hintStyle: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
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
                    ShimmerLoading(
                      type: 'boxText',
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    ClipRRect(
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
                                      hintText: 'ข้อมูลประจำเดือนนี้',
                                      hintStyle: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
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
                    ShimmerLoading(
                      type: 'boxText',
                    ),
                  ],
                );
              }
            }));
  }
}

class ShowTrailOfflineList extends StatefulWidget {
  final OfflineTrail result;
  final int userId;

  ShowTrailOfflineList({Key key, OfflineTrail result, this.userId})
      : result = result,
        super(key: key);

  @override
  _ShowTrailOfflineListState createState() =>
      _ShowTrailOfflineListState(result);
}

class _ShowTrailOfflineListState extends State<ShowTrailOfflineList> {
  final OfflineTrail result;

  _ShowTrailOfflineListState(this.result);

  var amount = 0;
  var product = '';

  Future<Null> getOrderDetail() async {
    var order = jsonDecode(result.orderDetail);
    product = order[0]['name'];
    amount = order[0]['qty'];
    setState(() {});
  }

  Widget _status() {
    print('_status');
    print(result.status);
    switch (result.status) {
      case 1:
        return Text(
          'เสร็จสมบูรณ์',
          style: TextStyle(fontSize: 18, color: kPrimaryColor),
        );
        break;
      case 2:
        return Text(
          'ธุรการกำลังแก้ไข',
          style: TextStyle(fontSize: 18, color: Colors.red),
        );
        break;
      case 3:
        return Text(
          'เข้าคิวแล้วกำลังส่งเข้าเซิฟเวอร์',
          style: TextStyle(fontSize: 18, color: kSecondaryColor),
        );
        break;
      case 4:
        return Text(
          'ส่งเสร็จแล้ว',
          style: TextStyle(fontSize: 18, color: kPrimaryColor),
        );
        break;
      default:
        return Text('กำลังนำส่งเข้าคิว',
            style: TextStyle(fontSize: 18, color: danger));
    }
  }

  void showModal(context) {
    // print('result ');
    // print(result.iD);
    // print(result.trialNumber);
    // print(result.orderDetail);

    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.amber),
                            child: IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.tasks,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  print('result.status =>${result.status}');
                                  // print(result.iD);
                                  locator<NavigationService>().navigateTo(
                                      'createBillTrail',
                                      ScreenArguments(
                                        userId: widget.userId,
                                        trailId: result.iD,
                                        editStatus: result.status,
                                      ));
                                }),
                          ),
                          Text(
                            'ดูรายละเอียด',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: kPrimaryColor),
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // print(result.iD);
                                    locator<NavigationService>().navigateTo(
                                        'createBill',
                                        ScreenArguments(
                                            userId: widget.userId,
                                            editStatus: 0,
                                            customerId: result.customerId));
                                  })),
                          Text(
                            'สร้างใบสั่งจองสินค้า',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState

    getOrderDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModal(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Icon(
                    Icons.arrow_right,
                    color: mainFontColor,
                    size: 20,
                  ),
                ),
                // Column(
                //   children: [
                //     Container(
                //         padding: EdgeInsets.all(4.0),
                //         decoration: BoxDecoration(
                //             shape: BoxShape.circle, color: kPrimaryColor),
                //         child: Icon(
                //           Icons.people_alt_rounded,
                //           color: Colors.white,
                //         )),
                //   ],
                // ),
                // SizedBox(
                //   width: 10,
                // ),
                Text(
                  'ชื่อลูกค้า  ${result.name} ${result.surname}',
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 5.0),
              child: Text(
                'ที่อยู่ : ${result.address} ตำบล${result.dISTRICTNAME}อำเภอ${result.aMPHURNAME}จังหวัด${result.pROVINCENAME}',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
              child: Text(
                'สินค้า : $product',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
              child: Text(
                'จำนวน : $amount ชิ้น',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
              child: Row(
                children: [
                  Text(
                    'สถานะ : ',
                    style: TextStyle(fontSize: 20),
                  ),
                  _status()
                ],
              ),
            ),
            MyDivider(),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Column(
            //         children: [
            //           Container(
            //               padding: EdgeInsets.all(4.0),
            //               decoration: BoxDecoration(
            //                   shape: BoxShape.circle, color: kPrimaryColor),
            //               child: Icon(
            //                 Icons.people_alt_rounded,
            //                 color: Colors.white,
            //               )),
            //         ],
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(
            //         'ลูกค้า : ${result.name} ${result.surname}',
            //         style: TextStyle(fontSize: 18),
            //       ),
            //       SizedBox(
            //         width: 30,
            //       ),
            //       Text(
            //         'ประเภท : ${result.customerType}',
            //         style: TextStyle(fontSize: 18),
            //       )
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Column(
            //         children: [
            //           Container(
            //               padding: EdgeInsets.all(4.0),
            //               decoration: BoxDecoration(
            //                   shape: BoxShape.circle, color: kPrimaryColor),
            //               child: Icon(
            //                 Icons.map,
            //                 color: Colors.white,
            //               )),
            //         ],
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Flexible(
            //         child: Text(
            //           'ที่อยู่ : ${result.address} ตำบล${result.dISTRICTNAME}อำเภอ${result.aMPHURNAME}จังหวัด${result.pROVINCENAME}',
            //           style: TextStyle(fontSize: 18),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Column(
            //         children: [
            //           Container(
            //               padding: EdgeInsets.all(4.0),
            //               decoration: BoxDecoration(
            //                   shape: BoxShape.circle, color: kPrimaryColor),
            //               child: Icon(
            //                 Icons.inventory,
            //                 color: Colors.white,
            //               )),
            //         ],
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(
            //         'สินค้า : $product',
            //         style: TextStyle(fontSize: 18),
            //       ),
            //       SizedBox(
            //         width: 30,
            //       ),
            //       Text(
            //         'จำนวน : $amount',
            //         style: TextStyle(fontSize: 18),
            //       )
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Column(
            //         children: [
            //           Container(
            //               padding: EdgeInsets.all(4.0),
            //               decoration: BoxDecoration(
            //                   shape: BoxShape.circle, color: kPrimaryColor),
            //               child: Icon(
            //                 Icons.view_module,
            //                 color: Colors.white,
            //               )),
            //         ],
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Row(
            //         children: [
            //           Text(
            //             'สถานะ : ',
            //             style: TextStyle(fontSize: 18),
            //           ),
            //           _status()
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class OfflineTrail {
  int iD;
  String trialNumber;
  int customerId;
  int userId;
  String orderDetail;
  String imageReceive;
  String imageSignature;
  String dateCreate;
  int status;
  String name;
  String surname;
  String idCard;
  int typeId;
  int sex;
  String address;
  int districtId;
  int amphurId;
  int provinceId;
  String zipcode;
  String birthday;
  String phone;
  String customerRefNo1;
  String customerRefNo2;
  String image;
  String imageIdCard;
  int editUserId;
  String timestamp;
  String customerType;
  String pROVINCENAME;
  String dISTRICTNAME;
  String aMPHURNAME;

  OfflineTrail(
      {this.iD,
      this.trialNumber,
      this.customerId,
      this.userId,
      this.orderDetail,
      this.imageReceive,
      this.imageSignature,
      this.dateCreate,
      this.status,
      this.name,
      this.surname,
      this.idCard,
      this.typeId,
      this.sex,
      this.address,
      this.districtId,
      this.amphurId,
      this.provinceId,
      this.zipcode,
      this.birthday,
      this.phone,
      this.customerRefNo1,
      this.customerRefNo2,
      this.image,
      this.imageIdCard,
      this.editUserId,
      this.timestamp,
      this.customerType,
      this.pROVINCENAME,
      this.dISTRICTNAME,
      this.aMPHURNAME});

  OfflineTrail.fromJson(Map<String, dynamic> json) {
    iD = json['trail_id'];
    trialNumber = json['Trial_number'];
    customerId = json['Customer_id'];
    userId = json['User_id'];
    orderDetail = json['Order_detail'];
    imageReceive = json['Image_receive'];
    imageSignature = json['Image_signature'];
    dateCreate = json['Date_create'];
    status = json['Status'];
    name = json['Name'];
    surname = json['Surname'];
    idCard = json['Id_card'];
    typeId = json['Type_id'];
    sex = json['Sex'];
    address = json['Address'];
    districtId = json['District_id'];
    amphurId = json['Amphur_id'];
    provinceId = json['Province_id'];
    zipcode = json['Zipcode'];
    birthday = json['Birthday'];
    phone = json['Phone'];
    customerRefNo1 = json['Customer_ref_no1'];
    customerRefNo2 = json['Customer_ref_no2'];
    image = json['Image'];
    imageIdCard = json['Image_id_card'];
    editUserId = json['Edit_user_id'];
    timestamp = json['Timestamp'];
    customerType = json['Customer_type'];
    pROVINCENAME = json['PROVINCE_NAME'];
    dISTRICTNAME = json['DISTRICT_NAME'];
    aMPHURNAME = json['AMPHUR_NAME'];
  }
}
