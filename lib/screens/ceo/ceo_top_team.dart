import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CeoTopTeam extends StatefulWidget {
  @override
  _CeoTopTeamState createState() => _CeoTopTeamState();
}

class _CeoTopTeamState extends State<CeoTopTeam> {
  GetReport s = GetReport();
  List topTeamTemp = [];
  Future<bool> isLoaded;
  String timeGen = '';
  String dayGen = '';
  FormatMethod f = FormatMethod();
  List<TopTeam> topTeam = [];

  Future getCache() async {

    var res = await Sqlite().getJson('CEO_TOP_TEAM', '1');
    if (res != null) {
      topTeamTemp = jsonDecode(res['JSON_VALUE']);

    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        if(mounted)AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        var result = await s.getCeoTopTeam();
        Navigator.pop(context);
        topTeamTemp = jsonDecode(result);

      }
    }
    final parsed = topTeamTemp.cast<Map<String, dynamic>>();
    topTeam = parsed.map<TopTeam>((json) => TopTeam.fromJson(json)).toList();
    topTeam.sort((a, b) => b.sumCountProductCat1 - a.sumCountProductCat1);
    try {
      dayGen = '${f.ThaiFormat(topTeamTemp[0]['day_gen'])}';
      timeGen = '${topTeamTemp[0]['time_gen']} น.';
    } catch (e) {
      print(e.toString());
      timeGen = '';
      dayGen = '';
    }
    isLoaded = Future.value(true);
    setState(() {});
  }

  Future _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      isLoaded = Future.value();
      topTeamTemp = [];
      var result = await s.getCeoTopTeam();
      topTeamTemp = jsonDecode(result);
      final parsed = topTeamTemp.cast<Map<String, dynamic>>();
      topTeam = parsed.map<TopTeam>((json) => TopTeam.fromJson(json)).toList();
      topTeam.sort((a, b) => b.sumCountProductCat1 - a.sumCountProductCat1);
      try {
        dayGen = '${f.ThaiFormat(topTeamTemp[0]['day_gen'])}';
        timeGen = '${topTeamTemp[0]['time_gen']} น.';
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
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     //print(topTeam[0]['isShow']);
            //     print(topTeam[0].isShow);
            //   },
            // ),
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
                                  child: Icon(FontAwesomeIcons.star,color: btTextColor,),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TOP TEAMS',style: TextStyle(fontSize: 24.0,height: 1),),
                                    Text('จัดอันดับทีมขายยอดเยี่ยม',style: TextStyle(fontSize: 16.0,height: 1),),
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
                    TopTeam res = topTeam[i];
                    res.saleInCar.sort(
                        (a, b) => b.sumCountProductCat1 - a.sumCountProductCat1);
                    return Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            showInfo(i, res, size),
                            Container(
                              width: size.width * 0.92,
                              height: 240,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: res.saleInCar.length,
                                  itemBuilder: (context, i) {
                                    SaleInCar data = res.saleInCar[i];
                                    TextStyle _itemFontStyle = TextStyle(fontSize: 18,color: whiteColor);
                                      return Card(
                                        elevation: 2,
                                        color: data.sRowVariant != ''
                                            ? danger
                                            : grayFontColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: 140
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${i + 1} ${data.saleName} ${data.saleStatus == 0 ? '(ออก)' : ''}',style: TextStyle(fontSize: 24,color: whiteFontColor),),
                                                SizedBox(height: 5,),
                                                IntrinsicWidth(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'รวมเงินสด ${data.cashCountProductCat1590 + data.cashCountProductCat1690} กระสอบ',
                                                        style: _itemFontStyle,
                                                      ),
                                                      Text(
                                                          'ราคา 590 : ${data.cashCountProductCat1590} กระสอบ',
                                                          style: _itemFontStyle,
                                                      ),
                                                      Text(
                                                          'ราคา 690 : ${data.cashCountProductCat1690} กระสอบ',
                                                          style: _itemFontStyle,
                                                      ),
                                                      Divider(color: Colors.white,),
                                                      Text(
                                                        'รวมเครดิต ${data.creditCountProductCat1590 + data.creditCountProductCat1690} กระสอบ',
                                                        style: _itemFontStyle,
                                                      ),
                                                      Text(
                                                          'ราคา 590 : ${data.creditCountProductCat1590} กระสอบ',
                                                          style: _itemFontStyle),
                                                      Text(
                                                          'ราคา 690 : ${data.creditCountProductCat1690} กระสอบ',
                                                          style: _itemFontStyle),
                                                      Text(
                                                        'รวม ${data.sumCountProductCat1} กระสอบ',
                                                        style: TextStyle(
                                                            color: whiteColor,
                                                            fontSize: 25
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                  },
                              ),
                            ),
                            // if (res.isShow)
                            //   ListView.builder(
                            //       itemCount: res.saleInCar.length,
                            //       shrinkWrap: true,
                            //       primary: false,
                            //       itemBuilder: (bc, i) {
                            //         SaleInCar data = res.saleInCar[i];
                            //         return Card(
                            //           color: data.sRowVariant != ''
                            //               ? danger
                            //               : whiteColor,
                            //           child: Column(
                            //             children: [
                            //               Text(
                            //                   '${i + 1} ${data.saleName} ${data.saleStatus == 0 ? '(ออก)' : ''}'),
                            //               Row(
                            //                 children: [
                            //                   Expanded(
                            //                     child: Card(
                            //                       color: darkColor,
                            //                       child: Column(
                            //                         crossAxisAlignment:
                            //                             CrossAxisAlignment.start,
                            //                         children: [
                            //                           Center(
                            //                             child: Text(
                            //                               'รวมเงินสด ${data.cashCountProductCat1590 + data.cashCountProductCat1690} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor),
                            //                             ),
                            //                           ),
                            //                           Text(
                            //                               'ราคา 590 : ${data.cashCountProductCat1590} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor)),
                            //                           Text(
                            //                               'ราคา 690 : ${data.cashCountProductCat1690} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor)),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   Expanded(
                            //                     child: Card(
                            //                       color: darkColor,
                            //                       child: Column(
                            //                         crossAxisAlignment:
                            //                             CrossAxisAlignment.start,
                            //                         children: [
                            //                           Center(
                            //                             child: Text(
                            //                               'รวมเครดิต ${data.creditCountProductCat1590 + data.creditCountProductCat1690} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor),
                            //                             ),
                            //                           ),
                            //                           Text(
                            //                               'ราคา 590 : ${data.creditCountProductCat1590} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor)),
                            //                           Text(
                            //                               'ราคา 690 : ${data.creditCountProductCat1690} กระสอบ',
                            //                               style: TextStyle(
                            //                                   color: whiteColor)),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //               Row(
                            //                 children: [
                            //                   Expanded(
                            //                       child: Card(
                            //                     color: darkColor,
                            //                     child: Center(
                            //                       child: Text(
                            //                         'รวม ${data.sumCountProductCat1} กระสอบ',
                            //                         style: TextStyle(
                            //                             color: kPrimaryColor),
                            //                       ),
                            //                     ),
                            //                   ))
                            //                 ],
                            //               ),
                            //             ],
                            //           ),
                            //         );
                            //       }),
                            // expandButton(res),
                          ],
                        ),
                      ),
                    );
                  }, childCount: topTeam.length)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
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

  IconButton expandButton(TopTeam res) {
    return IconButton(
        icon: Icon(res.isShow ? Icons.expand_less : Icons.expand_more),
        onPressed: () {
          res.isShow = !res.isShow;
          setState(() {});
        });
  }

  Widget showInfo(int i, TopTeam res, Size size) {
    return Column(
      children: [
        HeaderText(text:'อันดับ ${i + 1}',textSize: 20,gHeight: 26,),
        SizedBox(height: 5,),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Center(
                      child: CircleAvatar(
                        backgroundImage: res.headImg != null
                            ? CachedNetworkImageProvider(
                                '$storagePath/${res.headImg}')
                            : AssetImage('assets/avatar.png'),
                        radius: 40,
                      ),
                    ),
                  ),
                  Text('ทีม : ${res.headName}',style: TextStyle(fontSize: 18),),
                  Text('${res.carPlate}',style: TextStyle(fontSize: 18,height: 1)),
                  Text('${res.carNote ?? ''}'),
                ],
              ),
            ),
            Expanded(
              flex: 4,
                child:
            Column(
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
                                  '${res.cashCountProductCat1590 + res.cashCountProductCat1690} กส.',
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
                                  '${res.cashCountProductCat1590} กส.',
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
                                  '${res.cashCountProductCat1690} กส.',
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
                                  '${res.creditCountProductCat1590 + res.creditCountProductCat1690} กส.',
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
                                  '${res.creditCountProductCat1590}  กส.',
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
                                  '${res.creditCountProductCat1690}  กส.',
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
                        'รวมทั้งหมด ${res.sumCountProductCat1} กระสอบ',
                        style: TextStyle(color: kPrimaryColor,fontSize: 24),
                      ),
                    )
                  ],
                ),
              ],
            ))
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Center(
            //           child: Text(
            //         '${f.SeperateNumber(res.sumCountProductCat1)} กระสอบ',
            //         style: TextStyle(color: kPrimaryColor),
            //       )),
            //       Container(
            //         width: size.width,
            //         child: Card(
            //           child: Center(
            //             child: Text(
            //                 'รวมเงินสด ${f.SeperateNumber(res.cashCountProductCat1590 + res.cashCountProductCat1690)} กระสอบ'),
            //           ),
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: Card(
            //               child: Column(
            //                 children: [
            //                   Text('เงินสด 590'),
            //                   Text(
            //                       '${f.SeperateNumber(res.cashCountProductCat1590)} กระสอบ'),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Card(
            //               child: Column(
            //                 children: [
            //                   Text('เงินสด 690'),
            //                   Text(
            //                       '${f.SeperateNumber(res.cashCountProductCat1690)} กระสอบ'),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       Container(
            //         width: size.width,
            //         child: Card(
            //           child: Center(
            //             child: Text(
            //                 'รวมเครดิต ${f.SeperateNumber(res.creditCountProductCat1590 + res.creditCountProductCat1690)} กระสอบ'),
            //           ),
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: Card(
            //               child: Column(
            //                 children: [
            //                   Text('เครดิต 590'),
            //                   Text(
            //                       '${f.SeperateNumber(res.creditCountProductCat1590)} กระสอบ'),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           Expanded(
            //             child: Card(
            //               child: Column(
            //                 children: [
            //                   Text('เครดิต 690'),
            //                   Text(
            //                       '${f.SeperateNumber(res.creditCountProductCat1690)} กระสอบ'),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ],
    );
  }
}
