import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class CeoTopSale extends StatefulWidget {
  @override
  _CeoTopSaleState createState() => _CeoTopSaleState();
}

class _CeoTopSaleState extends State<CeoTopSale> {
  String dayGen = '';
  String timeGen = '';
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();
  List<SaleInCar> topSale = [];
  Future<bool> isLoaded;

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    var data;
    if (isConnect) {
      isLoaded = Future.value();
      data = [];
      var result = await s.getCeoTopSale();
      data = jsonDecode(result);
      final parsed = data.cast<Map<String, dynamic>>();
      topSale =
          parsed.map<SaleInCar>((json) => SaleInCar.fromJson(json)).toList();
      topSale.sort((a, b) => b.sumCountProductCat1 - a.sumCountProductCat1);
      try {
        dayGen = '${f.ThaiFormat(data[0]['day_gen'])}';
        timeGen = '${data[0]['time_gen']} น.';
      } catch (e) {
        print(e.toString());
        timeGen = '';
        dayGen = '';
      }
      isLoaded = Future.value(true);
      setState(() {});
    }
  }

  Future getData() async {
    await getCache();
  }

  Future getCache() async {

    var res = await Sqlite().getJson('CEO_TOP_SALE', '1');
    var data;
    if (res != null) {
      data = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        var result = await s.getCeoTopSale();
        data = jsonDecode(result);
      }
    }
    final parsed = data.cast<Map<String, dynamic>>();
    topSale =
        parsed.map<SaleInCar>((json) => SaleInCar.fromJson(json)).toList();
    topSale.sort((a, b) => b.sumCountProductCat1 - a.sumCountProductCat1);
    try {
      dayGen = '${f.ThaiFormat(data[0]['day_gen'])}';
      timeGen = '${data[0]['time_gen']} น.';
    } catch (e) {
      print(e.toString());
      timeGen = '';
      dayGen = '';
    }
    isLoaded = Future.value(true);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getData();
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
                title: Text(''),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                    child: Icon(FontAwesomeIcons.medal,color: btTextColor,),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('TOP SALES',style: TextStyle(fontSize: 24.0,height: 1),),
                                      Text('จัดอันดับพนักงานขายยอดเยี่ยม',style: TextStyle(fontSize: 16.0,height: 1),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20,right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('หมายเหตุ',style: TextStyle(fontSize: 15.0,height: 1),),
                                      Text('ข้อมูลที่แสดงนับจาก ยอดขายเงินสด กับยอดขายเครดิตที่เก็บเงินลูกค้าครบแล้วเท่านั้น'),
                                      Text('(ข้อมูลอัพเดทล่าสุดวันที่ $dayGen เวลา $timeGen)'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate((bc, i) {
                      SaleInCar data = topSale[i];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16,right: 16),
                        child: Card(
                          color: data.sRowVariant != '' ? danger : whiteColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeaderText(text: 'อันดับ ${i + 1}',textSize: 20,gHeight: 26,),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        child: Container(
                                          width: size.width * 0.21,
                                          child: CachedNetworkImage(
                                            imageUrl: '$storagePath${data.image}',
                                            errorWidget: (context, url, error) =>
                                                Image.asset('assets/avatar.png'),
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      Text(
                                          '${data.saleName} ${data.saleStatus == 0 ? '(ออก)' : ''}',
                                          style: TextStyle(
                                              color: data.sRowVariant != ''
                                                  ? whiteFontColor
                                                  : darkColor,
                                            fontSize: 18
                                          )),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              IntrinsicWidth(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('เงินสด',style: TextStyle(fontSize: 15)),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'รวมเงินสด',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.cashCountProductCat1590 + data.cashCountProductCat1690} กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'ราคา 590 ',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.cashCountProductCat1590} กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'ราคา 690 ',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.cashCountProductCat1690} กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),

                                              IntrinsicWidth(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('เครดิต',style: TextStyle(fontSize: 15)),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'รวมเครดิต',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.creditCountProductCat1590 + data.creditCountProductCat1690} กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'ราคา 590 ',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.creditCountProductCat1590}  กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'ราคา 690 ',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                        Text(
                                                          '${data.creditCountProductCat1690}  กส.',
                                                          style: TextStyle(fontSize: 18),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Center(
                                              child: Text(
                                                'รวมทั้งหมด ${data.sumCountProductCat1} กระสอบ',
                                                style: TextStyle(color: kPrimaryColor,fontSize: 24),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5,),


                            ],
                          ),
                        ),
                      );
                    }, childCount: topSale.length)),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Footer(),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
