import 'dart:convert';
import 'dart:io';

import 'package:alert_dialog/alert_dialog.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/header_text.dart';
import 'package:system/components/square_input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:system/configs/constants.dart';

class ShowBill extends StatefulWidget {
  final int userId;

  const ShowBill({Key key, this.userId}) : super(key: key);

  @override
  _ShowBillState createState() => _ShowBillState();
}

class _ShowBillState extends State<ShowBill> {
  Future<List<BillOnline>> _onlineResult;
  Future<List<BillOnline>> _offlineResult;
  List<BillOnline> _offline = [];
  List _result;
  var _contextGolbal;

  var client = http.Client();
  var _user;
  FormatMethod f = FormatMethod();
  Map<String, dynamic> comData = {
    'cashSumCat1_590': 0,
    'cashSumCat1_690': 0,
    'cashSumCat2': 0,
    'cashSumMoney': 0,
    'creditSumCat1_590': 0,
    'creditSumCat1_690': 0,
    'creditSumCat2': 0,
    'creditSumMoney': 0,
    'creditWaitSumCat1_590': 0,
    'creditWaitSumCat1_690': 0,
    'creditWaitSumCat2': 0,
    'creditWaitSumMoney': 0,
  };
  Widget testImage;
  DateTimeRange initDateTimeRange;
  DateTimeRange defaultDateTimeRange;
  var _dateRange = TextEditingController();
  var _search = TextEditingController();
  var isFirst = 1;

  Future<Null> getUserAll() async {
    var user = await Sqlite().getUserAll();
    _user = user.toList();
  }

  Future<Null> getData({String startDate = '', String endDate = ''}) async {
    var result = await Sqlite()
        .getBill(widget.userId, selectStart: startDate, selectEnd: endDate);
    _result = result.toList();
    print('result ----> ${_result.length}');
    if (_result.length > 0) {}
    if (mounted) setState(() {});
  }

  Future<Null> genRowOffline() async {
    // print('get bill offline');
    // print('result ----> ${_result.length}');
    _offlineResult = parseResults(jsonEncode(_result));
    // print('_offlineResult ----> ${_offlineResult}');
    // print('_offline ----> ${_offline}');
    _offline.clear();
    // print('_offline ----> ${_offline}');
    _offline.addAll(await _offlineResult);
    // print(_offline);
  }

  Future<Null> _checkSync() async {
    //ถ้า status เป็น 10 15
    //เปลี่ยนเป็น Download Bill
    print('check bill online');
    var result = _result.where((element) => element['isSync'] == 1).toList();
    print(result);
    // var result =
    //     await Sqlite().getBill(widget.userId, where: 'BILL.isSync = 1');
    // var _results = result.toList();
    // List<int> statusToRemove = [6, 7, 8, 9, 10, 12, 13, 14, 15, 16];
    // for (var bill in _results) {
    //   var res = await client.post(
    //       'https://landgreen.ml/system/public/api/getBillCredit',
    //       body: {'billNumber': '${bill['Bill_number']}'}).then((value) async {
    //     if (value.statusCode == 200) {
    //       var dataSet = jsonDecode(value.body);
    //       if (dataSet.isNotEmpty) {
    //         for (var onlineBill in dataSet) {
    //           if (!DateTime.parse(onlineBill['Timestamp'])
    //               .isAtSameMomentAs(DateTime.parse(bill['Timestamp']))) {
    //             if (statusToRemove.contains(bill['Status'])) {
    //               print('Remove bill');
    //               //await Sqlite().deleteBill(bill['ID']);
    //             } else {
    //               print(onlineBill['Timestamp']);
    //               print(bill['Timestamp']);
    //               print('Timestamp not equal update bill');
    //               await Sqlite().updateBill(onlineBill, bill['ID']);
    //             }
    //           }
    //         }
    //       }
    //     }
    //   });
    // }
  }

  Future<Null> uploadContract() async {
    var contract = await Sqlite().getContract(widget.userId);
    if (contract.isNotEmpty) {
      print('upload Contract');
      for (var val in contract) {
        print(val);
        var res = await client.post(
            'https://landgreen.ml/system/public/api/uploadContract',
            body: {
              'Bill_number': val['Bill_number'],
              "Contract_number": val['Contract_number'],
              "User_id": "${val['User_id']}",
              "Image_signature":
                  "data:image/png;base64,${val['Image_signature']}",
              "Signature_date": "${val['Signature_date']}",
              "Image_signature_witness_1":
                  "data:image/png;base64,${val['Image_signature_witness_1']}",
              "Witness_name_1": "${val['Witness_name_1']}",
              "Image_signature_witness_2":
                  "data:image/png;base64,${val['Image_signature_witness_2']}",
              "Witness_name_2": "${val['Witness_name_2']}",
              "Other_name_1": "${val['Other_name_1']}",
              "Other_relationship_1": "${val['Other_relationship_1']}",
              "Other_phone_1": "${val['Other_phone_1']}",
              "Other_name_2": "${val['Other_name_2']}",
              "Other_relationship_2": "${val['Other_relationship_2']}",
              "Other_phone_2": "${val['Other_phone_2']}",
              "Book_number": "${val['Book_number']}",
              "Status": "${val['Status']}",
              "Edit_user_id": "${val['Edit_user_id']}",
            }).then((value) {
          if (value != null) {
            print('UPDATE CONTRACT');
            Sqlite().rawQuery(
                'UPDATE CONTRACT SET Receipt_id = 1 WHERE ID = ${val['ID']}');
            //ลบ Contract offline
          }
        });
      }
    } else {
      print('contract empty');
    }
  }

