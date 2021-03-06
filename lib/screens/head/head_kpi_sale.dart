import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;
import 'package:system/screens/head/components/head_kpi_sale_detail.dart';

class HeadKPISale extends StatefulWidget {
  final int carId;
  final DateTime selectedMonth;

  const HeadKPISale({Key key, this.carId, this.selectedMonth})
      : super(key: key);

  @override
  _HeadKPISaleState createState() => _HeadKPISaleState();
}

class _HeadKPISaleState extends State<HeadKPISale> {
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
    sumWaitBill = 0;
    sumWaitCat1 = 0;
    sumSuccessBill = 0;
    sumSuccessCat1 = 0;
    sumSuccessPercent = 0;
    sumPaySomeMoney = 0;
  }

  Future<Null> calculateShowData(showData) async {
    showData.forEach((element) {
      sumBill += element['sum_bill'];
      sumCat1 += element['sum_cat1'];
      sumWaitBill += element['book_bill'];
      sumWaitCat1 += element['book_cat1'];
      sumSuccessBill += element['sended_bill'];
      sumSuccessCat1 += element['sended_cat1'];
    });
    sumPaySomeMoney = sumCat1 - (sumSuccessCat1 + sumWaitCat1);
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
    print('firstDayOfMonth => $firstDayOfMonth');
    print('lastDayOfMonth => $lastDayOfMonth');
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
        .getJson('KPI_SALE_TEAM_${widget.carId}', selectedMonth);
    if (!isRefresh && res != null) {
      print('offline');
      print('${res['JSON_VALUE']}');
      print('${res['JSON_VALUE'].runtimeType}');
      List temp = jsonDecode(res['JSON_VALUE'],);
      print("temp => ${temp.runtimeType}");
      // List obj_car = temp.where((ele) => ele['car_id']==widget.carId).toList();
      await calculateShowData(temp);
      temp.sort((a, b) => b['book_bill'] - a['book_bill']);
      return temp;
    } else {
      print('online');
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      final body = {
        'func': 'reportKPISale',
        'car_id': '${widget.carId}',
        'changeMonthSelect': selectedMonth
      };
      final response = await http.post('$apiPath-accounts', body: body);
      Navigator.pop(context);
      if (response.statusCode == 200) {
        List temp = jsonDecode(response.body);
        List obj_car = temp.where((ele) => ele['car_id']==widget.carId).toList();
        print('????????????????????????????????? =>${obj_car[0]['car_sale'].runtimeType}');
        String jsonInsert = jsonEncode(obj_car[0]['car_sale']);
        Sqlite().insertJson('KPI_SALE_TEAM_${widget.carId}',
            selectedMonth, jsonInsert);
        List obj = obj_car[0]['car_sale'];
        await calculateShowData(obj);
        obj.sort((a, b) => b['book_bill'] - a['book_bill']);
        return obj;
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
                titleSpacing: 0.00,
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
            body: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                slivers: [
                  showTeamName(),
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
              ),
            ),
          ),
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
                            child: Icon(FontAwesomeIcons.chartPie,color: btTextColor,),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('????????????????????? ${ (snapshot.data['car_name'] == null)?' ':snapshot.data['car_name']} ',style: TextStyle(fontSize: 24.0,height: 1),),
                              Text('????????????????????????????????????????????????????????? ?????????${(snapshot.data['team_name'] == null)?' ':snapshot.data['team_name'] } ',style: TextStyle(fontSize: 18.0,height: 1),),
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
                '?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? $firstBillDue ????????? $lastBillDue (?????????????????????????????????????????????????????????????????????????????????)',style: TextStyle(fontSize: 15),),
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
                            Text('???????????????????????? ',style: _baseFontStyle,),
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
                  HeaderText(text: '?????????????????????',textSize: 20,gHeight: 26,),
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
                            Text('???????????????????????? ',style: _baseFontStyle,),
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
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeaderText(text: '???????????????????????????????????????',textSize: 20,gHeight: 26,),
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
                            Text('???????????????????????? ',style: _baseFontStyle,),
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
                            Text('?????????????????????%????????????????????????????????????????????????',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),
                            ),
                            Text('${f.SeperateNumber(sumSuccessPercent)} %',style: TextStyle(
                              fontSize: 18,color: (sumSuccessPercent<50)?dangerColor:(sumSuccessPercent<80)?warningColor:kSecondaryColor,
                            ),),
                          ],
                        ),
                        Text('(%?????????????????? ??????????????????????????????????????????????????????????????? ????????????????????? ??????????????????????????????????????????????????????)',style: TextStyle(fontSize: 12)),
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
                print('has data =>${snap.data.length}');
                return ListView.builder(
                    itemCount: snap.data.length,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (bc, i) {
                      var res = snap.data[i];
                      var work_status = res['Sale_work_status']==1?'':'(?????????)';
                      var percent = 0;
                      if (res['sum_cat1'] > 0) {
                        percent =
                            ((res['sended_cat1'] / res['sum_cat1']) *
                                100)
                                .round();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(name: '(${res['Sale_id']})???????????????????????????????????????????????????????????????????????????????????????'),
                                  builder: (context) => HeadKPISaleDetail(
                                    saleId: res['Sale_id'],
                                    selectedReport: initDate,
                                  )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Stack(
                                children: [
                                  HeaderText(text: '????????? ${res['Sale_name']} $work_status',),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              Text('?????????????????????????????????????????????',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['sum_bill'])} ?????????',style: _baseFontStyle,),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('??????????????????????????????????????????????????????',style: _baseFontStyle,),
                                              Text('${f.SeperateNumber(res['sum_cat1'])} ??????????????????',style: _baseFontStyle,),
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
                                          padding: const EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 3),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '?????????????????????',
                                                style: TextStyle(color: Colors.white,fontSize: 18,height: 1),
                                              ),
                                              Text(
                                                '$percent%',
                                                style: TextStyle(color: Colors.white,fontSize: 38,height: 0.8),
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
                                                  Text('?????????????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['book_bill'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('???????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['book_cat1'] )} ??????????????????',style: _baseFontStyleInCard,),
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
                                                  Text('${f.SeperateNumber(res['sended_bill'])} ?????????',style: _baseFontStyleInCard,),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('???????????????',style: _baseFontStyleInCard,),
                                                  Text('${f.SeperateNumber(res['sended_cat1'])} ??????????????????',style: _baseFontStyleInCard,),
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


}
