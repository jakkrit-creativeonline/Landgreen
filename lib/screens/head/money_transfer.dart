import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/show_modal_bottom_sheet.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MoneyTransfer extends StatefulWidget {
  final int userId;

  const MoneyTransfer({Key key, this.userId}) : super(key: key);

  @override
  _MoneyTransferState createState() => _MoneyTransferState();
}

class _MoneyTransferState extends State<MoneyTransfer> {
  // Stream<List<MoneyTransferResult>> _resultStream;
  // StreamController<List> _controllerStream = new StreamController<List> ();
  List<MoneyTransferResult> _result;
  Future<bool> _setFutureResult;
  List<TransferHistoryResult> _resultHistory;
  Future<bool> isLoaded;
  Future<bool> isHistoryLoaded;
  FormatMethod f = FormatMethod();
  List _orderDetail;

  var _dateRange = TextEditingController();
  DateTimeRange initDateTimeRange;
  DateTimeRange defaultDateTimeRange;

  Future<List<MoneyTransferResult>> fetchResult(http.Client client) async {
    //print(widget.userId);
    final response = await client.post(
        'https://landgreen.ml/system/public/api/getMoneyTransfer',
        body: {'user_id': '${widget.userId}'});

    //Sqlite().insertJson('MoneyTransfer', '${widget.userId}', response.body);
    return await parseResult(response.body);
  }

  Stream<List<MoneyTransferResult>> fetchResultStream(
      http.Client client) async* {
    //print(widget.userId);
    var response = await client.post(
        'https://landgreen.ml/system/public/api/getMoneyTransfer',
        body: {'user_id': '${widget.userId}'});

    //Sqlite().insertJson('MoneyTransfer', '${widget.userId}', response.body);
    // return await parseResult(response.body);

    var parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

    List<MoneyTransferResult> _resultreturn = parsed
        .map<MoneyTransferResult>((json) => MoneyTransferResult.fromJson(json))
        .toList();
    // print("fetchResultStream");
    // print(_resultreturn.runtimeType);
    // _controllerStream.add(_resultreturn);
    yield _resultreturn;
  }

  // Future<List<MoneyTransferResult>> getchResultOffline() async {
  //   final response = await Sqlite().query('JSON_TABLE',
  //       where:
  //           'DATA_TABLE = "MoneyTransfer" AND JSON_KEY = "${widget.userId}"');
  //   return await parseResult(response.body);
  // }

  Future<List<MoneyTransferResult>> parseResult(String resBody) async {
    final parsed = jsonDecode(resBody).cast<Map<String, dynamic>>();
    return parsed
        .map<MoneyTransferResult>((json) => MoneyTransferResult.fromJson(json))
        .toList();
  }

  Future<Null> getOrderDetail(http.Client client) async {
    final res = await client.get(
      'https://landgreen.ml/system/public/api-heads/getBillOrderDetail',
    );
    _orderDetail = json.decode(res.body);
  }

  Future<List<TransferHistoryResult>> fetchHistory(http.Client client,
      {String startDate = '', String endDate = ''}) async {
    // final res = await client.post('https://landgreen.ml/system/public/api-heads',
    //     body: {
    //       'user_id': '512',
    //       'func': 'bill_money_transfer_get_table_data_history'
    //     });
    final res = await client.post(
        'https://landgreen.ml/system/public/api/getBillMoneyTransferHistory',
        body: {
          'user_id': '${widget.userId}',
          'startDate': startDate,
          'endDate': endDate,
        });
    final parsed = jsonDecode(res.body).cast<Map<String, dynamic>>();
    isHistoryLoaded = Future.value(true);
    return parsed
        .map<TransferHistoryResult>(
            (json) => TransferHistoryResult.fromJson(json))
        .toList();
  }

  Future<void> getData() async {
    //await getOrderDetail(http.Client());

    _result = await fetchResult(http.Client());
    _setFutureResult = Future.value(true);
    // _resultStream = await fetchResultStream(http.Client());
    _resultHistory = await fetchHistory(http.Client());

    setState(() {});
  }

