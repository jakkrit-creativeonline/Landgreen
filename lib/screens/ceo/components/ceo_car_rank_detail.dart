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

class CeoCarRankDetail extends StatefulWidget {
  @override
  _CeoCarRankDetailState createState() => _CeoCarRankDetailState();
}

class _CeoCarRankDetailState extends State<CeoCarRankDetail> {
  List carData = [];
  List provinceData = [];
  List showData = [];
  List showDataTemp = [];
  String selectedReport;
  List<DropdownMenuItem> optionReport = [];
  var client = Client();
  Future<bool> isLoaded;
  FormatMethod f = FormatMethod();
  DateTime initDate = DateTime.now();
  String selectedMonth = '';
  var monthSelectText = TextEditingController();

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

  Future getAvaliable() async {
    //print('getAvaliable');
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

  Future refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      isLoaded = Future.value();
      showData = [];
      showDataTemp = [];

      var res = await client.post('$apiPath-ceo', body: {
        'func': 'get_data_report_rank_head_cache',
        'namefile': selectedReport
      });
      if (res.body != '{}') {
        Sqlite().insertJson('CEO_CAR_RANKING_DETAIL', selectedReport, res.body);
        showDataTemp = jsonDecode(res.body);
      }
      generateData(showDataTemp);
      isLoaded = Future.value(true);
      Navigator.pop(context);
      if(mounted)setState(() {});
    }
  }

  Future getData() async {
    getCarAll();
    getProvinceAll();
    await getAvaliable();
    await getCache(selectedReport);
  }

  Future getCarAll() async {
    var res = await Sqlite().query('SETTING_CAR', firstRow: false);
    carData = res;
    //print(carData);
  }

  Future getProvinceAll() async {
    var res = await Sqlite().query('PROVINCE', firstRow: false);
    provinceData = res;
  }

  generateData(showDataTemp) {
    //เฉพาะหัวหน้า
    List result = showDataTemp
        .where(
            (element) => element['Level_id'] > 1 && element['Work_car_id'] != 0)
        .toList();
    result.sort((a, b) => b['Level_id'] - a['Level_id']);

    //รถที่ไม่ซ้ำกัน
    List result_cut = [];
    result.forEach((data) {
      var find = result_cut.firstWhere(
          (element) => element['Work_car_id'] == data['Work_car_id'],
          orElse: () => '');
      if (find == '') {
        result_cut.add(data);
      }
    });

    result_cut.sort((a, b) =>
        (b['sum_cat1_cash_forsale'] + b['sum_cat1_credit_forsale']) -
        (a['sum_cat1_cash_forsale'] + a['sum_cat1_credit_forsale']));

    result_cut.forEach((data) {
      var find_car = carData.firstWhere(
          (element) => element['ID'] == data['Work_car_id'],
          orElse: () => null);
      var find_province = provinceData.firstWhere(
          (element) =>
              element['PROVINCE_ID'] == data['sale_data']['Sales_Province_id'],
          orElse: () => null);
      //print(find_province);
      List sale_inteam = showDataTemp
          .where((element) =>
              element['sale_data']['Work_car_id'] == data['Work_car_id'])
          .toList();
      List sale_inteam_list = [];

      sale_inteam.forEach((element) {
        bool isRed = false;
        var plus_count_product_cat1 = element['cash_sumCat1_590'] +
            element['cash_sumCat1_690'] +
            element['credit_sumCat1_590'] +
            element['credit_sumCat1_690'] +
            element['credit_wait_sumCat1_590'] +
            element['credit_wait_sumCat1_690'];
        if (plus_count_product_cat1 == 0) {
          isRed = true;
        }
        Map<String, dynamic> tmp_saleinteam = {
          'cash_count_commission_pay_success': 0,
          'cash_count_product_cat1':
              element['cash_sumCat1_590'] + element['cash_sumCat1_690'],
          'cash_count_product_cat2': element['cash_sumCat2'],
          'cash_money_total': element['cash_sumMoneyTotal'],
          'credit_count_commission_pay_success': 0,
          'credit_count_product_cat1': element['credit_sumCat1_590'] +
              element['credit_sumCat1_690'] +
              element['credit_wait_sumCat1_590'] +
              element['credit_wait_sumCat1_690'],
          'credit_count_product_cat2': element['credit_sumCat2'],
          'credit_money_total': element['credit_sumMoneyTotal'] +
              element['credit_wait_sumMoneyTotal'],
          'plus_count_product_cat1': plus_count_product_cat1,
          'sale_id': element['ID'],
          'sale_name': element['Name'],
          'isRed': isRed,
        };
        sale_inteam_list.add(tmp_saleinteam);
      });

      var sum_plus_count_product_cat1 =
          data['sum_cat1_cash_forsale'] + data['sum_cat1_credit_forsale'];
      Map<String, dynamic> tmp = {
        'car_head_img': data['sale_data']['Image'],
        'User_name': data['Name'],
        'count_sale_people': data['cat1forsale'].length,
        'Plate_number': find_car != null ? find_car['Plate_number'] : null,
        'car_province_area':
            find_province != null ? find_province['PROVINCE_NAME'] : null,
        'sum_plus_count_product_cat1': sum_plus_count_product_cat1,
        'sum_cash_count_product_cat1': data['sum_cat1_cash_forsale'],
        'sum_credit_count_product_cat1': data['sum_cat1_credit_forsale'],
        'team_id': data['ID'],
        'sale_array_in_team': sale_inteam_list,
        'isShow': false
      };
      showData.add(tmp);
    });
    showData.removeWhere((element) => element['Plate_number'] == null);
  }

  Future getCache(selectedReport) async {
    showData = [];
    showDataTemp = [];
    var res = await Sqlite().getJson('CEO_CAR_RANKING_DETAIL', selectedReport);
    if (res != null) {
      showDataTemp = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var res = await client.post('$apiPath-ceo', body: {
          'func': 'get_data_report_rank_head_cache',
          'namefile': selectedReport
        });
        if (res.body != '{}') {
          Sqlite()
              .insertJson('CEO_CAR_RANKING_DETAIL', selectedReport, res.body);
          showDataTemp = jsonDecode(res.body);
        }
      }
    }

    generateData(showDataTemp);
    isLoaded = Future.value(true);
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
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                                    Text('รายงานยอดขายรายทีม',style: TextStyle(fontSize: 24.0,height: 1),),
                                    Text('หน้านี้สรุปข้อมูลจากวันที่ลูกค้าเซ็นรับสินค้า',style: TextStyle(fontSize: 16.0,height: 1),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text('สถิติยอดขายแบ่งตามทะเบียนรถ'),
                        // DropDown(
                        //   items: optionReport,
                        //   hintText: '',
                        //   value: selectedReport,
                        //   onChange: (val) => getCache(val),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20,),
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
                  if (showData.length > 0)
                    //listview builder จ้า
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                        var res = showData[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CeoHeadIncomeExpense(headId: res['team_id']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18,right: 18,top: 10),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              children: [
                                ceoRankDetailCardTest(
                                  ranking: i + 1,
                                  imgAvatar: res['car_head_img'],
                                  headName: res['User_name'],
                                  saleCount: res['count_sale_people'],
                                  carNumber: res['Plate_number'],
                                  headArea: res['car_province_area'],
                                  sumCat1: res['sum_plus_count_product_cat1'],
                                  cashCat1: res['sum_cash_count_product_cat1'],
                                  creditCat1: res['sum_credit_count_product_cat1'],
                                  dataShow: res['sale_array_in_team'],
                                  headId: res['team_id'],
                                  isSHow: res['isShow'],
                                ),
                                // Container(
                                //   width: size.width,
                                //   child: IconButton(
                                //       icon: Icon(res['isShow'] == true
                                //           ? Icons.expand_less
                                //           : Icons.expand_more),
                                //       onPressed: () {
                                //         res['isShow'] = !res['isShow'];
                                //         setState(() {});
                                //       }),
                                // )
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: showData.length)),
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

  Widget ceoRankDetailCardTest({
    ranking,
    imgAvatar,
    headName,
    saleCount,
    carNumber,
    headArea,
    sumCat1,
    cashCat1,
    creditCat1,
    List dataShow,
    headId,
    isSHow,
  }) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18,height: 1);
    TextStyle _baseFontWhiteStyle = TextStyle(fontSize: 18,height: 1,color: whiteColor);
    FormatMethod f = FormatMethod();
    dataShow.sort(
        (a, b) => b['plus_count_product_cat1'] - a['plus_count_product_cat1']);
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            HeaderText(text:'อันดับที่ $ranking ทีม$headName',textSize: 20,gHeight: 26,),
            Positioned(
              top: 0,
                right: 0,
                child: Icon(Icons.arrow_right,color: whiteColor,)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0,top: 8,right: 8,bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                          '$storagePath/$imgAvatar'),
                      radius: 30,
                    )
                  ],
                )
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('พนักงาน   : $saleCount คน',style: _baseFontStyle,),
                    Text('ทะเบียนรถ : $carNumber',style: _baseFontStyle,),
                    Text('เขตที่ขาย  : $headArea',style: _baseFontStyle,)
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ยอดขายรวม ${f.SeperateNumber(sumCat1)} กระสอบ',style: _baseFontStyle),
                      Text('เงินสด ${f.SeperateNumber(cashCat1)} กระสอบ',style: _baseFontStyle),
                      Text('เครดิต ${f.SeperateNumber(creditCat1)} กระสอบ',style: _baseFontStyle),
                    ],
                  ))
            ],
          ),
        ),
        Divider(height: 10,indent: 8,endIndent: 8,),
        // if (isSHow == true)

        Padding(
          padding: const EdgeInsets.only(left: 8,right: 8),
          child: Container(
            width: size.width *0.9,
            height: 135,
            child: ListView.builder(
                itemCount: dataShow.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (bc, i) {
                  var res = dataShow[i];
                  return Card(
                    color: res['isRed'] ? danger : grayFontColor,
                    elevation: 1,
                    child:ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 120,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${i + 1}. ${res['sale_name']}',style: _baseFontWhiteStyle,),
                              Divider(color: whiteFontColor,),
                              Text('เงินสด ${res['cash_count_product_cat1']} กระสอบ',style: _baseFontWhiteStyle),
                              Text('เครดิต ${res['credit_count_product_cat1']} กระสอบ',style: _baseFontWhiteStyle),
                              Divider(color: whiteFontColor,),
                              Text('รวม ${res['plus_count_product_cat1']} กระสอบ',style: TextStyle(fontSize: 20,color: whiteFontColor)),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //   children: [
                              //     Expanded(
                              //       child: Text(
                              //           'เงินสด ${res['cash_count_product_cat1']} กระสอบ'),
                              //     ),
                              //     Expanded(
                              //       child: Text(
                              //           'เครดิต ${res['credit_count_product_cat1']} กระสอบ'),
                              //     ),
                              //     Expanded(
                              //       child: Text(
                              //           'รวม ${res['plus_count_product_cat1']} กระสอบ'),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                      ),
                    )

                  );
                  // return Card(
                  //   color: res['isRed'] ? danger : lightColor,
                  //   margin: EdgeInsets.only(bottom: 8),
                  //   elevation: 1,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('ลำดับ ${i + 1} ${res['sale_name']}'),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Expanded(
                  //             child: Text(
                  //                 'เงินสด ${res['cash_count_product_cat1']} กระสอบ'),
                  //           ),
                  //           Expanded(
                  //             child: Text(
                  //                 'เครดิต ${res['credit_count_product_cat1']} กระสอบ'),
                  //           ),
                  //           Expanded(
                  //             child: Text(
                  //                 'รวม ${res['plus_count_product_cat1']} กระสอบ'),
                  //           ),
                  //         ],
                  //       )
                  //     ],
                  //   ),
                  // );
                }),
          ),
        ),
        SizedBox(height: 5,)
      ],
    );
  }
}