  Future<Null> uploadReceipt() async {
    print('start upload receipt');
    var receipt = await Sqlite().getReceipt(); //ต้อง loop ก่อน
    // print("receipt -------> ${receipt}");
    if (receipt.isNotEmpty) {
      for (var val in receipt) {
        if (val['isSync'] == 0) {
          var postUri =
              Uri.parse('https://landgreen.ml/system/public/api/uploadReceipt');
          var req = new http.MultipartRequest('POST', postUri);
          http.MultipartFile multipartFile;
          req.fields['Bill_number'] = '${val['Bill_number']}';
          req.fields['Receipt_number'] = '${val['Receipt_number']}';
          req.fields['User_id'] = '${val['User_id']}';
          req.fields['Image_signature'] =
              'data:image/png;base64,${val['Image_signature']}';
          req.fields['Signature_date'] = '${val['Signature_date']}';
          req.fields['Status'] = '${val['Status']}';
          req.fields['Edit_user_id'] = '${val['Edit_user_id']}';
          if (val['Image_receive'] != null) {
            var imgList = jsonDecode(val['Image_receive']);
            for (var img in imgList) {
              multipartFile =
                  await http.MultipartFile.fromPath('Image_receive[]', img);
              req.files.add(multipartFile);
            }
          }
          req
              .send()
              .then((response) {
                http.Response.fromStream(response).then((value) async {
                  if (value.statusCode == 200) {
                    print('update offline receipt ${val['ID']}');
                    // var result = await jsonDecode(value.body);
                    await Sqlite().rawQuery(
                        'UPDATE RECEIPT SET isSync = 1 WHERE ID = ${val['ID']}');
                  } else {
                    print(value.statusCode);
                    print(value.body);
                  }
                });
              })
              .catchError(
                  (err) => print('Fucking error here : ${err.toString()}'))
              .whenComplete(() async {
                print('uploaded receipt');
              });
        }
      }
    } else {
      print('null ja');
    }
  }

  Future<Null> _showDateTimeRange(context) async {
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar;
    String errorInvalidRangeText;

    if (DateTime.now().day == 1) {
      var _yesterday = DateTime.now().subtract(Duration(days: 1));
      print('_yesterday =>${_yesterday}');
      var _yd = _yesterday.day;
      var _ym = _yesterday.month;
      var _yy = _yesterday.year;
      var _d = DateTime.now().day;
      var _m = DateTime.now().month;
      var _y = DateTime.now().year;
      initDateTimeRange = DateTimeRange(
          start: DateTime(_yy, _ym, _yd, 0, 0, 0),
          end: DateTime(_y, _m, _d, 23, 59, 59));
    }
    print("DateTime.now() => ${initDateTimeRange}");

    final DateTimeRange picked = await showDateRangePicker(
      context: context,
      initialDateRange: initDateTimeRange,
      initialEntryMode: initialEntryMode,
      currentDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      errorInvalidRangeText: errorInvalidRangeText,
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
      isFirst = 0;
      _refresh(
          startDate: picked.start.toString().split(' ')[0],
          endDate: picked.end.toString().split(' ')[0]);
    }
  }

  Future _refresh({String startDate = '', String endDate = ''}) async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    print("isConnect -----> ${isConnect}");
    if (isConnect) ServiceUploadAll().uploadALL();
    _search.clear();
    print(1);
    await getData(startDate: startDate, endDate: endDate);
    print(2);
    await genRowOffline();
    print(3);
    if (isConnect) {
      print(4);
      //ถ้าหน้านี้เปิดเน็ตให้ไปดึงบิลออนไลน์มาเก็บไว้ในเครื่อง
      await getSaleCommission(widget.userId);
      print('isFirst ${isFirst}');
      if (isFirst == 0) {
        getOnline(startDate: startDate, endDate: endDate);
      }
    }
    await getCacheSale();

    if (mounted) setState(() {});
    // Future.delayed(const Duration(seconds: 1), () {

