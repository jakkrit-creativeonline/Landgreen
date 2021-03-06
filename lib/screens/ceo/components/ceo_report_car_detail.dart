import 'dart:convert';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/report_car_detail_sale.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:month_picker_dialog/month_picker_dialog.dart';

class CeoReportCarDetail extends StatefulWidget {
  final int carId;
  final DateTime selectedMonth;

  const CeoReportCarDetail({Key key, this.carId, this.selectedMonth})
      : super(key: key);

  @override
  _CeoReportCarDetailState createState() => _CeoReportCarDetailState();
}

class _CeoReportCarDetailState extends State<CeoReportCarDetail> {
  Future<Map<String, dynamic>> carDetail;

  Future<List> showData;

  String firstBillDue = '';
  String lastBillDue = '';
  String selectedMonth = '';
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

  FormatMethod f = FormatMethod();
  var monthSelectText = TextEditingController();


  resetData() {
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

  Future<Null> calculateShowData(showData) async {
    showData.forEach((element) {
      sumBill += element['bill_total'];
      sumCat1 += element['bill_cat1'];
      sumMoney += element['bill_money_due'];
      sumWaitBill += element['waitPay_bill'];
      sumWaitCat1 += element['waitPay_cat1'];
      sumWaitMoney += element['waitPay_money_due'];
      sumSuccessBill += element['paySuccess_bill'];
      sumSuccessCat1 += element['paySuccess_cat1'];
      sumSuccessMoney += element['paySuccess_money'];
    });
    sumPaySomeMoney = sumMoney - (sumSuccessMoney + sumWaitMoney);
    if(sumMoney>0){
      sumSuccessPercent = ((sumSuccessMoney / sumMoney) * 100).round();
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
    print('calculateShowData');
    if (mounted) setState(() {});
  }

  Future<Map<String, dynamic>> getCarDetail() async {
    return Sqlite().getDetailCar(widget.carId);
  }

  Future<List> fetchShowData({bool isRefresh = false}) async {
    resetData();
    var res = await Sqlite()
        .getJson('CEO_CREDIT_REPORT_CAR_${widget.carId}', selectedMonth);
    if (!isRefresh && res != null) {
      print('offline');
      List temp = jsonDecode(res['JSON_VALUE']);
      await calculateShowData(temp);
      temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
      return temp;
    } else {
      print('online');
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      final body = {
        'func': 'reportCreditPerCarDetail',
        'car_id': '${widget.carId}',
        'changeMonthSelect': selectedMonth
      };
      final response = await http.post('$apiPath-credit', body: body);
      Navigator.pop(context);
      if (response.statusCode == 200) {
        List temp = jsonDecode(response.body);
        Sqlite().insertJson('CEO_CREDIT_REPORT_CAR_${widget.carId}',
            selectedMonth, response.body);
        await calculateShowData(temp);
        temp.sort((a, b) => b['waitPay_money_due'] - a['waitPay_money_due']);
        return temp;
      } else
        throw Exception('????????????????????????????????? ???????????????????????????????????????????????????????????????');
    }
  }

  Future refresh() async {
    showData =  fetchShowData(isRefresh: true);
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
        showData = Future.value();
        setState(() {});
        initDate = date;
        selectedMonth =
            '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="????????????????????????????????? "+f.ThaiMonthFormat(_str);
        showData =  fetchShowData();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print('widget.selectedMonth =>${widget.selectedMonth}');
    if (widget.selectedMonth != null) {
      initDate = widget.selectedMonth;
      selectedMonth =
          '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
      var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
      monthSelectText.text="????????????????????????????????? "+f.ThaiMonthFormat(_str);
    }
    carDetail = getCarDetail();
    showData = fetchShowData();
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
                  showTeamName(),
                  summaryInfo(size),
                  showDetail(size),
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

  Widget showDetail(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    TextStyle _baseFontStyleInCard = TextStyle(fontSize: 18,color: Colors.white);
    Size size = MediaQuery.of(context).size;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder(
            future: showData,
            builder: (context, snap) {
              if (snap.hasData) {
                print('has data');
                return ListView.builder(
                    itemCount: snap.data.length,
                    primary: false,
                    shrinkWrap: true,
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
                                          settings: RouteSettings(name: 'CEO????????????????????????????????????????????????????????????'),
                                          builder: (context) => ReportCarDetailSale(
                                                saleId: res['sale_id'],
                                                selectedReport: initDate,
                                              )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Stack(
                                children: [
                                  HeaderText(text: '????????? ${res['Sale_name']}',),
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
                                              Text('${f.SeperateNumber(res['bill_cat1'])} ??????????????????',style: _baseFontStyle,),
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
                                                  Text('${f.SeperateNumber(res['waitPay_cat1'] )} ??????????????????',style: _baseFontStyleInCard,),
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
                                                  Text('${f.SeperateNumber(res['paySuccess_cat1'])} ??????????????????',style: _baseFontStyleInCard,),
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
                      // return GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => ReportCarDetailSale(
                      //                   saleId: res['sale_id'],
                      //                   selectedReport: initDate,
                      //                 )));
                      //   },
                      //   child: Card(
                      //     child: Row(
                      //       children: [
                      //         Expanded(
                      //           flex: 1,
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text('????????? : ${res['Sale_name']}'),
                      //               Text(
                      //                 '????????????????????? : $percent %',
                      //                 style: TextStyle(
                      //                     color: percent == 0
                      //                         ? darkColor
                      //                         : percent < 50
                      //                             ? redColor
                      //                             : percent < 80
                      //                                 ? orangeColor
                      //                                 : kPrimaryColor),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text('?????????????????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_total'])} ?????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_cat1'])} ??????????????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['bill_money_due'])} ?????????'),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text(
                      //                   '????????????????????????',
                      //                   style: TextStyle(color: dangerColor),
                      //                 ),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_bill'])} ?????????',
                      //                     style: TextStyle(color: dangerColor)),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_cat1'])} ??????????????????',
                      //                     style: TextStyle(color: dangerColor)),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['waitPay_money_due'])} ?????????',
                      //                     style: TextStyle(color: dangerColor)),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Expanded(
                      //           child: Card(
                      //             child: Column(
                      //               children: [
                      //                 Text('?????????????????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_bill'])} ?????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_cat1'])} ??????????????????'),
                      //                 Text(
                      //                     '${f.SeperateNumber(res['paySuccess_money'])} ?????????'),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    });
              } else if (snap.hasError) {
                print('error ${snap.error}');
                return Align(
                    alignment: Alignment.topCenter,
                    child: Text('????????????????????????????????? ???????????????????????????????????????????????????????????????'));
              } else {
                print('loading');
                return ShimmerLoading(type: 'boxText2row',);
              }
            }),
      ),
    );
  }

  SliverToBoxAdapter summaryInfo(Size size) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          children: [
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
            // Text('???????????????????????????????????? ??????????????????????????????????????????????????????????????? (???????????????????????????????????? 7 ?????????)'),
            // Text(
            //     '???????????????????????????????????????????????????????????????????????? $firstBillDue ????????? $lastBillDue (?????????????????????????????????????????????????????????????????????????????????)'),
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
            //
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
            // RaisedButton(
            //     child: Text('TEST MONTH PICKER'),
            //     onPressed: () => _showMonthPicker())
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter showTeamName() {
    return SliverToBoxAdapter(
      child: FutureBuilder(
          future: carDetail,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
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
                              Text('????????????????????? ${ (snapshot.data['car_name']==null)?' ':snapshot.data['car_name'] } ',style: TextStyle(fontSize: 24.0,height: 1),),
                              Text('?????????????????? ?????????????????? ?????????${ (snapshot.data['team_name']==null)?' ':snapshot.data['team_name'] } ',style: TextStyle(fontSize: 18.0,height: 1),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text('?????????????????? ?????????????????? ????????????????????? ${snapshot.data['car_name']}'),
                  // Text('?????????${snapshot.data['team_name']}')
                ],
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top:10.0),
                child: Center(child: Text('???????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????')),
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
