import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;


class CEOReportDay extends StatefulWidget {
  @override
  _CEOReportDayState createState() => _CEOReportDayState();
}

class _CEOReportDayState extends State<CEOReportDay> {
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

  int sumProductCat2 = 0;
  int cashProductCat2 = 0;
  int creditProductCat2 = 0;

  int sumProduct590 = 0;
  int cashProduct590 = 0;
  int creditProduct590 = 0;

  int sumProduct690 = 0;
  int cashProduct690 = 0;
  int creditProduct690 = 0;

  double percentCredit=0;
  double percentCash=0;


  String selectedReport = '98';
  String selectedText ='ข้อมูลเมื่อวานนี้';

  static const Map<String, String> optionReport = {
    '99': 'ข้อมูลประจำวันนี้',
    '98': 'ข้อมูลเมื่อวานนี้',
    '97': 'ข้อมูลสัปดาห์นี้',
    '96': 'ข้อมูลสัปดาห์ที่แล้ว',
    '13': 'ข้อมูลประจำเดือนนี้',
    '14': 'ข้อมูลเดือนที่แล้ว',
    '15': 'ข้อมูลประจำปีนี้',
    '16': 'ข้อมูลปีทีแล้ว'
  };

  @override
  void initState() {
    getData();
    super.initState();
  }

   getData() async{

     var res = await Sqlite().getJson('CEO_CAR_RANKING_TODAY', selectedReport);
     isLoaded = Future.value();
     showData = Future.value();
     reset();
     if (res != null) {
       List data = jsonDecode(res['JSON_VALUE']);
       data.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
       await calCulateData(data);
       showData = Future.value(data);
       // return data;
     } else {
       bool isConnect = await DataConnectionChecker().hasConnection;
       if (isConnect) {

         try {
           AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
           var res = await http.post('$apiPath-ceo',
               body: {'func': 'getCacheCarRankingToday', 'monthSelect': selectedReport});
           if (res.statusCode == 200) {
             print('online');
             Sqlite().insertJson('CEO_CAR_RANKING_TODAY', selectedReport, res.body);
             List data = jsonDecode(res.body);
             data.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
             await calCulateData(data);
             showData = Future.value(data);
             // return data;
           }
           Navigator.pop(context);
         } catch (e) {
           print('error $e');
           Navigator.pop(context);
           setState(() {});
           // return [];
           showData = Future.value([]);
         }

       }
     }
     isLoaded = Future.value(true);
     setState(() {});
   }


  reset() {
    sumMoneyTotal = 0;
    cashMoneyTotal = 0;
    creditMoneyTotal = 0;

    sumProductCat1 = 0;
    cashProductCat1 = 0;
    creditProductCat1 = 0;

    cashProductCat2 = 0;

    sumProduct590 = 0;
    cashProduct590 = 0;
    creditProduct590 = 0;

    sumProduct690 = 0;
    cashProduct690 = 0;
    creditProduct690 = 0;
    percentCredit =0;
    percentCash = 0;

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
    });
    cashProductCat1 = cashProduct590 + cashProduct690;
    creditProductCat1 = creditProduct590 + creditProduct690;
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
        print('selectedReport=>${selectedReport}');
        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-ceo',
              body: {'func': 'getCacheCarRankingToday', 'monthSelect': selectedReport});
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('CEO_CAR_RANKING_TODAY', selectedReport, res.body);
            List data = jsonDecode(res.body);
            data.sort((a, b) => b['car_sum_cat1'] - a['car_sum_cat1']);
            await calCulateData(data);
            // return data;
            showData = Future.value(data);
            Navigator.pop(context);
          }
        } catch (e) {
          print('error $e');
          Navigator.pop(context);
          setState(() {});
          return [];
        }

      }

      isLoaded = Future.value(true);
      setState(() {});
    }
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
                                child: Icon(FontAwesomeIcons.chartLine,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายงานยอดขายรายวัน',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('หน้านี้สรุปข้อมูลจากเซลสร้างใบสั่งจองสินค้า',style: TextStyle(fontSize: 16.0,height: 1),),
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
                            DropDown(
                              items: optionReport
                                  .map((key, value) {
                                return MapEntry(
                                    key,
                                    DropdownMenuItem<String>(value: key, child: Center(child: Text(value,style: TextStyle(fontSize: 18,height: 1),),))
                                );
                              })
                                  .values
                                  .toList(),
                              hintText: 'รายงานข้อมูลยอดขาย',
                              value: selectedReport,
                              onChange: (val) {
                                selectedText = optionReport[val];
                                selectedReport = val;
                                getData();
                              },
                              validator: (val) => val == null ? '' : null,
                              fromPage: 'ceo_dashboard',
                            ),
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
                                                          '(${f.SeperateNumber(sumMoneyTotal)} บาท) ${f.SeperateNumber(sumProductCat1)} กระสอบ',style: _baseFontStyle),
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
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายฮอร์โมนได้้',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(cashProductCat2)} ขวด',style: _baseFontStyle),
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
                                                          '(${f.SeperateNumber(cashMoneyTotal)} บาท) ${f.SeperateNumber(cashProductCat1)} กระสอบ',style: _baseFontStyle),
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
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'ขายฮอร์โมนได้้',style: _baseFontStyle,),
                                                      Text(
                                                          '${f.SeperateNumber(cashProductCat2)} ขวด',style: _baseFontStyle),
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
                                                          '(${f.SeperateNumber(creditMoneyTotal)} บาท) ${f.SeperateNumber(creditProductCat1)} กระสอบ',style: _baseFontStyle),
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
                                            ListView.builder(
                                              shrinkWrap: true,
                                                primary: false,
                                                itemCount: snapshot.data.length,
                                                itemBuilder: (bc, i) {
                                                  var data = snapshot.data[i];
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10,right: 10,top: 8),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.arrow_right,size: 20,),
                                                            Flexible(child: Text('อันดับที่ ${i + 1} ทะเบียนรถ ${data['car_plate_number']} ${data['car_plate_province']} ',style: _baseFontStyle,)),
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

                                                            Text('รวม : ${f.SeperateNumber(data['car_sum_cat1'])} กระสอบ',style: _baseFontStyle,),
                                                          ],

                                                        ),
                                                      ),
                                                      Divider(indent: 16,endIndent: 16,),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 16,right: 16),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                    'เงินสด 590 : ${f.SeperateNumber(data['car_bill_cash_cat1_590'])} กระสอบ',style: _baseFontStyle,),
                                                                Text(
                                                                    'เงินสด 690 : ${f.SeperateNumber(data['car_bill_cash_cat1_690'])} กระสอบ',style: _baseFontStyle,),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                    'เครดิต 590 : ${f.SeperateNumber(data['car_bill_credit_cat1_590'])} กระสอบ',style: _baseFontStyle,),
                                                                Text(
                                                                    'เครดิต 690 : ${f.SeperateNumber(data['car_bill_credit_cat1_690'])} กระสอบ',style: _baseFontStyle,),
                                                              ],
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 2,),
                                                      if(i!=snapshot.data.length-1)
                                                        Divider(thickness: 2,),

                                                    ],
                                                  );
                                                }),

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