    // });
  }

  Future<Null> getOnline({String startDate = '', String endDate = ''}) async {
    AlertNewDesign()
        .showLoading(_contextGolbal, MediaQuery.of(_contextGolbal).size);
    // alert(
    //   _contextGolbal,
    //   title: Text("แจ้งเตือน!!!"),
    //   content: Text(
    //       "หากรายการบิลยังไม่แสดง\nให้เปิดหน้านี้ค้างไว้ประมาณ 2-5 นาที นะครับ\nระบบกำลังดึงข้อมูลบิลมาเก็บไว้ในเครื่องให้อยู่ครับ"),
    // );
    print('getOnline user_id => ${widget.userId}');
    _offline = [];
    _offlineResult = Future.value();
    if (mounted) setState(() {});
    final response = await client
        .post('https://landgreen.ml/system/public/api/getBillOnline', body: {
      'User_id': '${widget.userId}',
      'startDate': startDate,
      'endDate': endDate
    });
    print('getOnline startDate => $startDate');
    print('getOnline endDate => $endDate');
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

    print(parsed.length);
    if (parsed.length > 0) {
      for (var i = 0; i < parsed.length; i++) {
        // print('${parsed[i]}');
        await Sqlite().insertOrUpdateBillFromOnline(parsed[i]);
      }
    }
    Navigator.pop(_contextGolbal);

    // await Future.forEach(parsed, (item) async {
    //   await Sqlite().insertOrUpdateBillFromOnline(item);
    // });
    // await for(var obj in parsed){
    //   await Sqlite().insertOrUpdateBillFromOnline(obj);
    // }

    await getData(startDate: startDate, endDate: endDate);
    await genRowOffline();
    if (mounted) setState(() {});
  }

  Future<Null> getCacheSale() async {
    try {
      var result = await Sqlite().getCommission(widget.userId);
      var dataSet = jsonDecode(result['DataSet']);
      comData = {
        'cashSumCat1_590': dataSet['cash_sumCat1_590'],
        'cashSumCat1_690': dataSet['cash_sumCat1_690'],
        'cashSumCat2': dataSet['cash_sumCat2'],
        'cashSumMoney': dataSet['cash_sumMoneyTotal'],
        'creditSumCat1_590': dataSet['credit_sumCat1_590'],
        'creditSumCat1_690': dataSet['credit_sumCat1_690'],
        'creditSumCat2': dataSet['credit_sumCat2'],
        'creditSumMoney': dataSet['credit_sumMoneyTotal'],
        'creditWaitSumCat1_590': dataSet['credit_wait_sumCat1_590'],
        'creditWaitSumCat1_690': dataSet['credit_wait_sumCat1_690'],
        'creditWaitSumCat2': dataSet['credit_wait_sumCat2'],
        'creditWaitSumMoney': dataSet['credit_wait_sumMoneyTotal'],
      };
    } catch (e) {
      print('ERROR GET CACHE SALE $e');
      setState(() {
        comData = {
          'cashSumCat1_590': 0,
          'cashSumCat1_690': 0,
          'cashSumCat2': 0,
          'cashSumMoney': 0,
          'creditSumCat1_590': 0,
          'creditSumCat1_690': 0,
          'creditSumCat2': 0,
          'creditSumMoney': 0,
          'creditWaitSumCat1_590': 0,
          'creditWaitSumCat1_690': 0,
          'creditWaitSumCat2': 0,
          'creditWaitSumMoney': 0,
        };
      });
    }
  }

  Future genRowOnline() async {
    print('get bill online');
    _onlineResult = fetchResult(http.Client());
    // print('_onlineResult =>${_onlineResult}');
    setState(() {});
  }

  Future getSaleCommission(int userId) async {
    try {
      print('get and insert SaleCommission');
      var res = await client.post(
          'https://landgreen.ml/system/public/api/SaleCommission',
          body: {'filename': '$userId'});
      var dataSet = res.body;
      if (dataSet != '') {
        Sqlite().insertCommission(userId, dataSet);
      }
    } catch (e) {
      print('ERROR GET SALE COMMISSION $e');
    }
  }

  Future<Null> resetBill() async {
    //await Sqlite().rawQuery('DELETE FROM CONTRACT WHERE 1');
    // await client.post(
    //   'https://landgreen.ml/system/public/api/reset',
    // );
    await Sqlite().rawQuery('DELETE FROM RECEIPT WHERE 1');
    await Sqlite().rawQuery('DELETE FROM BILL WHERE 1');
    await Sqlite().rawQuery('DELETE FROM CONTRACT WHERE 1');
    // await Sqlite().rawQuery('DELETE FROM CUSTOMER WHERE 1');
    // await Sqlite().rawQuery('UPDATE BILL SET Status = 1 WHERE Pay_type = 1');
    // await Sqlite().rawQuery('UPDATE BILL SET Status = 2 WHERE Pay_type = 2');
  }

  Future<List<BillOnline>> fetchResult(http.Client client) async {
    final response = await client.post(
        'https://landgreen.ml/system/public/api/getBillOnline',
        body: {'User_id': '${widget.userId}'});

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<BillOnline>((json) => BillOnline.fromJson(json)).toList();
    // Use the compute function to run parseResults in a separate isolate
    //return compute(parseResults, response.body);
  }

  Future<List<BillOnline>> parseResults(String resBody) async {
    final parsed = jsonDecode(resBody).cast<Map<String, dynamic>>();
    return await parsed
        .map<BillOnline>((json) => BillOnline.fromJson(json))
        .toList();
  }

  void filterResult(String query) async {
    List<BillOnline> dummySearchList = [];
    dummySearchList.addAll(await _offlineResult);
    if (query.isNotEmpty) {
      List<BillOnline> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.customerName.contains(query) ||
            item.customerSurname.contains(query) ||
            item.billNumber.contains(query) ||
            item.moneyTotal.toString().contains(query) ||
            (item.receiptNumber != null &&
                item.receiptNumber.contains(query))) {
          dummyListData.add(item);
        }
      });
      _offline.clear();
      _offline.addAll(dummyListData);
      setState(() {});
      return;
    } else {
      _offline.clear();
      _offline.addAll(await _offlineResult);
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    DateTime n = DateTime.now();
    initDateTimeRange = DateTimeRange(
        start: DateTime(n.year, n.month),
        end: DateTime(n.year, n.month, n.day));
    defaultDateTimeRange = initDateTimeRange;
    _dateRange.text = 'ข้อมูลประจำเดือนนี้';
    getUserAll();

    if (n.day == 1) {
      var _startDate = DateTime(n.year, n.month, 1, 0, 0, 0);
      int lastday = DateTime(n.year, n.month + 1, 0).day;
      var _endDate = DateTime(n.year, n.month, lastday, 23, 59, 59);
      if (DateTime.now().day == 1) {
        print('วันที่  1 ');
        //วันที่ 1 ให้เอาบิลของเดือนที่แล้วมาโชว์
        _startDate = DateTime(n.year, n.month - 1, 1, 0, 0, 0);
        int lastdaypreiousmonth = DateTime(n.year, n.month, 0).day;
        _endDate = DateTime(n.year, n.month, lastdaypreiousmonth, 23, 59, 59);
      }
      _refresh(startDate: _startDate.toString(), endDate: _endDate.toString());
    } else {
      _refresh();
    }

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _contextGolbal = context;
    Size size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
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
                  title: Text('ข้อมูลบิล'),
                ),
              ),
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () async {
              //     //_showDateTimeRange(context);
              //
              //     //_refresh(startDate: '2020-12-01', endDate: '2020-12-24');
              //
              //     //await resetBill();
              //
              //     Sqlite().rawQuery('UPDATE BILL SET Status = 1 WHERE Pay_type = 1');
              //     Sqlite().rawQuery('UPDATE BILL SET Status = 2 WHERE Pay_type = 2');
              //     Sqlite().rawQuery('DELETE FROM RECEIPT WHERE 1');
              //     Sqlite().rawQuery('UPDATE BILL SET isSync = 0 WHERE 1');
              //   },
              //   elevation: 2.0,
              //   child: Icon(
              //     Icons.refresh,
              //     color: Colors.white,
              //   ),
              // ),
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: Container(
                  width: size.width,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 24.0, left: 16.0, right: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //SizedBox(height: 400,child: testImage,),
                              Card(
                                child: Column(
                                  children: [
                                    HeaderText(
                                      text: 'สรุปยอดขาย เงินสด / ประจำเดือนนี้',
                                      textSize: 20,
                                      gHeight: 26,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ยอดขายเงินสดรวม',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['cashSumMoney'])} บาท',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                '(${f.SeperateNumber(comData['cashSumCat1_590'] + comData['cashSumCat1_690'])} กระสอบ)',
                                                style:
                                                    TextStyle(fontSize: 16.0)),
                                          ),
                                          MyDivider(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ขายปุ๋ยราคา 590 ได้',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['cashSumCat1_590'])} กระสอบ',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ขายปุ๋ยราคา 690 ได้',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['cashSumCat1_690'])} กระสอบ',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ขายฮอร์โมนได้',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['cashSumCat2'])} ขวด',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: 10,
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    HeaderText(
                                      text: 'สรุปยอดขาย เครดิต / ประจำเดือนนี้',
                                      textSize: 20,
                                      gHeight: 26,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ยอดขายเครดิตรวม',
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['creditWaitSumMoney'])} บาท',
                                                  style:
                                                      TextStyle(fontSize: 20.0))
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                '(${f.SeperateNumber(comData['creditWaitSumCat1_590'] + comData['creditWaitSumCat1_690'])} กระสอบ)',
                                                style:
                                                    TextStyle(fontSize: 16.0)),
                                          ),
                                          MyDivider(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ขายปุ๋ยราคา 590 ได้',
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['creditWaitSumCat1_590'])} กระสอบ',
                                                  style:
                                                      TextStyle(fontSize: 18.0))
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'ขายปุ๋ยราคา 690 ได้',
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['creditWaitSumCat1_690'])} กระสอบ',
                                                  style:
                                                      TextStyle(fontSize: 18.0))
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'รอลูกค้าชำระ',
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                              ),
                                              Text(
                                                  '${f.SeperateNumber(comData['creditWaitSumCat1_590'] + comData['creditWaitSumCat1_690'])} กระสอบ',
                                                  style:
                                                      TextStyle(fontSize: 18.0))
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              MyDivider(),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: size.height * 0.6,
                                // color: darkColor,
                                child: Card(
                                  // color: darkColor,
                                  child: FutureBuilder(
                                    future: _offlineResult,
                                    builder: (context, data) {
                                      print('data.has=>${data.hasData}');
                                      if (data.hasData) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showDateTimeRange(context);
                                              },
                                              child: AbsorbPointer(
                                                child: ClipRRect(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        color:
                                                            kPrimaryLightColor,
                                                        width: 6,
                                                        height: 26,
                                                      ),
                                                      Expanded(
                                                        child: Stack(children: [
                                                          Container(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      8,
                                                                      1,
                                                                      8,
                                                                      1),
                                                              child: TextField(
                                                                controller:
                                                                    _dateRange,
                                                                decoration:
                                                                    InputDecoration(
                                                                  // labelText:'ข้อมูล ณ วันที่',
                                                                  hintText:
                                                                      'ข้อมูลประจำเดือนนี้',
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              0.0),
                                                                  isDense: true,
                                                                ),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                            color:
                                                                backgroudBarColor,
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: Container(
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_drop_down_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size: 28,
                                                              ),
                                                            ),
                                                          )
                                                        ]),
                                                      ),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(1),
                                                ),
                                              ),
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Text(
                                            //       'รายละเอียดยอดขาย',
                                            //       style: TextStyle(
                                            //         fontSize: 24,
                                            //       ),
                                            //     ),
                                            //     // Text(
                                            //     //   ' (OFFLINE)',
                                            //     //   style: TextStyle(
                                            //     //       fontSize: 24,
                                            //     //       color: Colors.redAccent),
                                            //     // )
                                            //   ],
                                            // ),
                                            // GestureDetector(
                                            //     onTap: () {
                                            //       _showDateTimeRange(context);
                                            //     },
                                            //     child: AbsorbPointer(
                                            //       child: TextField(
                                            //           controller: _dateRange,
                                            //           decoration: InputDecoration(
                                            //               labelText:
                                            //                   'ข้อมูล ณ วันที่',
                                            //               hintText:
                                            //                   'ข้อมูลประจำวันที่',
                                            //               prefixIcon:
                                            //                   Icon(Icons.search),
                                            //               filled: true,
                                            //               isDense: true,
                                            //               fillColor: Colors.white,
                                            //               border: OutlineInputBorder(
                                            //                   borderRadius:
                                            //                       BorderRadius.all(
                                            //                           Radius.circular(
                                            //                               25))))),
                                            //     )),
                                            // TextField(
                                            //     onChanged: (value) =>
                                            //         filterResult(value),
                                            //     controller: _search,
                                            //     decoration: InputDecoration(
                                            //         labelText: 'Search',
                                            //         hintText: 'Search',
                                            //         prefixIcon: Icon(Icons.search),
                                            //         suffixIcon: IconButton(
                                            //             icon: Icon(Icons.close),
                                            //             onPressed: () {
                                            //               node.unfocus();
                                            //               _search.clear();
                                            //               filterResult('');
                                            //             }),
                                            //         filled: true,
                                            //         isDense: true,
                                            //         fillColor: Colors.white,
                                            //         border: OutlineInputBorder(
                                            //             borderRadius:
                                            //                 BorderRadius.all(
                                            //                     Radius.circular(
                                            //                         25))))),
                                            Expanded(
                                              child: (_offline.length != 0)
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          _offline == null
                                                              ? 0
                                                              : _offline.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        var result =
                                                            _offline[index];
                                                        print(
                                                            '_offline.length ${_offline.length}');
                                                        return ShowBillOnline(
                                                            result,
                                                            f,
                                                            widget.userId,
                                                            _user,
                                                            false);
                                                      },
                                                    )
                                                  : Center(
                                                      child: Container(
                                                        width:
                                                            size.width * 0.98,
                                                        height:
                                                            size.height * 0.42,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                "assets/img/bgAlert.png"),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.28,
                                                              child: Image.asset(
                                                                  "assets/icons/icon_alert.png"),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 15),
                                                              child: Text(
                                                                "ไม่มีข้อมูลที่ท่านเรียก",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 28,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5),
                                                              child: Text(
                                                                "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้เปิดบิล ไม่ได้ออกใบเสร็จ\nหรือ ไม่ได้ออกแจกสินค้าทดลอง ในวันเวลา\nดังกล่าวที่คุณเลือกมานี้",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    color: Colors
                                                                        .white,
                                                                    height: 1),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        );
                                      } else if (data.hasError) {
                                        return Center(child: ShimmerLoading());
                                      } else {
                                        return Center(child: ShimmerLoading());
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              // Container(
                              //   height: size.height * 0.6,
                              //   child: Card(
                              //     color: darkColor,
                              //     child: FutureBuilder(
                              //       future: _onlineResult,
                              //       builder: (context, data) {
                              //         if (data.hasData) {
                              //           return Container(
                              //               padding: EdgeInsets.symmetric(
                              //                   vertical: 16.0, horizontal: 16),
                              //               child: Column(
                              //                 children: [
                              //                   Row(
                              //                     children: [
                              //                       Text(
                              //                         'รายละเอียดยอดขาย',
                              //                         style: TextStyle(
                              //                             fontSize: 24,
                              //                             color: Colors.white),
                              //                       ),
                              //                       Text(
                              //                         ' (ONLINE)',
                              //                         style: TextStyle(
                              //                             fontSize: 24,
                              //                             color: kPrimaryColor),
                              //                       )
                              //                     ],
                              //                   ),
                              //                   Expanded(
                              //                     child: ListView.builder(
                              //                       shrinkWrap: true,
                              //                       scrollDirection: Axis.vertical,
                              //                       itemCount: data.data.length,
                              //                       itemBuilder: (BuildContext context,
                              //                           int index) {
                              //                         var result = data.data[index];
                              //                         return ShowBillOnline(result, f,
                              //                             widget.userId, _user, true);
                              //                       },
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ));
                              //         } else if (data.hasError) {
                              //           print(data.error);
                              //           return Center(child: CircularProgressIndicator());
                              //         } else {
                              //           return Center(child: CircularProgressIndicator());
                              //         }
                              //       },
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 30,
                              // ),
                            ],
                          ),
                        ),
                        Footer(),
                      ],
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