  Future _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print('isConnect ${isConnect}');
    if (isConnect) {
      _setFutureResult = Future.value();
      setState(() {});
      await getData();
    } else {
      print('isConnect');
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
                  'หน้านี้เป็นหน้าแจ้งโอนเงิน ต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตนะครับถึงจะใช้งานได้',
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

  Future onSubmit() async {
    print('wowza');
  }

  void showModal(context, var sumMoney, List billId) {
    var callBack = showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return TransferDetail(
            sumMoney: sumMoney,
            billId: billId,
            userId: widget.userId,
          );
        });
    callBack.then((value) {
      locator<NavigationService>().moveWithArgsTo(
          'moneyTransfer', ScreenArguments(userId: widget.userId));
    });
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
      getHistoryTimeRange(
          startDate: picked.start.toString().split(' ')[0],
          endDate: picked.end.toString().split(' ')[0]);
    }
  }

  getHistoryTimeRange({startDate: '', endDate: ''}) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print('isConnect ${isConnect}');
    if (isConnect) {
      _setFutureResult = Future.value();
      isHistoryLoaded = Future.value();
      setState(() {});

      _result = await fetchResult(http.Client());
      _setFutureResult = Future.value(true);
      // _resultStream = await fetchResultStream(http.Client());
      _resultHistory = await fetchHistory(http.Client(),
          startDate: startDate, endDate: endDate);
      setState(() {});
    } else {
      print('isConnect');
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
                  'หน้านี้เป็นหน้าแจ้งโอนเงิน ต้องใช้อินเทอร์เน็ตนะครับ\nรบกวนต้องอยู่ในที่ๆมีสัญญาณอินเทอร์เน็ตนะครับถึงจะใช้งานได้',
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

  @override
  void initState() {
    DateTime n = DateTime.now();
    initDateTimeRange = DateTimeRange(
        start: DateTime(n.year, n.month),
        end: DateTime(n.year, n.month, n.day));
    defaultDateTimeRange = initDateTimeRange;
    _dateRange.text = 'ประวัติการแจ้งโอนเงินสดประจำเดือนนี้';
    _refresh();
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
                  title: Text('แจ้งโอนเงินสด'),
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
              body: Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                width: double.infinity,
                height: size.height,
                // color: Color(0xfff6f6ff),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: [
                      headWidget(),
                      moneyTranferContainer(size),
                      moneyTranferHistoryContainer(size),
                      SliverToBoxAdapter(
                        child: Footer(),
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  SliverToBoxAdapter headWidget() {
    return SliverToBoxAdapter(
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
                padding: const EdgeInsets.only(
                    left: 8, top: 8, right: 14, bottom: 8),
                child: Icon(
                  FontAwesomeIcons.moneyBillAlt,
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
                    'แจ้งโอนเงินสดให้ธุรการ',
                    style: TextStyle(fontSize: 24.0, height: 1),
                  ),
                  Text(
                    'เลือกรายการบิลที่แจ้งโอนให้ธุรการแล้วกดปุ่มแจ้งโอน',
                    style: TextStyle(fontSize: 16.0, height: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter moneyTranferHistoryContainer(Size size) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
                future: isHistoryLoaded,
                builder: (context, data) {
                  if (data.hasData) {
                    return Container(
                      height: size.height * 0.5,
                      child: Card(
                        elevation: 2.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HeaderText(text: 'ประวัติการแจ้งโอนเงินสด',textSize: 20,gHeight: 26,),
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
                                                  const EdgeInsets.fromLTRB(
                                                      8, 1, 8, 1),
                                              child: TextField(
                                                controller: _dateRange,
                                                decoration: InputDecoration(
                                                  // labelText:'ข้อมูล ณ วันที่',
                                                  hintText:
                                                      'ประวัติการแจ้งโอนเงินสดประจำเดือนนี้',
                                                  contentPadding:
                                                      EdgeInsets.all(0.0),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
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
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: ListView.builder(
                                    itemCount: _resultHistory.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var result = _resultHistory[index];
                                      return MoneyTransferHistoeyList(
                                        result: result,
                                      );
                                    }),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Card(
                        child: ShimmerLoading(
                      type: 'boxItem',
                    ));
                  }
                })
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter moneyTranferContainer(Size size) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: size.height * 0.6,
              child: Card(
                elevation: 2.0,
                child: FutureBuilder(
                    future: _setFutureResult,
                    builder: (context, snapshot) {
                      print('snapshot');
                      print(snapshot.hasData);
                      // return Container();
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            HeaderText(
                              text: 'รายการรอแจ้งโอนเงินสด',
                              textSize: 20,
                              gHeight: 26,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'ติ๊กเลือกบิลที่จะแจ้งโอนเงินสดจากนั้นกดปุ่มแจ้งโอน',
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // color:Colors.amber,
                                                  width: 20,
                                                  height: 18,
                                                  child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      icon: Icon(
                                                        Icons.library_add_check,
                                                        size: 18,
                                                      ),
                                                      onPressed: () {
                                                        if (_result != null) {
                                                          for (MoneyTransferResult b
                                                              in _result) {
                                                            if (b.selected)
                                                              print(
                                                                  b.billNumber);
                                                            b.selected = true;
                                                          }
                                                        }
                                                        // _result.then((value) {
                                                        //   // print('value ${value}');
                                                        //   for (MoneyTransferResult b in value) {
                                                        //
                                                        //     if (b.selected) print(b.billNumber);
                                                        //     b.selected = true;
                                                        //   }
                                                        // });
                                                        setState(() {});
                                                      }),
                                                ),
                                                Text(
                                                  'เลือกทั้งหมด',
                                                  style: TextStyle(
                                                      fontSize: 20, height: 1),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomButton(
                                        text: 'แจ้งโอน',
                                        onPress: () {
                                          var sumMoney = 0;
                                          List billId = [];
                                          if (_result != null) {
                                            for (MoneyTransferResult b
                                                in _result) {
                                              if (b.selected) {
                                                if (b.payType == 1) {
                                                  sumMoney += b.moneyTotal;
                                                } else {
                                                  sumMoney += b.moneyEarnest;
                                                }
                                                billId.add(b.billId);
                                              }
                                            }
                                            if (sumMoney == 0) {
                                              ShowModalBottom().alertDialog(
                                                  context,
                                                  'กรุณาเลือกรายการที่ต้องการโอน');
                                            } else {
                                              showModal(
                                                  context, sumMoney, billId);
                                            }
                                          }
                                          // _result.then((value) {
                                          //   for (MoneyTransferResult b in value) {
                                          //     if (b.selected) {
                                          //       if (b.payType == 1) {
                                          //         sumMoney += b.moneyTotal;
                                          //       } else {
                                          //         sumMoney += b.moneyEarnest;
                                          //       }
                                          //       billId.add(b.billId);
                                          //     }
                                          //   }
                                          //   if (sumMoney == 0) {
                                          //     ShowModalBottom().alertDialog(context,
                                          //         'กรุณาเลือกรายการที่ต้องการโอน');
                                          //   } else {
                                          //     showModal(context, sumMoney, billId);
                                          //   }
                                          //
                                          //   // print(sumMoney);
                                          // });
                                        },
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: size.height * 0.4,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.0),
                                    child: ListView.builder(
                                        itemCount: _result.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var result = _result[index];
                                          return MoneyTransferList(
                                            result: result,
                                            currentUserId: widget.userId,
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        print('else');
                        return ShimmerLoading(
                          type: 'boxText2row',
                        );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoneyTransferHistoeyList extends StatefulWidget {
  final TransferHistoryResult result;

  const MoneyTransferHistoeyList({Key key, TransferHistoryResult result})
      : result = result,
        super(key: key);
  @override
  _MoneyTransferHistoeyListState createState() =>
      _MoneyTransferHistoeyListState(result);
}

class _MoneyTransferHistoeyListState extends State<MoneyTransferHistoeyList> {
  final TransferHistoryResult result;

  _MoneyTransferHistoeyListState(this.result);

  FormatMethod f = FormatMethod();

  void showImageDetail(context, String tag, String url, Size size) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return AlertDialog(
            content: Container(
                height: size.height * 0.5,
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
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    showImageDetail(context, '${result.iD}',
                        '$storagePath${result.img}', size);
                  },
                  child: Hero(
                    tag: '${result.iD}',
                    child: Container(
                      height: 100,
                      child: CachedNetworkImage(
                        imageUrl: '$storagePath${result.img}',
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                          text: 'ยอดขาย : ',
                          style: TextStyle(fontSize: 20.0),
                          children: [
                            TextSpan(
                                text: '${f.SeperateNumber(result.moneyTotal)}',
                                style: TextStyle(
                                    fontSize: 20.0, color: kPrimaryColor))
                          ]),
                    ),
                    Text.rich(
                      TextSpan(
                          text: 'เงินที่โอน : ',
                          style: TextStyle(fontSize: 20.0),
                          children: [
                            TextSpan(
                                text: '${f.SeperateNumber(result.money)}',
                                style: TextStyle(
                                    fontSize: 20.0, color: kPrimaryColor))
                          ]),
                    ),
                    Wrap(
                      children: [
                        Text(
                          'สถานะ : ',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        if (result.status == 0)
                          Text('รอบัญชีตรวจสอบ',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.blueAccent)),
                        if (result.status == 1)
                          Text('บัญชีอนุมัติแล้ว',
                              style: TextStyle(
                                  fontSize: 20.0, color: kPrimaryColor)),
                        if (result.status == 2)
                          Text(
                              (result.remark != null)
                                  ? 'บัญชีไม่อนุมัติ (${result.remark})'
                                  : 'บัญชีไม่อนุมัติ',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.redAccent)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MoneyTransferList extends StatefulWidget {
  final MoneyTransferResult result;
  final int currentUserId;
  MoneyTransferList({Key key, this.result, this.currentUserId})
      : super(key: key);
  // MoneyTransferList(MoneyTransferResult result)
  //     : result = result,
  //       super(key: new ObjectKey(result));

  @override
  _MoneyTransferListState createState() => _MoneyTransferListState(result);
}

class _MoneyTransferListState extends State<MoneyTransferList> {
  final MoneyTransferResult result;
  _MoneyTransferListState(this.result);
  FormatMethod f = FormatMethod();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextStyle _baseFontStyle = TextStyle(
      fontSize: 18,
    );
    print('result =>${result}');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            result.selected = !result.selected;
          });
        },
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                    value: result.selected,
                    onChanged: (value) {
                      setState(() {
                        result.selected = value;
                      });
                    }),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ชื่อลูกค้า : ',
                          style: _baseFontStyle,
                        ),
                        Text('${result.customerName} ${result.customerSurname}',
                            style: _baseFontStyle),
                      ],
                    ),
                    Row(
                      children: [
                        Text('ผู้ขาย : ', style: _baseFontStyle),
                        Text('${result.saleName} ${result.saleSurname}',
                            style: _baseFontStyle),
                      ],
                    ),
                    Row(
                      children: [
                        Text('ชนิดบิล : ', style: _baseFontStyle),
                        Text('${result.payType == 1 ? 'เงินสด' : 'เครดิต'}',
                            style: _baseFontStyle),
                      ],
                    ),
                    Row(
                      children: [
                        Text('ยอดขาย : ', style: _baseFontStyle),
                        Text(
                            '${f.SeperateNumber(result.moneyTotal.toString())} บาท',
                            style: _baseFontStyle),
                      ],
                    ),
                    Row(
                      children: [
                        Text('เงินที่ต้องโอน : ', style: _baseFontStyle),
                        Text(
                            '${f.SeperateNumber(result.payType == 1 ? result.moneyTotal.toString() : result.moneyEarnest.toString())} บาท',
                            style: _baseFontStyle),
                      ],
                    )
                  ],
                )),
                // RaisedButton(
                //   color: kPrimaryColor,
                //   textColor: btTextColor,
                //   onPressed: (){
                //     locator<NavigationService>().navigateTo(
                //         'createReceipt',
                //         ScreenArguments(
                //           isBillOnline: true,
                //           receiptId: result.receiptId,
                //           billId: result.billId,
                //           userId: result.userId,
                //           receiptNumber: result.receiptNumber,
                //         ));
                //   },
                //   child: Text('ดูใบเสร็จ'),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: CustomButton(
                    text: 'ดูใบเสร็จ',
                    onPress: () {
                      locator<NavigationService>().navigateTo(
                          'createReceipt',
                          ScreenArguments(
                            isBillOnline: true,
                            receiptId: result.receiptId,
                            billId: result.billId,
                            userId: result.userId,
                            receiptNumber: result.receiptNumber,
                          ));
                    },
                  ),
                )
                // IconButton(
                //     icon: Icon(Icons.zoom_in),
                //     color: kPrimaryColor,
                //     iconSize: 28.0,
                //     onPressed: () {
                //       print('receiptId => ${result.receiptId}');
                //       print('billId => ${result.billId}');
                //       print('BilluserId => ${result.userId}');
                //       print('receiptNumber => ${result.receiptNumber}');
                //       print('CurrentuserId => ${widget.currentUserId}');
                //
                //       locator<NavigationService>().navigateTo(
                //           'createReceipt',
                //           ScreenArguments(
                //             isBillOnline: true,
                //             receiptId: result.receiptId,
                //             billId: result.billId,
                //             userId: result.userId,
                //             receiptNumber: result.receiptNumber,
                //           ));
                //     })
              ],
            ),
          ),
        ),
      ),
    );
    // return ListTile(
    //     title: Row(
    //   children: <Widget>[
    //     Checkbox(
    //         value: result.selected,
    //         onChanged: (bool value) {
    //           setState(() {
    //             result.selected = value;
    //           });
    //         }),
    //     Expanded(child: new Text(result.customerName)),
    //   ],
    // ));
  }
}

