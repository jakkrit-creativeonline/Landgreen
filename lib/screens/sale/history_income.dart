import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryIncome extends StatefulWidget {
  final int userId;

  const HistoryIncome({Key key, this.userId}) : super(key: key);

  @override
  _HistoryIncomeState createState() => _HistoryIncomeState();
}

class _HistoryIncomeState extends State<HistoryIncome> {
  List incomeData = [];
  List productData = [];
  Future<bool> isLoaded;
  FormatMethod f = FormatMethod();

  Future getData() async {
    var res = await Sqlite().getJson('HISTORY_INCOME', '${widget.userId}');
    if (res != null) {
      incomeData = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var client = Client();
        var body = {
          'func': 'getCommissionPayHistoryforSale',
          'user_id': '${widget.userId}'
        };
        var res = await client.post('$apiPath-accounts', body: body);
        incomeData = jsonDecode(res.body);
        Sqlite().insertJson('HISTORY_INCOME', '${widget.userId}', res.body);
      }
    }
    isLoaded = Future.value(true);
    setState(() {});
  }

  String thai_month(date) {
    DateTime now = DateTime.parse(date);
    List monthTh = [
      null,
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return '${monthTh[now.month]} ${(now.year + 543).toString().substring(2)}';
  }

  _launchURL(id) async {
    var url = 'https://thanyakit.com/systemv2/public/#/account-tax_view/$id';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Text> listProduct(data) {
    return List.generate(data.length, (index) {
      var res = data[index];
      if (index == 0 && res != 0) {
        return Text('ปุ๋ยกระสอบ 590 : $res กระสอบ');
      }
      if (index == 1 && res != 0) {
        return Text('ปุ๋ยกระสอบ 690 : $res กระสอบ');
      }
      if (index == 2 && res != 0) {
        return Text('ฮอร์โมน : $res ขวด');
      }
      return Text('');
    });
  }

  List<Widget> listDetail(data, rate_590, rate_690, dataOrder) {
    TextStyle _baseFontStyle = TextStyle(fontSize: 18, height: 1);
    TextStyle _miniFontStyle = TextStyle(fontSize: 15, height: 1);
    return List.generate(data.length, (index) {
      var res = data[index];
      var res2 = dataOrder[index];

      if (res != 0) {
        if (index == 0) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ปุ๋ยราคา 590  ขายได้ ${res2} กส.',
                      style: _baseFontStyle,
                    ),
                  ),
                  Text('${f.SeperateNumber(res)} บาท', style: _baseFontStyle)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '',
                      style: _baseFontStyle,
                    ),
                  ),
                  Text('(คอม.เรท $rate_590 บาท/กส.)', style: _miniFontStyle)
                ],
              ),
            ],
          );
        }
        if (index == 1) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('ปุ๋ยราคา 690  ขายได้ ${res2} กส.',
                        style: _baseFontStyle),
                  ),
                  Text('${f.SeperateNumber(res)} บาท', style: _baseFontStyle)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '',
                      style: _baseFontStyle,
                    ),
                  ),
                  Text('(คอม.เรท $rate_690 บาท/กส.)', style: _miniFontStyle)
                ],
              ),
            ],
          );
        }
        if (index == 2) {
          return Row(
            children: [
              Expanded(
                child:
                    Text('ฮอร์โมน ขายได้ ${res2} ขวด ', style: _baseFontStyle),
              ),
              Text('${f.SeperateNumber(res)} บาท', style: _baseFontStyle)
            ],
          );
        }
      }

      return Row(
        children: [Container()],
      );
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
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    print("--------->${incomeData.length}");
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
                  // title: Text('สร้างใบสั่งจองสินค้า'),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/bgTop2.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  title: Text('ประวัติรายได้'),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: (incomeData.length > 0)
                    ? FutureBuilder(
                        future: isLoaded,
                        builder: (bc, snap) {
                          if (snap.hasData) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              child: ListView.builder(
                                  itemCount: incomeData.length,
                                  shrinkWrap: true,
                                  itemBuilder: (bc, i) {
                                    var res = incomeData[i];
                                    return Card(
                                      elevation: 1,
                                      child: Container(
                                        padding: EdgeInsets.all(0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            HeaderText(
                                              text:
                                                  'รายได้เดือน ${thai_month(res['Data_date'])}',
                                              textSize: 20,
                                              gHeight: 26,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8, top: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_right,
                                                      color: mainFontColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    'รายละเอียดรายได้',
                                                    style: _baseFontStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  bottom: 8),
                                              child: Column(
                                                children: [
                                                  Column(
                                                    children: listDetail(
                                                        res['Sumcommission']
                                                            .split(','),
                                                        res[
                                                            'Sale_received_commission_rate_cat1_590'],
                                                        res[
                                                            'Sale_received_commission_rate_cat1_690'],
                                                        res['Qtyordercat']
                                                            .split(',')),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                              'รายได้อื่น ๆ : ',
                                                              style:
                                                                  _baseFontStyle)),
                                                      Text(
                                                          '${f.SeperateNumber(res['Sum_income'])} บาท',
                                                          style: _baseFontStyle)
                                                    ],
                                                  ),
                                                  if (res['Sale_level_id'] != 1)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                'ค่าส่วนต่าง : ',
                                                                style:
                                                                    _baseFontStyle)),
                                                        res['Sale_level_id'] ==
                                                                2
                                                            ? Text(
                                                                '${f.SeperateNumber(res['Sum_money_share_headmain'])} บาท',
                                                                style:
                                                                    _baseFontStyle)
                                                            : Text(
                                                                '${f.SeperateNumber(res['Sumusermoney2other'])} บาท',
                                                                style:
                                                                    _baseFontStyle)
                                                      ],
                                                    ),
                                                  if (res['MoneyRecommend'] !=
                                                      0)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                'ค่าแนะนำ : ',
                                                                style:
                                                                    _baseFontStyle)),
                                                        Text(
                                                            '${f.SeperateNumber(res['MoneyRecommend'])} บาท',
                                                            style:
                                                                _baseFontStyle)
                                                      ],
                                                    ),
                                                  if (res['SumEXPENSES'] != 0)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                'หักค่าใช้จ่าย : ',
                                                                style:
                                                                    _baseFontStyle)),
                                                        Text(
                                                            '${f.SeperateNumber(res['SumEXPENSES'])} บาท',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  dangerColor,
                                                            ))
                                                      ],
                                                    ),
                                                  if (res['Tax_money'] != 0)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                'หัก ณ ที่จ่าย 3% : ',
                                                                style:
                                                                    _baseFontStyle)),
                                                        // IconButton(
                                                        //     icon: Icon(Icons.slideshow),
                                                        //     onPressed: () =>
                                                        //         _launchURL(res['ID'])),
                                                        Text(
                                                            '${f.SeperateNumber(res['Tax_money'])} บาท',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  dangerColor,
                                                            )),
                                                      ],
                                                    ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                              'รายได้สุทธิ : ',
                                                              style:
                                                                  _baseFontStyle)),
                                                      Text(
                                                          '${f.SeperateNumber(res['Net_money'])} บาท',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                kPrimaryColor,
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Text('สินค้าที่ขาย'),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //   MainAxisAlignment.spaceEvenly,
                                            //   children: listProduct(
                                            //       res['Qtyordercat'].split(',')),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          } else {
                            return ListView(
                              children: [
                                ShimmerLoading(
                                  type: 'boxText',
                                ),
                              ],
                            );
                            // return Column(
                            //   children: [
                            //     Text('ประวัติรายได้'),
                            //     Center(
                            //       child: CircularProgressIndicator(),
                            //     ),
                            //   ],
                            // );
                          }
                        }
                        )
                    : Center(
                      child: Container(
                        width:
                        size.width * 0.98,
                        height:
                        size.height * 0.42,
                        decoration:
                        BoxDecoration(
                          image:
                          DecorationImage(
                            image: AssetImage(
                                "assets/img/bgAlert.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .center,
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            SizedBox(
                              width:
                              size.width *
                                  0.28,
                              child: Image.asset(
                                  "assets/icons/icon_alert.png"),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  top: 15),
                              child: Text(
                                "ไม่มีข้อมูลที่ท่านเรียก",
                                style:
                                TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  top: 5),
                              child: Text(
                                "ไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้เปิดบิล ไม่ได้ออกใบเสร็จ\nหรือไม่ได้ออกแจกสินค้าทดลอง",
                                style: TextStyle(
                                    fontSize:
                                    23,
                                    color: Colors
                                        .white,
                                    height: 1),
                                textAlign:
                                TextAlign
                                    .center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                  Footer(),
                ],
              ),
            ),
          ),
        ));
  }
}
