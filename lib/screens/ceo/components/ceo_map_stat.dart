import 'dart:convert';
import 'dart:ui';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/ceo_map_detail.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:touchable/touchable.dart';
import 'package:http/http.dart';

class CeoMapStat extends StatefulWidget {
  final DateTime selectedMonth;

  const CeoMapStat({Key key, this.selectedMonth})
      : super(key: key);
  @override
  _CeoMapStatState createState() => _CeoMapStatState();
}

class _CeoMapStatState extends State<CeoMapStat> {
  List showData = [];
  Future<bool> isLoaded;
  var client = Client();
  String selectedReport;
  List<DropdownMenuItem> optionReport = [];
  int totalRows = 0;
  List<MapData> mapData = [];
  Map<String, MapData> mapDataSerie;
  String lastRank;
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();

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
    print('getAvaliable Map');
    var res = await Sqlite().getJson('AVALIABLE_REPORT', '1');
    print(res);
    if (res != null) {
      List data = jsonDecode(res['JSON_VALUE']);

      data.sort((a, b) => b['ID'] - a['ID']);
      print('datadata >${data}');
      setAvaliableOption(data);
    } else {
      setOption(5);
    }
    print('selectedReport=>${selectedReport}');
  }

  Future<Null> getData() async {
    await getAvaliable();

    await getCache(selectedReport);
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
      //print(dateString);
      //print(thai_date(int.parse(element['Year']), int.parse(element['Month'])));
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
      y = (m==0)?(y - 1):y;
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

  Future<Null> getCache(selectedReport) async {
    print('getCache');
    showData = [];
    print('getCache=> ${selectedReport}');
    var res = await Sqlite().getJson('CEO_PROVINCE_RANKING', selectedReport);
    if (res != null) {
      showData = jsonDecode(res['JSON_VALUE']);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        var result = await s.getCeoMap(selectedReport: selectedReport);
        if(showData.isEmpty){
          var _result = await s.getCeoMap(selectedReport: selectedReport);
          if(!_result.isEmpty){
            showData = jsonDecode(result);
          }

        }else{
          showData = jsonDecode(result);
        }
        setState(() {

        });
        // var res = await client.post('$apiPath-ceo', body: {
        //   'func': 'getCacheProvinceRanking',
        //   'namefile': selectedReport
        // });
        // if (res.body != '{}') {
        //   Sqlite().insertJson('CEO_PROVINCE_RANKING', selectedReport, res.body);
        //   showData = jsonDecode(res.body);
        // }
      }
    }
    showData.sort(
            (a, b) => b['sum_count_product_cat1'] - a['sum_count_product_cat1']);
    totalRows = showData.length;


    int i = 0;
    showData.forEach((element) {
      if (i == showData.length - 1) {
        lastRank = element['PROVINCE_NAME'];
      }
      int main = 700;
      var code = 'TH-${element['PROVINCE_CODE']}';
      var itemproduct = element['sum_count_product_cat1'];

      var overonehundred = (main * 100) / 100;
      var overeighty = (main * 80) / 100; //80     560
      var overfifty = (main * 50) / 100;

      Color gold = Color(0xFFFFD700);
      Color red = Color(0xFFF76262);
      Color green = Color(0xFF43AEA8);
      Color orange = Color(0xFFF37F2D);


      // mapData.add(MapData(path, name, itemproduct, color));
      i++;
    });

    mapData.sort((a, b) => b.total - a.total);
    //print('test geo ${pathTest['TH-39'].geo}');
    isLoaded = Future.value(true);
    setState(() {});
    //initMap
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
    Size _size =Size(size.width*0.9, size.height*0.82);

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
            body: CustomScrollView(
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
                            child: Icon(FontAwesomeIcons.medal,color: btTextColor,),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('อันดับยอดขายแต่ละจังหวัด',style: TextStyle(fontSize: 24.0,height: 1),),
                              Text('หน้านี้สรุปข้อมูลจากวันที่ลูกค้าเซ็นรับสินค้า',style: TextStyle(fontSize: 16.0,height: 1),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (showData.length>0)?
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        childAspectRatio: 1.2),
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            var result = showData[i];
                            return Card(
                                      elevation: 2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          (i==0)
                                              ?Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(FontAwesomeIcons.medal,color: kPrimaryLightColor,),
                                              Text('อันดับ ${i + 1}',style: TextStyle(fontSize: 25,),),
                                            ],
                                          )
                                              :Text('อันดับ ${i + 1}',style: TextStyle(fontSize: 25,),),
                                          Text('จังหวัด${result['PROVINCE_NAME'].trim()}',style: TextStyle(fontSize: 25,)),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8,right: 8),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('เงินสด',style: TextStyle(fontSize: 20,)),
                                                    Text('${f.SeperateNumber(result['cash_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('เครดิต',style: TextStyle(fontSize: 20,)),
                                                    Text('${f.SeperateNumber(result['credit_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('รวม',style: TextStyle(fontSize: 20,)),
                                                    Text('${f.SeperateNumber(result['sum_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                      },
                      childCount: showData.length,
                    ),
                  ),
                ):
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                    child: Center(
                      child: Container(
                        width: size.width * 0.98,
                        height: size.height * 0.42,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/img/bgAlert.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: size.width * 0.28,
                              child: Image.asset(
                                  "assets/icons/icon_alert.png"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                "ไม่มีข้อมูลแสดงผล",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "เพราะทีมขายยัังไม่ได้ทำการออกบิล \nต้องให้ทีมขายออกบิลระบบถึงจะ\nนำข้อมูลมาแสดงผลได้",
                                style: TextStyle(
                                    fontSize: 23,
                                    color: Colors.white,
                                    height: 1),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // SliverToBoxAdapter(
                //   child: FutureBuilder(
                //       future: isLoaded,
                //       builder: (context, snapshot) {
                //         if (snapshot.hasData) {
                //           return GridView.builder(
                //             itemCount: showData.length,
                //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 2,childAspectRatio: 1.2),
                //             itemBuilder: (context, i) {
                //               var result = showData[i];
                //               return Column(
                //                 mainAxisSize: MainAxisSize.min,
                //
                //                 children: [
                //                  Text('อันดับ ${i + 1}',style: TextStyle(fontSize: 25,)),
                //
                //                 ],
                //               );
                //               // return Card(
                //               //   elevation: 3,
                //               //   child: Column(
                //               //     mainAxisAlignment: MainAxisAlignment.center,
                //               //     crossAxisAlignment: CrossAxisAlignment.center,
                //               //     children: [
                //               //       (i==0)
                //               //           ?Row(
                //               //         mainAxisAlignment: MainAxisAlignment.center,
                //               //         crossAxisAlignment: CrossAxisAlignment.center,
                //               //         children: [
                //               //           Icon(FontAwesomeIcons.medal,color: kPrimaryLightColor,),
                //               //           Text('อันดับ ${i + 1}',style: TextStyle(fontSize: 25,),),
                //               //         ],
                //               //       )
                //               //           :Text('อันดับ ${i + 1}',style: TextStyle(fontSize: 25,),),
                //               //       Text('จังหวัด${result['PROVINCE_NAME'].trim()}',style: TextStyle(fontSize: 25,)),
                //               //       Padding(
                //               //         padding: const EdgeInsets.only(left: 8,right: 8),
                //               //         child: Column(
                //               //           children: [
                //               //             Row(
                //               //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               //               crossAxisAlignment: CrossAxisAlignment.start,
                //               //               children: [
                //               //                 Text('เงินสด',style: TextStyle(fontSize: 20,)),
                //               //                 Text('${f.SeperateNumber(result['cash_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                //               //               ],
                //               //             ),
                //               //             Row(
                //               //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               //               crossAxisAlignment: CrossAxisAlignment.start,
                //               //               children: [
                //               //                 Text('เครดิต',style: TextStyle(fontSize: 20,)),
                //               //                 Text('${f.SeperateNumber(result['credit_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                //               //               ],
                //               //             ),
                //               //             Row(
                //               //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               //               crossAxisAlignment: CrossAxisAlignment.start,
                //               //               children: [
                //               //                 Text('รวม',style: TextStyle(fontSize: 20,)),
                //               //                 Text('${f.SeperateNumber(result['sum_count_product_cat1'])} กระสอบ',style: TextStyle(fontSize: 20,)),
                //               //               ],
                //               //             ),
                //               //           ],
                //               //         ),
                //               //       ),
                //               //     ],
                //               //   ),
                //               // );
                //             },
                //           );
                //         } else if (snapshot.hasError) {
                //           print(snapshot.error);
                //           return Container();
                //         } else {
                //           return Container();
                //         }
                //       }),
                // ),
                SliverFillRemaining(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Footer(),
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
