import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;

class CEOReportCar extends StatefulWidget {
  @override
  _CEOReportCarState createState() => _CEOReportCarState();
}

class _CEOReportCarState extends State<CEOReportCar> {

  GetReport s = GetReport();
  FormatMethod f = FormatMethod();
  Future<bool> isLoaded;

  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  TextStyle _baseFontStyleHeight1 = TextStyle(fontSize: 18,height: 1);

  Future<List> showData;

  int sumMoneyTotal = 0;
  int cashMoneyTotal = 0;
  int creditMoneyTotal = 0;

  int sumProductCat1 = 0;
  int cashProductCat1 = 0;
  int creditProductCat1 = 0;
  int receiveProductCat1=0;

  int sumProductCat2 = 0;
  int cashProductCat2 = 0;
  int creditProductCat2 = 0;


  int sumProduct590 = 0;
  int cashProduct590 = 0;
  int creditProduct590 = 0;
  int receiveProduct590=0;

  int sumProduct690 = 0;
  int cashProduct690 = 0;
  int creditProduct690 = 0;
  int receiveProduct690=0;

  double percentCredit=0;
  double percentCash=0;
  double percentGoal=0;


  String firstBillDue = '';
  String lastBillDue = '';
  String selectedMonth = '';

  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();

  void initState() {
    getData();
    super.initState();
  }