class BillOnline {
  int iD;
  String billNumber;
  var userId;
  var customerId;
  var payType;
  var moneyTotal;
  var moneyEarnest;
  var moneyDue;
  String dateSend;
  var dateDue;
  var datePay;
  var status;
  var commissionPay;
  var commissionSum;
  var commissionPaydate;
  String imageSignature;
  String signatureDate;
  int editUserId;
  String timestamp;
  String orderDetail;
  var creditTermId;
  var salesProvinceId;
  String dateCreate;
  var consignUserId;
  var remark;
  var idheadsale;
  var idcredit;
  var billLocation;
  var saleWorkCarId;
  var statusAppPuiya;
  var openInvoice;
  var creditChange15;
  var creditUserId;
  String receiptNumber;
  var receiptStatus;
  var receiptId;
  String customerName;
  String saleName;
  String customerSurname;
  int isSync;
  int receiptSync;

  BillOnline(
      {this.iD,
      this.billNumber,
      this.userId,
      this.customerId,
      this.payType,
      this.moneyTotal,
      this.moneyEarnest,
      this.moneyDue,
      this.dateSend,
      this.dateDue,
      this.datePay,
      this.status,
      this.commissionPay,
      this.commissionSum,
      this.commissionPaydate,
      this.imageSignature,
      this.signatureDate,
      this.editUserId,
      this.timestamp,
      this.orderDetail,
      this.creditTermId,
      this.salesProvinceId,
      this.dateCreate,
      this.consignUserId,
      this.remark,
      this.idheadsale,
      this.idcredit,
      this.billLocation,
      this.saleWorkCarId,
      this.statusAppPuiya,
      this.openInvoice,
      this.creditChange15,
      this.creditUserId,
      this.receiptNumber,
      this.receiptStatus,
      this.receiptId,
      this.customerName,
      this.saleName,
      this.customerSurname,
      this.receiptSync,
      this.isSync});