class TransferDetail extends StatefulWidget {
  final sumMoney;
  final List billId;
  final int userId;

  const TransferDetail({Key key, this.sumMoney, this.billId, this.userId})
      : super(key: key);
  @override
  _TransferDetailState createState() => _TransferDetailState();
}

class _TransferDetailState extends State<TransferDetail> {
  File _image;
  FormatMethod f = FormatMethod();
  final picker = ImagePicker();
  FTPConnect ftpConnect;

  Future pickImage(bool isFromCamera) async {
    var pickedFile;
    if (isFromCamera) {
      pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 70, maxWidth: 700);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 700);
    }
    if (pickedFile != null) {
      //_showLoading(context);
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  Future submit() async {
    ftpConnect = FTPConnect(ftpHost, user: ftpUser, pass: ftpPass, port: 21);
    double percentage = 0.0;
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: false);
    pr.style(
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      message: 'กรุณารอสักครู่\nระบบกำลังประมวลผล',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    await pr.show();
    Future.delayed(Duration(seconds: 2)).then((value) {
      percentage += 30.0;
      pr.update(
        progress: percentage,
        message: "ส่งข้อมูล...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.green, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
    });

    var postUri = Uri.parse(
        'https://landgreen.ml/system/public/api/recordBillMoneyTransfer');
    var req = new http.MultipartRequest('POST', postUri);
    req.fields['bill_id'] = '${widget.billId}';
    req.fields['user_id'] = '${widget.userId}';
    req.fields['money'] = '${widget.sumMoney}';
    bool isUpload = false;
    if (_image != null) {
      print('${req}');
      await ftpConnect.connect();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      DateTime now = DateTime.now();
      String folderName = now.year.toString();
      String subFolderName = now.month.toString();
      String mainFolder =
          '/domains/landgreen.ml/public_html/system/storage/app/faarunApp/moneyTransfer/';
      String uploadPath = '$mainFolder$folderName/$subFolderName';
      await ftpConnect.createFolderIfNotExist(mainFolder);
      await ftpConnect.createFolderIfNotExist('$mainFolder$folderName');
      await ftpConnect
          .createFolderIfNotExist('$mainFolder$folderName/$subFolderName');
      await ftpConnect.changeDirectory(uploadPath);
      String name =
          '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
      File file = await _image.copy('$appDocPath/$name.jpeg');
      String imageName =
          'faarunApp/moneyTransfer/$folderName/$subFolderName/$name.jpeg';
      req.fields['ImageSlip'] = '$imageName';
      isUpload = await ftpConnect.uploadFileWithRetry(file, pRetryCount: 2);
      await ftpConnect.disconnect();
    }

    if (isUpload) {
      print('isUpload รูป');
      print('${req}');
      req.send().then((value) {
        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");

        percentage = percentage + 30.0;
        pr.update(progress: percentage, message: "ส่งข้อมูล...");

        http.Response.fromStream(value).then((res) {
          if (res.statusCode == 200) {
            print(jsonDecode(res.body));
          } else {
            print(res.body);
          }
          Future.delayed(Duration(seconds: 2)).then((value) {
            pr.update(progress: percentage, message: "ส่งข้อมูลเสร็จแล้ว...");
            pr.hide().then((value) {
              // locator<NavigationService>().moveWithArgsTo(
              //     'moneyTransfer', ScreenArguments(userId: widget.userId));
              Navigator.pop(context, 'โอนเงินเสร็จแล้ว');
            });
          });

          percentage = 0.0;
        });
      });
    } else {
      pr.update(
          progress: percentage,
          message: "ส่งข้อมูลล้มเหลว กรุณาลองใหม่ในภายหลัง");
      pr.hide().then((value) {
        Navigator.pop(context, 'โอนเงินเสร็จแล้ว');
        // locator<NavigationService>().moveWithArgsTo(
        //     'moneyTransfer', ScreenArguments(userId: widget.userId));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Text(
                'แจ้งโอนเงินสด',
                style: TextStyle(fontSize: 24, color: kPrimaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 130,
                        child: Card(
                          elevation: 2.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                    child: Text(
                                  'โอนไปที่',
                                  style: TextStyle(fontSize: 20),
                                )),
                                Text('ธนาคารกรุงเทพฯ สาขาบ่อพลอยนิวกรุงไทย',
                                    style: TextStyle(fontSize: 20)),
                                Text('บัญชีเลขที่ : 441-7-05287-7',
                                    style: TextStyle(fontSize: 20)),
                                Text('ชื่อบัญชี : บจ.แลนด์กรีนอะโกร',
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 130,
                        child: Card(
                          elevation: 2.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('ทั้งหมด', style: TextStyle(fontSize: 20)),
                                Text(
                                    '${f.SeperateNumber(widget.sumMoney.toString())}',
                                    style: TextStyle(
                                        fontSize: 20, color: kPrimaryColor))
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if (_image != null)
                SizedBox(
                  height: 200,
                  child: Image.file(
                    _image,
                    fit: BoxFit.cover,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                          icon: Icon(Icons.photo_camera),
                          onPressed: () => pickImage(true)),
                      Text('ถ่ายภาพ')
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          icon: Icon(Icons.photo_library),
                          onPressed: () => pickImage(false)),
                      Text('เลือกรูปภาพ')
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                text: 'แจ้งโอนเงิน',
                onPress: () async {
                  if (_image == null) {
                    ShowModalBottom().alertDialog(context, 'กรุณาแนบสลิป');
                  } else {
                    await submit();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TransferHistoryResult {
  int iD;
  int status;
  var remark;
  int money;
  int moneyTotal;
  String img;

  TransferHistoryResult(
      {this.iD,
      this.status,
      this.remark,
      this.money,
      this.moneyTotal,
      this.img});

  TransferHistoryResult.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    status = json['Status'];
    remark = json['Remark'];
    money = json['Money'];
    moneyTotal = json['Money_total'];
    img = json['image'];
  }
}

class MoneyTransferResult {
  int billId;
  String billNumber;
  int moneyTotal;
  int moneyEarnest;
  int payType;
  String saleName;
  String saleSurname;
  String receiptNumber;
  int receiptId;
  int status;
  Null consignUserId;
  String orderDetail;
  String customerName;
  String customerSurname;
  int userId;

  bool selected;

  MoneyTransferResult({
    this.billId,
    this.billNumber,
    this.moneyTotal,
    this.moneyEarnest,
    this.payType,
    this.saleName,
    this.saleSurname,
    this.receiptNumber,
    this.receiptId,
    this.status,
    this.consignUserId,
    this.orderDetail,
    this.customerName,
    this.customerSurname,
    this.userId,
    this.selected,
  });

  MoneyTransferResult.fromJson(Map<String, dynamic> json) {
    billId = json['Bill_id'];
    billNumber = json['Bill_number'];
    moneyTotal = json['Money_total'];
    moneyEarnest = json['Money_earnest'];
    payType = json['Pay_type'];
    saleName = json['Sale_name'];
    saleSurname = json['Sale_surname'];
    receiptNumber = json['Receipt_number'];
    receiptId = json['Receipt_id'];
    status = json['Status'];
    consignUserId = json['Consign_user_id'];
    orderDetail = json['Order_detail'];
    customerName = json['Customer_name'];
    customerSurname = json['Customer_surname'];
    userId = json['User_id'];
    selected = false;
  }
}
