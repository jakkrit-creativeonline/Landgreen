import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/ceo_head_income_expense.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CeoManagerRankDetail extends StatefulWidget {
  @override
  _CeoManagerRankDetailState createState() => _CeoManagerRankDetailState();
}

class _CeoManagerRankDetailState extends State<CeoManagerRankDetail> {
  String selectedReport;
  List<DropdownMenuItem> optionReport = [];
  List showData = [];
  Future<bool> isLoaded;
  FormatMethod f = FormatMethod();
  GetReport s = GetReport();
  DateTime initDate = DateTime.now();
  String selectedMonth = '';
  var monthSelectText = TextEditingController();

  Future getAvaliable() async {
    print('getAvaliable');
    var res = await Sqlite().getJson('AVALIABLE_REPORT', '1');
    if (res != null) {
      List data = jsonDecode(res['JSON_VALUE']);
      data.sort((a, b) => b['ID'] - a['ID']);
      setAvaliableOption(data);
    } else {
      setOption(5);
    }
  }

  setAvaliableOption(List data) {
    var monthTH = [
      null,
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค."
    ];
    data.forEach((element) {
      var dateString = '${element['Year']}-${element['Month']}';
      optionReport.add(
        DropdownMenuItem(
          value: dateString,
          child: Text(
            thai_date(int.parse(element['Year']), int.parse(element['Month'])),
          ),
        ),
      );
    });
    selectedReport = '${data[0]['Year']}-${data[0]['Month']}';
    optionReport[0] =
        DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
  }

  setOption(int n) {
    DateTime now = DateTime.now();
    var y = now.year;
    var m = now.month;
    var d = now.day;
    for (int i = 0; i < n; i++) {
      DateTime date = DateTime(now.year, (now.month - i));
      var year = date.year;
      var month = date.month;
      var monthTH = [
        null,
        "ม.ค.",
        "ก.พ.",
        "มี.ค.",
        "เม.ย.",
        "พ.ค.",
        "มิ.ย.",
        "ก.ค.",
        "ส.ค.",
        "ก.ย.",
        "ต.ค.",
        "พ.ย.",
        "ธ.ค."
      ];
      var dateString = '${year.toString()}-${month.toString().padLeft(2, '0')}';
      optionReport.add(DropdownMenuItem(
          value: dateString, child: Text(thai_date(date.year, date.month))));
    }
    // (d >= 1 && d <= 5)
    if (d >= 1 && d <= 5) {
      m = (m - 1) == 0 ? 12 : (m - 1);
      y = y - 1;
      selectedReport = '${y.toString()}-${m.toString().padLeft(2, '0')}';
      optionReport[1] =
          DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
    } else {
      selectedReport = '${y.toString()}-${m.toString().padLeft(2, '0')}';
      optionReport[0] =
          DropdownMenuItem(value: selectedReport, child: Text('ประจำเดือนนี้'));
    }
    //setState(() {});
  }

  String thai_date(int y, int m) {
    var monthTH = [
      null,
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค."
    ];
    return 'ประจำ ${monthTH[m]} ${(y + 543).toString().substring(2)}';
  }

  calPercent(now, before) {
    int result = 0;
    if (before == 0 && now != 0) {
      result = 100;
    } else if (before == 0 && now == 0) {
      result = 0;
    } else if (before != 0 && now == 0) {
      result = 0;
    } else {
      result = (((now / before) * 100) - 100).ceil();
    }
    return result;
  }

  Future getData() async {
    await getAvaliable();
    await getCache(selectedReport);
  }

  Future refresh() async {
    isLoaded = Future.value();
    AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
    var res = await s.getCeoManagerRankDetail(selectedReport: selectedReport);
    showData = jsonDecode(res);
    showData.sort((a, b) => b['sum_money_total'] - a['sum_money_total']);
    isLoaded = Future.value(true);
    if(mounted) setState(() {});
    Navigator.pop(context);
  }

