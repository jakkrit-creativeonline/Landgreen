import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportCarDetailSale extends StatefulWidget {
  final int saleId;
  final DateTime selectedReport;

  const ReportCarDetailSale({Key key, this.saleId, this.selectedReport})
      : super(key: key);

  @override
  _ReportCarDetailSaleState createState() => _ReportCarDetailSaleState();
}

class _ReportCarDetailSaleState extends State<ReportCarDetailSale> {
  String selectedMonth = '';

  FormatMethod f = FormatMethod();

  DateTime initDate = DateTime.now();

  List showData = [];

  List showDataSuccess = [];

  Future<bool> isLoaded;

  String saleName = '';
  String saleStatus = '';
  String firstBillDue = '';
  String lastBillDue = '';
  int sumBill = 0;
  int sumCat1 = 0;
  int sumMoney = 0;
  int sumWaitBill = 0;
  int sumWaitCat1 = 0;
  int sumWaitMoney = 0;
  int sumSuccessBill = 0;
  int sumSuccessCat1 = 0;
  int sumSuccessMoney = 0;
  int sumSuccessPercent = 0;
  int sumPaySomeMoney = 0;

  var monthSelectText = TextEditingController();

  void resetData() {
    sumBill = 0;
    sumCat1 = 0;
    sumMoney = 0;
    sumWaitBill = 0;
    sumWaitCat1 = 0;
    sumWaitMoney = 0;
    sumSuccessBill = 0;
    sumSuccessCat1 = 0;
    sumSuccessMoney = 0;
    sumSuccessPercent = 0;
    sumPaySomeMoney = 0;
    showData = [];
    showDataSuccess = [];
  }

  Future<Null> getUserData() async {
    var res = await Sqlite().getUserDataById(widget.saleId);
    saleName = '${res[0]['Name']} ${res[0]['Surname']}';
    saleStatus = res[0]['Work_status'] == 0 ? '(ออก)' : '';
    setState(() {});
  }

  Future calCulateData(List temp) async {
    sumBill = temp.length;
    print(temp);
    temp.forEach((ele) {
      List json = jsonDecode(ele['bill_data']['Order_detail']);
      List order = json.where((element) => element['cat_id'] == 1).toList();
      String product = '';
      order.forEach((element) {
        product +=
            '${element['name']} ${element['price_sell']} ${element['qty']} กระสอบ, ';
      });
      ele['bill_data']['product'] = product.substring(0, product.length - 2);
      if ([7, 10, 12, 15].contains(ele['bill_data']['Status'])) {
        showDataSuccess.add(ele);
        sumCat1 += ele['current_paySuccess_cat1'];
        sumSuccessBill += 1;
        sumSuccessCat1 += ele['current_paySuccess_cat1'];
        sumSuccessMoney += (ele['bill_data']['Money_total'] -
            ele['bill_data']['Money_earnest']);
      } else {
        showData.add(ele);
        sumCat1 += ele['current_waitPay_cat1'];
        sumWaitBill += 1;
        sumWaitCat1 += ele['current_waitPay_cat1'];
        sumWaitMoney += ele['bill_data']['Money_due'];
      }
      sumMoney +=
          (ele['bill_data']['Money_total'] - ele['bill_data']['Money_earnest']);
    });
    sumPaySomeMoney = sumMoney - (sumSuccessMoney + sumWaitMoney);
    sumSuccessPercent = ((sumSuccessMoney / sumMoney) * 100).round();
    DateTime now;
    if (selectedMonth == '') {
      now = DateTime.now();
    } else {
      now = DateTime.parse(selectedMonth.split('/')[0] +
          '-' +
          selectedMonth.split('/')[1] +
          '-01');
    }
    String lastDayOfMonth =
        DateTime(now.year, now.month + 1, 0).toString().split(' ')[0];
    String firstDayOfMonth =
        DateTime(now.year, now.month).toString().split(' ')[0];

    firstBillDue = '${f.ThaiFormat(firstDayOfMonth)}';
    lastBillDue = '${f.ThaiFormat(lastDayOfMonth)}';
  }