  BillOnline.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    billNumber = json['Bill_number'];
    userId = json['User_id'];
    customerId = json['Customer_id'];
    payType = json['Pay_type'];
    moneyTotal = json['Money_total'];
    moneyEarnest = json['Money_earnest'];
    moneyDue = json['Money_due'];
    dateSend = json['Date_send'];
    dateDue = json['Date_due'];
    datePay = json['Date_pay'];
    status = json['Status'];
    commissionPay = json['Commission_pay'];
    commissionSum = json['Commission_sum'];
    commissionPaydate = json['Commission_paydate'];
    imageSignature = json['Image_signature'];
    signatureDate = json['Signature_date'];
    editUserId = (json['Edit_user_id'] == 'null')?json['User_id']:json['Edit_user_id'];
    timestamp = json['Timestamp'];
    orderDetail = json['Order_detail'];
    creditTermId = json['Credit_term_id'];
    salesProvinceId = json['Sales_province_id'];
    dateCreate = json['Date_create'];
    consignUserId = json['Consign_user_id'];
    remark = json['Remark'];
    idheadsale = json['idheadsale'];
    idcredit = json['idcredit'];
    billLocation = json['bill_location'];
    saleWorkCarId = json['Sale_work_car_id'];
    statusAppPuiya = json['Status_app_puiya'];
    openInvoice = json['Open_invoice'];
    creditChange15 = json['Credit_change15'];
    creditUserId = json['Credit_user_id'];
    receiptNumber = json['Receipt_number'];
    receiptStatus = json['Receipt_status'];
    receiptId = json['Receipt_id'];
    customerName = json['Customer_name'];
    customerSurname = json['Customer_surname'];
    saleName = json['Sale_name'];
    receiptSync = json['ReceiptSync'];
    isSync = json['isSync'];
  }
}