  Future getCache(selectedReport) async {
    print(selectedReport);
    var res = await Sqlite().getJson('CEO_MANAGER_RANK_DETAIL', selectedReport);
    if (res != null) {
      showData = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var res =
            await s.getCeoManagerRankDetail(selectedReport: selectedReport);
        showData = jsonDecode(res);
      }
    }
    showData.sort((a, b) => b['sum_money_total'] - a['sum_money_total']);
    isLoaded = Future.value(true);
    if(mounted) setState(() {});
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
        '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}';

        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="ข้อมูลเดือน "+f.ThaiMonthFormat(_str);
        // showData = fetchShowData();
        getCache(selectedMonth);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
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
                // leading: Builder(
                //   builder: (context) => IconButton(
                //     icon: Icon(Icons.menu, size: 40),
                //     onPressed: () => Scaffold.of(context).openDrawer(),
                //   ),
                // ),

              ),
            ),
            body: RefreshIndicator(
              onRefresh: refresh,
              child: CustomScrollView(
                slivers:[
                  SliverToBoxAdapter(
                    child: FutureBuilder(
                        future: isLoaded,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                            child: Icon(FontAwesomeIcons.chartLine,color: btTextColor,),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('รายงานยอดขายตามสายงานบริหาร',style: TextStyle(fontSize: 24.0,height: 1),),
                                              Text('หน้านี้สรุปข้อมูลจากวันที่ลูกค้าเซ็นรับสินค้า',style: TextStyle(fontSize: 16.0,height: 1),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // DropDown(
                                  //   items: optionReport,
                                  //   value: selectedReport,
                                  //   hintText: '',
                                  //   onChange: (val) {
                                  //     selectedReport = val;
                                  //     getCache(selectedReport);
                                  //   },
                                  // ),
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
                                  ListView.builder(
                                      primary: false,
                                      itemCount: showData.length,
                                      shrinkWrap: true,
                                      itemBuilder: (bc, i) {
                                        var res = showData[i];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    settings: RouteSettings(name: 'CEOดูข้อมูลใต้สีส้มอีกที'),
                                                    builder: (context) =>
                                                        CeoHeadIncomeExpense(
                                                          headId: res['ID'],
                                                        )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 0),
                                            child: Card(
                                              elevation: 2,
                                              child: Column(
                                                children: [
                                                  HeaderText(text:'อันดับที่ ${i + 1} คุณ${res['Name']} ',textSize: 20,gHeight: 26,),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex:1,
                                                            child: showInfo(i, size, res),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Card(
                                                            color: darkColor,
                                                            child: Column(
                                                              children: [
                                                                showPercent(res: res, type: 0),
                                                                Divider(color: whiteColor,height: 2,),
                                                                IntrinsicHeight(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      showPercent(res: res, type: 1),
                                                                      VerticalDivider(color: whiteColor,),
                                                                      showPercent(res: res, type: 2),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )

                                                      ],
                                                    ),
                                                  ),


                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                ShimmerLoading(type: 'boxItem',),
                                ShimmerLoading(type: 'boxItem',),
                                ShimmerLoading(type: 'boxItem1Row',),
                              ],
                            );
                          }
                        }),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                        child: Footer(),
                    ),
                  )
                ]

              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showPercent({res, int type = 0}) {
    //type 0 = รวม, 1 = เงินสด, 2 = เครดิต
    var text = '';
    var money = 0;
    var percent = 0;
    var productCat1 = 0;
    var productCat2 = 0;
    var message = '';
    switch (type) {
      case 0:
        text = 'ยอดขายรวม';
        money = res['sum_money_total'];
        percent =
            calPercent(res['sum_money_total'], res['before_sum_money_total']);
        productCat1 =
            res['cash_count_product_cat1'] + res['credit_count_product_cat1'];
        productCat2 =
            res['cash_count_product_cat2'] + res['credit_count_product_cat2'];
        message =
            '$text ${f.SeperateNumber(productCat1)} กระสอบ | ${f.SeperateNumber(productCat2)} ขวด';
        break;
      case 1:
        text = 'ยอดขายเงินสด';
        money = res['cash_money_total'];
        percent =
            calPercent(res['cash_money_total'], res['before_cash_money_total']);
        productCat1 = res['cash_count_product_cat1'];
        productCat2 = res['cash_count_product_cat2'];
        message =
            '$text ${f.SeperateNumber(productCat1)} กระสอบ | ${f.SeperateNumber(productCat2)} ขวด';
        break;
      case 2:
        text = 'ยอดขายเครดิต';
        money = res['credit_money_total'];
        percent = calPercent(
            res['credit_money_total'], res['before_credit_money_total']);
        productCat1 = res['credit_count_product_cat1'];
        message = '$text ${f.SeperateNumber(productCat1)} กระสอบ';
        break;
      default:
        return Container();
    }
    Color _setColor;
    if(percent == 0){
      _setColor = whiteColor;
    }else if(percent > 0){
      _setColor = kSecondaryColor;
    }else{
      _setColor = dangerColor;
    }
    return Tooltip(
      message: message,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            child: Column(
              children: [
                Text(text, style: TextStyle(fontSize: 18, color: whiteColor,height: 1)),
                Text('${f.SeperateNumber(money)} บาท',
                    style: TextStyle(fontSize: 18, color: _setColor,height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      percent == 0
                          ? Icons.remove
                          : percent > 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                      color: _setColor,
                    ),
                    Text('${percent.abs()} %',
                        style: TextStyle(fontSize: 18, color: _setColor,height: 1)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showInfo(int i, Size size, res) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,height: 1);
    print('$storagePath/${res['Image']}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipOval(
          child: CachedNetworkImage(
            width: size.width*0.2,
            imageUrl: '$storagePath/${res['Image']}',
            errorWidget: (context, url, error) {
              return Image.asset('assets/avatar.png');
            },
          ),
        ),
        SizedBox(height: 5,),
        Text('หัวหน้าทีม ${res['head_count']} คน',style: _baseFontStyle,),
        Text('พนักงานขาย ${res['sale_count']} คน',style: _baseFontStyle),
        Text('จำนวนรถยนต์ ${res['car_count']} คน',style: _baseFontStyle),
      ],
    );
  }
}
