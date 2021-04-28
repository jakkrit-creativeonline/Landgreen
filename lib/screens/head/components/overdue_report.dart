import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/header_text.dart';

import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class OverDueReport extends StatefulWidget {
  final int workCarId;
  final int userId;

  const OverDueReport({Key key, this.workCarId, this.userId}) : super(key: key);
  @override
  _OverDueReportState createState() => _OverDueReportState();
}

class _OverDueReportState extends State<OverDueReport> {
  List ds = [];
  DateTimeRange dtr;
  int sumQty = 0;
  int qty_590 = 0;
  int qty_690 = 0;
  int sum_money_due = 0;
  int sum_pay_success = 0;
  int sum_pay_success_people = 0;
  Future<bool> isLoaded;
  FormatMethod f = FormatMethod();

  var client = Client();
  var client2 = new Client();

  void reset() {
    sumQty = 0;
    qty_590 = 0;
    qty_690 = 0;
    sum_money_due = 0;
    sum_pay_success = 0;
    sum_pay_success_people = 0;
    ds = [];
  }

  Future<Null> getData({String startDate = '', String endDate = ''}) async {
    print('get over due');
    await getOverDue(startDate: startDate, endDate: endDate);
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Null> getOverDue({String startDate = '', String endDate = ''}) async {
    reset();
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      var data = {
        'func': 'get_overdue_in_car',
        'startDate': startDate,
        'endDate': endDate,
        'carID': '${widget.workCarId}',
        // 'user_id': '${widget.userId}'
      };
      print('data in over due 1 $data');
        var res =  await client.post('$apiPath-manager', body: data);
        ds = jsonDecode(res.body);
        if (ds != null && ds.length > 0) {
          sum_money_due =
              ds.fold(0, (pv, ele) => pv + ele['customer_money_due']);
          ds.forEach((element) {
            var obj = jsonDecode(element['bill_order']);
            obj.forEach((item) {
              if (item['cat_id'] == 1) {
                sumQty += item['qty'];
                if (item['price_sell'] == 590) {
                  qty_590 += item['qty'];
                } else if (item['price_sell'] == 690) {
                  qty_690 += item['qty'];
                }
              }
            });
          });
        }
        data['func'] = 'get_customer_credit_pay_success_in_car';
        print('data in over due $data');

      var res2 = await client2.post('$apiPath-credit', body: data);
      List result2 = jsonDecode(res2.body);
      print('result in over due $result2');
      if (result2 != null && result2.length > 0) {
        sum_pay_success = result2.fold(
            0, (pv, ele) => pv + int.parse(ele['customer_money_pay']));
        sum_pay_success_people = result2.length;
      }

    }
    isLoaded = Future.value(true);
    if(mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    DateTime n = DateTime.now();
    dtr = DateTimeRange(
        start: DateTime(n.year, n.month),
        end: DateTime(n.year, n.month, n.day));
    getData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextStyle _baseFontStyle = TextStyle(fontSize: 18);
    double height = 235;
    if(size.width <=375){
      height = 270;
    }
    return FutureBuilder(
        future: isLoaded,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (ds.length > 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
                child: Card(
                  child: Column(
                    children: [
                      HeaderText(text: 'สรุปข้อมูลลูกค้าเครดิตค้างชำระประจำเดือนนี้',textSize: 20,gHeight: 26,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ค้างชำระ',style: _baseFontStyle,),
                                Text('${ds.length} บิล / ${f.SeperateNumber(sumQty)} กระสอบ',style: _baseFontStyle),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('จำนวนเงินทั้งหมด',style: _baseFontStyle,),
                                Text('${f.SeperateNumber(sum_money_due)} บาท',style: _baseFontStyle),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ชำระเงินแล้วบางส่วน',style: _baseFontStyle,),
                                Text('${f.SeperateNumber(sum_pay_success)} บาท / ${f.SeperateNumber(sum_pay_success_people)} บิล',style: _baseFontStyle),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('คิดเป็น',style: _baseFontStyle,),
                                Text('${(sum_pay_success / sum_money_due * 100).toStringAsFixed(2)} %',style: _baseFontStyle),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ปุ๋ยเม็ด 590 จำนวน',style: _baseFontStyle,),
                                Text('${f.SeperateNumber(qty_590)} กระสอบ',style: _baseFontStyle),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ปุ๋ยเม็ด 690 จำนวน',style: _baseFontStyle,),
                                Text('${f.SeperateNumber(qty_690)} กระสอบ',style: _baseFontStyle),
                              ],
                            ),

                          ],
                        ),
                      ),

                      Container(
                        height: height,
                        child: ListView.builder(
                            itemCount: ds.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (bc, i) {
                              var res = ds[i];
                              List obj = jsonDecode(res['bill_order']);
                              var product = '';
                              var productQty =0;
                              var totalObj =
                                  obj.where((element) => element['cat_id'] == 1);
                              for (int i = 0; i < totalObj.length; i++) {
                                if (obj[i]['cat_id'] == 1) {
                                  product +=
                                      "${obj[i]['name']} ราคา ${obj[i]['price_sell']}";
                                  print(i - totalObj.length);
                                  if (i - totalObj.length != -1) {
                                    product += '\n';
                                  }
                                  productQty += obj[i]['qty'];
                                }
                              }
                              return Card(
                                elevation: 2,
                                child: Container(
                                  width: size.width * 0.5,
                                  padding: EdgeInsets.only(left: 8,right: 8,top: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.arrow_right,color: mainFontColor,size: 20,),
                                          Text('ชื่อลูกค้า ${res['customer_name']} ${res['customer_surname']}',style: _baseFontStyle,),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('สินค้าที่สั่งซื้อ \n${product} จำนวน ${productQty} กส.',style: _baseFontStyle,),
                                            Text(
                                                'ที่อยู่ลูกค้า \n${res['customer_address']} ต.${res['customer_district']}อ.${res['customer_amphur']}จ.${res['customer_province']}',
                                                style: _baseFontStyle
                                            ),
                                            SizedBox(height: 5,),
                                            Stack(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('ค้างชำระ ${f.SeperateNumber(res['customer_money_due'])} บาท',style: TextStyle(fontSize: 18,color: dangerColor),),
                                                        Text(
                                                            'กำหนดชำระ ${f.ThaiFormat(res['bill_date_due'])}'
                                                            ,style: TextStyle(fontSize: 18,color: dangerColor)
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: -12,
                                                  child: IconButton(
                                                    color: dangerColor,
                                                    icon: Icon(Icons.phone),
                                                    onPressed: () {
                                                      _makePhoneCall(
                                                          'tel:${res['customer_phone']}');
                                                    }),
                                                ),
                                              ],
                                            )

                                          ],
                                        ),
                                      ),





                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        });
  }
}
