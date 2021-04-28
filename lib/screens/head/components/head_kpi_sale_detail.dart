import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HeadKPISaleDetail extends StatefulWidget {
  final int saleId;
  final DateTime selectedReport;

  const HeadKPISaleDetail({Key key, this.saleId, this.selectedReport})
      : super(key: key);

  @override
  _HeadKPISaleDetailState createState() => _HeadKPISaleDetailState();
}

class _HeadKPISaleDetailState extends State<HeadKPISaleDetail> {
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

    print(temp);
    sumBill = temp[0]["sum_bill"];
    sumCat1 = temp[0]["sum_cat1"];
    sumSuccessBill = temp[0]["sended_bill"];
    sumSuccessCat1 = temp[0]["sended_cat1"];
    sumWaitBill = temp[0]["book_bill"];
    sumWaitCat1 = temp[0]["book_cat1"];
    showData = temp[0]["dataBillBook"];
    showDataSuccess = temp[0]["dataBillSended"];

    if(sumCat1>0){
      sumSuccessPercent = ((sumSuccessCat1 / sumCat1) * 100).round();
    }else{
      sumSuccessPercent = 0;
    }

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
        .getJson('KPI_SALE_TEAM_SALE_${widget.saleId}', selectedMonth);
    if (!isRefresh && res != null) {
      List temp = jsonDecode(res['JSON_VALUE']);
      await calCulateData(temp);
      setState(() {});
    } else {
      final body = {
        'func': 'reportKPISaleDetailSale',
        'changeMonthSelect': selectedMonth,
        'sale_id': '${widget.saleId}'
      };
      print("body=>${body}");
      final res = await http.post('$apiPath-accounts', body: body);
      if (res.statusCode == 200 ) {

        if(res.body != '{"nofile":"nofile"}'){
          print('res.body => ${res.body.runtimeType}');
          List temp = jsonDecode('[${res.body}]');
          Sqlite().insertJson('KPI_SALE_TEAM_SALE_${widget.saleId}',
              selectedMonth, '[${res.body}]');
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
                                  child: Icon(FontAwesomeIcons.chartPie,color: btTextColor,),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${saleName}',style: TextStyle(fontSize: 24.0,height: 1),),
                                    Text('รายงาน เปิดใบสั่งจอง รายบุคคล',style: TextStyle(fontSize: 18.0,height: 1),),
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
              HeaderText(text: 'รายการบิลที่จองแล้ว',textSize: 20,gHeight: 26,),
              // Text('รายการบิลที่ค้างชำระ'),
              Container(
                height: size.height * 0.5,
                child: ListView.builder(
                    itemCount: showData.length,
                    itemBuilder: (bc, i) {
                      var res = showData[i];
                      List json = jsonDecode(res['Order_detail']);
                      List order = json.where((element) => element['cat_id'] == 1).toList();
                      String product = '';
                      order.forEach((element) {
                        product +=
                        '${element['name']} ${element['price_sell']} ${element['qty']} กระสอบ, ';
                      });
                      String billType= res['Pay_type']==1?"เงินสด":"เครดิต";
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
                                        Text('ลูกค้าชื่อ ${res['cus_name']}',style: _baseFontStyle,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('เบอร์โทร : ${res['cus_phone']}',style: _baseFontStyle,),
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
                                                  'tel:${res['cus_phone']}')),
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
                                Text('ประเภท : $billType',style: _baseFontStyle),
                                Text('ที่อยู่ลูกค้า : ${res['cus_address']}',style: _baseFontStyle),
                                if(res['Date_send']!="" && res['Date_send'] != null)
                                Text('กำหนดส่ง : ${f.ThaiFormat(res['Date_send'])}',style: _baseFontStyle),
                                Text('รายการสั่งซื้อ : ${product}',style: _baseFontStyle),
                                if(res['Pay_type']==2)
                                Text('สินเชื่อ: ${res['Credit_name']}',style: _baseFontStyle),
                                if(res['Pay_type']==2)
                                Text('กำหนดชำระ : ${f.ThaiFormat(res['Date_due'])}',style: TextStyle(color: dangerColor,fontSize: 18),),
                                // if(res['Pay_type']=='2')
                                // Text(
                                //   'ค้างจ่าย : ${f.SeperateNumber(res['Money_due'])} บาท',
                                //   style: TextStyle(color: dangerColor,fontSize: 18),
                                // ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Divider(indent: 15,endIndent: 10,),
                          ),
                        ],
                      );
                    }),
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
              HeaderText(text:'รายการบิลที่ส่งแล้ว',textSize: 20,gHeight: 26,),
              Container(
                width: size.width * 0.9,
                height: size.height * 0.5,
                child: ListView.builder(
                    itemCount: showDataSuccess.length,
                    itemBuilder: (bc, i) {
                      var res = showDataSuccess[i];
                      List json = jsonDecode(res['Order_detail']);
                      List order = json.where((element) => element['cat_id'] == 1).toList();
                      String product = '';
                      order.forEach((element) {
                        product +=
                        '${element['name']} ${element['price_sell']} ${element['qty']} กระสอบ, ';
                      });
                      String billType= res['Pay_type']==1?"เงินสด":"เครดิต";
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
                                        Text('ลูกค้าชื่อ ${res['cus_name']}',style: _baseFontStyle,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text('เบอร์โทร : ${res['cus_phone']}',style: _baseFontStyle,),
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
                                                  'tel:${res['cus_phone']}')),
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
                                Text('ประเภท : $billType',style: _baseFontStyle),
                                Text('ที่อยู่ลูกค้า : ${res['cus_address']}',style: _baseFontStyle),
                                if(res['Date_send']!="" && res['Date_send'] != null)
                                  Text('กำหนดส่ง : ${f.ThaiFormat(res['Date_send'])}',style: _baseFontStyle),
                                Text('รายการสั่งซื้อ : ${product}',style: _baseFontStyle),
                                if(res['Pay_type']==2)
                                  Text('สินเชื่อ: ${res['Credit_name']}',style: _baseFontStyle),
                                if(res['Pay_type']==2)
                                  Text('กำหนดชำระ : ${f.ThaiFormat(res['Date_due'])}',style: TextStyle(color: dangerColor,fontSize: 18),),


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
                    }),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text('ข้อมูลเครดิต ตามวันที่กำหนดชำระบิล (ไม่รวมเครดิต 7 วัน)'),
            Text(
                'ข้อมูลลูกค้าเซ็นใบสั่งจองสินค้าวันที่ $firstBillDue ถึง $lastBillDue \n(นับรวมยอดขายของคนที่ออกด้วย)'),

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
                            Text('จำนวนบิล ',style: _baseFontStyle,),
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
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'จองแล้ว',textSize: 20,gHeight: 26,),
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
                            Text('จำนวนบิล ',style: _baseFontStyle,),
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
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: 'ส่งแล้ว',textSize: 20,gHeight: 26,),
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
                            Text('จำนวนบิล ',style: _baseFontStyle,),
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
                            Text('คิดเป็น%ที่ส่งแล้ว',style: TextStyle(
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
          ],
        ),
      ),
    );
  }


}