class ShowBillOnline extends StatefulWidget {
  final BillOnline result;
  final FormatMethod f;
  final int userId;
  final List user;
  final bool isOnline;

  ShowBillOnline(
      BillOnline result, this.f, this.userId, this.user, this.isOnline)
      : result = result,
        super(key: ObjectKey(result));

  @override
  _ShowBillOnlineState createState() =>
      _ShowBillOnlineState(result, f, userId, user, isOnline);
}

class _ShowBillOnlineState extends State<ShowBillOnline> {
  final BillOnline result;
  final FormatMethod f;
  final int userId;
  final List _user;
  final bool isOnline;

  _ShowBillOnlineState(
      this.result, this.f, this.userId, this._user, this.isOnline);

  getSale(var userId) {
    var consignName = _user.firstWhere((element) => element['ID'] == userId);
    return consignName['Name'];
  }

  Widget _receiptSyncStatus() {
    var status = result.receiptSync;
    switch (status) {
      case 0:
        return Text(
          '(ยังไม่ได้ส่ง)',
          style: TextStyle(fontSize: 16, color: danger),
        );
        break;
      case 1:
        return Text('(เข้าคิวแล้วกำลังส่ง)',
            style: TextStyle(fontSize: 16, color: kSecondaryColor));
        break;
      case 2:
        return Text('(ส่งเสร็จแล้ว)',
            style: TextStyle(fontSize: 16, color: kPrimaryColor));
        break;
      default:
        return Text('(ส่งเสร็จแล้ว)',
            style: TextStyle(fontSize: 16, color: kPrimaryColor));
    }
  }

