import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/ceo_report_car_detail.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class CreditReportCar extends StatefulWidget {
  @override
  _CreditReportCarState createState() => _CreditReportCarState();
}

class _CreditReportCarState extends State<CreditReportCar> {
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();
  Future<List> showData;
  Future<bool> isLoaded;
  String selectedMonth = '';
  String timeGen = '';
  String dayGen = '';
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
  DateTime initDate = DateTime.now();
  int totalLength = 0;
  int showLength = 0;
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
  }

  Future _refresh() async {
    showData = fetchShowData(isRefresh: true);
  }

  Future<List> fetchShowData({bool isRefresh = false}) async {
    resetData();
    var res = await Sqlite().getJson('CEO_CREDIT_REPORT_CAR', selectedMonth);
    if (!isRefresh && res != null) {
      List temp = jsonDecode(res['JSON_VALUE']);
      await calculateShowData(temp);
      temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
      return temp;
    } else {
      var result = await s.getCreditReportCar(selectedMonth: selectedMonth);
      try {
        List temp = jsonDecode(result);
        await calculateShowData(temp);
        temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
        return temp;
      } catch (e) {
        throw Exception('?????????????????????????????????????????? : $e');
      }
    }
  }

  Future calculateShowData(showData) async {
    showData.forEach((element) {
      sumBill += element['bill_total'];
      sumCat1 += element['bill_cat1_590'] + element['bill_cat1_690'];
      sumMoney += element['bill_money_due'];
      sumWaitBill += element['waitPay_bill'];
      sumWaitCat1 += element['waitPay_cat1_590'] + element['waitPay_cat1_690'];
      sumWaitMoney += element['waitPay_money_due'];
      sumSuccessBill += element['paySuccess_bill'];
      sumSuccessCat1 +=
          element['paySuccess_cat1_590'] + element['paySuccess_cat1_690'];
      sumSuccessMoney += element['paySuccess_money'];
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
    setState(() {});
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
        monthSelectText.text="????????????????????????????????? "+f.ThaiMonthFormat(_str);
        showData = fetchShowData();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    showData = fetchShowData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      summaryInfo(size),

                      showDetail(size),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: true,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Footer(),
                        ),
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }

  Widget showDetail(size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    TextStyle _baseFontStyleInCard = TextStyle(fontSize: 18,color: Colors.white);
    Size size = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
            future: showData,
            builder: (bc, snap) {
              if (snap.hasData) {
                return ListView.builder(
                    shrinkWrap:true,
                    primary: false,
                    itemCount: snap.data.length,
                    itemBuilder: (bc, i) {
                      var res = snap.data[i];
                      var percent = 0;
                      if (res['bill_money_due'] > 0) {
                        percent =
                            ((res['paySuccess_money'] / res['bill_money_due']) *
                                    100)
                                .round();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(name: '??????????????????????????????????????????????????????????????????????????????'),
                                  builder: (context) => CeoReportCarDetail(
                                        carId: res['car_id'],
                                        selectedMonth: initDate,
                                      )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Stack(
                                children: [
                                  HeaderText(text: '???????????????????????? ${i+1} ????????? ${res['team_name']}',),
                                  Positioned(
                                    right: -1,
                                    top: -2,
                                    child: Container(
                                      child: Icon(Icons.arrow_right,color: Colors.white,size: 28,),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 7,top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('????????????????????? : ${res['car_name']}',style: _baseFontStyle,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('????????????????????????????????????????????????',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_total'])} ?????????',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('?????????????????????????????????',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_cat1_590'] + res['bill_cat1_690'])} ??????????????????',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('????????????????????????????????????????????????????????????',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['bill_money_due'])} ?????????',style: _baseFontStyle,),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Card(
                                        color: (percent == 0)
                                                ? darkColor
                                                    : percent < 50
                                                ? redColor
                                                  : percent < 80
                                                  ? warningColor
                                                  : kSecondaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10,left: 8,right: 8,bottom: 5),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '????????????????????????????????????',
                                                style: TextStyle(color: Colors.white,fontSize: 18,height: 1),
                                              ),
                                              Text(
                                                '$percent%',
                                                style: TextStyle(color: Colors.white,fontSize: 40,height: 0.8),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              Divider(indent: 15,endIndent: 10,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 8,bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: dangerColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8,bottom: 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('????????????????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_bill'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('???????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_cat1_590'] + res['waitPay_cat1_690'])} ??????????????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('?????????????????????????????????????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['waitPay_money_due'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: kSecondaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8,bottom: 8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('?????????????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_bill'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('???????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_cat1_590'] + res['paySuccess_cat1_690'])} ??????????????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('?????????????????????????????????????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['paySuccess_money'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      );
                    });
              } else if (snap.hasError) {
                return Center(child: Text(''));
              } else {
                return ShimmerLoading(type: 'boxText2row',);
              }
            }),
      ),
    );
    // return SliverList(
    //     delegate: SliverChildBuilderDelegate((bc, i) {
    //   var res = showData[i];
    //   var percent = 0;
    //   if (res['bill_money_due'] > 0) {
    //     percent =
    //         ((res['paySuccess_money'] / res['bill_money_due']) * 100).round();
    //   }
    //   return GestureDetector(
    //     onTap: () {
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => CeoReportCarDetail(
    //                     carId: res['car_id'],
    //                   )));
    //     },
    //     child: Card(
    //       child: Row(
    //         children: [
    //           Expanded(
    //             flex: 1,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text('????????? : ${res['team_name']}'),
    //                 Text('????????????????????? : ${res['car_name']}'),
    //                 Text(
    //                   '????????????????????? : $percent %',
    //                   style: TextStyle(
    //                       color: percent == 0
    //                           ? darkColor
    //                           : percent < 50
    //                               ? redColor
    //                               : percent < 80
    //                                   ? orangeColor
    //                                   : kPrimaryColor),
    //                 )
    //               ],
    //             ),
    //           ),
    //           Expanded(
    //             child: Card(
    //               child: Column(
    //                 children: [
    //                   Text('?????????????????????'),
    //                   Text('${f.SeperateNumber(res['bill_total'])} ?????????'),
    //                   Text(
    //                       '${f.SeperateNumber(res['bill_cat1_590'] + res['bill_cat1_690'])} ??????????????????'),
    //                   Text('${f.SeperateNumber(res['bill_money_due'])} ?????????'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: Card(
    //               child: Column(
    //                 children: [
    //                   Text('????????????????????????'),
    //                   Text('${f.SeperateNumber(res['waitPay_bill'])} ?????????'),
    //                   Text(
    //                       '${f.SeperateNumber(res['waitPay_cat1_590'] + res['waitPay_cat1_690'])} ??????????????????'),
    //                   Text('${f.SeperateNumber(res['waitPay_money_due'])} ?????????'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             child: Card(
    //               child: Column(
    //                 children: [
    //                   Text('?????????????????????'),
    //                   Text('${f.SeperateNumber(res['paySuccess_bill'])} ?????????'),
    //                   Text(
    //                       '${f.SeperateNumber(res['paySuccess_cat1_590'] + res['paySuccess_cat1_690'])} ??????????????????'),
    //                   Text('${f.SeperateNumber(res['paySuccess_money'])} ?????????'),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }, childCount: showLength));
  }

  SliverToBoxAdapter summaryInfo(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text('?????????????????? ?????????????????? ???????????????????????????????????????????????????',style: TextStyle(fontSize: 24.0,height: 1),),
                        Text('?????????????????????????????????????????????????????????????????????????????????????????????????????????????????? (???????????????????????????????????? 7 ?????????)',style: TextStyle(fontSize: 16.0,height: 1),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Text('?????????????????? ?????????????????? ???????????????????????????????????????????????????'),
            // Text('???????????????????????????????????? ??????????????????????????????????????????????????????????????? (???????????????????????????????????? 7 ?????????)'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                  '???????????????????????????????????????????????????????????????????????? $firstBillDue ????????? $lastBillDue (?????????????????????????????????????????????????????????????????????????????????)',style: TextStyle(fontSize: 15),),
            ),
            SizedBox(height: 5,),
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
                                        // labelText:'?????????????????? ??? ??????????????????',
                                        hintText: '?????????????????????????????????????????????????????????',
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
            // RaisedButton(
            //     child: Text('TEST MONTH SELECT'),
            //     onPressed: () => _showMonthPicker()),
            SizedBox(height: 5,),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: '??????????????????????????????????????????',textSize: 20,gHeight: 26,),
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
                            Text('??????????????????????????? ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumBill)} ?????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumCat1)} ??????????????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('???????????????????????????????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumMoney)} ?????????',style: _baseFontStyle),
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
            //           Text('??????????????????????????????????????????'),
            //           Text('??????????????????????????? : ${f.SeperateNumber(sumBill)} ?????????'),
            //           Text('????????????????????????????????? : ${f.SeperateNumber(sumCat1)} ??????????????????'),
            //           Text(
            //               '???????????????????????????????????????????????????????????? : ${f.SeperateNumber(sumMoney)} ?????????'),
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
                  HeaderText(text: '?????????????????????????????????',textSize: 20,gHeight: 26,),
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
                            Text('??????????????????????????? ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumWaitBill)} ?????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitCat1)} ??????????????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('???????????????????????????????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumWaitMoney)} ?????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('??????????????????????????????????????????(?????????????????????????????????????????????) ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumPaySomeMoney)} ?????????',style: _baseFontStyle),
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
            //           Text('????????????????????? ????????????????????????'),
            //           Text('??????????????????????????? : ${f.SeperateNumber(sumWaitBill)} ?????????'),
            //           Text(
            //               '????????????????????????????????? : ${f.SeperateNumber(sumWaitCat1)} ??????????????????'),
            //           Text(
            //               '???????????????????????????????????????????????????????????? : ${f.SeperateNumber(sumWaitMoney)} ?????????'),
            //           Text(
            //               '??????????????????????????????????????????(?????????????????????????????????????????????) : ${f.SeperateNumber(sumPaySomeMoney)} ?????????'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: '??????????????????????????????',textSize: 20,gHeight: 26,),
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
                            Text('??????????????????????????? ',style: _baseFontStyle,),
                            Text('${f.SeperateNumber(sumSuccessBill)} ?????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessCat1)} ??????????????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('???????????????????????????????????????????????????????????? ',style: _baseFontStyle),
                            Text('${f.SeperateNumber(sumSuccessMoney)} ?????????',style: _baseFontStyle),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('?????????????????????%???????????????????????????????????????????????????',style: TextStyle(
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
            //           Text('????????????????????? ?????????????????????'),
            //           Text('??????????????????????????? : ${f.SeperateNumber(sumSuccessBill)} ?????????'),
            //           Text(
            //               '????????????????????????????????? : ${f.SeperateNumber(sumSuccessCat1)} ??????????????????'),
            //           Text(
            //               '???????????????????????????????????????????????????????????? : ${f.SeperateNumber(sumSuccessMoney)} ?????????'),
            //           Text(
            //               '?????????????????????%??????????????????????????????????????????????????? : ${f.SeperateNumber(sumSuccessPercent)} %'),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