  getData() async{

    var res = await Sqlite().getJson('CEO_CAR_RANKING_ACCOUNT', selectedMonth);
    showData = Future.value();
    reset();
    if (res != null) {
      List data = jsonDecode(res['JSON_VALUE']);
      data.sort((a, b) => (b['car_sum_cat1']+b['car_bill_credit_recieved_cat1_590']+b['car_bill_credit_recieved_cat1_690']) - (a['car_sum_cat1']+a['car_bill_credit_recieved_cat1_590']+a['car_bill_credit_recieved_cat1_690']));
      await calCulateData(data);
      showData = Future.value(data);
      // return data;
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {

        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-ceo',
              body: {'func': 'getCacheCarRankingAccount', 'monthSelect': selectedMonth});
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('CEO_CAR_RANKING_ACCOUNT', selectedMonth, res.body);
            List data = jsonDecode(res.body);
            data.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
            await calCulateData(data);
            showData = Future.value(data);
            // return data;
            Navigator.pop(context);
          }
        } catch (e) {
          print('error $e');
          Navigator.pop(context);
          setState(() {});
          // return [];
          showData = Future.value([]);
        }

      }
    }
    setState(() {});
  }


  reset() {
    sumMoneyTotal = 0;
    cashMoneyTotal = 0;
    creditMoneyTotal = 0;

    sumProductCat1 = 0;
    cashProductCat1 = 0;
    creditProductCat1 = 0;
    receiveProductCat1 =0;

    cashProductCat2 = 0;

    sumProduct590 = 0;
    cashProduct590 = 0;
    creditProduct590 = 0;
    receiveProduct590 =0;

    sumProduct690 = 0;
    cashProduct690 = 0;
    creditProduct690 = 0;
    receiveProduct690 =0;

    percentCredit =0;
    percentCash = 0;
    percentGoal = 0;


  }

  Future calCulateData(List showData) async {
    showData.forEach((e) {
      sumMoneyTotal += e['car_bill_money_total'];
      cashMoneyTotal += e['car_bill_cash_money_total'];
      creditMoneyTotal += e['car_bill_credit_money_total'];

      cashProductCat2 += e['car_bill_cash_cat2'];

      cashProduct590 += e['car_bill_cash_cat1_590'];
      creditProduct590 += e['car_bill_credit_cat1_590'];

      cashProduct690 += e['car_bill_cash_cat1_690'];
      creditProduct690 += e['car_bill_credit_cat1_690'];

      receiveProduct590 += e['car_bill_credit_recieved_cat1_590'];
      receiveProduct690 += e['car_bill_credit_recieved_cat1_690'];
    });
    cashProductCat1 = cashProduct590 + cashProduct690;
    creditProductCat1 = creditProduct590 + creditProduct690;
    receiveProductCat1 = receiveProduct590 + receiveProduct690;
    sumProductCat1 = cashProductCat1 + creditProductCat1;
    sumProduct590 = cashProduct590 + creditProduct590;
    sumProduct690 = cashProduct690 + creditProduct690;
    if(sumProductCat1!=0){
      percentCredit = (creditProductCat1/sumProductCat1)*100;
      percentCash = (cashProductCat1/sumProductCat1)*100;
    }



    setState(() {});
  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      isLoaded = Future.value();

      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        reset();
        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-ceo',
              body: {'func': 'getCacheCarRankingAccount', 'monthSelect': selectedMonth});
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('CEO_CAR_RANKING_ACCOUNT', selectedMonth, res.body);
            List data = jsonDecode(res.body);
            data.sort((a, b) => (b['car_sum_cat1']+b['car_bill_credit_recieved_cat1_590']+b['car_bill_credit_recieved_cat1_690']) - (a['car_sum_cat1']+a['car_bill_credit_recieved_cat1_590']+a['car_bill_credit_recieved_cat1_690']));
            await calCulateData(data);
            showData = Future.value(data);
            Navigator.pop(context);
            // return data;
          }
        } catch (e) {
          print('error $e');
          Navigator.pop(context);
          setState(() {});
          // return [];
          showData = Future.value([]);
        }

      }

      isLoaded = Future.value(true);
      setState(() {});
    }
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
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(FontAwesomeIcons.flag,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายงานยอดขายทีมเป้า 300 กระสอบ',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('หน้านี้สรุปข้อมูลจากบิลที่ลูกค้าได้รับสินค้าแล้วทั้งหมด',style: TextStyle(fontSize: 16.0,height: 1),),
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
                            SizedBox(height: 8,),
                            FutureBuilder(
                              future: showData,
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  return Column(
                                    children: [
                                      Card(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            HeaderText(text:'สรุปยอดขายรวมทั้งหมด',textSize: 20,gHeight: 26,),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ยอดขายรวม ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(sumProductCat1)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(sumProduct590)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(sumProduct690)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  // Row(
                                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                                  //   children: [
                                                  //     Text(
                                                  //       'ขายฮอร์โมนได้้',style: _baseFontStyle,),
                                                  //     Text(
                                                  //         '${f.SeperateNumber(cashProductCat2)} ขวด',style: _baseFontStyle),
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Card(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            HeaderText(text:'ยอดขาย เงินสด ( ${percentCash.toStringAsFixed(0) }%)',textSize: 20,gHeight: 26,),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ยอดขายเงินสดรวม ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(cashProductCat1)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(cashProduct590)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(cashProduct690)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Card(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            HeaderText(text:'ยอดขาย เครดิต ( ${percentCredit.toStringAsFixed(0) }%)',textSize: 20,gHeight: 26,),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ยอดขายเครดิตรวม ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(creditProductCat1)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 590 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(creditProduct590)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายปุ๋ยราคา 690 ได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(creditProduct690)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Text('หมายเหตุ: ข้อมูลสรุปเฉพาะยอดขายเครดิตอย่างเดียวไม่นับบิลเครดิต 7 วัน',style: TextStyle(fontSize: 12),)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Card(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            HeaderText(text:'ยอดเก็บ เครดิต ',textSize: 20,gHeight: 26,),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ยอดเก็บเครดิตรวม ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(receiveProductCat1)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ปุ๋ยราคา 590 เก็บได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(receiveProduct590)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ปุ๋ยราคา 690 เก็บได้ ',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(receiveProduct690)} กระสอบ',style: _baseFontStyle),
                                                    ],
                                                  ),
                                                  Text('หมายเหตุ: ข้อมูลสรุปเฉพาะยอดที่เก็บเงินลูกค้าครบเต็มจำนวนค้างชำระ และนับบิลเครดิต 7 วันด้วย',style: TextStyle(fontSize: 12),)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Card(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            HeaderText(text:'รายละเอียดยอดขายแต่ละคันรถ',textSize: 20,gHeight: 26,),
                                            SingleChildScrollView(
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  itemCount: snapshot.data.length,
                                                  itemBuilder: (bc, i) {
                                                    var data = snapshot.data[i];
                                                    var sumTeam = data['car_sum_cat1']+data['car_bill_credit_recieved_cat1_590']+data['car_bill_credit_recieved_cat1_690'];
                                                    double percentGoalTeam = (sumTeam/300)*100;
                                                    return Stack(
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 10,top: 8),
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.arrow_right,size: 20,),
                                                                  Text('อันดับที่ ${i + 1} ทะเบียนรถ ${data['car_plate_number']} ${data['car_plate_province']} ',style: _baseFontStyle,),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 16),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text('ทีมขาย ${data['car_team_name']} เขตพื้นที่การขาย จังหวัด${data['car_team_province_area']}',style: _baseFontStyle,),

                                                                  Text('รวมทั้งหมด : ${f.SeperateNumber(data['car_sum_cat1']+data['car_bill_credit_recieved_cat1_590']+data['car_bill_credit_recieved_cat1_690'])} กระสอบ',
                                                                    style: _baseFontStyle,),
                                                                ],

                                                              ),
                                                            ),
                                                            Divider(indent: 16,endIndent: 16,),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 16,right: 16),
                                                              child: IntrinsicHeight(
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text('ขายเงินสด',style: _baseFontStyle),
                                                                        Text(
                                                                          'ราคา 590 : ${f.SeperateNumber(data['car_bill_cash_cat1_590'])} กส.',style: _baseFontStyle,),
                                                                        Text(
                                                                          'ราคา 690 : ${f.SeperateNumber(data['car_bill_cash_cat1_690'])} กส.',style: _baseFontStyle,),
                                                                      ],
                                                                    ),
                                                                    VerticalDivider(),
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text('ขายเครดิต',style: _baseFontStyle),
                                                                        Text(
                                                                          'ราคา 590 : ${f.SeperateNumber(data['car_bill_credit_cat1_590'])} กส.',style: _baseFontStyle,),
                                                                        Text(
                                                                          'ราคา 690 : ${f.SeperateNumber(data['car_bill_credit_cat1_690'])} กส.',style: _baseFontStyle,),
                                                                      ],
                                                                    ),
                                                                    VerticalDivider(),
                                                                    Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text('เก็บเครดิต',style: _baseFontStyle),
                                                                        Text(
                                                                          'ราคา 590 : ${f.SeperateNumber(data['car_bill_credit_recieved_cat1_590'])} กส.',style: _baseFontStyle,),
                                                                        Text(
                                                                          'ราคา 690 : ${f.SeperateNumber(data['car_bill_credit_recieved_cat1_690'])} กส.',style: _baseFontStyle,),
                                                                      ],
                                                                    ),

                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 2,),
                                                            if(i!=snapshot.data.length-1)
                                                              Divider(thickness: 2,),

                                                          ],
                                                        ),
                                                        Positioned(
                                                          child: Card(
                                                            color:(percentGoalTeam>=100)?kSecondaryColor:
                                                            (percentGoalTeam<50)?dangerColor:warningColor,
                                                            child: ConstrainedBox(
                                                              child: Column(

                                                                children: [
                                                                  Text('เป้า300กส.',style: TextStyle(fontSize: 16,color:whiteColor,height: 1),),
                                                                  Text('${percentGoalTeam.toStringAsFixed(0)}%',
                                                                          style: TextStyle(fontSize: 30,color:whiteColor,height: 0.7),
                                                                  ),
                                                                ],
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                              ),
                                                              constraints: BoxConstraints(
                                                                minHeight: 60,
                                                                minWidth: 60
                                                              ),
                                                            ),
                                                          ),
                                                          top: 0,
                                                          right: 5,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ),

                                          ],
                                        ),
                                        elevation: 0.2,

                                      ),
                                      SizedBox(height: 15,),

                                    ],
                                  );

                                }else{
                                  return ShimmerLoading(type: 'boxText',);
                                }
                              },
                            ),
                          ],
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
