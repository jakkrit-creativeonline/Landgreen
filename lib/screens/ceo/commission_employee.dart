import 'dart:convert';


import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;


class CommissionEmployee extends StatefulWidget {
  @override
  _CommissionEmployeeState createState() => _CommissionEmployeeState();
}

class _CommissionEmployeeState extends State<CommissionEmployee> {

  FormatMethod f = FormatMethod();
  Future<bool> isLoaded;
  Future<List> _listCommissionPay;
  Future<List> _listCommissionPayDebt;
  List  _userDebt =[];
  List  _userCredit =[];

  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  String selectedMonth = '';
  String startDate ='';
  String endDate='';

  int sum_customer_receive,
      cat1_qty_bill_received,
      sum_customer_receiveDebt,
      cat1_qty_bill_receivedDebt;


  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();
  @override
  void initState() {
    // _userId = widget.userId;

    super.initState();
    getData();

  }



  getData() async{
    selectedMonth = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
    var year = '${initDate.toString().split('-')[0]}';
    var month = '${initDate.toString().split('-')[1]}';

    var res = await Sqlite().getJson('COMMISSION_HISTORY', selectedMonth);
    _listCommissionPay = Future.value();

    if (res != null ) {
      List data = jsonDecode(res['JSON_VALUE']);
      _listCommissionPay = Future.value(data);
      await CalculateData();
      // setState(() {});
    } else {

      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-commission',
              body: {
                'func': 'get_commission_employee_forapp',
                'year': year,
                'month':month
              }
          );
          print('res =>${res}');
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('COMMISSION_HISTORY', selectedMonth, res.body);

            List data = jsonDecode(res.body);
            _listCommissionPay = Future.value(data);
            Navigator.pop(context);
            await CalculateData();

            // setState(() {});

            // return data;
          }
        } catch (e) {
          print('error $e');
          setState(() {});
          // return [];
          _listCommissionPay =Future.value([]);
          setState(() {});

        }

      }
    }

    var resDebt = await Sqlite().getJson('COMMISSION_HISTORY_DEBT', selectedMonth);
    _listCommissionPayDebt = Future.value();
    if (resDebt != null ) {
      List dataDebt = jsonDecode(resDebt['JSON_VALUE']);

      _listCommissionPayDebt = Future.value(dataDebt);
      await CalculateDataDebt();
      // setState(() {});
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        try {

          var resDebt = await http.post('$apiPath-commission',
              body: {
                'func': 'get_commission_employee_f_forapp',
                'year': year,
                'month':month
              }
          );
          if (resDebt.statusCode == 200) {
            print('online ->${selectedMonth}');
            Sqlite().insertJson('COMMISSION_HISTORY_DEBT', selectedMonth, resDebt.body);

            List dataDebt = jsonDecode(resDebt.body);
            _listCommissionPayDebt = Future.value(dataDebt);
            await CalculateDataDebt();

          }
        } catch (e) {
          print('error $e');

          _listCommissionPayDebt =Future.value([]);
          setState(() {});
        }

      }
    }

  }

  CalculateData() async{
    cat1_qty_bill_received = 0;
    sum_customer_receive = 0;


    print('CalculateData');
    print(_listCommissionPay);
    await _listCommissionPay.then((value){

                                    List arraycheck = [];
                                    _userCredit =[];
                                     value.forEach((ele) {

                                       //แยกรายได้ของฝ่ายติดตามหนี้แต่ละคน
                                       var indexFind = _userCredit.indexWhere((element)=>element['Credit_user_id']==ele['Credit_user_id']);
                                       if(indexFind == -1){
                                         _userCredit.add({
                                           'Credit_user_id':ele['Credit_user_id'],
                                           'Credit_name_care':ele['Credit_name_care'],
                                           'moneypay':ele['history_money_pay'],
                                           'qty':0,
                                         });
                                         indexFind = _userCredit.indexWhere((element)=>element['Credit_user_id'].toString()==ele['Credit_user_id'].toString());
                                       }else{
                                         _userCredit[indexFind]['moneypay']+=ele['history_money_pay'];
                                       }



                                       //นับจำนวนเงินที่ลูกค้าจ่าย
                                       sum_customer_receive+=ele['history_money_pay'];
                                       //หาว่ามีบิลที่ซ้ำกันไหม กรณีลูกค้าจ่ายซ้ำ เพื่อนับกระสอบเฉพาะที่ลูกค้าจ่ายครบ
                                       var result = value.where((element) => element['receipt_id']==ele['receipt_id']);
                                       if(result.length >1){
                                         // print('result =>${result.length}');
                                         // print('จ่ายหมด ${ele['bill_money_due']}');
                                          //ถ้ายังไม่นับให้นับจำนวนกระสอบ
                                           if(ele['bill_money_due']<=0){
                                             // print(arraycheck.indexWhere((element)=>element==ele['receipt_id']));
                                             if(arraycheck.indexWhere((element)=>element==ele['receipt_id']) == -1 ){
                                               List obj = jsonDecode(ele['bill_order_detail']);
                                               obj.forEach((itemObj) {
                                                 if(itemObj['cat_id'] == 1){
                                                   cat1_qty_bill_received+=itemObj['qty'];
                                                   _userCredit[indexFind]['qty']+=itemObj['qty'];
                                                 }

                                               });
                                               arraycheck.add(ele['receipt_id']);
                                             }
                                           }
                                       }else{
                                         if(ele['bill_money_due']<=0){
                                           List obj = jsonDecode(ele['bill_order_detail']);
                                           obj.forEach((itemObj) {
                                             if(itemObj['cat_id'] == 1){
                                               cat1_qty_bill_received+=itemObj['qty'];
                                               _userCredit[indexFind]['qty']+=itemObj['qty'];
                                             }
                                           });
                                         }
                                       }



                                     });
                                  });
    print('sum_customer_receive=${sum_customer_receive}');
    print('cat1_qty_bill_received=${cat1_qty_bill_received}');
    print('_userCredit=${_userCredit}');

    if(mounted)setState(() {});
  }

  CalculateDataDebt() async{
    cat1_qty_bill_receivedDebt = 0;
    sum_customer_receiveDebt = 0;


    print('CalculateDataDebt');
    await _listCommissionPayDebt.then((value){


      List arraycheck = [];
      _userDebt=[];
      value.forEach((ele) {
        //แยกรายได้ของฝ่ายติดตามหนี้แต่ละคน
        var indexFindDebt = _userDebt.indexWhere((element)=>element['debt_id'].toString()==ele['debt_id'].toString());
        if(indexFindDebt == -1){
          _userDebt.add({
            'debt_id':ele['debt_id'],
            'debt_name':ele['debt_name'],
            'finance_com_rate':ele['finance_com_rate'],
            'moneypay':ele['history_money_pay'],
            'qty':0,
          });
          indexFindDebt = _userDebt.indexWhere((element)=>element['debt_id'].toString()==ele['debt_id'].toString());
        }else{
          _userDebt[indexFindDebt]['moneypay']+=ele['history_money_pay'];
        }


        //นับจำนวนเงินที่ลูกค้าจ่าย
        sum_customer_receiveDebt+=ele['history_money_pay'];
        //หาว่ามีบิลที่ซ้ำกันไหม กรณีลูกค้าจ่ายซ้ำ เพื่อนับกระสอบเฉพาะที่ลูกค้าจ่ายครบ
        var result = value.where((element) => element['receipt_id']==ele['receipt_id']);
        if(result.length >1){
          //ถ้ายังไม่นับให้นับจำนวนกระสอบ
            if(ele['bill_money_due']<=0){
              if(arraycheck.indexOf((element)=>element==ele['receipt_id']) == -1 ){
                List obj = jsonDecode(ele['bill_order_detail']);
                obj.forEach((itemObj) {
                  if(itemObj['cat_id'] == 1){
                    cat1_qty_bill_receivedDebt+=itemObj['qty'];
                    _userDebt[indexFindDebt]['qty']+=itemObj['qty'];
                  }

                });
                arraycheck.add(ele['receipt_id']);
              }
            }
        }else{
          if(ele['bill_money_due']<=0){
            List obj = jsonDecode(ele['bill_order_detail']);
            obj.forEach((itemObj) {
              if(itemObj['cat_id'] == 1){
                cat1_qty_bill_receivedDebt+=itemObj['qty'];
                _userDebt[indexFindDebt]['qty']+=itemObj['qty'];
              }
            });
          }
        }




      });
    });
    print('sum_customer_receiveDebt=${sum_customer_receiveDebt}');
    print('cat1_qty_bill_receivedDebt=${cat1_qty_bill_receivedDebt}');
    print('_userDebt=${_userDebt}');
    if(mounted)setState(() {});
  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    AlertNewDesign().showLoading(context,MediaQuery.of(context).size);

    if (isConnect) {
      _listCommissionPay = Future.value();
      _listCommissionPayDebt = Future.value();
      setState(() {});
      var year = '${initDate.toString().split('-')[0]}';
      var month = '${initDate.toString().split('-')[1]}';
      try {

        var res = await http.post('$apiPath-commission',
            body: {
              'func': 'get_commission_employee_forapp',
              'year': year,
              'month':month
            }
        );
        if (res.statusCode == 200) {
          print('online');
          Sqlite().insertJson('COMMISSION_HISTORY', selectedMonth, res.body);
          List data = jsonDecode(res.body);
          _listCommissionPay = Future.value(data);
          Navigator.pop(context);
          await CalculateData();
          // setState(() {});
        }
      } catch (e) {
        print('error $e');
        // setState(() {});
        // return [];
        _listCommissionPay =Future.value([]);
        setState(() {});
      }

      try {

        var resDebt = await http.post('$apiPath-commission',
            body: {
              'func': 'get_commission_employee_f_forapp',
              'year': year,
              'month':month
            }
        );
        if (resDebt.statusCode == 200) {
          print('online ${selectedMonth}');
          Sqlite().insertJson('COMMISSION_HISTORY_DEBT', selectedMonth, resDebt.body);

          List dataDebt = jsonDecode(resDebt.body);
          _listCommissionPayDebt = Future.value(dataDebt);
          await CalculateDataDebt();

        }
      } catch (e) {
        print('error $e');

        _listCommissionPayDebt =Future.value([]);
        setState(() {});
      }


    }
  }

  Future _showMonthPicker() async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(2020, 6),
      // lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: initDate,
      locale: Locale("th"),
    ).then((date) {
      if (date != null) {
        initDate = date;
        selectedMonth =
        '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        getData();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
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
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10,bottom: 5),
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
                                padding: const EdgeInsets.only(left: 8,top: 8,bottom: 8,right: 15),
                                child: Icon(FontAwesomeIcons.chalkboardTeacher,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายงานรายได้ฝ่ายสินเชื่อ',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('หน้านี้สรุปข้อมูลจากวันที่ลูกค้าชำระเงิน',style: TextStyle(fontSize: 16.0,height: 1),),
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
                              padding: const EdgeInsets.symmetric(horizontal: 3),
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
                                          child: Stack(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                                    child: TextField(
                                                      controller: monthSelectText,
                                                      textAlign: TextAlign.center,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        // labelText:'ข้อมูล ณ วันที่',
                                                        hintText: 'ข้อมูลประจำเดือนนี้',
                                                        contentPadding: EdgeInsets.all(5),
                                                        border: InputBorder.none,
                                                        isDense: true,

                                                      ),

                                                      style: TextStyle(fontSize: 18,),
                                                    ),
                                                  ),

                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(width: 2,color: subFontColor),
                                                      bottom: BorderSide(width: 2,color: subFontColor),
                                                    ),
                                                    color: bgInputColor,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 5,
                                                  child: Container(
                                                    child: Icon(Icons.arrow_drop_down_outlined,color: Colors.black,size: 28,),
                                                  ),
                                                )
                                              ]
                                          ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: _listCommissionPay,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Card(
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        HeaderText(text:'ฝ่ายสินเชื่อ',textSize: 20,gHeight: 26,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10,top: 8,bottom: 8,right: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('ยอดเงินที่เก็บลูกค้าได้ทั้งหมด',style: _baseFontStyle,),
                                                  Text('${f.SeperateNumber(sum_customer_receive)} บาท',style: _baseFontStyle,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('จำนวนกระสอบที่ลูกค้าจ่ายครบ',style: _baseFontStyle,),
                                                  Text('${f.SeperateNumber(cat1_qty_bill_received)} กระสอบ',style: _baseFontStyle,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('ค่าคอมที่ฝ่ายสินเชื่อจะได้ (1.5%)',style: _baseFontStyle,),
                                                  Text('${f.SeperateNumber(((sum_customer_receive*1.5)/100))} กระสอบ',style: _baseFontStyle,),
                                                ],
                                              ),
                                              Divider(),
                                              ListView.builder(
                                                primary: false,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  var objUserCredit = _userCredit[index];
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('${index+1}. ${objUserCredit['Credit_name_care']}',style: _baseFontStyle,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('เก็บเงินจากลูกค้าได้',style: _baseFontStyle,),
                                                          Text('${f.SeperateNumber(objUserCredit['moneypay'])} บาท',style: _baseFontStyle,),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('จำนวนกระสอบที่ลูกค้าจ่ายครบ',style: _baseFontStyle,),
                                                          Text('${f.SeperateNumber(objUserCredit['qty'])} กระสอบ',style: _baseFontStyle,),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('ค่าคอมที่จะได้รับ (1.5%)',style: _baseFontStyle,),
                                                          Text('${f.SeperateNumber((objUserCredit['moneypay']*1.5)/100)} บาท',style: _baseFontStyle,),
                                                        ],
                                                      ),
                                                      if(index != _userCredit.length-1)
                                                        Divider(),

                                                    ],
                                                  );
                                                },
                                                itemCount: _userCredit.length,
                                              ),



                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );

                            }else{
                              return ShimmerLoading(type: 'boxText1row',);
                            }
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: _listCommissionPayDebt,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Card(
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        HeaderText(text:'ฝ่ายติดตามหนี้',textSize: 20,gHeight: 26,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10,top: 8,bottom: 8,right: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('ยอดเงินที่เก็บลูกค้าได้ทั้งหมด',style: _baseFontStyle,),
                                                  Text('${f.SeperateNumber(sum_customer_receiveDebt)} บาท',style: _baseFontStyle,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('จำนวนกระสอบที่ลูกค้าจ่ายครบ',style: _baseFontStyle,),
                                                  Text('${f.SeperateNumber(cat1_qty_bill_receivedDebt)} กระสอบ',style: _baseFontStyle,),
                                                ],
                                              ),
                                              Divider(),
                                              ListView.builder(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index) {
                                                    var objUserDebt = _userDebt[index];
                                                    return Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('${index+1}. ${objUserDebt['debt_name']}',style: _baseFontStyle,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('เก็บเงินจากลูกค้าได้',style: _baseFontStyle,),
                                                              Text('${f.SeperateNumber(objUserDebt['moneypay'])} บาท',style: _baseFontStyle,),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('จำนวนกระสอบที่ลูกค้าจ่ายครบ',style: _baseFontStyle,),
                                                              Text('${f.SeperateNumber(objUserDebt['qty'])} กระสอบ',style: _baseFontStyle,),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('ค่าคอมที่จะได้รับ (${objUserDebt['finance_com_rate']}%)',style: _baseFontStyle,),
                                                              Text('${f.SeperateNumber((objUserDebt['moneypay']*objUserDebt['finance_com_rate'])/100)} บาท',style: _baseFontStyle,),
                                                            ],
                                                          ),
                                                          if(index != _userDebt.length-1)
                                                            Divider(),

                                                        ],
                                                    );
                                                  },
                                                itemCount: _userDebt.length,
                                              ),



                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              );

                            }else{
                              return ShimmerLoading(type: 'boxText2row',);
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
        )
    );
  }
}