  Widget _billSyncStatus() {
    var status = result.isSync;
    var statusBill = result.status;
    switch (status) {
      case 0:
        var _string = (statusBill == 0)
            ? '(ระบบไม่นำส่งบิลยังไม่สมบูรณ์)'
            : '(อยู่ในเครื่องรอเข้าคิว ดึงรีเฟสเพื่อส่งบิล)';
        return Text(
          _string,
          style: TextStyle(fontSize: 16, color: danger),
        );
        break;
      case 1:
        return Text('(เข้าคิวแล้วรอเข้าเซิฟเวอร์ ธุรการยังไม่เห็นบิล)',
            style: TextStyle(fontSize: 16, color: Color(0xF9AB00)));
        break;
      case 2:
        return Text('(ส่งเสร็จแล้วอยู่ในเซิฟเวอร์แล้ว ธุรการยังเห็นบิลแล้ว)',
            style: TextStyle(fontSize: 16, color: kPrimaryColor));
        break;
      default:
        return Text('(ส่งเสร็จแล้วอยู่ในเซิฟเวอร์แล้ว ธุรการยังเห็นบิลแล้ว)',
            style: TextStyle(fontSize: 16, color: kPrimaryColor));
    }
  }

  Widget _status() {
    var _sizeFont = 20.0;
    var status = result.status;
    var consignUserId = result.consignUserId;
    var payType = result.payType;
    String message = '';
    switch (status) {
      case 0:
        message = '';
        if (consignUserId != null) {
          message = 'ฝากส่งแล้ว';
        }

        return Text(
          'ยังไม่เซ็นยืนยันสั่งจอง $message',
          style: TextStyle(color: Colors.redAccent, fontSize: _sizeFont),
        );
        break;
      case 1:
        message = '';
        if (consignUserId != null) {
          if (consignUserId == userId) {
            message = 'ฝากส่งจาก ${getSale(result.userId)}';
          }
        }
        return Text(
          'สั่งจองเรียบร้อย $message',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 2:
        return Text(
          'รอสินเชื่ออนุมัติ',
          style: TextStyle(color: Colors.redAccent, fontSize: _sizeFont),
        );
        break;
      case 3:
        return Text(
          'รอสินเซ็นรับสินค้า',
          style: TextStyle(color: Colors.blue, fontSize: _sizeFont),
        );
        break;
      case 4:
        return Text(
          'รอหัวหน้าทีม แจ้งโอนเงิน',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 5:
        return Text(
          'สินเชื่ออนุมัติแล้ว รอออกใบเสร็จ',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 6:
        return Text(
          'สินเชื่อไม่อนุมัติ',
          style: TextStyle(color: Colors.black, fontSize: _sizeFont),
        );
        break;
      case 7:
        return Text(
          'รอรับคอมมิชชั่น',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 8:
        return Text(
          'รอบัญชี ตรวจสอบเงินโอน',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 9:
        return Text(
          'รอรับคอมมิชชั่น (รอลูกค้าชำระยอดคงเหลือ)',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 10:
        return Text(
          'รับคอมมิชชั่นเรียบร้อย',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 11:
        if (payType == 1) {
          return Text(
            'ธุรการแก้ไขบิล',
            style: TextStyle(color: Colors.redAccent, fontSize: _sizeFont),
          );
        } else {
          return Text(
            'สินเชื่อแก้ไขบิล',
            style: TextStyle(color: Colors.redAccent, fontSize: _sizeFont),
          );
        }
        break;
      case 12:
        return Text(
          'สินเชื่อปิดบิล (ลูกค้าชำระเกิน2เดือน)',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 13:
        return Text(
          'ฝ่ายติดตามหนี้ปิดบิล (ไม่ได้รับคอมมิชชั่น)',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 14:
        return Text(
          'ทนายปิดบิล (ไม่ได้รับคอมมิชชั่น)',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 15:
        return Text(
          'สินเชื่อปิดบิล (ลูกค้าชำระเกิน3เดือน)',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
      case 16:
        return Text(
          'บัญชีปิดบิล',
          style: TextStyle(color: kPrimaryColor, fontSize: _sizeFont),
        );
        break;
    }
  }

  void showModal(context) {
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
                                    FontAwesomeIcons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    print(result);
                                    Navigator.pop(context);
                                    locator<NavigationService>().navigateTo(
                                        'createBill',
                                        ScreenArguments(
                                            userId: userId,
                                            billId: result.iD,
                                            isBillOnline: isOnline));
                                  })),
                          Text(
                            'ดูบิล',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                      if (result.receiptId != null)
                        Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber),
                                child: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.receipt,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      print(
                                          'showReceipt isOnline=>${isOnline}');
                                      print('billId => ${result.iD}');
                                      print('BilluserId => ${userId}');
                                      print('receiptId => ${result.receiptId}');
                                      Navigator.pop(context);
                                      locator<NavigationService>().navigateTo(
                                          'createReceipt',
                                          ScreenArguments(
                                              billId: result.iD,
                                              userId: userId,
                                              isBillOnline: isOnline,
                                              receiptId: result.receiptId));
                                    })),
                            Text(
                              'ดูใบเสร็จ',
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      if ([0, 1, 5, 3].contains(result.status) && !isOnline)
                        _button(bc)
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _button(context) {
    if (result.status == 0) {
      return Row(
        children: [
          // Column(
          //   children: [
          //     Container(
          //         decoration: BoxDecoration(
          //             shape: BoxShape.circle, color: Colors.amber),
          //         child: IconButton(
          //             icon: Icon(
          //               FontAwesomeIcons.tasks,
          //               color: Colors.white,
          //             ),
          //             onPressed: () {})),
          //     Text(
          //       'ฝากส่ง',
          //       style: TextStyle(fontSize: 18),
          //     )
          //   ],
          // ),
          // SizedBox(
          //   width: 10,
          // ),
          Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.redAccent),
                  child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        locator<NavigationService>().navigateTo(
                            'createBill',
                            ScreenArguments(
                                userId: userId,
                                billId: result.iD,
                                editStatus: 0,
                                isBillOnline: isOnline));
                      })),
              Text(
                'แก้ไข ใบสั่งจอง',
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ],
      );
    } else if (result.status == 1 || result.status == 5) {
      return Column(
        children: [
          Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
              child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.receipt,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    locator<NavigationService>().navigateTo(
                        'createReceipt',
                        ScreenArguments(
                            billId: result.iD,
                            userId: userId,
                            isBillOnline: isOnline));
                  })),
          Text(
            'ออกใบเสร็จ',
            style: TextStyle(fontSize: 18),
          )
        ],
      );
    } else if (result.status == 3) {
      return Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.redAccent),
              child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.tasks,
                    color: Colors.white,
                  ),
                  onPressed: () {})),
          Text(
            'แก้ไขใบเสร็จ',
            style: TextStyle(fontSize: 18),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0.0),
      child: GestureDetector(
        onTap: () {
          showModal(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, bottom: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    'ชื่อลูกค้า  ${result.customerName} ${result.customerSurname}',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ประเภทบิล',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'บิล${result.payType == 2 ? 'เครดิต' : 'เงินสด'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        // result.payType == 2
                        //     ? Icon(
                        //         Icons.monetization_on,
                        //         color: Colors.amberAccent,
                        //         size: 36,
                        //       )
                        //     : Icon(
                        //         Icons.monetization_on_outlined,
                        //         color: kPrimaryColor,
                        //         size: 36,
                        //       ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ยอดขาย',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${f.SeperateNumber(result.moneyTotal.toString().split('.')[0])}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        // Column(
                        //   children: [
                        //     Container(
                        //         padding: EdgeInsets.all(4.0),
                        //         decoration: BoxDecoration(
                        //             shape: BoxShape.circle, color: kPrimaryColor),
                        //         child: Icon(
                        //           Icons.attach_money,
                        //           color: Colors.white,
                        //         )),
                        //   ],
                        // ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'สถานะ',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _status(),
                        ),
                        // Column(
                        //   children: [
                        //     Container(
                        //         padding: EdgeInsets.all(4.0),
                        //         decoration: BoxDecoration(
                        //             shape: BoxShape.circle, color: kPrimaryColor),
                        //         child: Icon(
                        //           Icons.view_module,
                        //           color: Colors.white,
                        //         )),
                        //   ],
                        // ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                        // Text(
                        //   'สถานะ : ',
                        //   style: TextStyle(fontSize: 18),
                        // ),
                        // _status()
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              'เลขที่ใบสั่งจอง',
                              style: TextStyle(fontSize: 20),
                            )),
                        Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${result.billNumber}',
                                  style: TextStyle(fontSize: 20),
                                ),
                                _billSyncStatus()
                              ],
                            ))
                        // Column(
                        //   children: [
                        //     Container(
                        //         padding: EdgeInsets.all(4.0),
                        //         decoration: BoxDecoration(
                        //             shape: BoxShape.circle, color: kPrimaryColor),
                        //         child: Icon(
                        //           Icons.view_module,
                        //           color: Colors.white,
                        //         )),
                        //   ],
                        // ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text.rich(TextSpan(
                        //         text: 'เลขที่ใบสั่งจอง : ',
                        //         style: TextStyle(fontSize: 18),
                        //         children: [
                        //           TextSpan(
                        //               text: '${result.billNumber}',
                        //               style: TextStyle(
                        //                   fontSize: 18, color: kPrimaryColor))
                        //         ])),
                        //     _billSyncStatus()
                        //   ],
                        // ),
                      ],
                    ),
                    if (result.receiptId != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                'เลขที่ใบเสร็จ',
                                style: TextStyle(fontSize: 20),
                              )),
                          Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${result.receiptNumber}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  _billSyncStatus()
                                ],
                              ))
                          // Column(
                          //   children: [
                          //     Container(
                          //         padding: EdgeInsets.all(4.0),
                          //         decoration: BoxDecoration(
                          //             shape: BoxShape.circle,
                          //             color: kPrimaryColor),
                          //         child: Icon(
                          //           Icons.view_module,
                          //           color: Colors.white,
                          //         )),
                          //   ],
                          // ),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text.rich(TextSpan(
                          //         text: 'เลขที่ใบเสร็จ : ',
                          //         style: TextStyle(fontSize: 20),
                          //         children: [
                          //           TextSpan(
                          //               text: '${result.receiptNumber}',
                          //               style: TextStyle(
                          //                   fontSize: 18, color: kPrimaryColor))
                          //         ])),
                          //     _receiptSyncStatus()
                          //   ],
                          // ),
                        ],
                      ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                  ],
                ),
              ),
              MyDivider(
                paddingTop: 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({
    Key key,
    this.text,
    this.icon,
  }) : super(key: key);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon),
        SizedBox(
          width: 10,
        ),
        Text(text)
      ],
    );
  }
}