  Future fetchShowData({bool isRefresh = false}) async {
    resetData();
    var res = await Sqlite()
        .getJson('CEO_CREDIT_REPORT_CAR_SALE_${widget.saleId}', selectedMonth);
    if (!isRefresh && res != null) {
      List temp = jsonDecode(res['JSON_VALUE']);
      await calCulateData(temp);
      setState(() {});
    } else {
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      final body = {
        'func': 'reportCreditPerCarDetailSale',
        'changeMonthSelect': selectedMonth,
        'sale_id': '${widget.saleId}'
      };
      final res = await http.post('$apiPath-credit', body: body);
      Navigator.pop(context);
      if (res.statusCode == 200 ) {

        if(res.body != '{"nofile":"nofile"}'){
          List temp = jsonDecode(res.body);
          Sqlite().insertJson('CEO_CREDIT_REPORT_CAR_SALE_${widget.saleId}',
              selectedMonth, res.body);
          await calCulateData(temp);
          setState(() {});
        }
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลได้');
      }
    }
  }

  Future refresh() async {
    await fetchShowData(isRefresh: true);
  }

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
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        fetchShowData();
      }
    });
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.selectedReport != null) {
      initDate = widget.selectedReport;
      selectedMonth =
          '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
      var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
      monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
    }
    getUserData();
    fetchShowData();
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
                // title: Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     MyNoti(
                //       userId: user_id,
                //     )
                //   ],
                // ),
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
              onRefresh: refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(FontAwesomeIcons.chartBar,color: btTextColor,),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${saleName}',style: TextStyle(fontSize: 24.0,height: 1),),
                                    Text('รายงาน เครดิต รายบุคคล',style: TextStyle(fontSize: 18.0,height: 1),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text('รายงาน เครดิต ทะเบียน ${snapshot.data['car_name']}'),
                        // Text('ทีม${snapshot.data['team_name']}')
                      ],
                    ),
                  ),
                  // SliverToBoxAdapter(
                  //   child: Center(
                  //     child: Text(
                  //         'รายการ เครดิต $saleName $saleStatus $selectedMonth'),
                  //   ),
                  // ),
                  summaryInfo(size),
                  showDetail(size),
                  showDetailPaySuccess(size),
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

  SliverToBoxAdapter showDetail(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Card(
          child: Column(
            children: [
              HeaderText(text: 'รายการบิลที่ค้างชำระ',textSize: 20,gHeight: 26,),
              // Text('รายการบิลที่ค้างชำระ'),
              Container(
                height: size.height * 0.5,
                child: (showData.length !=0)?ListView.builder(
                    itemCount: showData.length,
                    itemBuilder: (bc, i) {
                      var res = showData[i]['bill_data'];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5,right: 10,top: 5),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_right),
                                        Text('ลูกค้าชื่อ ${res['Customer_name']}',style: _baseFontStyle,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('เบอร์โทร : ${res['Customer_phone']}',style: _baseFontStyle,),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  top: -5,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          height:30,
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.call,
                                                size: 20,
                                              ),
                                              onPressed: () => _makePhoneCall(
                                                  'tel:${res['Customer_phone']}')),
                                        ),
                                        Text('โทรหาลูกค้า',style: TextStyle(fontSize: 12),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16,right: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('เลขที่บิล : ${res['Bill_number']}',style: _baseFontStyle),
                                Text('ที่อยู่ลูกค้า : ${res['Customer_address']}',style: _baseFontStyle),
                                Text('รายการสั่งซื้อ : ${res['product']}',style: _baseFontStyle),
                                Text('สินเชื่อ: ${res['Credit_name']}',style: _baseFontStyle),
                                Text('กำหนดชำระ : ${f.ThaiFormat(res['Date_due'])}',style: TextStyle(color: dangerColor,fontSize: 18),),
                                Text(
                                  'ค้างจ่าย : ${f.SeperateNumber(res['Money_due'])} บาท',
                                  style: TextStyle(color: dangerColor,fontSize: 18),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Divider(indent: 15,endIndent: 10,),
                          ),
                        ],
                      );
                    }):Center(
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
                          child: Image.asset("assets/icons/icon_alert.png"),
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
                            "เดือนที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะไม่มีรายการบิลค้างชำระ\nในวันเวลาดังกล่าวที่คุณเลือกมานี้",
                            style: TextStyle(
                                fontSize: 23, color: Colors.white, height: 1),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter showDetailPaySuccess(size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Card(
          child: Column(
            children: [
              HeaderText(text:'รายการบิลที่เก็บครบ',textSize: 20,gHeight: 26,),
              Container(
                width: size.width * 0.9,
                height: size.height * 0.5,
                child: (showDataSuccess.length!=0)?ListView.builder(
                    itemCount: showDataSuccess.length,
                    itemBuilder: (bc, i) {
                      var res = showDataSuccess[i]['bill_data'];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5,right: 10,top: 5),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_right),
                                        Text('ลูกค้าชื่อ ${res['Customer_name']}',style: _baseFontStyle,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('เบอร์โทร : ${res['Customer_phone']}',style: _baseFontStyle,),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  top: -5,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          height:30,
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.call,
                                                size: 20,
                                              ),
                                              onPressed: () => _makePhoneCall(
                                                  'tel:${res['Customer_phone']}')),
                                        ),
                                        Text('โทรหาลูกค้า',style: TextStyle(fontSize: 12),)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16,right: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('เลขที่บิล : ${res['Bill_number']}',style: _baseFontStyle),
                                Text('ที่อยู่ลูกค้า : ${res['Customer_address']}',style: _baseFontStyle),
                                Text('รายการสั่งซื้อ : ${res['product']}',style: _baseFontStyle),
                                Text('สินเชื่อ: ${res['Credit_name']}',style: _baseFontStyle),
                                Text('กำหนดชำระ : ${f.ThaiFormat(res['Date_due'])}',style: _baseFontStyle,),
                                Text(
                                  'จ่ายครบ : ${f.SeperateNumber(res['Money_total'] - res['Money_earnest'])}  บาท',
                                  style: TextStyle(color: kSecondaryColor,fontSize: 18),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Divider(indent: 15,endIndent: 10,),
                          ),
                        ],
                      );
                      // return Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text('เลขที่บิล : ${res['Bill_number']}'),
                      //         Text('ชื่อลูกค้า : ${res['Customer_name']}'),
                      //         Text('เบอร์โทร : ${res['Customer_phone']}'),
                      //         Text(
                      //             'ที่อยู่ลูกค้า : ${res['Customer_address']}'),
                      //         Text('สินค้า : ${res['product']}'),
                      //         Text(
                      //             'กำหนดชำระ : ${f.ThaiFormat(res['Date_due'])}'),
                      //         Text(
                      //           'จ่ายครบ : ${f.SeperateNumber(res['Money_total'] - res['Money_earnest'])} บาท',
                      //           style: TextStyle(color: blueColor),
                      //         ),
                      //         Text('สินเชื่อ : ${res['Credit_name'] ?? ' '}')
                      //       ],
                      //     ),
                      //     IconButton(
                      //         icon: Icon(
                      //           Icons.call,
                      //           size: 18,
                      //         ),
                      //         onPressed: () => _makePhoneCall(
                      //             'tel:${res['Customer_phone']}'))
                      //   ],
                      // );
                    }):Center(
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
                          child: Image.asset("assets/icons/icon_alert.png"),
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
                            "เดือนที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะไม่มีรายการบิลที่เก็บเงินลูกค้าครบ\nในวันเวลาดังกล่าวที่คุณเลือกมานี้",
                            style: TextStyle(
                                fontSize: 23, color: Colors.white, height: 1),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter summaryInfo(size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text('ข้อมูลเครดิต ตามวันที่กำหนดชำระบิล (ไม่รวมเครดิต 7 วัน)'),
            Text(
                'ข้อมูลบิลกำหนดชำระวันที่ $firstBillDue ถึง $lastBillDue (นับรวมยอดขายของคนที่ออกด้วย)'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 5),
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
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'สรุปรวมทั้งหมด',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('บิลเครดิต ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),

            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text('สรุปรวมทั้งหมด'),
            //         Text('บิลเครดิต : ${f.SeperateNumber(sumBill)} บิล'),
            //         Text('จำนวนกระสอบ : ${f.SeperateNumber(sumCat1)} กระสอบ'),
            //         Text(
            //             'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumMoney)} บาท'),
            //       ],
            //     ),
            //   ),
            // ),

            // Container(
            //   width: size.width * 0.5,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('สรุปรวม ค้างจ่าย'),
            //           Text('บิลเครดิต : ${f.SeperateNumber(sumWaitBill)} บิล'),
            //           Text(
            //               'จำนวนกระสอบ : ${f.SeperateNumber(sumWaitCat1)} กระสอบ'),
            //           Text(
            //               'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumWaitMoney)} บาท'),
            //           Text(
            //               'เก็บได้บางส่วน(ลูกค้าทะยอยจ่าย) : ${f.SeperateNumber(sumPaySomeMoney)} บาท'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'ค้างจ่ายรวม',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('บิลเครดิต ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumWaitBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('เก็บได้บางส่วน(ลูกค้าทะยอยจ่าย) ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumPaySomeMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Card(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       HeaderText(text: 'ค้างจ่ายรวม',textSize: 20,gHeight: 26,),
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           children: [
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('บิลเครดิต ',style: _baseFontStyle,),
            //                 Text('${f.SeperateNumber(sumWaitBill)} บิล',style: _baseFontStyle),
            //               ],
            //             ),
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('จำนวนกระสอบ ',style: _baseFontStyle),
            //                 Text('${f.SeperateNumber(sumWaitCat1)} กระสอบ',style: _baseFontStyle),
            //               ],
            //             ),
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
            //                 Text('${f.SeperateNumber(sumWaitMoney)} บาท',style: _baseFontStyle),
            //               ],
            //             ),
            //             Row(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('เก็บได้บางส่วน(ลูกค้าทะยอยจ่าย) ',style: _baseFontStyle),
            //                 Text('${f.SeperateNumber(sumPaySomeMoney)} บาท',style: _baseFontStyle),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //
            //     ],
            //   ),
            // ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'เก็บครบรวม',textSize: 20,gHeight: 26,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('บิลเครดิต ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumSuccessBill)} บิล',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนกระสอบ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessCat1)} กระสอบ',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('จำนวนเงินที่ต้องเก็บ ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessMoney)} บาท',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('คิดเป็น%เงินที่เก็บได้ครบ',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),
                            ),
                            Text('${f.SeperateNumber(sumSuccessPercent)} %',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Container(
            //   width: size.width * 0.5,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('สรุปรวม เก็บครบ'),
            //           Text('บิลเครดิต : ${f.SeperateNumber(sumSuccessBill)} บิล'),
            //           Text(
            //               'จำนวนกระสอบ : ${f.SeperateNumber(sumSuccessCat1)} กระสอบ'),
            //           Text(
            //               'จำนวนเงินที่ต้องเก็บ : ${f.SeperateNumber(sumSuccessMoney)} บาท'),
            //           Text(
            //               'คิดเป็น%เงินที่เก็บได้ครบ : ${f.SeperateNumber(sumSuccessPercent)} %'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // RaisedButton(
            //     child: Text('TEST MONTH PICKER'),
            //     onPressed: () => _showMonthPicker())
          ],
        ),
      ),
    );
  }
}
