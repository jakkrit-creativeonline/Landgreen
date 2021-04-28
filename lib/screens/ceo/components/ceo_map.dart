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

class CeoMap extends StatefulWidget {
  final DateTime selectedMonth;

  const CeoMap({Key key, this.selectedMonth})
      : super(key: key);
  @override
  _CeoMapState createState() => _CeoMapState();
}

class _CeoMapState extends State<CeoMap> {
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

    Map<String, MapData> pathTemp = pathTest;

    int i = 0;
    showData.forEach((element) {
      if (i == showData.length - 1) {
        lastRank = element['PROVINCE_NAME'];
      }
      int main = 700;
      var code = 'TH-${element['PROVINCE_CODE']}';
      var itemproduct = element['sum_count_product_cat1'];
      MapData item = pathTemp[code];
      var overonehundred = (main * 100) / 100;
      var overeighty = (main * 80) / 100; //80     560
      var overfifty = (main * 50) / 100;

      Color gold = Color(0xFFFFD700);
      Color red = Color(0xFFF76262);
      Color green = Color(0xFF43AEA8);
      Color orange = Color(0xFFF37F2D);

      if (itemproduct > overonehundred) {
        item.color = gold;
      } else if (itemproduct >= overeighty && itemproduct <= overonehundred) {
        item.color = green;
      } else if (itemproduct >= overfifty && itemproduct < overeighty) {
        item.color = orange;
      } else if (itemproduct < overfifty) {
        item.color = red;
      }
      item.total = itemproduct;
      // mapData.add(MapData(path, name, itemproduct, color));
      i++;
    });

    mapData = pathTemp.values.toList();
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
    Size _size =Size(size.width*0.9, size.height*0.79);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // DropDown(
          //   items: optionReport,
          //   hintText: '',
          //   value: selectedReport,
          //   onChange: (val) => getCache(val),
          // ),
          Card(
            child: Column(
              children: [
                HeaderText(text:'ข้อมูล Heat map ยอดขายแบ่งตามพื้นที่ประจำเดือนนี้',textSize: 20,gHeight: 26,),
                SizedBox(height: 10,),
                FutureBuilder(
                    future: isLoaded,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: CanvasTouchDetector(
                            builder: (context) => CustomPaint(
                              painter: PathTestPainter(
                                  context, showData.length, lastRank,
                                  paths: mapData),
                              size: _size,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Container();
                      } else {
                        return ShimmerLoading(type: 'boxItem1Row',);
                      }
                    }),
                InkWell(
                  onTap: (){
                    Navigator.push(context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(name: 'Heatmapเพิ่มเติม'),
                                        builder: (BuildContext bc) => CeoMapDetail(
                                              mapData: mapData,
                                              showData: showData,
                                            )));
                  },
                  child: Card(
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: grayFontColor,
                      ),
                      width: size.width*0.85,
                      height: 40,
                      child: Center(
                        child: Text('ดูข้อมูลเพิ่มเติมคลิ๊ก',style: TextStyle(fontSize: 24,color: whiteFontColor),),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1,),
              ],

            ),
          ),

          // if (showData.length != 0)
          //   Container(
          //       width: size.width,
          //       child: RaisedButton(
          //           child: Text('ดูเพิ่มเติม'),
          //           onPressed: () {
          //             Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (BuildContext bc) => CeoMapDetail(
          //                           mapData: mapData,
          //                           showData: showData,
          //                         )));
          //           })),
          SizedBox(height: 8,),
          FutureBuilder(
              future: isLoaded,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: (){
                      locator<NavigationService>().navigateTo(
                          'ceo_mapStat',
                          ScreenArguments()
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              HeaderText(text:'ข้อมูลสถิติยอดขายแต่ละจังหวัด',textSize: 20,gHeight: 26,),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(Icons.arrow_right,color: whiteColor,))
                            ],
                          ),
                          SizedBox(height: 5,),
                          Container(
                            height: 300,
                            child: GridView.builder(
                                primary: false,
                                itemCount: 4,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 2,childAspectRatio: 1.2),
                                itemBuilder: (context, i) {
                                  var result = showData[i];
                                  return Card(
                                    elevation: 3,
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
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              locator<NavigationService>().navigateTo(
                                  'ceo_mapStat',
                                  ScreenArguments()
                              );
                            },
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: grayFontColor,
                                ),
                                width: size.width*0.85,
                                height: 40,
                                child: Center(
                                  child: Text('ดูข้อมูลเพิ่มเติมคลิ๊ก',style: TextStyle(fontSize: 24,color: whiteFontColor),),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2,),
                        ],
                      ),
                    ),
                  );
                  // return Container(
                  //   height: 500,
                  //   child: ListView.builder(
                  //       itemCount: showData.length,
                  //       primary: true,
                  //       shrinkWrap: true,
                  //       itemBuilder: (bc, i) {
                  //         var result = showData[i];
                  //         return Card(
                  //           child: Column(
                  //             children: [
                  //               Text('อันดับ ${i + 1}'),
                  //               Text('จังหวัด${result['PROVINCE_NAME']}'),
                  //               Text(
                  //                   'เงินสด ${result['cash_count_product_cat1']} กระสอบ'),
                  //               Text(
                  //                   'เครดิต ${result['credit_count_product_cat1']} กระสอบ'),
                  //               Text(
                  //                   'รวม ${result['sum_count_product_cat1']} กระสอบ'),
                  //             ],
                  //           ),
                  //         );
                  //       }),
                  // );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Container();
                } else {
                  return Container();
                }
              }),
        ],
      ),
    );
  }
}

class PathTestPainter extends CustomPainter {
  final BuildContext context;
  final List<MapData> paths;
  final String lastRankName;
  final int lastRank;
  PathTestPainter(this.context, this.lastRank, this.lastRankName, {this.paths});

  Future showDetail(context, items) async {
    return showDialog(
            context: context,
            builder: (BuildContext bc) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${items.name} (ยอดขาย ${items.total} กระสอบ)'),
                  ],
                ),
              );
            }) ??
        false;
  }

  @override
  bool shouldRepaint(PathTestPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    //print('lastRank inside paint $lastRank');
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    //Background paint
    Paint background = Paint()..color = Colors.white;

    //Rect paint
    Paint rectPaint = Paint()..color = Colors.green;

    //Define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    var screen_width = size.width;
    var screen_height = size.height;

    var myCanvas = TouchyCanvas(context, canvas);

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(0.39);

    //canvas.scale(0.4);

    int i = 0;
    List<Offset> itemOffset = [];
    paths.forEach((element) {
      Path path = parseSvgPathData(element.path);
      if (i < 5) {
        var pathRect = path.transform(matrix4.storage).getBounds();
        var rectCenter = pathRect.center;
        //canvas.drawRect(pathRect, rectPaint);
        itemOffset.add(rectCenter);
      }
      if (element.name == lastRankName.replaceAll(' ', '')) {
        // print('element name ${element.name}');
        // print('lastRank $lastRank');
        // print(element.name == lastRank.replaceAll(' ', ''));
        // print(element.name.length);
        // print(lastRank.length);
        var pathRect = path.transform(matrix4.storage).getBounds();
        var rectCenter = pathRect.center;
        itemOffset.add(rectCenter);
      }
      // if (element.name == lastRank) {
      //   var pathRect = path.transform(matrix4.storage).getBounds();
      //   var rectCenter = pathRect.center;
      //   itemOffset.add(rectCenter);
      //   print('lastRank $lastRank');
      //   print('element name ${element.name}');
      // }
      paint.color = element.color;
      myCanvas.drawPath(path.transform(matrix4.storage), paint,
          onTapDown: (detail) {
        showDetail(context, element);
      });
      i++;
    });
    if (itemOffset.length > 5) {
      for (int i = 0; i < itemOffset.length; i++) {
        if (i != itemOffset.length - 1) {

          TextSpan span = new TextSpan(
              style: new TextStyle(fontSize: 14, color: backgroudBarColor),
              text: 'อันดับ ${i + 1}');
          TextPainter tp = new TextPainter(
              text: span,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, itemOffset[i] + Offset(-25, -10));
        } else {
          TextSpan span = new TextSpan(
              style: new TextStyle(fontSize: 14, color: backgroudBarColor),
              text: 'อันดับ $lastRank สุดท้าย');
          TextPainter tp = new TextPainter(
              text: span,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, itemOffset[i] + Offset(-50, 0));
        }
      }
    } else {
      for (int i = 0; i < itemOffset.length; i++) {
        TextSpan span = new TextSpan(
            style: new TextStyle(fontSize: 18, color: Colors.grey[500]),
            text: 'อันดับ ${i + 1}');
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, itemOffset[i] + Offset(-30, -10));
      }
    }
  }
}

Map<String, MapData> pathTest = {
  "TH-57": MapData(
      "M211.11,106.74l2.52,-2.93l0.57,-1.39l-0.01,-0.79l-1.59,-1.98l-1.26,-3.81l-0.75,-0.52l-1.28,-0.14l-0.77,-1.09l-0.96,-2.75l0.09,-1.39l0.73,-1.17l1.05,-0.87l2.7,-1.63l1.38,-2.07l0.9,-0.52l1.55,0.03l0.55,-0.28l1.46,-2.41l1.04,-4.75l1.15,-1.6l0.46,-1.52l0.91,-0.81l2.18,-0.46l0.65,-0.57l-0.62,-3.34l-1.68,-1.32l-0.63,-0.95l-0.46,-2.95l0.75,-1.25l1.4,-1.29l1.49,-4.93l2.91,-1.83l3.23,0.6l2.39,-0.32l2.34,1.15l1.26,3.61l1.41,1.39l0.75,0.25l1.1,-1.0l2.83,-6.04l0.32,-3.7l-0.22,-1.05l-1.09,-0.69l-3.06,-0.5l-2.04,-1.96l-2.38,-1.33l-0.49,-0.76l-0.08,-1.72l3.2,-1.2l2.29,-1.59l0.99,-1.2l0.09,-1.23l-0.55,-0.48l-3.19,-1.05l-2.15,-1.6l1.11,-1.98l0.55,-3.08l-0.83,-1.93l-3.46,-3.68l-1.2,-6.46l-0.96,-2.17l-4.03,-4.2l-0.74,-1.45l1.53,-0.55l1.35,0.5l5.35,3.62l8.33,2.71l4.19,-0.11l2.49,1.47l1.35,0.29l2.18,-0.4l3.99,-1.66l2.16,-0.38l4.36,0.01l2.03,-0.66l2.05,-1.88l1.0,-1.89l1.43,-4.03l1.16,-1.64l1.84,-1.2l2.33,-0.77l6.39,-1.09l1.3,0.84l0.62,0.88l0.64,2.11l2.36,2.55l1.35,0.52l2.82,0.31l1.31,0.79l2.16,3.31l4.55,2.85l-0.19,3.8l0.62,2.22l1.56,1.91l2.08,1.1l2.12,0.04l2.05,-2.04l-0.06,-4.22l1.12,-0.93l3.32,-1.26l1.33,-4.16l2.05,-2.58l3.12,-2.07l3.77,-0.85l3.89,1.04l2.05,2.24l6.18,13.36l2.82,3.69l1.59,3.19l2.61,1.33l1.24,1.6l1.78,1.08l1.86,0.66l1.13,-0.45l0.61,-1.32l0.31,6.24l-0.77,4.44l-5.48,15.17l-0.94,5.74l-0.97,1.6l-3.91,2.09l-0.82,1.11l-1.16,3.08l-3.98,5.2l-0.53,2.42l1.01,2.22l-5.37,5.83l-4.8,1.04l-1.46,0.99l-0.88,1.37l-0.69,0.34l-3.7,-0.15l-1.2,0.33l-3.99,2.62l-2.0,4.18l-0.18,1.18l0.33,1.42l-1.43,1.93l0.15,1.72l-1.76,2.21l-0.11,2.85l-5.44,2.53l-0.41,0.68l-0.23,1.81l-0.75,0.05l-2.77,-1.01l-3.33,0.52l-1.53,0.64l-4.79,4.33l-1.81,0.51l-1.94,-0.72l-0.8,-0.68l-0.04,-2.43l1.18,-4.62l-0.37,-1.44l-1.24,-1.11l-17.96,2.97l-4.38,2.68l-1.6,0.2l-0.38,-1.97l-1.28,-1.47l-1.94,-0.89l-1.43,-3.59l-1.86,-0.88l-1.71,0.74l-2.86,3.97l-0.04,2.18l-1.67,3.07l-0.16,3.23l1.14,2.12l0.22,1.11l-0.27,7.5l-2.74,6.22l-0.14,2.3l-1.24,7.01l0.56,0.97l1.62,0.37l0.03,2.12l-1.75,2.49l-1.34,3.64l-2.95,0.26l-1.64,0.72l-5.37,6.13l-1.42,0.85l-2.58,0.31l-1.64,-6.15l-5.94,-6.93l-2.02,-6.77l-0.12,-0.81l1.08,-4.54l1.96,-2.16l0.4,-1.26l0.09,-2.04l-2.05,-7.06l-0.09,-0.82l0.83,-1.42l0.28,-1.33l-0.73,-3.23l-1.54,-3.94l0.24,-3.49l-0.51,-1.6l-1.58,-2.28Z",
      "เชียงราย",
      0,
      Colors.black,
      1),
  "TH-56": MapData(
      "M349.56,106.39l1.25,1.96l0.09,0.66l-2.49,1.4l-2.31,4.5l-3.42,2.87l-0.34,1.28l0.17,1.75l0.71,1.76l0.9,1.27l1.01,0.75l2.16,0.51l1.72,-1.12l1.31,1.52l2.14,0.48l0.33,1.25l-1.41,7.55l1.7,4.44l-0.04,3.24l0.59,1.45l0.42,2.6l1.31,1.21l-0.09,0.31l-2.78,2.59l-3.38,1.03l-1.19,0.82l-1.06,2.28l-0.19,1.22l0.33,0.9l1.8,2.42l-1.58,-0.06l-3.15,-1.97l-1.63,-0.59l-2.55,-0.14l-1.11,0.38l-1.1,1.95l-0.93,2.76l-0.03,1.33l0.59,0.85l2.36,0.11l1.03,0.36l0.44,0.66l-0.08,1.18l-0.98,1.0l-2.55,1.61l-3.57,0.19l-1.49,0.81l-6.48,10.82l-0.84,2.65l-11.71,-0.84l-3.92,0.51l-4.6,-1.41l-3.29,1.05l-1.34,1.02l-2.32,-1.21l-2.28,0.06l-0.43,-1.49l0.27,-2.05l-1.43,-2.59l-1.69,-1.52l-7.29,-4.21l-1.48,-1.17l-1.33,-2.86l-1.2,-1.71l-1.32,-0.68l-3.16,-0.36l-2.12,-0.91l-1.87,0.21l-2.19,-0.57l-0.11,-2.29l-2.04,-3.25l-3.67,-1.1l-0.82,-0.65l-0.89,-2.0l-0.92,-3.51l-3.09,-5.08l-0.74,-2.58l-2.11,-5.01l-0.74,-7.16l0.12,-1.26l0.7,-1.29l0.05,-0.76l-1.34,-3.32l0.01,-2.34l-1.01,-3.57l-0.14,-2.43l1.85,-0.26l4.21,-2.63l17.5,-2.99l0.83,0.75l0.26,1.47l-1.17,4.03l0.07,2.84l1.14,1.08l1.47,0.67l1.55,0.17l1.54,-0.62l4.91,-4.41l1.26,-0.5l3.05,-0.49l2.63,0.98l1.27,-0.09l0.63,-0.87l0.19,-1.74l4.76,-2.0l0.86,-0.74l0.17,-2.98l1.76,-2.22l-0.14,-1.76l1.18,-1.23l0.28,-0.82l-0.33,-1.56l0.15,-0.9l1.8,-3.85l3.72,-2.44l0.96,-0.28l3.84,0.12l1.02,-0.51l0.89,-1.38l1.24,-0.85l4.86,-1.06l5.5,-5.92l1.54,2.32l0.6,5.34l0.66,2.04l3.98,5.62l0.79,5.49l1.41,1.42l1.91,1.18l3.22,1.38l3.25,0.92l1.88,-0.12l0.87,-1.1Z",
      "พะเยา ",
      0,
      Colors.black,
      1),
  "TH-55": MapData(
      "M403.15,233.41l-7.26,6.02l-4.11,2.61l-5.13,4.66l-1.67,2.83l0.05,0.57l0.68,0.76l-0.16,1.19l-3.2,2.99l0.04,0.79l1.18,0.83l-0.02,1.02l-2.66,1.85l-2.61,5.5l-3.5,2.17l-5.26,4.49l-4.43,-0.36l-3.12,0.29l-1.93,-1.11l-6.25,-0.34l-2.98,-1.23l-1.08,-0.07l-0.79,0.35l-2.27,2.01l-3.11,0.21l-0.78,1.16l-3.88,0.37l-2.28,-0.31l-2.24,0.68l-0.98,-0.34l0.19,-1.18l-2.03,-11.33l2.74,-1.55l1.7,-0.52l1.15,-1.6l0.96,-2.52l0.85,-4.58l1.2,-2.6l1.98,-2.94l0.11,-1.37l-0.89,-1.68l0.09,-4.11l0.19,-0.5l2.08,-1.91l2.09,-5.03l0.53,-2.38l-0.07,-2.53l-0.25,-1.52l-0.83,-1.56l-3.15,-0.39l-1.72,-1.85l-5.4,-0.18l-2.18,0.85l-0.77,-0.56l-1.0,-6.25l-1.36,-2.12l-0.14,-1.12l0.65,-4.01l1.34,-1.32l0.09,-0.75l-0.99,-0.91l-2.09,-0.42l-0.57,-0.88l-0.54,-2.13l0.47,-2.69l2.44,-3.09l0.42,-1.72l-0.54,-0.67l-1.34,-0.26l-0.73,-0.48l-0.46,-0.89l-0.14,-2.59l-0.43,-0.54l-1.21,-0.49l-0.42,-0.48l-0.04,-0.73l1.31,-4.02l6.31,-10.6l1.1,-0.61l2.81,0.02l0.93,-0.27l2.71,-1.71l1.17,-1.2l0.24,-1.32l-0.52,-1.36l-1.21,-0.64l-2.66,-0.23l-0.1,-0.26l0.03,-0.92l0.9,-2.68l0.93,-1.66l2.88,-0.03l1.46,0.52l3.24,2.01l1.03,0.28l1.25,-0.25l0.41,-0.54l-0.02,-0.59l-2.13,-3.0l1.13,-2.96l4.34,-1.62l2.41,-2.01l0.84,-1.54l-0.31,-0.65l-1.07,-0.86l-0.39,-2.51l-0.58,-1.41l0.04,-3.25l-1.68,-4.33l1.4,-7.38l-0.41,-1.76l-0.82,-0.63l-1.6,-0.15l-0.75,-1.15l-0.77,-0.46l-1.05,0.12l-0.96,0.97l-1.12,-0.16l-1.17,-0.65l-1.5,-2.36l-0.21,-2.52l0.52,-0.87l3.02,-2.36l2.21,-4.39l2.63,-1.56l-0.05,-1.38l-1.54,-2.4l1.04,-1.7l2.12,-1.57l2.64,-0.13l8.73,3.31l1.48,0.83l1.69,2.12l1.0,0.44l0.46,-0.15l1.02,-1.44l4.97,-4.63l4.4,-5.18l1.7,-2.73l0.91,-0.57l10.65,-0.05l2.99,0.32l2.28,0.84l4.8,2.91l2.99,1.11l3.23,0.27l3.12,-0.37l2.68,-0.73l2.29,-1.38l0.98,-0.26l1.7,0.45l1.34,0.74l0.77,0.8l0.88,2.44l0.22,2.65l-0.54,3.07l-1.34,2.29l-2.44,0.67l-2.59,1.71l-1.66,4.11l-0.58,4.72l0.82,3.59l0.87,0.59l1.75,0.36l0.77,1.08l-0.18,1.93l2.19,9.35l-0.33,6.6l0.26,2.65l0.74,1.85l6.1,5.66l2.82,3.16l0.84,3.0l-4.52,4.35l-1.81,5.28l-3.66,4.59l-0.97,2.25l-0.17,2.23l0.57,6.65l-0.48,1.82l-1.59,3.59l-0.38,2.1l0.69,2.21l2.48,2.45l0.51,1.56l-0.52,1.52l-1.33,1.76l-2.95,2.77l-2.76,1.13l-0.89,0.83l-0.4,1.28l0.09,2.55l-0.36,1.07l-1.33,1.29l-7.03,3.87l-0.53,0.71l-0.94,3.14l-3.2,3.32l-0.58,2.25l0.74,2.18l1.62,2.17l2.24,2.09Z",
      "น่าน ",
      0,
      Colors.black,
      1),
  "TH-54": MapData(
      "M323.8,286.2l-2.41,-3.74l-1.31,-1.25l-1.35,-1.94l-1.93,-0.1l-2.97,0.67l-1.08,0.61l-1.66,2.59l-2.21,1.9l-3.63,2.3l-2.66,2.47l-1.52,0.9l-6.45,2.33l-2.65,-0.43l-2.55,0.79l-2.27,0.29l-0.61,0.43l-0.23,1.22l-0.42,0.46l-1.93,1.32l-1.71,1.88l-0.81,-0.22l-2.33,-1.82l-1.14,-0.34l-10.34,0.61l-1.21,0.31l-3.54,1.99l-1.96,2.83l-0.65,1.85l-1.67,1.55l-1.67,-0.91l-1.03,-2.12l-1.18,-0.91l-3.61,-4.15l-4.93,-2.0l-2.23,-0.5l-5.22,0.97l-2.79,1.58l-1.67,1.69l-4.43,5.69l-1.01,0.6l-1.48,1.95l-0.79,0.44l-1.74,-0.21l-0.89,0.28l-2.07,1.7l-1.89,0.96l-1.76,-0.01l-0.91,-0.39l-3.96,-5.55l-0.4,-1.48l-0.06,-1.7l0.3,-0.46l3.59,-0.6l1.84,0.14l2.1,-1.66l2.43,-3.91l11.8,-13.29l5.1,-3.79l2.6,-2.71l1.12,-3.4l1.35,-0.61l1.42,0.45l1.13,0.99l1.43,-0.01l2.17,-1.92l2.31,-0.93l1.7,-1.4l1.62,-0.58l0.64,-0.56l3.85,-5.09l0.4,-3.35l5.54,-8.3l2.95,-2.32l2.77,-3.74l3.28,-0.72l1.36,-0.87l3.65,-6.32l1.16,-1.31l1.49,-2.92l2.87,-1.52l1.07,-1.01l3.66,-7.03l1.71,-2.66l0.64,-2.21l0.01,-3.45l0.7,-1.35l2.98,-1.32l1.91,0.22l0.5,-0.34l0.61,-1.47l0.47,-2.88l-0.28,-1.03l-1.26,-2.03l0.89,-4.44l-0.05,-1.88l-1.02,-5.35l2.38,-4.7l0.01,-1.91l-0.94,-1.97l1.17,-0.9l2.89,-0.96l4.59,1.41l3.97,-0.51l11.45,0.83l-0.22,1.93l0.64,0.82l1.44,0.78l0.1,2.45l0.56,1.13l0.63,0.58l1.88,0.6l-0.3,1.08l-2.49,3.18l-0.55,3.07l0.59,2.39l0.78,1.2l2.3,0.55l0.54,0.41l-1.41,1.61l-0.69,4.26l0.17,1.36l1.37,2.13l1.07,6.39l0.59,0.72l0.83,0.25l2.28,-0.86l1.71,0.23l3.03,-0.2l1.98,1.92l3.02,0.31l0.67,1.75l0.16,3.15l-0.48,2.17l-2.03,4.91l-1.96,1.75l-0.41,0.91l-0.09,4.39l0.95,2.18l-2.05,3.28l-1.26,2.72l-0.87,4.66l-0.92,2.42l-0.91,1.28l-1.57,0.45l-2.67,1.48l-0.51,0.6l2.03,11.58l-0.18,1.01l-3.6,1.6l-2.06,2.08l-0.65,1.41l0.01,2.74l-0.41,1.85l-1.27,2.62l-0.86,0.98Z",
      "แพร่",
      0,
      Colors.black,
      1),
  "TH-53": MapData(
      "M277.08,297.35l1.63,0.22l2.33,1.82l0.67,0.33l0.83,-0.06l0.64,-0.38l1.26,-1.62l2.0,-1.38l1.02,-1.94l2.12,-0.25l2.5,-0.78l2.69,0.42l7.51,-2.86l3.42,-2.98l3.62,-2.29l2.3,-1.97l1.88,-2.8l3.37,-0.86l1.45,0.0l0.38,0.33l4.45,6.39l0.77,0.37l1.39,-1.4l1.37,-2.84l0.45,-2.06l-0.02,-2.66l0.51,-1.06l1.82,-1.85l3.49,-1.54l1.52,0.49l2.29,-0.69l2.15,0.32l4.2,-0.38l0.93,-1.27l3.0,-0.16l2.79,-2.29l0.77,0.03l3.14,1.27l6.14,0.32l2.04,1.13l3.2,-0.29l2.23,0.34l2.57,-0.07l5.35,-4.56l3.65,-2.32l2.61,-5.51l2.37,-1.54l0.53,-0.79l-0.17,-1.44l-1.17,-0.86l2.82,-2.38l0.36,-0.63l0.31,-1.28l-0.81,-1.33l0.12,-0.38l1.34,-2.14l5.07,-4.6l4.07,-2.58l7.37,-6.11l0.67,0.6l6.76,3.09l0.88,1.22l-2.67,3.43l-0.2,5.18l1.34,3.31l2.08,1.6l0.3,0.78l-0.23,1.62l-1.6,4.17l-0.46,2.22l0.39,2.25l1.84,4.14l0.3,1.38l-0.7,1.23l-4.95,3.34l-4.97,8.6l-2.78,2.39l-3.38,1.86l-0.94,1.29l-0.47,2.52l0.33,3.72l-0.49,1.19l-2.16,0.94l-0.78,0.61l-0.34,0.9l0.28,0.99l0.82,1.12l-1.82,1.65l-0.24,1.11l0.45,3.27l-0.62,2.05l-1.6,1.04l-2.84,0.76l-0.92,-0.25l-0.59,-1.28l-0.73,-0.61l-1.12,-0.04l-1.05,0.46l-2.57,3.0l-1.56,3.59l-6.09,4.62l-3.21,5.2l-3.02,2.97l-4.66,2.14l-1.81,1.84l-5.57,4.1l-2.45,3.83l-0.53,0.33l-3.31,1.08l-4.49,0.98l-0.55,-0.02l-0.79,-1.3l-0.61,-0.32l-4.78,0.07l-10.54,3.78l-1.5,1.44l-2.29,-0.39l-1.36,0.21l-0.92,0.53l-3.48,2.94l-1.25,1.81l-0.52,1.63l-0.01,1.1l1.47,5.79l-0.32,1.15l-5.51,4.52l-1.41,0.49l-1.86,-0.94l-2.49,0.27l-12.54,3.8l-0.92,-0.4l-0.82,-0.84l-0.89,-0.21l-2.61,1.06l0.11,-4.38l-0.5,-2.7l-0.89,-2.16l1.02,-1.88l2.48,-2.13l1.38,-4.03l-0.09,-6.05l-0.25,-0.81l-1.15,-1.18l-0.24,-1.21l2.47,-0.91l1.16,-1.57l0.17,-0.87l-1.78,-4.17l-2.43,-2.77l-2.48,-1.78l-1.01,-2.25l-1.5,-0.6l-2.2,-3.22l-0.07,-0.78l0.31,-0.45l2.22,-1.33l1.56,-1.91l1.13,-5.38l-0.06,-1.87l-0.89,-3.39l-2.51,-2.86l-2.12,-1.81l-0.44,-1.14l0.4,-1.39l-0.19,-0.99l-2.29,-2.33Z",
      "อุตรดิตถ์",
      0,
      Colors.black,
      1),
  "TH-52": MapData(
      "M252.91,114.54l0.18,2.91l1.0,3.51l0.0,2.4l1.32,3.19l-0.73,1.81l-0.14,1.44l0.76,7.36l2.14,5.09l0.77,2.65l3.07,5.05l0.89,3.44l0.98,2.2l1.17,0.95l3.38,0.89l1.9,3.01l-0.07,1.9l0.46,0.77l1.92,0.63l2.45,-0.14l2.06,0.89l2.86,0.29l1.31,0.59l2.52,4.57l1.58,1.24l7.26,4.2l1.5,1.34l1.31,2.35l-0.3,1.82l0.47,1.85l0.83,0.49l1.93,-0.17l2.33,1.21l0.98,2.06l-0.03,1.47l-2.24,4.08l-0.19,1.24l0.58,1.97l0.52,4.8l-0.88,4.54l1.32,2.26l0.13,1.56l-0.84,3.03l-2.02,-0.16l-2.71,1.05l-0.65,0.56l-0.85,1.69l-0.02,3.48l-0.59,2.01l-1.67,2.58l-3.6,6.93l-0.85,0.81l-3.09,1.71l-1.53,2.98l-1.16,1.33l-3.5,6.14l-1.09,0.71l-3.45,0.8l-2.92,3.87l-2.99,2.37l-5.61,8.41l-0.32,0.91l-0.08,2.43l-3.7,4.89l-2.11,1.03l-1.7,1.39l-2.33,0.95l-2.05,1.86l-0.82,0.01l-1.05,-0.95l-1.76,-0.55l-1.1,0.23l-0.81,0.56l-0.49,0.68l-0.68,2.76l-2.53,2.66l-5.17,3.85l-11.84,13.33l-2.11,3.47l-1.27,1.36l-0.79,0.49l-1.6,-0.18l-3.25,0.46l-1.22,0.76l-0.21,1.52l0.58,2.7l3.86,5.47l1.07,0.74l2.6,0.12l2.15,-1.07l1.97,-1.64l2.94,-0.17l2.67,-2.73l0.46,1.27l-0.35,4.27l-1.97,2.63l-0.54,1.24l-0.18,2.28l0.37,1.62l-0.38,0.27l-2.2,-0.24l-0.69,0.48l-0.28,0.67l-0.25,3.42l0.53,0.66l0.95,0.48l0.59,2.88l-2.02,1.93l-0.6,5.23l0.14,0.79l1.15,2.06l1.49,1.06l-0.75,2.61l-0.03,1.67l1.32,0.96l1.16,1.35l2.09,0.96l0.59,2.03l-0.07,1.51l-0.47,0.94l-1.19,0.99l-0.7,1.06l-0.38,2.28l0.31,2.6l-0.32,0.74l-0.92,0.87l-0.31,1.48l-2.81,1.48l-1.26,0.29l-1.19,0.81l-1.22,-0.58l-1.42,-2.84l-1.8,-2.02l-0.99,-0.5l-2.32,-0.3l-4.15,-6.82l-0.83,-3.54l0.23,-3.24l-0.33,-1.0l-0.84,-0.7l-3.59,-0.43l-1.66,0.66l-1.36,1.5l-0.72,2.29l-2.92,2.96l-4.22,-2.32l-2.35,-0.06l-2.0,-1.33l-2.75,-0.37l-2.38,-1.31l-1.27,-1.89l-1.45,-0.8l-0.16,-0.4l0.27,-4.26l1.69,-5.16l0.11,-1.35l-0.52,-4.49l-0.39,-1.65l-1.35,-2.6l-0.05,-2.03l2.82,0.09l1.12,-0.64l0.56,-0.74l0.44,-1.72l0.43,-4.9l1.96,-2.1l0.29,-3.22l2.41,-2.1l1.86,-2.97l-0.33,-1.42l-1.2,-1.92l0.06,-0.51l0.72,-0.55l1.61,-0.33l2.98,0.53l0.72,-0.14l0.44,-1.1l-0.85,-2.4l1.59,-0.21l0.58,-1.0l-0.49,-1.41l-4.19,-4.79l-2.8,-1.15l-0.19,-2.58l-1.8,-1.64l0.11,-4.54l-0.86,-2.27l-2.44,-4.61l-0.3,-3.54l0.2,-1.81l-0.54,-3.51l-1.22,-1.92l-0.2,-2.61l-1.97,-3.08l-1.14,-4.27l0.48,-0.79l3.28,-1.66l1.64,0.05l1.75,-0.71l1.27,0.43l0.85,-0.2l0.9,-2.45l0.72,-1.06l0.72,-0.62l2.04,-0.84l0.47,-0.58l1.76,-3.7l0.15,-1.64l2.79,-4.44l3.45,-4.64l1.61,-3.1l2.66,-1.48l3.8,-0.11l1.6,-1.13l0.48,-3.33l0.87,-0.75l0.35,-0.75l0.25,-2.63l1.98,-1.66l0.7,-2.17l0.11,-0.94l-0.37,-1.02l-2.22,-0.74l-0.79,-0.69l0.62,-1.66l1.29,-1.6l-0.99,-2.34l0.31,-1.81l1.45,-4.18l1.61,-2.13l0.31,-1.53l-0.18,-2.58l-1.03,-2.32l-0.82,-5.04l-0.82,-0.58l-1.43,0.27l-0.17,-0.55l1.75,-2.26l2.63,-1.27l0.75,-1.08l0.83,-4.64l-0.81,-3.5l0.44,-0.77l2.37,-1.5l2.89,-0.35l1.22,-0.55l5.6,-6.31l0.89,-0.62l4.12,-0.69l0.69,-1.21l0.8,-2.67l1.56,-2.02l0.36,-1.83l-0.24,-1.49l-0.65,-0.58l-1.28,-0.1l-0.13,-0.24l1.24,-6.94l0.12,-2.22l2.76,-6.32l0.27,-7.63l-0.28,-1.35l-1.1,-1.99l0.16,-2.93l1.64,-2.96l0.01,-2.1l2.71,-3.74l1.12,-0.49l1.29,0.64l0.66,2.31l0.74,1.24l2.14,1.06l1.02,1.21l0.34,2.02Z",
      "ลำปาง",
      0,
      Colors.black,
      1),
  "TH-51": MapData(
      "M212.49,215.8l-0.35,2.91l-0.77,0.64l-0.78,0.28l-1.72,-0.24l-1.66,0.24l-1.82,0.76l-1.25,0.98l-1.68,3.2l-3.43,4.62l-2.87,4.58l-0.18,1.72l-1.67,3.5l-3.16,1.95l-0.83,1.23l-0.72,2.2l-1.71,-0.42l-1.76,0.71l-1.8,-0.0l-3.46,1.75l-0.81,1.32l1.19,4.69l1.97,3.09l0.17,2.52l1.22,1.94l0.5,3.29l-0.2,1.82l0.32,3.7l3.3,6.9l-0.08,4.64l1.83,1.71l0.04,2.15l0.43,0.8l2.46,0.82l2.05,2.0l2.47,3.2l-0.04,0.9l-1.51,0.13l-0.44,0.5l0.78,3.05l-4.26,-0.35l-1.48,0.56l-0.65,0.71l-0.04,1.16l1.47,2.77l-1.72,2.7l-2.48,2.2l-0.34,3.34l-1.7,1.51l-0.28,0.63l-0.46,5.03l-0.71,1.95l-1.11,0.56l-2.55,-0.19l-3.46,-2.7l-1.67,-0.76l-3.68,-0.27l-1.97,0.47l-1.5,1.04l-1.11,1.65l-0.44,1.82l-0.0,2.27l-1.47,1.94l-0.63,2.56l-0.5,0.83l-4.52,3.51l-5.25,1.81l-5.2,-0.13l-0.76,-1.55l0.0,-6.83l-1.42,-5.12l0.72,-1.89l-0.75,-1.44l-0.03,-1.34l0.53,-1.13l3.5,-1.13l0.99,-1.45l0.0,-1.52l-0.57,-1.65l-2.92,-4.47l3.64,-0.04l1.61,0.49l4.13,1.99l2.41,1.71l1.35,0.42l4.13,-1.28l1.11,-0.62l1.57,-1.76l0.26,-3.33l1.17,-5.41l-0.29,-0.97l-1.3,-1.41l-0.58,-1.23l-3.83,-12.5l-0.77,-0.69l-0.67,-0.13l-2.77,0.3l-0.44,-0.25l-0.4,-0.9l-0.51,-2.21l1.54,-8.68l-0.2,-7.25l-0.39,-1.51l-1.42,-1.84l-0.4,-5.55l-0.65,-2.48l-1.21,-1.23l-7.02,-4.0l-3.52,-1.31l0.21,-0.79l2.5,-3.17l-1.6,-3.12l1.81,-3.76l-0.06,-1.46l-0.65,-0.95l1.25,-0.67l6.48,-1.41l2.11,-1.19l4.35,-3.5l9.95,-4.94l0.81,-2.03l2.84,-4.18l0.8,-1.97l1.32,-0.75l3.45,-6.67l1.32,-0.11l1.77,1.63l0.79,0.05l2.82,-2.37l3.63,-0.4l2.82,-2.42l1.0,-0.32l3.53,-0.27l0.49,0.2l0.19,2.19l2.19,2.65l1.64,0.95l0.67,1.72l0.02,1.54l-1.4,1.33l0.11,1.56l3.34,2.58l1.76,0.86l3.04,2.67l2.56,1.34Z",
      "ลำพูน",
      0,
      Colors.black,
      1),
  "TH-50": MapData(
      "M221.68,162.82l-2.29,1.45l-0.69,1.13l0.77,3.74l-0.5,3.39l-0.55,1.57l-2.88,1.45l-1.61,1.81l-0.4,0.9l-0.0,0.8l0.54,0.59l1.98,0.03l0.17,2.43l0.6,2.47l1.0,2.24l0.16,2.39l-0.26,1.26l-1.6,2.12l-1.75,5.47l-0.03,1.1l0.95,1.99l-1.19,1.3l-0.57,1.24l-0.09,1.33l1.19,0.89l1.76,0.41l0.37,0.76l-0.68,2.52l-1.44,0.91l-0.59,0.83l-0.32,2.82l-0.33,0.56l-0.49,0.4l-1.92,-0.92l-3.6,-3.02l-1.81,-0.89l-2.93,-2.1l-0.19,-1.1l1.01,-0.78l0.5,-0.96l-0.13,-1.6l-0.81,-2.0l-1.74,-1.05l-2.01,-2.42l0.12,-1.52l-0.46,-0.88l-1.08,-0.42l-3.65,0.29l-1.31,0.46l-2.64,2.32l-2.33,0.06l-1.38,0.37l-2.65,2.31l-2.09,-1.65l-1.16,-0.1l-0.91,0.31l-3.64,6.85l-1.35,0.79l-0.8,1.99l-2.85,4.19l-0.62,1.79l-9.84,4.88l-4.43,3.56l-1.97,1.11l-6.37,1.36l-1.82,0.96l-0.13,0.6l0.78,1.01l0.07,1.1l-1.83,4.09l1.56,3.01l-2.32,2.68l-0.4,1.35l0.21,0.46l3.81,1.45l6.96,3.97l1.21,1.55l0.69,7.2l0.34,0.82l1.15,1.22l0.3,1.18l0.2,7.15l-1.53,8.93l0.82,3.03l0.61,0.7l1.06,0.28l2.34,-0.35l0.83,0.41l3.77,12.37l0.68,1.44l1.37,1.6l0.07,0.73l-1.16,4.85l-0.24,3.24l-1.64,1.63l-4.31,1.45l-1.1,-0.35l-2.37,-1.69l-4.19,-2.01l-1.88,-0.55l-4.43,0.04l-2.51,1.29l-2.73,0.91l-0.97,0.7l-0.85,1.61l0.18,1.64l-0.26,0.78l-3.35,2.81l-0.85,1.48l0.6,3.48l1.16,1.84l-0.08,1.78l-1.52,2.39l-3.26,0.59l-2.62,1.26l-1.1,1.68l-1.17,3.12l-0.41,3.22l0.33,2.92l0.65,1.05l1.99,1.7l0.76,1.49l-0.2,2.94l-1.59,3.67l0.33,0.98l2.03,1.23l0.15,3.18l-0.54,2.26l-1.11,0.67l-5.34,1.51l-3.86,0.19l-4.55,2.21l-1.95,-0.28l-1.29,-1.28l-1.76,-0.86l-1.64,-1.47l-1.85,-0.77l-1.07,-1.11l0.4,-4.16l-1.0,-3.86l-1.73,-2.21l0.32,-0.71l1.68,-1.27l0.31,-0.99l-0.58,-1.31l-1.69,-1.09l1.13,-6.89l-0.26,-1.94l-2.14,-5.47l-2.11,-0.77l-2.02,0.41l-0.54,-0.55l-0.19,-5.77l0.31,-1.62l0.73,-1.05l2.95,-2.27l0.86,-1.96l-0.22,-0.53l-6.08,-2.47l-1.16,-1.02l-0.06,-0.95l-2.26,-4.39l1.36,-1.1l0.09,-1.99l1.71,-1.52l0.17,-1.61l-0.32,-0.81l-1.48,-1.95l-2.15,-1.42l-5.6,-6.95l-3.66,-2.16l-2.13,-1.97l-0.86,-1.2l-1.08,-3.87l-0.02,-0.97l1.29,-4.28l0.99,-1.31l2.05,-1.12l0.42,-1.38l-0.27,-2.05l-1.69,-2.79l-0.44,-1.45l0.48,-2.11l-0.18,-4.12l-0.53,-1.42l-1.19,-1.42l1.41,-5.03l1.52,-3.46l-0.31,-0.95l-1.37,-1.01l-0.4,-2.36l0.66,-1.07l5.05,-4.39l1.75,-4.44l0.51,-0.24l1.11,0.44l1.44,-0.14l0.91,-0.78l0.45,-1.01l-0.18,-0.99l-0.73,-0.62l-1.93,-1.26l-2.86,-1.18l-4.52,-6.01l-0.14,-0.9l0.44,-1.7l-0.06,-3.86l-0.37,-1.63l-1.53,-2.72l1.12,-2.62l-0.18,-7.23l1.16,-3.37l0.14,-1.63l-0.67,-0.91l-1.76,-0.13l-1.39,-3.97l-0.19,-1.69l3.09,-6.77l1.26,-5.4l-0.11,-1.47l-1.54,-4.64l0.12,-0.88l2.42,-4.6l-0.02,-1.18l-1.43,-3.12l0.08,-0.6l3.04,-2.57l1.11,-4.4l1.16,-0.27l1.68,-1.28l1.76,-0.08l0.6,0.18l1.32,1.26l1.73,0.44l0.82,0.59l1.66,1.8l1.34,2.87l2.58,2.07l3.25,4.58l2.12,1.27l4.39,-0.06l3.56,0.53l2.49,1.0l1.73,1.18l0.99,-0.45l1.22,-2.44l0.64,-0.46l6.7,1.4l1.35,-0.29l2.8,-1.28l3.56,-0.49l2.33,-1.45l0.98,-1.45l0.76,-1.95l0.4,-2.15l-0.48,-2.64l-2.88,-4.97l-3.08,-2.82l-0.73,-1.16l1.02,-2.97l1.41,-6.08l-0.64,-7.97l-1.18,-2.06l-0.21,-1.04l0.84,-2.32l0.02,-3.84l0.84,-4.67l-0.91,-1.93l-2.49,-2.05l-0.21,-3.04l-1.69,-2.01l-0.68,-2.31l-0.35,-3.23l-0.69,-0.75l-3.45,-2.16l-2.36,-2.28l-1.15,-2.11l-0.2,-3.18l0.73,-0.07l2.75,2.53l2.24,0.92l0.43,-0.14l0.4,-0.93l0.97,-0.85l2.06,-0.79l2.4,-0.46l0.98,-0.62l2.76,-3.2l1.79,-0.79l9.57,-1.38l2.14,-0.72l6.28,-4.77l3.01,1.36l1.46,1.03l1.31,1.17l2.06,3.08l0.42,0.17l1.84,-0.42l3.84,-2.77l4.27,-1.69l1.59,-1.38l1.43,-2.44l0.91,-3.03l-1.01,-6.93l0.2,-1.01l1.33,-2.11l-0.82,-4.18l1.17,-7.62l2.05,-3.71l3.9,-2.86l4.68,-1.83l4.35,-0.64l2.01,0.19l4.41,1.26l1.82,0.84l4.17,3.41l2.52,1.18l2.82,-0.44l13.03,-3.99l5.12,-4.53l2.0,-1.11l2.41,1.81l3.35,1.16l-0.47,1.12l-2.52,1.86l-3.18,1.14l-0.54,0.83l-0.05,0.83l0.94,2.15l2.45,1.4l1.53,1.63l1.1,0.57l2.72,0.39l0.67,0.39l-0.22,4.17l-0.76,1.97l-0.83,0.91l-1.18,2.95l-0.52,0.53l-1.71,-1.86l-0.34,-2.0l-0.64,-1.14l-2.89,-1.43l-2.41,0.36l-3.35,-0.59l-3.38,2.07l-1.6,5.1l-1.35,1.21l-0.9,1.65l0.5,3.29l0.81,1.23l1.53,1.09l0.6,2.68l-2.43,0.63l-1.25,1.12l-0.5,1.57l-1.19,1.7l-1.0,4.65l-1.27,2.16l-1.76,0.09l-1.22,0.67l-1.46,2.14l-3.77,2.53l-0.71,1.03l-0.37,1.29l0.34,1.95l1.25,2.76l0.73,0.65l1.67,0.39l1.16,3.64l1.55,1.88l-0.47,1.54l-2.64,3.3l0.26,0.87l1.42,1.82l0.44,1.41l-0.25,3.44l1.55,4.02l0.7,3.06l-1.09,2.52l0.08,1.13l2.07,7.66l-0.43,2.2l-2.02,2.32l-1.11,4.65l0.14,1.11l1.69,6.25l6.33,7.64l1.59,6.03Z",
      "เชียงใหม่",
      0,
      Colors.black,
      1),
  "TH-93": MapData(
      "M301.14,1400.47l3.51,0.57l2.28,1.93l1.28,0.48l-4.31,3.8l-1.31,1.57l-0.29,2.33l1.27,9.28l1.96,5.26l0.71,3.98l0.69,1.92l4.34,3.86l3.81,9.3l2.1,3.59l2.82,2.22l5.06,0.37l1.97,0.64l0.79,2.0l-3.17,3.59l-0.71,2.82l-0.96,0.63l-3.64,1.22l-1.64,2.66l-5.37,0.91l-5.5,1.89l-3.08,0.23l-9.0,4.82l-4.23,4.55l-5.47,-6.83l-1.28,-2.02l-2.75,-7.57l0.87,-2.04l-0.56,-3.37l-3.53,-4.47l-0.88,-3.31l-1.9,-1.83l-2.98,-8.98l-0.28,-2.07l-2.83,-3.23l0.08,-2.91l-0.29,-1.13l-2.78,-4.11l-0.44,-1.29l0.16,-3.73l2.06,-1.29l0.46,-1.09l-0.0,-1.59l-0.45,-0.86l-2.28,-2.41l-1.32,-6.38l-4.18,-9.55l0.46,-0.43l4.84,-0.96l2.0,-1.99l15.48,-2.07l4.42,1.89l1.1,1.46l0.58,2.43l1.6,1.11l1.41,1.7l1.79,0.7l5.33,1.06l2.15,0.74Z",
      "พัทลุง",
      0,
      Colors.black,
      6),
  "TH-92": MapData(
      "M207.17,1416.33l5.7,-4.23l3.12,-5.36l0.02,-1.24l-2.67,-4.61l-0.39,-2.59l-1.87,-2.91l0.11,-0.58l3.85,-3.87l1.21,-2.08l0.41,-1.57l-0.48,-1.85l2.42,1.1l1.56,2.41l2.01,1.89l1.97,0.23l4.93,-0.15l3.76,1.82l1.4,0.08l3.26,-0.86l0.95,-3.05l1.8,-1.66l0.73,-1.71l2.61,-2.01l1.31,-2.57l0.41,-0.28l3.18,0.03l2.93,-0.59l3.88,0.11l2.36,-0.52l0.98,0.45l0.91,1.23l-0.94,2.87l-0.85,4.79l0.47,4.39l0.92,1.45l4.27,9.75l1.33,6.39l2.39,2.61l0.36,0.98l-0.4,1.59l-1.82,0.98l-0.37,0.56l-0.01,4.75l3.1,4.91l0.23,4.1l2.84,3.23l0.23,1.94l3.01,9.05l2.0,2.0l0.81,3.18l2.2,3.11l1.3,1.28l0.51,3.03l-0.76,1.33l-0.1,0.93l2.8,7.73l1.38,2.18l5.77,7.19l1.45,2.61l-2.51,0.66l-1.15,-0.31l-1.78,-1.05l-1.94,-1.69l-3.5,-4.83l-1.25,-0.99l-0.75,0.1l-0.7,0.6l-2.15,5.24l-1.43,1.54l-1.29,-0.35l-3.32,-2.26l-1.34,-2.33l-0.02,-2.73l-0.67,-0.41l-0.96,0.07l-3.32,1.41l-1.25,0.14l-2.46,-0.15l-0.88,-0.8l-1.94,0.61l-3.1,1.62l-1.37,-0.64l-0.52,-1.11l0.05,-3.76l-0.6,-0.35l-3.78,2.16l-1.74,1.46l-0.29,0.02l-0.28,-1.22l-0.39,-0.31l-2.66,-0.55l-2.73,-4.31l-1.87,-4.93l0.51,-2.13l2.3,-1.33l2.04,-3.21l1.43,-3.93l0.58,-3.72l-0.4,-0.46l-1.03,0.21l-3.05,5.83l-1.89,1.99l-2.26,-0.87l-0.38,-1.43l0.52,-4.62l-0.44,-1.64l-0.34,-0.29l-1.81,0.02l-1.18,1.65l-0.76,2.21l-0.32,1.84l0.44,3.77l-0.35,1.26l-1.59,0.52l-2.57,-1.0l-2.65,-1.93l-3.12,-0.55l-1.41,-0.88l-4.32,-6.54l0.94,-1.76l0.17,-2.56l-0.63,-5.85l-1.08,-1.79l-0.48,-1.49l-3.23,-0.25l1.23,-2.11l-0.16,-2.4l-0.8,-2.8l-0.79,-4.91l-1.07,-0.45l-1.9,0.57l-1.77,-1.09l0.92,-0.51l0.45,-0.7l-0.37,-1.26ZM226.87,1460.5l0.31,0.47l-2.1,0.1l-2.21,1.1l-2.48,3.54l-0.26,-5.65l0.68,-2.04l3.32,1.91l2.74,0.58Z",
      "ตรัง",
      0,
      Colors.black,
      6),
  "TH-91": MapData(
      "M260.22,1473.8l3.48,-0.03l3.42,-1.44l0.69,-0.0l-0.05,2.53l1.5,2.63l3.53,2.44l1.73,0.47l1.68,-1.34l1.73,-3.35l0.6,-2.09l0.65,-0.7l0.38,0.04l3.22,4.48l2.99,2.85l2.72,1.39l0.76,0.09l2.89,-0.76l0.81,0.7l0.92,1.07l0.39,1.18l0.51,4.39l1.48,2.3l3.94,4.77l1.36,0.81l1.78,0.15l1.27,0.67l2.45,0.57l1.12,0.65l1.79,1.85l0.05,1.6l-0.44,2.36l-1.69,5.32l1.68,5.88l-0.62,3.71l-0.24,0.52l-1.27,-0.61l-1.55,0.5l-0.97,1.19l-1.18,8.24l0.14,1.96l1.05,3.84l-2.31,2.96l0.3,3.83l-0.43,2.63l-1.39,3.18l-0.55,-1.51l-1.28,-1.79l-1.76,-0.61l1.2,-3.22l-0.04,-2.11l-1.41,-0.81l-1.4,0.36l-1.1,1.13l-0.83,1.9l-3.18,-2.69l-3.04,-3.5l-1.23,-3.44l-1.16,-0.49l-1.81,0.82l0.08,-0.66l1.2,-2.13l-1.41,-4.1l-0.9,-0.71l-1.78,-0.05l-0.93,-2.93l-1.25,-1.43l-2.77,-2.11l-2.63,-4.12l-2.11,-1.58l-2.55,0.71l-1.57,-4.04l-1.41,-1.53l-9.41,-3.57l-2.51,-2.35l0.03,-4.15l0.42,-1.72l1.81,-0.16l0.79,-0.9l-0.16,-1.19l-0.62,-1.02l-2.78,-1.4l0.55,-4.03l-0.7,-1.54l2.71,-5.0l1.28,-0.84l3.35,-4.94ZM250.77,1541.97l-0.45,0.28l-1.04,-1.52l-1.47,-4.73l-3.51,-3.27l0.23,-1.15l2.28,-2.91l0.23,-1.23l-0.23,-2.47l2.01,-1.57l1.06,-5.14l2.28,4.95l0.01,5.39l1.7,3.96l0.88,3.08l-0.45,2.44l-2.62,1.04l-0.57,2.47l-0.35,0.37ZM202.06,1534.15l2.62,-0.16l1.79,0.91l-4.29,2.65l-2.26,0.39l-2.07,-0.59l-0.61,-0.61l0.94,0.03l2.02,-2.22l1.86,-0.41Z",
      "สตูล",
      0,
      Colors.black,
      6),
  "TH-90": MapData(
      "M311.59,1520.98l-1.24,-0.03l-1.06,-0.78l0.44,-0.98l0.64,-3.94l-1.68,-5.83l1.67,-5.15l0.46,-2.49l-0.14,-2.03l-2.66,-2.54l-3.13,-0.9l-1.36,-0.7l-1.75,-0.15l-1.25,-0.84l-1.66,-2.35l-1.97,-2.08l-1.42,-2.2l-0.44,-4.18l-0.46,-1.39l-2.03,-2.11l-1.54,-2.78l4.21,-4.55l8.88,-4.76l2.94,-0.19l5.51,-1.89l5.05,-0.7l0.6,-0.33l1.62,-2.65l3.53,-1.16l1.22,-0.82l0.81,-2.96l2.54,-2.85l0.24,2.82l0.54,1.27l0.96,0.85l1.7,0.12l1.45,0.93l-2.97,1.58l-0.46,1.1l0.43,1.38l1.66,1.41l1.42,2.88l1.4,1.32l1.67,0.61l1.67,-0.17l2.05,1.79l1.18,0.44l2.81,0.11l3.94,-1.01l2.86,-2.59l0.91,-1.38l-0.27,-3.94l18.75,25.37l2.16,1.82l4.78,1.75l2.51,-1.03l4.87,4.47l5.61,4.24l5.43,2.66l7.39,-0.06l-0.05,0.74l-1.9,3.06l-0.91,2.13l-0.29,7.32l1.49,2.55l1.13,6.11l1.42,1.01l2.75,0.91l0.45,4.23l-0.21,1.18l-2.28,3.5l-2.24,2.57l-3.42,5.41l-5.81,1.31l-3.25,1.31l-1.63,1.19l-0.72,1.12l-0.69,3.26l-0.16,2.63l0.34,4.43l-0.32,1.31l-0.59,0.77l-0.66,0.59l-2.79,1.32l-5.16,0.13l0.39,-1.62l-1.99,-4.33l-0.54,-6.34l-1.05,-2.24l-2.66,-1.63l-3.4,-0.34l-0.73,-0.54l-0.21,-3.19l-0.56,-0.98l-2.08,0.09l-6.91,4.94l-1.75,0.24l-1.85,-0.45l-3.73,-1.65l-6.59,-1.91l-1.92,-0.89l-3.57,-2.54l-1.76,-0.41l-2.76,0.32l-1.74,-0.14l-2.34,-0.72l-4.11,-1.98l-2.04,-1.79l-1.17,-1.97l-4.01,-12.18l-0.83,-0.95l-1.41,-0.53l-2.32,-0.03l-1.9,1.23ZM326.66,1397.57l7.92,38.09l6.55,15.59l7.23,11.41l0.76,2.1l-0.05,1.05l-2.24,-0.18l-5.17,-4.84l-3.0,-1.84l-3.17,0.05l-1.59,-0.83l1.3,-2.84l-1.07,-3.49l-0.73,-4.72l-1.53,-1.11l0.2,-8.45l-0.43,-7.59l-1.82,-4.33l-3.53,-1.57l-3.82,0.42l-2.73,3.86l-0.78,1.84l-0.39,0.34l-1.44,-1.14l-0.36,-2.59l0.66,-1.93l3.57,-2.19l1.62,-2.14l0.46,-4.44l-0.7,-5.84l-1.48,-5.5l-2.02,-3.42l-2.48,-0.96l-6.41,1.58l-1.07,0.87l-1.52,-0.53l-2.46,-2.02l-3.15,-0.52l1.74,-5.9l0.8,-1.39l4.57,-2.09l5.18,-1.62l3.59,-1.87l6.38,-1.29l2.62,11.97Z",
      "สงขลา",
      0,
      Colors.black,
      6),
  "TH-96": MapData(
      "M450.09,1607.55l-0.4,-1.27l0.21,-4.54l-1.27,-2.75l0.37,-7.49l-0.22,-0.99l-0.96,-1.7l-2.92,-1.92l-0.93,-3.91l-1.31,-1.73l-3.3,-2.16l-1.88,-4.45l1.81,-1.71l0.53,-1.01l0.32,-4.29l3.25,-16.28l0.62,-0.59l4.34,-1.41l5.49,-0.79l0.97,-0.71l7.73,-9.52l-0.04,-1.04l-1.17,-1.46l0.65,-2.01l-0.19,-1.1l-1.99,-1.41l-0.67,-0.68l-0.08,-0.55l0.91,-0.98l2.48,-0.65l1.39,0.4l1.31,-0.5l2.11,1.22l0.29,2.07l1.52,2.28l1.28,0.41l3.61,0.0l5.05,7.75l4.03,4.0l10.92,6.85l12.04,11.54l5.61,4.05l-0.67,5.58l0.5,8.42l-1.16,3.31l-2.8,2.79l-8.01,6.16l-2.74,3.31l-1.69,4.63l-0.07,4.75l-0.66,3.99l-4.71,3.86l-1.51,2.76l-3.19,1.98l-0.64,0.78l-0.84,2.23l-1.12,1.21l-1.5,0.17l-2.13,-1.15l-2.42,-3.5l-1.63,-0.58l-1.7,0.48l-2.83,2.23l-1.99,-0.42l-1.55,-1.71l-2.06,-4.83l0.35,-2.9l-0.25,-0.36l-3.0,-1.07l-1.05,-2.04l-1.94,-2.43l-2.5,-0.55l-2.58,0.6l-3.39,1.32Z",
      "นราธิวาส",
      0,
      Colors.black,
      6),
  "TH-95": MapData(
      "M376.84,1564.29l5.6,-0.15l3.05,-1.42l0.85,-0.76l0.73,-1.01l0.35,-1.44l-0.33,-4.62l0.79,-5.54l0.6,-0.92l1.35,-0.97l3.17,-1.28l6.11,-1.49l3.52,-5.54l2.23,-2.55l2.4,-3.7l0.24,-1.46l-0.41,-3.79l1.5,0.79l2.52,2.17l1.6,0.83l2.03,-0.03l2.36,0.6l2.22,-0.13l1.94,-0.75l3.04,-2.53l1.15,-1.48l1.45,-3.08l0.92,-0.8l0.0,2.34l0.77,3.13l-0.27,3.0l2.21,3.89l1.08,1.12l1.23,0.25l3.47,-1.35l5.45,-1.05l4.12,0.18l4.28,-2.57l1.19,-0.26l0.68,0.39l2.56,4.05l1.32,1.04l1.41,0.26l3.47,-1.23l1.01,1.27l-0.16,0.64l-6.46,7.97l-1.53,1.5l-5.52,0.81l-4.43,1.44l-0.96,0.87l-3.38,16.61l-0.32,4.25l-2.33,2.65l0.04,0.75l1.8,4.15l4.0,2.97l0.86,1.38l0.82,3.66l0.89,0.87l2.14,1.18l0.78,1.43l-0.2,8.25l1.28,2.82l-0.22,4.41l0.45,1.54l-11.26,4.37l-3.86,2.49l-4.11,1.96l-4.21,0.76l-3.44,1.79l-1.54,5.18l-0.33,2.42l-0.89,2.11l-1.33,1.86l-1.62,1.54l-5.0,3.02l-2.82,0.89l-1.54,-0.72l-2.85,-5.36l-2.18,-2.5l-2.58,-1.69l-3.15,-0.13l-0.89,-0.35l-3.26,-5.41l-0.18,-1.09l0.23,-1.14l5.09,-10.12l1.64,-1.05l4.25,-1.19l1.06,-2.21l0.97,-5.75l0.17,-6.17l0.55,-4.43l-0.91,-2.34l-3.59,-3.0l0.09,-2.19l1.32,-1.64l1.44,-0.69l1.12,-1.19l0.2,-2.65l-0.34,-2.43l-0.72,-1.41l-1.6,-0.67l-5.09,1.04l-1.62,-0.53l-3.77,-2.89l-2.28,0.55l-2.77,2.96l-1.83,0.47l-5.91,-1.3l-1.51,0.45l-0.72,0.74l-0.99,-2.16l0.08,-3.75Z",
      "ยะลา",
      0,
      Colors.black,
      6),
  "TH-58": MapData(
      "M60.36,324.25l-14.78,-13.63l-1.62,-2.76l-0.46,-4.0l-0.99,-1.21l-2.56,-2.13l-1.13,-2.79l-2.44,-2.45l-0.53,-0.97l1.91,-0.26l0.33,-0.5l-1.43,-5.17l0.62,-1.51l3.0,-5.22l3.3,-2.27l0.48,-0.98l-0.76,-2.69l-0.83,-1.23l-2.13,-5.58l-2.09,-1.15l-0.72,0.05l-0.02,-1.08l0.59,-1.94l-0.28,-1.32l-0.98,-1.99l-0.39,-3.02l-6.0,-8.38l-1.11,-2.16l0.21,-0.72l1.65,-0.85l0.82,-1.73l0.09,-2.21l-0.7,-1.84l-1.62,-1.02l-5.75,-2.22l-1.23,0.29l-0.42,0.39l-2.07,5.47l-1.15,1.36l-4.24,-2.83l-2.11,-2.11l-1.45,-2.39l-0.6,-2.66l-0.47,-5.22l-2.74,-4.22l-2.47,-5.1l-0.48,-1.71l-1.23,-2.13l-2.64,-2.72l2.26,0.28l0.8,0.52l2.95,5.1l1.31,0.86l1.31,0.21l2.76,-0.48l5.02,0.13l4.44,-2.06l7.5,-4.92l1.99,-0.65l5.79,0.14l5.06,-1.39l0.74,0.06l0.45,-0.36l0.7,-1.39l0.86,-4.66l-0.77,-4.56l-1.23,-4.47l-0.93,-8.67l-1.33,-4.19l0.31,-3.9l-0.55,-1.58l-6.15,-5.46l-0.33,-1.01l3.22,-2.54l1.62,-1.76l0.8,-1.84l0.69,-4.25l1.1,-1.97l6.73,-5.12l1.54,-1.73l0.83,-1.85l0.47,-8.81l-0.31,-2.18l-0.88,-2.25l-3.84,-3.36l-0.47,-0.8l0.29,-0.81l1.91,-0.03l1.22,-0.44l1.06,-2.77l-2.49,-4.04l-1.69,-6.51l3.49,-4.71l3.57,-3.12l1.03,-1.34l0.75,-1.85l-0.84,-2.64l-0.12,-4.1l0.79,-1.15l3.98,-0.59l6.75,-3.33l3.43,-3.48l2.18,-0.32l1.12,-0.54l0.6,-1.57l0.03,-1.99l-0.9,-4.14l-0.11,-1.98l1.43,-7.28l0.61,-1.31l1.89,-0.43l2.95,3.36l1.6,0.48l2.62,-0.43l2.1,1.16l4.28,3.86l4.43,1.55l0.41,0.89l-0.13,2.21l0.28,1.29l2.16,1.63l3.13,-0.55l4.75,-2.23l4.26,-0.07l5.11,0.48l4.9,-0.16l3.65,-1.86l0.26,3.22l1.28,2.38l2.49,2.41l3.92,2.62l0.3,3.04l0.72,2.46l1.66,1.95l0.25,3.15l0.53,0.7l1.35,0.73l1.37,2.05l0.09,0.85l-0.86,3.93l-0.01,3.8l-0.84,2.41l0.28,1.35l1.14,1.93l0.62,7.74l-2.42,9.21l0.94,1.61l3.0,2.72l2.68,4.43l0.55,2.8l-0.38,1.89l-1.12,2.55l-2.44,1.74l-3.49,0.47l-4.05,1.56l-4.4,-1.17l-2.36,-0.23l-1.11,0.76l-1.14,2.34l-0.41,0.22l-1.36,-1.06l-2.71,-1.09l-3.7,-0.55l-3.42,0.18l-1.82,-0.52l-0.76,-0.64l-3.23,-4.56l-2.56,-2.04l-1.28,-2.8l-1.75,-1.9l-1.05,-0.75l-1.67,-0.41l-1.79,-1.46l-2.55,0.04l-1.78,1.32l-1.43,0.47l-1.16,4.49l-3.09,2.67l-0.1,1.18l1.43,3.12l-0.01,0.75l-2.57,5.13l0.17,1.47l1.4,3.87l-0.17,3.11l-0.96,3.32l-3.13,6.95l0.22,1.98l1.49,4.19l0.55,0.44l1.58,0.0l0.19,0.29l-0.13,1.33l-1.17,3.48l0.18,7.2l-1.11,2.08l-0.02,0.7l1.59,2.95l0.31,1.42l0.05,3.73l-0.46,2.17l0.26,0.86l4.69,6.22l3.0,1.28l2.35,1.59l0.08,0.5l-0.57,0.92l-0.59,0.31l-1.85,-0.44l-0.95,0.25l-0.54,0.69l-1.51,4.07l-4.98,4.31l-0.85,1.41l0.03,1.64l0.44,1.33l1.44,1.13l0.13,0.44l-1.48,3.21l-1.45,5.41l1.3,1.72l0.42,1.17l0.16,3.92l-0.49,2.2l0.51,1.72l1.68,2.77l0.21,1.7l-0.19,0.87l-1.98,1.07l-1.19,1.55l-1.36,4.44l-0.0,1.28l1.13,4.08l1.0,1.42l2.3,2.11l3.56,2.08l5.52,6.88l2.23,1.5l0.84,0.96l0.69,1.32l0.04,0.81l-1.86,1.87l-0.11,2.0l-1.25,0.88l-0.03,1.31l1.49,2.44l0.83,2.63l1.46,1.25l4.94,2.0l-4.53,0.96l-1.39,0.61l-2.23,1.71l-1.94,2.13l-7.45,-0.12l-1.11,0.28l-13.36,6.26l-1.93,1.49l-1.16,0.4l-4.61,0.2l-1.71,1.43Z",
      "แม่ฮ่องสอน",
      0,
      Colors.black,
      1),
  "TH-13": MapData(
      "M385.75,696.31l0.22,21.24l-1.02,7.55l-7.08,1.38l-17.07,2.04l-1.58,-0.21l-8.46,-2.48l-3.67,-0.59l-4.89,0.15l-1.28,-0.28l-2.13,-1.34l-7.1,-2.76l-3.11,-0.56l-1.98,-1.15l-2.12,-4.41l-0.35,-3.34l1.4,-3.84l11.43,-0.04l4.12,0.35l3.32,-1.36l2.88,1.13l5.48,-1.16l1.87,-0.75l1.29,-1.65l2.67,-2.25l22.59,-10.52l0.93,0.06l1.89,1.42l1.75,3.4Z",
      "ปทุมธานี",
      0,
      Colors.black,
      2),
  "TH-12": MapData(
      "M324.77,707.41l-0.45,1.77l-0.81,1.5l-0.19,2.53l0.42,1.99l2.47,4.9l2.1,1.1l3.11,0.56l7.04,2.74l2.18,1.36l1.51,0.32l4.31,-0.14l-3.05,10.41l-2.66,2.77l-0.45,2.18l-0.34,0.42l-1.0,0.31l-4.96,-0.6l-10.14,0.17l-3.05,-7.13l-1.8,-3.22l-0.37,-3.62l0.93,-4.34l-0.05,-1.41l-0.71,-1.76l-2.61,-3.7l0.14,-1.42l1.49,-3.42l0.49,-4.53l1.52,-1.81l0.86,-0.14l2.5,0.67l1.58,1.53Z",
      "นนทบุรี",
      0,
      Colors.black,
      2),
  "TH-11": MapData(
      "M338.21,775.11l-0.71,-7.26l0.28,-1.63l1.88,-0.58l1.48,-1.44l0.79,-4.53l-0.22,-2.63l1.26,0.49l0.82,-0.1l1.9,-1.97l1.39,-0.24l1.28,-2.28l0.87,-0.42l0.76,-0.09l0.71,0.82l0.83,0.37l0.06,0.86l-1.24,2.02l0.13,0.53l2.34,1.23l6.39,0.36l1.8,-0.28l1.13,-1.05l1.79,-4.79l0.7,-0.35l4.57,-0.28l2.64,0.29l1.95,1.14l3.11,1.09l3.03,-0.07l7.15,2.63l1.8,1.03l0.69,2.05l-0.08,0.55l-1.72,1.79l-1.11,1.82l-1.46,0.41l-0.47,0.53l-0.29,2.99l-0.59,0.42l-1.22,0.1l-0.79,0.59l-1.16,2.66l-0.54,3.15l-1.4,1.12l-0.5,0.88l-2.68,-0.79l-4.57,-0.56l-2.39,-0.97l-7.54,-1.02l-3.18,-1.18l-4.24,-2.98l-1.88,-0.75l-0.17,-0.54l0.99,-3.73l-0.11,-1.83l-0.32,-0.36l-0.44,0.2l-1.22,2.33l-0.42,1.87l0.11,4.56l-0.79,1.34l-2.0,0.89l-9.17,1.6Z",
      "สมุทรปราการ",
      0,
      Colors.black,
      2),
  "TH-10": MapData(
      "M331.32,775.77l0.76,-1.01l0.16,-1.04l-0.71,-5.31l-1.7,-5.77l-0.62,-1.15l-1.35,-1.4l-2.04,-0.77l-0.72,-1.65l-2.03,-10.3l0.68,-2.42l0.22,-2.44l10.01,-0.17l5.01,0.6l1.43,-0.45l0.63,-0.78l0.4,-2.08l2.71,-2.87l3.13,-10.67l3.3,0.53l8.42,2.47l1.82,0.24l17.15,-2.05l6.9,-1.33l-0.8,10.97l0.52,1.15l1.81,1.31l0.55,1.01l-3.19,3.84l-4.78,7.53l-0.16,0.77l0.49,1.06l-2.26,0.02l-5.94,-2.39l-6.58,0.13l-1.29,0.68l-2.23,5.39l-1.82,0.4l-6.27,-0.35l-1.74,-0.9l1.13,-1.86l-0.14,-1.51l-1.11,-0.65l-0.68,-0.82l-1.48,0.04l-1.16,0.61l-1.3,2.27l-1.26,0.15l-1.84,1.94l-1.59,-0.51l-0.83,0.5l0.17,2.85l-0.73,4.3l-1.19,1.09l-2.18,0.84l-0.34,2.06l0.73,7.38l-3.61,0.63l-2.49,-0.11Z",
      "กรุงเทพมหานคร",
      0,
      Colors.black,
      2),
  "TH-17": MapData(
      "M318.74,600.57l-1.51,-3.71l1.39,-0.82l0.75,-0.95l0.33,-1.11l-0.12,-2.29l1.19,-0.7l3.24,0.77l0.57,0.48l0.67,1.57l-0.36,1.89l1.7,3.28l1.86,1.16l6.16,2.5l-0.42,0.63l-0.02,0.93l1.3,1.59l1.24,6.07l-0.8,2.66l-1.91,2.31l-0.05,1.48l1.91,5.8l0.45,0.79l1.71,1.52l0.47,1.05l0.86,6.39l0.9,2.89l-1.51,2.49l-4.6,-0.53l-1.6,-2.26l-2.97,0.04l-1.72,-1.39l-1.92,-0.97l-1.14,-1.96l-0.82,-0.57l-0.93,-0.03l-2.91,0.91l-0.67,-0.06l-1.83,-0.97l-1.29,-0.13l-3.75,0.7l-1.82,-2.55l-0.19,-0.86l0.98,-1.4l0.28,-1.14l0.15,-6.26l-0.24,-0.75l-0.47,-0.27l-1.41,0.33l-0.67,-0.28l-0.51,-0.69l-0.05,-0.69l1.13,-1.47l0.63,-1.43l4.32,0.35l1.68,-0.26l1.85,-1.45l2.19,-3.2l0.32,-1.3l-0.67,-1.16l-1.3,-0.92l-2.19,-0.65l0.36,-1.68l0.55,-0.8l2.27,-0.86l0.67,-2.1l-0.13,-0.44l-1.6,0.48Z",
      "สิงห์บุรี",
      0,
      Colors.black,
      2),
  "TH-16": MapData(
      "M427.83,575.86l-0.2,2.59l-2.16,4.12l0.22,4.61l-0.33,8.97l0.34,3.36l1.2,0.56l2.39,-0.12l2.79,1.83l1.63,0.57l2.93,0.31l1.56,2.2l1.06,3.64l4.77,9.49l0.44,1.62l0.03,3.24l-0.42,1.12l-4.54,2.93l-1.83,0.74l-1.32,1.22l-3.2,1.42l-0.64,0.9l-0.8,2.8l-0.62,0.84l-2.03,0.95l-1.31,1.32l-1.36,0.43l-0.75,1.17l-4.9,-1.22l-1.3,-1.0l-2.47,-0.61l-0.16,-1.17l-1.0,-2.16l-1.26,-1.13l-2.44,-0.94l-1.31,-3.03l-0.6,-0.75l-5.46,-1.67l-5.07,1.3l-5.3,3.2l-0.64,1.27l0.22,1.29l-0.27,0.88l-3.19,3.55l-3.68,0.02l-1.61,-2.09l-2.24,-0.81l-0.57,-0.65l-0.35,-1.47l-0.02,-4.18l-0.82,-1.37l-2.15,-1.79l0.16,-1.34l-0.31,-0.77l-1.27,-0.37l-3.06,1.23l-1.76,0.01l-0.88,0.45l-0.4,0.62l-0.35,2.05l-2.29,1.04l-0.28,2.06l-2.14,3.13l-1.54,3.0l-10.96,6.73l-0.95,1.13l-1.65,3.7l-3.56,-0.9l-1.62,-1.34l-1.73,-0.17l-4.1,-3.13l-0.97,-1.62l1.36,-2.08l0.28,-1.01l-0.91,-2.88l-0.87,-6.45l-0.61,-1.33l-2.07,-2.16l-1.85,-5.58l-0.01,-1.03l1.81,-2.14l0.56,-1.12l0.41,-1.99l-1.27,-6.35l-1.28,-1.54l0.01,-0.51l1.73,-3.09l2.83,-3.22l1.17,-2.91l0.06,-3.47l0.57,-0.72l2.5,-1.44l0.95,-0.9l0.75,-3.81l2.59,-3.59l1.6,-1.62l1.74,-0.92l3.01,-3.66l11.96,-10.97l1.79,-2.21l0.76,-1.85l-0.12,-1.53l-0.89,-3.08l8.87,1.86l5.34,1.53l5.7,-1.45l2.99,-0.41l2.18,0.06l5.91,4.16l1.47,1.7l1.89,0.49l2.29,-0.25l3.49,2.82l1.27,0.64l3.01,0.35l4.5,-1.37l3.73,0.72l0.93,0.9l0.81,1.72l0.51,3.07l0.96,1.54l3.99,3.29Z",
      "ลพบุรี",
      0,
      Colors.black,
      2),
  "TH-15": MapData(
      "M332.23,637.19l1.06,1.92l0.55,0.34l4.85,0.59l1.09,1.79l2.9,2.33l-0.2,1.24l0.31,1.29l-0.36,3.08l-1.38,5.82l-0.85,1.53l0.63,2.5l0.36,8.04l-0.23,1.59l-2.67,1.6l-2.45,-0.78l-2.14,0.09l-0.12,-5.24l-0.55,-1.25l-0.74,-0.49l-2.68,0.33l-2.17,1.09l-1.77,-0.03l-2.43,0.52l-3.48,-0.64l-2.4,0.93l-3.76,0.11l-2.86,-2.95l-1.8,-5.09l0.08,-0.66l1.48,-1.13l0.59,-1.1l-1.26,-2.45l1.57,-2.2l0.57,-2.44l-0.99,-3.45l0.48,-2.87l-1.08,-4.67l0.56,-1.95l1.63,-1.71l3.71,-0.71l1.13,0.11l1.75,0.94l0.98,0.1l3.58,-0.91l1.65,2.36l2.02,1.05l1.76,1.41l0.91,0.21l2.14,-0.2Z",
      "อ่างทอง",
      0,
      Colors.black,
      2),
  "TH-14": MapData(
      "M318.32,705.83l0.0,-3.26l-0.75,-1.4l-2.08,-0.69l-3.62,-0.46l2.61,-3.51l0.75,-1.57l-0.05,-2.68l2.19,-8.4l0.77,-6.34l0.05,-2.32l-2.58,-4.59l-0.41,-4.24l2.37,-0.19l2.25,-0.92l3.49,0.64l2.5,-0.53l1.79,0.03l2.29,-1.12l2.19,-0.32l0.75,1.1l-0.02,4.57l0.56,1.28l2.38,-0.06l2.64,0.79l3.19,-1.83l0.44,-2.16l-0.36,-8.1l-0.63,-2.36l0.81,-1.36l1.4,-5.91l0.38,-3.23l-0.19,-2.04l0.89,0.55l1.6,0.13l2.2,1.57l2.99,0.67l-1.85,5.28l-0.16,1.77l1.65,1.74l0.86,2.19l1.19,0.87l2.05,0.37l2.84,-0.29l5.77,-2.25l5.02,0.05l1.91,0.65l-0.11,3.17l-0.25,0.45l-1.13,0.63l-0.17,0.6l1.32,3.49l-0.86,4.02l0.36,3.84l0.45,1.05l2.11,1.76l0.61,0.92l-0.37,2.82l-0.94,2.37l0.18,1.21l1.04,0.49l2.19,-0.05l0.81,0.51l0.33,0.73l0.11,6.88l-17.81,8.37l-2.85,2.39l-1.3,1.65l-1.53,0.56l-5.26,1.13l-2.89,-1.13l-3.37,1.37l-4.04,-0.35l-11.59,0.04l-1.8,-1.72l-2.87,-0.77l-1.24,0.21l-1.15,1.21Z",
      "พระนครศรีอยุธยา",
      0,
      Colors.black,
      2),
  "TH-71": MapData(
      "M88.91,599.79l-0.77,-2.43l0.46,-1.99l2.22,-3.83l0.58,-2.14l-1.38,-3.48l-0.05,-0.8l3.7,0.17l2.08,-0.92l1.76,-1.7l3.74,-5.31l1.09,-0.24l2.35,0.38l1.9,0.73l3.68,2.23l1.69,0.66l1.02,-0.21l0.56,-1.12l-0.04,-1.85l-0.41,-0.79l-1.38,-0.97l0.54,-1.16l1.76,-1.48l0.13,-1.13l-0.43,-1.82l0.06,-0.65l0.48,-0.33l3.88,-0.83l3.68,-1.69l4.17,2.1l1.48,1.61l0.34,2.29l0.7,0.21l2.86,-3.26l1.08,-5.39l-0.19,-5.68l-2.54,-16.55l0.1,-7.52l3.76,1.53l3.27,2.41l1.46,0.3l1.49,1.0l1.66,0.15l7.72,11.87l0.19,0.73l-1.11,0.68l0.41,1.16l4.29,2.92l1.18,3.75l3.17,2.67l3.17,5.24l4.42,5.5l2.01,4.1l4.93,2.57l4.47,3.48l0.56,2.87l0.09,3.23l0.68,2.72l-0.29,1.76l0.08,2.42l1.17,2.93l6.05,4.91l1.27,2.0l0.65,0.41l2.81,-0.17l3.98,-0.92l2.9,1.29l2.69,-0.2l4.57,1.48l1.0,0.6l1.35,0.13l2.94,-0.7l0.99,0.85l0.85,1.53l0.84,2.69l0.49,4.19l-0.28,1.95l-2.63,3.01l0.06,1.49l0.7,1.93l1.31,0.84l1.56,-0.44l0.88,0.18l4.34,5.61l2.16,1.91l3.63,-0.98l2.28,1.0l0.67,2.11l-0.26,0.82l-0.69,0.73l-0.04,0.86l2.57,3.72l1.01,0.26l4.11,-1.01l0.73,-0.55l0.96,-1.65l1.19,-0.87l0.89,-1.86l0.85,-5.83l1.68,0.76l1.32,-0.11l2.85,0.58l1.32,-0.4l1.97,-1.51l2.99,-0.04l1.94,0.82l6.24,7.45l3.38,2.73l1.96,2.72l3.92,1.86l2.6,0.46l2.32,1.96l-0.29,1.26l-1.78,1.24l-0.23,1.1l0.9,1.42l3.01,2.15l0.87,1.15l-0.89,1.16l-3.3,1.81l-1.93,0.68l-0.91,0.89l-0.78,20.26l0.59,4.34l-0.2,5.46l-1.21,3.97l-4.67,4.34l-0.3,0.82l0.84,7.13l0.51,0.77l1.55,0.21l1.31,1.27l0.8,2.19l-0.39,2.88l0.57,1.57l1.57,2.32l2.43,1.1l1.28,3.05l1.71,0.96l0.22,0.84l-0.88,0.49l-0.56,0.91l-2.9,7.05l-1.46,0.62l-0.8,0.91l-1.23,3.43l-0.82,0.67l-3.58,0.18l-2.07,-0.46l-5.88,-0.49l-1.85,0.28l-6.1,2.51l-4.08,0.78l-3.59,3.45l-0.97,0.36l-2.27,-0.6l-1.55,-0.9l-1.88,-2.65l-1.09,-0.59l-0.73,0.16l-2.32,1.73l-11.31,3.49l-1.83,-0.44l-2.85,-1.62l-2.45,0.97l-2.72,-0.79l-1.13,0.68l-1.1,1.44l-3.09,1.9l-5.78,0.71l-3.98,-4.11l-0.78,-1.68l-1.21,-5.2l0.26,-4.01l-0.29,-0.94l-1.17,-1.39l-2.03,-0.69l-1.41,-2.91l-3.45,-2.59l-0.92,-1.21l-2.43,-4.53l-3.43,-4.12l-0.55,-1.91l-0.24,-2.48l-1.14,-1.96l-2.14,-1.39l-4.83,-1.74l-12.8,-9.64l-2.39,-2.52l-2.88,-5.3l-1.04,-0.15l-1.4,0.43l-1.45,-0.05l-2.69,-2.96l-3.32,-1.12l-2.2,-1.73l-4.89,-6.15l-7.52,-15.33l-2.82,-1.42l-0.7,-1.37l-0.58,-2.63l-0.96,-2.45l-1.46,-2.25l-13.11,-12.63l-5.83,-9.22l-0.8,-2.0l0.34,-2.3l-1.81,-2.19l-0.06,-6.31l-0.76,-2.51l-2.53,-4.85l0.02,-1.29l1.4,-3.12l-0.58,-2.63l-3.39,-3.59Z",
      "กาญจนบุรี",
      0,
      Colors.black,
      4),
  "TH-70": MapData(
      "M195.36,750.7l5.6,-0.7l3.29,-2.02l1.83,-1.95l2.69,0.8l2.23,-0.97l2.68,1.56l2.27,0.49l11.5,-3.54l2.61,-1.83l0.63,0.34l0.91,1.6l1.1,1.16l1.75,1.01l2.62,0.64l1.39,-0.54l3.45,-3.37l3.97,-0.73l6.05,-2.49l1.56,-0.26l5.89,0.49l2.11,0.46l3.91,-0.23l1.24,-1.07l1.41,-3.69l2.01,-1.15l3.29,-7.78l0.94,-0.52l0.89,0.08l4.39,1.17l1.08,0.72l0.51,0.9l0.33,1.23l-0.01,2.8l1.13,3.81l-0.12,1.63l-1.02,3.27l0.47,2.8l-0.76,3.14l0.45,1.21l1.66,2.16l1.46,0.6l1.93,-0.62l2.93,-2.44l0.51,0.23l0.89,1.66l-0.13,2.14l0.31,0.66l0.89,0.45l2.69,0.29l0.55,0.66l-0.23,4.91l-0.11,0.78l-2.2,2.2l-0.64,1.31l-1.21,10.06l-2.71,-0.16l-1.42,0.88l-2.31,0.7l-5.15,-2.14l-1.11,0.18l-0.46,0.47l-2.45,5.3l-0.16,4.4l-2.1,4.37l-1.47,5.43l-6.68,-0.09l-3.22,-0.4l-6.86,2.43l-3.92,4.48l-0.05,4.73l-0.35,1.44l-0.88,0.83l-1.94,0.8l-5.64,0.87l-5.87,-0.72l-1.22,0.52l-1.58,1.55l-2.67,-1.02l-2.23,0.93l-4.43,-1.53l-1.47,-1.22l-2.35,-0.66l-1.69,-1.41l-1.27,-0.42l-0.96,0.04l-2.85,2.88l0.06,3.22l-0.3,0.77l-3.24,2.1l-0.99,0.31l-0.67,-0.26l-1.67,-3.36l-1.4,-1.04l-5.73,-2.69l0.28,-1.86l-1.81,-6.39l-0.06,-1.34l1.53,-3.19l-0.36,-3.2l0.55,-5.46l-0.1,-2.18l-3.89,-17.12l-0.27,-9.21l0.36,-2.54l-0.03,-2.89l-0.36,-0.67Z",
      "ราชบุรี",
      0,
      Colors.black,
      4),
  "TH-19": MapData(
      "M416.19,636.2l1.52,19.15l-1.73,2.82l-0.43,1.87l0.47,0.95l2.01,1.45l1.29,2.16l2.22,2.31l-0.9,0.89l-0.67,3.36l-1.47,2.02l-0.98,2.75l0.12,2.44l-2.61,2.3l-1.69,0.37l-1.41,-1.94l-2.46,-1.73l-0.96,-0.27l-3.56,-0.0l-2.09,-2.48l-1.05,-0.23l-0.5,0.78l0.04,3.06l-1.99,3.01l0.25,1.32l-0.3,0.99l-1.12,1.37l-3.91,2.78l-1.21,-1.24l-0.65,-0.23l-1.93,0.26l-0.61,0.4l-0.39,0.76l0.46,2.83l-0.58,1.53l-3.11,3.51l-1.57,-3.05l-2.31,-1.74l-1.46,-0.05l-4.08,1.83l-0.32,-7.25l-0.37,-0.59l-1.08,-0.68l-2.37,0.01l-0.54,-0.31l1.16,-3.54l0.2,-2.37l-0.81,-1.33l-2.05,-1.7l-0.29,-0.64l-0.36,-3.72l0.86,-4.1l-1.32,-3.47l1.07,-0.67l0.46,-0.81l0.28,-2.37l-0.33,-1.53l-2.43,-0.92l-5.19,-0.05l-1.65,0.42l-4.2,1.84l-3.5,0.21l-1.79,-0.88l-0.82,-2.14l-1.51,-1.37l0.12,-1.48l1.98,-5.64l1.75,-3.93l0.8,-0.93l9.68,-5.69l1.31,-1.07l1.65,-3.13l2.17,-3.19l0.32,-0.8l-0.07,-1.18l2.19,-0.93l0.54,-2.36l0.41,-0.47l2.03,-0.07l2.48,-1.13l1.09,0.03l0.07,1.99l2.25,1.92l0.66,1.13l-0.04,3.94l0.44,1.78l0.89,0.99l2.15,0.76l1.75,2.2l2.96,0.18l1.51,-0.28l3.44,-3.83l0.38,-1.22l-0.22,-1.28l0.34,-0.71l5.14,-3.09l4.7,-1.23l5.0,1.51l1.79,3.66l2.7,1.13l0.95,0.86l0.9,1.96l0.1,1.23Z",
      "สระบุรี",
      0,
      Colors.black,
      2),
  "TH-72": MapData(
      "M209.52,609.3l1.01,-2.54l0.62,-3.15l1.72,-1.67l0.95,-0.4l2.73,2.35l6.15,1.79l1.35,3.78l10.61,2.23l2.78,1.79l8.04,2.26l2.19,-0.31l0.24,-1.36l-0.68,-3.03l2.22,-0.7l1.79,0.57l3.92,2.12l2.2,0.81l7.76,1.06l7.99,3.29l8.35,0.81l2.41,0.63l2.86,-0.54l3.55,-1.22l1.35,-0.76l0.87,-1.06l-0.47,-1.87l0.28,-0.51l7.31,1.76l2.01,2.05l0.88,0.5l1.83,-0.4l5.02,-2.61l-1.44,2.13l-0.11,0.73l0.2,0.71l1.2,1.23l1.9,-0.14l0.09,0.29l-0.16,6.04l-1.27,2.62l0.3,1.25l1.8,2.53l-1.62,1.76l-0.66,2.25l1.09,4.85l-0.48,2.83l0.98,3.34l-0.49,2.13l-1.5,1.9l-0.16,0.61l1.26,2.36l-0.38,0.69l-1.56,1.23l-0.2,1.19l2.25,5.92l2.79,2.72l1.18,0.22l0.43,4.39l2.58,4.59l-0.82,8.29l-2.2,8.43l0.07,2.57l-0.65,1.37l-2.9,3.9l-5.33,2.5l-1.31,1.44l-3.1,-0.33l-11.46,0.31l-4.15,-0.48l-6.44,3.95l-5.23,4.89l-1.5,0.31l-5.33,0.07l-0.87,-2.27l-1.6,-1.49l-1.53,-0.25l-0.9,-7.06l4.86,-4.8l1.31,-4.27l0.2,-5.6l-0.59,-4.32l0.72,-19.93l5.82,-3.02l1.27,-1.72l-0.37,-1.08l-3.77,-2.94l-0.68,-1.08l0.1,-0.36l1.83,-1.31l0.46,-1.01l-0.12,-1.01l-2.68,-2.33l-2.69,-0.5l-3.7,-1.73l-1.87,-2.64l-3.4,-2.75l-6.29,-7.49l-1.1,-0.69l-1.29,-0.33l-3.3,0.06l-1.88,1.42l-1.23,0.46l-2.76,-0.58l-1.15,0.14l-1.2,-0.69l-1.1,-0.0l-0.69,1.23l0.1,1.77l-1.18,4.64l-1.41,1.15l-1.13,1.82l-4.46,1.05l-2.36,-3.32l1.0,-2.17l-0.21,-1.4l-0.72,-1.38l-1.42,-0.84l-1.37,-0.36l-3.34,1.02l-1.86,-1.66l-4.5,-5.76l-1.4,-0.32l-1.47,0.43l-0.66,-0.45l-0.68,-2.74l2.57,-2.89l0.37,-2.34l-0.5,-4.3l-0.87,-2.81l-0.77,-1.55l-1.09,-0.96Z",
      "สุพรรณบุรี",
      0,
      Colors.black,
      2),
  "TH-75": MapData(
      "M282.58,797.74l-1.41,0.4l-1.79,1.59l-2.04,-0.32l-0.84,0.31l-1.04,2.73l-0.0,1.12l-1.7,-0.89l-1.51,-2.23l0.62,-4.15l-0.57,-2.27l1.49,-5.54l2.13,-4.44l0.16,-4.39l1.81,-3.51l0.28,-1.13l0.58,-0.7l5.74,2.1l2.62,-0.76l1.33,-0.84l2.69,0.18l4.11,5.31l1.14,2.74l-3.51,1.26l-1.68,1.2l-1.81,3.85l-1.92,-0.52l-0.48,0.25l0.22,0.5l1.29,0.56l-0.15,1.57l-0.77,1.58l-1.23,1.11l-3.34,1.31l-0.41,2.01Z",
      "สมุทรสงคราม",
      0,
      Colors.black,
      2),
  "TH-73": MapData(
      "M317.52,707.0l-0.35,3.95l-1.61,3.95l-0.16,1.75l1.03,1.93l1.68,2.05l0.62,1.49l0.06,1.11l-0.94,4.43l0.24,3.21l5.12,11.32l-0.24,2.64l-0.69,2.48l0.48,2.29l-0.81,0.68l-5.36,1.93l-0.23,0.44l0.18,1.22l-1.03,1.23l0.18,1.62l-4.91,0.63l-1.09,-0.51l-1.77,-1.51l-8.6,-0.32l-3.36,-0.58l-0.89,-0.92l-2.85,-0.32l-0.51,-0.36l0.07,-2.38l-1.0,-1.86l-0.76,-0.49l-0.7,0.0l-0.62,0.41l-2.79,2.33l-1.17,0.27l-0.89,-0.38l-1.85,-2.78l0.75,-3.1l-0.47,-2.8l1.0,-3.12l0.14,-1.84l-1.14,-3.94l0.02,-2.73l-0.39,-1.44l-0.65,-1.13l-1.37,-0.93l-5.36,-1.29l-0.47,-1.29l-1.62,-0.85l-1.31,-3.09l-2.45,-1.12l-1.41,-2.09l-0.49,-1.26l0.32,-2.49l5.34,-0.07l1.72,-0.35l5.41,-4.99l6.25,-3.85l3.88,0.53l11.43,-0.31l1.21,0.32l2.1,-0.0l0.72,-0.41l0.86,-1.14l5.21,-2.44l5.75,1.03l0.55,0.94l0.0,4.33Z",
      "นครปฐม",
      0,
      Colors.black,
      2),
  "TH-77": MapData(
      "M233.08,1050.19l-4.52,0.87l-1.61,1.47l-2.38,0.92l-1.34,1.19l-5.65,-0.35l-1.95,0.27l-1.81,-0.79l-1.39,-0.15l-2.69,0.14l-1.03,0.59l-1.05,0.04l-4.16,-1.1l-7.74,-3.89l-0.57,-0.69l-0.65,-2.68l1.02,-0.82l2.47,-4.28l3.23,-1.31l0.92,-1.03l3.34,-9.9l1.36,-2.39l3.52,-4.25l1.33,-2.5l1.63,-4.37l1.11,-1.63l4.17,-4.56l0.67,-1.82l0.77,-4.62l0.96,-1.66l3.09,-3.11l1.37,-1.88l1.04,-2.24l0.44,-2.02l-0.06,-6.89l0.9,-1.64l1.62,-1.02l2.4,-0.47l4.48,-0.27l1.59,-1.21l7.03,-9.47l0.93,-2.65l1.59,-7.29l-0.5,-1.53l-1.78,-0.51l-3.91,-2.94l-1.28,-1.59l-0.74,-2.27l0.34,-2.13l1.67,-4.39l0.12,-2.54l-0.86,-2.02l-1.63,-1.43l-1.98,-0.64l-1.51,-1.38l0.33,-2.81l2.61,-8.6l-0.47,-1.23l-1.15,-0.62l-1.29,-0.0l-6.11,1.99l-1.16,-0.28l-0.3,-1.57l0.47,-0.87l1.92,-1.84l0.27,-1.9l-1.96,-4.39l0.17,-3.04l-0.3,-1.34l-2.45,-3.33l-0.55,-1.25l-0.66,-8.22l-0.75,-2.49l-2.44,-4.36l-0.43,-2.12l1.85,-4.61l0.32,-2.48l-0.2,-3.74l7.22,-1.96l1.98,-0.27l2.37,0.23l6.28,1.49l2.22,2.2l1.82,0.69l1.52,0.11l1.39,-1.48l2.47,-0.92l1.59,-1.02l4.32,-0.86l3.27,0.47l1.65,-0.11l5.8,-4.5l1.34,-0.63l10.14,-0.05l4.07,-0.82l2.16,10.07l-0.4,6.95l0.41,2.53l3.28,7.89l0.12,1.41l-0.9,1.6l-2.38,8.15l0.1,1.2l2.93,3.39l0.46,1.05l0.65,4.01l-0.42,1.21l-2.21,1.85l-0.81,1.14l-0.73,4.05l-2.77,4.79l-10.82,11.42l-2.67,4.89l-0.91,5.19l1.44,3.91l-0.15,0.28l-1.32,0.13l-0.94,0.53l-0.48,1.16l-0.02,1.31l0.79,4.06l-0.64,2.47l0.43,0.98l-3.63,0.5l-3.17,3.09l-8.81,14.51l-1.03,2.99l-2.13,3.13l-1.07,6.88l-0.67,2.17l-3.52,8.3l-2.03,2.16l-0.58,1.36l-0.33,6.41l0.36,2.37l1.8,4.5l0.0,1.81l-1.26,1.21l-0.58,-1.6l-0.39,-0.26l-1.72,0.05l-2.12,1.34l-2.33,2.82l-1.33,3.32l-0.25,2.19l0.37,2.36l1.58,4.01l0.33,1.84l-0.29,2.08l-0.88,2.17Z",
      "ประจวบคีรีขันธ์",
      0,
      Colors.black,
      4),
  "TH-76": MapData(
      "M271.58,794.44l0.49,1.82l-0.57,4.48l1.67,2.48l1.74,1.03l0.68,0.12l0.73,-0.52l-0.07,-1.23l0.82,-2.33l2.52,0.21l0.84,-0.43l1.15,-1.24l1.06,-0.29l0.69,3.4l3.41,4.52l8.14,7.17l1.46,6.13l1.78,4.24l-0.24,1.74l-0.91,1.66l-3.56,4.8l-0.81,1.62l-1.12,3.66l-1.48,7.91l-0.56,1.55l-3.95,6.29l-1.46,4.37l-1.01,4.52l-0.5,4.7l0.03,3.22l-4.1,0.84l-10.33,0.07l-1.57,0.74l-5.63,4.41l-4.64,-0.41l-4.5,0.89l-1.75,1.08l-2.56,0.97l-1.12,1.35l-2.76,-0.7l-2.34,-2.25l-6.46,-1.54l-2.44,-0.24l-2.14,0.28l-7.22,1.96l-0.15,-0.72l-1.17,-1.65l-5.32,-2.95l-2.17,-1.97l-1.53,-2.02l-3.53,-1.33l-0.57,-3.01l-0.63,-1.16l-1.28,-0.79l-3.23,-0.79l-1.01,-1.71l0.03,-4.03l-0.4,-2.27l-0.95,-1.5l-2.93,-3.15l-0.73,-4.45l-1.62,-4.22l0.1,-1.32l1.4,-3.19l-0.32,-2.52l-1.55,-2.19l-6.19,-4.73l-0.47,-1.98l1.5,-4.94l0.32,-2.87l-0.34,-4.52l1.16,-1.64l1.91,-0.72l4.24,-0.47l1.51,-1.25l5.79,2.72l1.24,0.93l1.59,3.28l0.76,0.44l1.03,0.03l4.37,-2.65l0.47,-1.2l-0.12,-2.98l2.62,-2.46l1.4,0.4l1.64,1.38l2.33,0.65l1.55,1.26l4.62,1.58l2.37,-0.93l1.63,0.9l1.24,0.09l1.78,-1.65l0.88,-0.39l5.84,0.72l5.76,-0.89l2.2,-0.91l1.13,-1.1l0.46,-1.78l-0.0,-4.49l1.46,-1.3l1.23,-1.94l0.93,-0.87l6.52,-2.3l3.07,0.41l6.72,0.09Z",
      "เพชรบุรี",
      0,
      Colors.black,
      4),
  "TH-18": MapData(
      "M319.43,601.17l-0.33,1.04l-1.88,0.54l-0.56,0.52l-0.85,2.15l0.02,0.75l0.42,0.6l2.54,0.75l1.18,1.35l-0.21,0.73l-2.14,3.13l-1.57,1.22l-1.3,0.18l-4.78,-0.33l-5.94,3.09l-1.5,0.31l-2.54,-2.46l-4.89,-1.01l-2.16,-0.82l-0.89,0.02l-0.66,0.68l-0.16,0.65l0.45,1.75l-0.48,0.45l-4.7,1.89l-2.53,0.5l-2.4,-0.63l-8.2,-0.78l-7.99,-3.29l-7.33,-1.01l0.34,-1.12l-0.75,-1.75l0.11,-0.82l1.26,-1.66l1.65,-0.52l2.01,-1.92l2.04,-1.18l1.98,-3.55l0.19,-1.22l-1.45,-1.48l-4.51,-7.04l-0.95,-2.53l-0.97,-1.58l-0.73,-4.91l-1.21,-2.79l0.03,-1.18l0.79,-1.17l3.7,-2.31l1.46,0.52l9.19,1.18l0.84,0.41l1.08,1.14l0.9,0.3l5.03,-1.0l1.82,-0.08l2.16,0.39l3.11,-0.24l4.33,1.24l0.9,1.81l1.3,0.24l1.79,-0.87l0.22,-0.44l-0.38,-0.32l-1.25,-0.05l-0.09,-1.26l1.4,-3.19l-0.06,-2.84l-1.93,-3.24l-2.28,-1.79l-0.26,-0.94l0.47,-0.31l2.2,0.04l0.28,-0.47l0.04,-1.64l5.05,0.11l0.99,-0.29l5.42,5.22l3.05,1.17l1.46,0.94l2.14,2.11l3.35,5.07l4.91,12.99l-0.79,0.31l-0.63,0.77l-0.14,3.28l-0.58,0.74l-1.57,0.91l-0.17,0.5l1.82,4.47l0.59,0.19l0.67,-0.34Z",
      "ชัยนาท",
      0,
      Colors.black,
      2),
  "TH-39": MapData(
      "M569.02,362.39l-1.04,0.48l-0.58,0.67l-0.79,2.51l-2.58,1.72l-3.44,0.66l-1.22,1.29l-0.27,1.27l0.27,1.12l3.47,6.99l1.22,1.68l12.84,12.37l-5.1,12.31l-1.68,6.64l-5.35,0.88l-1.47,-1.81l-1.01,-0.72l-3.21,-1.09l-3.87,-0.5l-4.44,1.05l-2.04,-0.38l-1.99,-1.17l-4.56,-1.65l-1.41,-0.21l-1.22,-2.13l-0.36,-1.37l-1.15,-0.6l-0.35,-0.96l-1.56,-1.63l-2.1,-1.06l-1.38,-0.19l-2.0,0.24l-1.29,1.25l-3.17,2.05l-0.95,0.23l-3.44,-0.88l-2.4,-1.28l-3.62,-0.69l-3.7,-0.29l-1.93,-2.89l-1.87,-3.58l-0.02,-0.53l0.93,-0.84l4.48,-1.74l2.45,-2.52l4.37,-1.83l0.36,-1.01l-0.58,-0.74l-1.61,-1.07l-0.77,-1.37l-1.46,-0.99l-0.84,-3.12l-1.39,-1.97l-2.41,-0.77l-2.41,-1.27l-2.15,-0.43l-2.31,-1.4l-1.75,-0.35l-1.24,-0.7l-2.52,-2.88l-0.74,-2.57l0.13,-0.53l3.37,-4.37l0.28,-3.43l3.74,-4.04l0.85,-1.53l-0.46,-2.46l0.19,-2.57l-3.47,-4.26l-0.66,-2.22l0.14,-1.56l0.73,-0.72l1.07,-0.17l4.05,-0.1l2.22,0.35l1.53,-0.33l2.28,-1.21l3.27,-2.36l0.91,-1.96l0.95,-1.21l-0.1,-2.02l-2.04,-6.21l2.54,-3.13l1.23,-0.37l1.52,0.87l1.4,0.01l1.73,-0.97l2.51,-2.38l0.95,-0.06l2.58,1.03l5.91,1.08l1.39,0.84l1.58,0.44l1.51,-0.36l1.64,-0.94l0.37,1.1l-0.16,5.13l1.07,2.58l0.77,4.88l4.03,8.05l0.61,2.08l0.48,3.36l-0.83,2.37l0.31,3.2l0.97,1.33l1.21,0.59l2.7,0.24l0.71,0.87l0.16,1.4l-0.75,1.19l-0.59,2.23l0.05,1.79l2.03,1.19l2.38,3.03l1.1,0.03l2.62,-1.24l2.34,-0.7l2.71,-0.32l0.58,0.22Z",
      "หนองบัวลำภู",
      0,
      Colors.black,
      3),
  "TH-": MapData(
      "M552.96,961.16l0.22,-0.33l0.81,0.05l1.62,-0.91l0.06,-1.02l1.18,0.85l2.43,0.08l-0.12,0.93l-2.01,0.69l-0.23,0.5l0.25,0.74l-1.42,-1.43l-0.99,-0.43l-1.79,0.29ZM370.73,863.12l0.53,-0.04l0.78,-1.14l2.01,-0.04l0.27,1.96l-0.93,0.76l-0.52,1.13l-0.71,0.41l-0.41,-1.36l-1.02,-1.67ZM272.33,1518.77l-1.11,0.22l-0.68,-0.33l0.25,-1.35l0.79,-0.52l0.76,1.98ZM269.27,1152.86l-0.65,-0.54l-0.4,0.12l-0.16,-0.66l1.13,-2.39l-0.08,-0.78l-0.59,-0.91l0.15,-0.93l0.98,0.28l0.58,-0.31l1.21,3.37l-0.51,0.36l-1.2,2.21l-0.45,0.19ZM245.1,1478.26l-3.81,-1.01l-1.52,-2.41l3.13,1.25l2.19,2.17ZM212.15,1540.41l-1.09,0.21l-0.83,-0.59l-1.29,-5.13l0.38,-0.51l3.18,0.64l1.13,1.44l-0.22,2.62l-0.65,1.03l-0.61,0.27ZM176.18,1396.42l0.31,0.3l1.58,0.1l-0.07,1.05l-1.12,1.16l0.5,2.43l-4.2,-5.26l-0.77,-0.45l0.58,-0.85l0.59,-0.2l1.33,0.26l1.14,0.82l0.14,0.64ZM117.95,1179.18l0.92,-0.72l0.17,-1.4l-0.51,-1.24l0.94,-1.04l0.86,0.84l0.82,0.22l-0.64,1.49l0.33,2.21l-0.89,0.49l-0.31,2.06l-0.57,-0.42l-0.6,0.1l-0.38,-0.44l-0.13,-2.14ZM109.71,1423.18l0.14,-1.52l0.57,-0.58l0.7,-0.03l-1.42,2.14ZM100.54,1249.7l-0.84,0.58l-0.21,-0.34l0.08,-2.01l4.19,-6.44l0.42,-0.0l0.24,0.53l-2.61,4.36l0.31,1.31l-1.59,2.02ZM31.4,1308.32l0.13,1.24l-0.98,-2.3l0.92,-0.59l-0.08,1.65Z",
      "",
      0,
      Colors.black,
      0),
  "TH-74": MapData(
      "M317.17,752.8l5.78,-2.2l1.38,7.25l0.87,2.0l2.16,0.86l1.71,2.2l1.68,5.7l0.69,5.19l-0.2,0.82l-0.81,1.1l-4.6,0.12l-2.05,0.82l-4.93,-2.46l-1.57,-1.26l-0.6,0.13l-1.07,2.06l-1.19,1.21l-1.67,0.89l-9.35,3.66l-4.02,0.82l-2.29,1.02l-1.19,-2.84l-4.18,-5.41l1.2,-10.14l0.5,-1.02l2.34,-2.47l0.35,-5.56l3.16,0.54l8.38,0.29l1.61,1.42l1.46,0.63l4.65,-0.47l1.14,-0.67l-0.21,-1.73l0.97,-1.06l-0.09,-1.43Z",
      "สมุทรสาคร",
      0,
      Colors.black,
      2),
  "TH-84": MapData(
      "M296.18,1206.63l0.4,1.17l-1.07,1.19l-0.9,3.1l-0.35,3.52l-0.78,2.64l-2.97,1.41l-0.8,2.37l-0.51,0.27l-1.64,-0.05l-5.88,0.76l-0.5,-1.67l-0.44,-4.02l-1.05,-2.03l1.53,-2.04l-0.2,-2.15l-1.37,-3.65l0.85,-1.0l2.32,-0.31l2.66,0.19l6.53,1.62l2.02,-0.35l1.02,-2.01l1.12,1.04ZM286.82,1182.41l4.07,0.19l3.28,2.08l1.25,3.47l1.04,7.45l-3.23,-1.93l-5.89,-2.45l-0.97,-0.81l0.51,-1.3l-0.37,-1.23l-2.08,-2.41l0.01,-0.46l1.65,-2.93l0.73,0.33ZM194.08,1183.13l0.36,2.31l1.5,4.37l1.2,6.82l0.97,2.48l3.3,4.94l0.58,1.61l0.62,4.43l4.61,8.44l5.94,7.66l-2.94,0.01l-0.32,0.32l-0.12,1.18l-3.65,2.21l-2.21,2.44l-0.59,1.97l0.42,4.54l2.3,5.13l5.35,1.31l5.22,0.37l3.19,2.88l3.53,-0.37l3.61,0.03l3.35,-0.55l3.22,-2.33l2.12,-5.36l1.39,-1.15l1.16,-0.14l5.0,0.9l1.91,-0.38l3.32,-1.81l3.34,-0.81l2.03,-1.47l4.43,0.38l0.92,-0.89l1.15,0.06l1.49,0.59l-1.37,1.64l-0.58,1.26l-0.1,2.38l0.48,3.83l-2.55,8.16l0.35,0.91l1.13,0.74l0.82,1.85l0.92,0.43l1.69,0.11l0.84,0.62l0.28,1.4l-0.03,3.96l-0.4,0.57l-1.07,0.46l-1.46,-0.89l-1.12,0.27l-0.61,3.87l-1.23,3.13l-0.08,1.26l-0.45,0.61l-0.85,0.41l-2.04,0.27l-0.81,0.42l-0.28,0.71l0.76,2.14l-0.36,0.57l-3.29,1.51l-1.9,0.0l-2.06,1.23l-0.46,-0.13l-1.28,-1.44l-2.08,0.42l-0.74,0.91l-2.82,5.54l-0.81,0.84l-1.68,0.01l-0.68,0.49l-0.47,1.62l0.12,2.57l-0.35,2.14l-0.01,1.93l0.43,2.19l-0.58,2.38l-0.58,0.97l-2.38,2.43l-0.61,3.25l-2.43,2.17l-1.52,0.83l-0.39,0.6l-0.24,1.76l0.33,1.26l-0.24,0.69l-2.01,1.47l-2.2,2.63l-4.15,1.7l-4.01,2.83l-1.11,-0.12l-2.93,-2.07l-1.24,0.02l-0.4,1.39l0.64,4.97l-0.18,1.09l-0.95,1.74l-2.21,2.79l-1.72,4.99l0.02,1.08l0.55,1.38l1.88,2.5l-5.33,1.84l-3.17,0.09l-4.26,-1.21l-1.76,-1.11l-4.68,-0.88l-2.43,-0.02l-1.65,1.2l-1.33,1.68l-3.48,1.11l-2.46,-0.57l-3.86,-0.34l-1.31,0.18l-1.77,0.89l-1.07,-2.76l-0.28,-1.68l0.05,-3.6l-0.86,-2.46l0.29,-1.88l1.02,-1.4l0.56,-1.6l0.05,-1.47l-0.37,-0.97l-1.49,-1.88l-0.7,-1.75l1.41,-2.18l3.23,-2.76l0.06,-0.72l-1.17,-2.32l-2.69,-2.69l-2.53,-1.11l-2.0,-2.4l-5.87,-0.63l-2.03,-2.24l-1.53,-0.86l-1.01,0.01l-1.07,0.62l-1.71,4.0l-0.97,0.64l-1.02,0.07l-5.66,-2.06l-4.05,1.64l-4.23,0.37l-3.58,-2.71l-0.27,-0.56l0.2,-0.38l2.51,-0.8l1.28,-2.35l1.65,-1.26l0.44,-0.77l0.03,-4.14l0.46,-3.18l-0.2,-1.56l-0.86,-1.04l-2.3,-0.18l-1.01,-0.49l-3.1,-4.74l-4.13,-3.26l-4.64,-1.11l-0.17,-0.38l0.68,-1.9l-0.87,-3.56l0.67,-1.39l3.38,-1.92l1.24,-0.11l0.41,-0.36l-0.24,-2.27l-2.41,-6.94l1.26,-0.86l0.32,-0.67l-0.8,-5.34l0.29,-1.78l0.99,-0.51l0.59,-1.05l-0.31,-2.92l0.7,-2.71l2.21,-2.73l0.42,-1.21l-0.41,-5.48l-0.5,-0.77l-1.46,-0.78l2.36,-3.55l1.37,-0.87l4.35,-1.26l1.27,1.74l1.63,0.23l5.15,-0.82l1.26,-0.76l0.49,-2.66l-0.65,-0.69l-1.51,0.03l-0.11,-3.79l1.85,0.42l0.56,-0.37l0.8,-1.94l-0.18,-0.68l-0.86,-0.91l0.15,-0.69l2.44,-0.91l5.33,-6.06l2.11,-1.28l0.49,-0.61l0.18,-0.82l-0.85,-1.17l-0.06,-1.39l-1.68,-1.29l-0.15,-1.84l2.27,-3.2l1.57,-5.7l0.44,-0.21l0.72,0.43l0.69,-0.0l7.16,-3.86l3.31,-1.26l0.81,0.01l2.7,0.92l2.97,-0.23l3.73,-1.19l1.69,0.57l1.49,-0.17l1.33,-0.6l1.95,-2.45l3.42,-1.69l1.34,-1.24l4.46,-0.64ZM254.59,1211.99l-1.9,0.74l-0.7,-0.33l2.3,-1.75l0.3,1.34Z",
      "สุราษฎร์ธานี",
      0,
      Colors.black,
      6),
  "TH-85": MapData(
      "M113.11,1231.01l0.67,-3.06l3.08,-5.92l1.91,-9.61l1.29,-2.57l2.83,1.97l0.48,-0.01l3.58,-2.81l1.27,-1.4l-0.19,-1.44l-0.3,-0.29l-3.67,0.01l-1.01,-2.13l-1.92,-0.83l0.67,-1.36l1.82,-1.37l1.33,-0.16l1.49,-2.24l-0.33,-1.21l-1.49,-1.99l1.38,-0.31l0.31,-1.26l-0.71,-1.18l-1.09,-0.73l3.29,1.5l1.59,-0.26l0.78,-1.93l1.31,-1.1l0.56,-1.15l-0.13,-0.49l-0.71,-0.5l-2.41,-0.1l-1.77,-0.73l-0.53,0.13l-0.55,0.88l-0.09,-2.71l0.68,-0.69l2.64,-0.56l1.69,-1.19l1.21,-1.37l1.85,-3.64l-0.13,-0.49l-0.5,0.03l-2.67,3.04l-0.83,0.51l-0.67,-0.13l-1.07,-1.57l-1.62,-1.05l0.71,-1.56l2.64,-2.81l1.28,0.96l0.98,-0.06l0.95,-0.48l0.13,-0.62l-0.34,-0.4l1.27,-0.92l0.61,-1.32l-0.44,-0.84l-1.42,-0.59l2.01,-2.52l0.69,-0.48l2.48,-0.02l1.15,-0.8l0.25,-1.12l-0.23,-0.45l-1.25,-0.5l-1.5,0.37l-0.65,-0.84l0.39,-1.87l4.77,-8.21l1.6,-1.85l2.96,-8.38l2.51,-4.73l0.85,-2.52l1.13,-7.0l1.66,-4.05l0.15,-2.44l2.05,-6.6l1.1,-5.59l1.51,-4.27l0.09,-2.31l-1.52,-6.89l-0.84,-1.4l-1.99,-1.72l-0.33,-1.19l0.94,-4.57l1.04,-2.41l4.74,-6.28l1.98,-1.77l4.05,-0.67l1.26,-1.76l1.43,1.04l1.36,2.14l1.48,0.8l-1.93,4.68l-0.06,1.14l0.32,0.8l1.24,0.35l0.63,1.13l1.64,0.6l0.4,1.92l1.87,1.59l0.52,2.15l0.98,1.36l-0.82,2.23l-1.4,1.88l0.27,1.3l1.02,1.25l-0.0,0.44l-1.91,2.56l-1.64,0.67l-2.31,2.48l-1.04,3.25l0.23,4.49l1.0,1.03l0.57,1.28l2.08,0.74l0.56,0.64l0.27,1.73l0.64,1.47l-0.22,1.09l-2.51,4.32l-1.42,1.15l-0.06,1.87l0.35,1.95l-1.89,3.06l-0.67,2.42l0.34,2.33l4.5,6.78l-0.03,1.67l-0.86,4.28l-1.63,2.18l-0.33,1.82l-0.85,1.51l-1.26,1.1l-2.61,0.59l-1.63,1.2l-3.7,5.07l-2.99,-0.38l-2.18,1.07l-1.84,2.54l-2.29,1.98l-1.33,4.37l-2.24,2.65l-2.32,1.02l-3.65,3.49l-1.11,2.65l0.19,1.83l2.86,8.48l-0.32,1.45l0.27,0.66l3.63,1.53l3.47,2.12l2.29,2.56l0.23,2.16l1.67,1.29l0.02,1.27l0.76,0.91l-0.01,0.46l-2.49,1.76l-5.25,5.98l-2.07,0.63l-0.52,0.45l-0.26,1.37l1.01,1.32l-0.6,1.46l-1.59,-0.43l-0.86,0.41l-0.24,0.98l0.22,3.54l0.54,0.58l1.61,0.05l-0.22,1.48l-0.46,0.78l-6.19,0.99l-0.75,-0.46l-0.88,-1.36l-1.15,-0.07l-5.05,1.78l-1.94,2.11l-1.22,2.19l-3.43,-0.94l-3.29,-3.31l-1.65,-1.16l-0.99,-0.01l-3.08,1.16ZM114.74,1185.87l0.49,1.71l-0.11,1.31l-1.6,2.37l-1.01,-1.68l0.43,-1.33l1.8,-2.38Z",
      "ระนอง",
      0,
      Colors.black,
      6),
  "TH-86": MapData(
      "M194.11,1182.33l-4.0,0.39l-0.9,0.36l-1.36,1.25l-3.47,1.72l-2.05,2.54l-0.94,0.38l-1.22,0.14l-1.92,-0.55l-3.72,1.2l-2.8,0.21l-2.5,-0.9l-1.21,-0.01l-3.47,1.31l-7.08,3.82l-0.9,-0.43l-0.79,0.03l-1.01,1.28l-0.65,3.75l-0.54,1.26l-1.99,2.79l-2.18,-2.42l-3.59,-2.19l-3.44,-1.46l0.27,-1.7l-3.02,-9.4l0.71,-2.53l3.7,-3.62l2.51,-1.19l2.31,-2.75l1.34,-4.39l2.16,-1.81l1.84,-2.54l1.64,-0.81l2.6,0.5l0.79,-0.27l3.79,-5.14l1.4,-1.05l2.65,-0.6l1.53,-1.32l0.71,-1.0l0.57,-2.48l1.64,-2.2l0.92,-4.49l-0.03,-2.15l-4.52,-6.79l-0.25,-1.92l0.6,-2.13l1.94,-3.19l-0.31,-3.76l1.35,-1.01l2.54,-4.37l0.29,-1.48l-1.07,-3.64l-0.79,-0.85l-1.93,-0.63l-0.48,-1.18l-0.91,-0.88l-0.16,-4.1l1.01,-3.0l2.02,-2.15l1.74,-0.76l2.01,-2.68l0.09,-1.13l-1.06,-1.34l-0.21,-0.83l1.32,-1.66l0.91,-2.61l-0.21,-0.81l-0.81,-0.78l-0.61,-2.33l-1.85,-1.56l-0.42,-1.95l-1.87,-0.82l-0.68,-1.18l-0.96,-0.09l-0.17,-1.24l1.93,-4.36l0.04,-0.66l-0.45,-0.69l-1.47,-0.78l-1.2,-1.97l-1.65,-1.2l1.15,-1.76l1.25,-0.56l1.88,0.67l1.17,0.04l4.69,-1.94l1.32,-1.85l0.44,-2.32l-0.03,-1.83l-1.07,-3.44l0.31,-2.2l0.98,-1.95l1.08,-1.01l4.33,1.43l1.4,-0.14l0.99,-1.45l1.38,-4.17l1.68,-1.71l4.75,-2.57l0.54,2.4l0.89,1.12l7.86,3.95l4.4,1.16l1.38,-0.08l0.88,-0.56l2.6,-0.13l1.17,0.12l1.97,0.81l2.02,-0.27l5.83,0.34l1.49,-1.25l2.47,-0.97l1.53,-1.43l3.84,-0.74l-0.77,2.65l0.2,2.68l1.69,4.66l0.39,2.17l-0.31,1.26l-0.42,-0.03l-1.14,-1.25l-2.04,-0.08l-2.67,0.4l-1.21,0.8l-0.4,1.16l0.0,4.45l-0.47,1.89l-6.51,9.87l-0.42,1.21l0.47,1.91l-3.21,0.65l-1.97,1.45l-2.76,3.68l-0.69,2.26l-0.84,5.19l-0.99,1.67l-2.44,0.63l-1.3,0.77l-0.46,1.45l0.25,1.05l0.98,0.76l1.5,0.22l-2.31,3.29l-0.4,2.08l0.83,1.59l3.32,2.2l1.08,1.14l0.04,3.17l-0.43,1.66l-0.55,0.58l-2.26,0.14l-2.09,1.16l-0.32,-1.05l-0.89,-1.05l-2.92,-1.46l-1.59,0.76l-2.59,0.36l-1.3,1.55l0.75,6.06l1.2,1.81l4.09,3.71l1.97,2.38l1.45,0.47l1.21,-0.28l-0.73,1.14l-4.49,0.6l-1.0,1.69l-0.61,2.55l-2.92,4.86l-0.9,2.72l0.23,3.34l2.21,3.6l0.48,1.76l-0.27,1.05l-1.57,1.26l-0.35,1.56l0.74,4.8l0.0,8.6l0.76,1.21l-0.02,0.56l-2.21,2.3l-0.72,3.91Z",
      "ชุมพร",
      0,
      Colors.black,
      6),
  "TH-80": MapData(
      "M279.52,1268.95l-1.12,1.49l-0.33,0.98l0.0,2.71l1.26,8.3l-0.49,1.89l1.38,3.32l2.16,21.23l0.87,3.55l2.03,3.11l6.06,3.65l0.88,1.46l0.46,1.92l2.41,4.72l1.75,2.61l0.67,2.13l0.68,1.06l3.73,1.88l0.84,1.44l1.63,0.34l1.73,-0.4l1.51,-0.91l0.17,-0.46l-0.98,-3.12l-0.22,-4.34l-1.13,-3.9l-2.99,-1.34l1.02,-0.44l3.05,2.21l2.93,3.38l1.28,2.23l5.51,14.3l3.4,21.63l4.21,19.24l-6.5,1.33l-3.62,1.88l-5.17,1.62l-4.69,2.14l-1.13,1.81l-1.76,5.98l-8.69,-2.28l-1.34,-1.65l-1.46,-0.96l-0.5,-2.28l-1.29,-1.74l-0.97,-0.65l-3.99,-1.46l-15.62,2.09l-0.75,0.32l-1.49,1.75l-4.72,0.9l-0.61,0.49l-0.56,-0.85l-0.45,-4.09l0.84,-4.72l0.95,-3.09l-0.14,-0.69l-1.03,-1.08l-1.37,-0.64l-2.55,0.51l-3.91,-0.11l-2.91,0.59l-2.65,-0.21l-1.15,0.43l-1.71,2.95l-2.45,1.84l-0.88,1.89l-1.8,1.66l-0.66,1.41l-0.23,1.55l-0.39,0.18l-2.97,0.44l-4.34,-1.92l-6.8,-0.07l-1.59,-1.59l-1.64,-2.51l-3.49,-1.63l-1.17,-1.35l1.29,-1.52l0.75,-1.85l-0.04,-1.06l-1.43,-3.66l-2.25,-1.88l-2.49,-5.26l-0.04,-0.34l0.97,-0.98l0.22,-1.84l-0.57,-3.23l0.81,-1.21l0.33,-1.39l1.54,-2.3l0.05,-8.83l-0.29,-1.4l-4.12,-3.35l-3.44,-4.78l-0.51,-1.26l0.18,-1.62l1.47,-3.87l2.15,-2.69l1.06,-1.98l0.21,-1.31l-0.59,-5.59l0.74,0.08l2.99,2.08l1.41,-0.01l4.11,-2.88l4.23,-1.75l2.28,-2.7l2.0,-1.46l0.5,-1.24l-0.33,-1.86l0.36,-1.19l1.5,-0.81l2.58,-2.32l0.47,-1.03l0.2,-2.31l2.26,-2.27l0.74,-1.22l0.63,-2.6l-0.42,-4.16l0.35,-2.15l-0.12,-2.51l0.35,-1.27l1.97,-0.18l1.15,-1.09l3.35,-6.28l1.49,-0.32l0.91,1.25l1.06,0.34l0.89,-0.26l1.35,-1.01l1.88,0.0l3.62,-1.7l0.61,-1.1l-0.7,-2.35l2.59,-0.52l1.05,-0.53l0.69,-0.95l0.1,-1.33l1.23,-3.13l0.46,-3.56l1.97,0.9l1.51,-0.59l0.52,-0.56l0.26,-4.63l-0.38,-1.78l-0.99,-0.9l-2.65,-0.5l-0.64,-1.64l-1.37,-1.25l2.54,-8.08l-0.48,-3.95l0.07,-2.14l1.96,-2.8l1.19,0.25l2.08,-1.34l1.18,1.1l3.92,1.71l-0.05,2.14l0.71,1.78l1.99,3.47l0.84,-0.09l0.06,7.49l0.59,2.25l2.65,3.91l0.32,1.58l0.01,5.3l1.43,3.82Z",
      "นครศรีธรรมราช",
      0,
      Colors.black,
      6),
  "TH-81": MapData(
      "M140.98,1338.59l0.72,-0.18l1.23,-1.57l-0.52,-2.8l1.73,-4.83l-1.1,-1.63l-0.21,-0.98l-0.44,-6.02l0.19,-2.62l2.82,-0.74l1.21,-0.86l1.04,-1.73l0.43,-4.06l0.94,-0.08l1.16,-0.61l1.51,-3.71l0.54,-0.69l0.82,-0.3l1.03,0.33l2.72,2.77l5.77,0.59l1.91,2.33l3.02,1.52l2.07,2.16l1.03,2.06l-3.15,2.74l-1.58,2.59l0.81,2.22l1.76,2.57l-0.52,2.58l-1.19,1.84l-0.21,1.84l0.86,2.53l-0.05,3.56l0.3,1.77l1.24,3.17l0.86,0.26l1.83,-0.97l1.02,-0.13l6.5,0.89l3.67,-1.18l1.51,-1.81l1.27,-0.99l0.78,-0.04l5.98,0.93l1.64,1.07l4.52,1.26l3.39,-0.11l5.65,-1.93l1.52,2.11l3.48,2.65l0.54,3.11l-0.2,6.85l-1.46,2.05l-0.33,1.39l-0.86,1.34l0.53,3.47l-0.11,1.16l-1.1,1.51l0.44,1.76l1.77,3.7l0.57,0.86l2.13,1.72l1.35,3.49l-0.67,2.34l-1.15,1.17l-0.22,0.76l1.4,1.8l0.77,2.35l-0.32,1.27l-1.14,1.96l-3.85,3.87l-0.25,0.62l0.35,1.54l1.67,2.44l0.51,2.9l2.5,4.17l-0.5,1.42l-2.54,4.11l-5.48,4.06l-1.45,-1.66l-1.55,-0.73l-1.65,-0.23l-0.75,-0.55l-1.53,-2.13l-4.28,-2.79l-1.57,-1.39l-0.73,-2.39l-0.38,-0.28l-0.68,0.0l-0.4,0.37l-0.25,3.67l-1.0,2.83l-1.99,1.33l-3.56,-0.71l-2.29,-2.41l-0.59,-7.07l-1.33,-2.7l4.25,-3.33l0.79,-1.44l0.91,-5.4l-0.07,-1.95l-0.68,-0.26l-2.03,2.06l-0.86,0.33l-1.12,-0.17l-2.94,-4.14l-3.48,-1.49l-0.71,-1.97l0.36,-2.31l-0.4,-1.11l-0.94,-1.15l-2.48,-1.6l-0.72,-1.74l-0.62,-0.55l-1.87,0.35l-0.79,0.77l-1.02,2.16l-4.64,1.92l-1.26,-0.35l-1.72,-4.03l-1.49,-0.95l-1.05,0.45l-0.74,1.57l-1.33,1.08l-0.49,-2.29l-1.95,-2.33l-0.23,-1.98l0.25,-5.31l-0.37,-1.5l0.37,-5.35l-0.36,-1.8l-1.88,-4.33l-0.72,-0.02l-1.49,2.83l-0.42,-7.75l-0.74,-1.09l-0.44,-0.16l-2.17,0.63l-3.0,1.9l-1.82,-0.31l-0.4,0.75l0.29,-6.56l0.49,-0.76l1.86,-1.46ZM191.26,1422.18l-1.48,-0.09l-0.62,-0.42l-0.65,-1.22l-1.9,-1.11l-2.44,-4.01l1.94,-1.03l3.85,0.6l1.94,1.18l0.29,3.22l-0.35,1.89l-0.59,0.98ZM190.96,1435.15l-1.37,0.94l-2.19,-1.26l-2.09,-2.49l-3.09,-7.22l0.1,-3.75l-0.21,-1.82l-0.61,-1.38l0.52,-0.51l0.38,0.0l4.2,3.68l0.02,3.78l1.1,4.0l1.68,3.66l1.55,2.38Z",
      "กระบี่",
      0,
      Colors.black,
      6),
  "TH-82": MapData(
      "M105.72,1247.38l1.33,0.41l1.14,-0.34l2.65,-2.7l-0.11,-0.62l-1.79,-0.92l-0.04,-1.35l0.95,-1.75l0.34,-1.5l1.3,-1.82l1.44,-4.92l3.94,-1.27l1.42,1.0l3.35,3.37l3.97,1.14l1.68,0.9l0.41,1.18l0.19,4.3l-0.31,0.91l-2.29,2.92l-0.73,2.88l0.3,2.87l-0.3,0.54l-1.17,0.72l-0.38,2.07l0.79,5.37l-1.28,0.89l-0.3,0.64l0.09,0.96l2.34,6.27l0.25,1.63l-1.27,0.22l-3.15,1.78l-0.87,0.85l-0.44,1.41l0.87,3.6l-0.59,1.37l-0.02,0.9l0.54,0.66l4.56,1.05l3.98,3.13l2.54,4.09l1.14,1.15l2.73,0.31l0.68,0.58l0.17,1.35l-0.46,3.13l0.02,3.91l-1.98,1.81l-1.19,2.26l-2.57,0.86l-0.4,0.94l0.46,1.05l4.03,2.98l4.57,-0.37l1.84,-0.54l1.97,-1.08l5.24,1.9l-0.4,3.96l-0.9,1.47l-0.86,0.6l-2.74,0.68l-0.56,0.51l-0.22,2.95l0.44,6.07l0.32,1.31l0.98,1.22l-1.7,4.65l0.51,2.8l-0.4,0.46l-0.15,-0.48l-1.45,-0.69l-2.39,-0.49l-1.82,-0.75l-0.54,0.29l-0.46,2.23l-1.24,0.54l-1.99,0.16l-1.69,0.86l-2.83,2.59l-1.36,0.46l-0.9,-1.11l-1.05,-0.15l-0.4,0.34l-0.17,1.19l-0.36,0.44l-0.34,-0.04l-0.62,-0.94l-1.07,-0.18l-0.4,0.4l0.0,0.97l-2.01,-0.17l-1.89,0.89l-0.83,1.33l0.2,0.57l3.16,1.27l0.34,1.55l-0.03,2.05l0.66,1.72l0.03,2.81l-1.77,4.35l-1.95,2.48l-1.13,-1.37l-0.97,-0.15l-0.4,0.37l-0.32,1.51l-0.86,1.0l-1.38,-1.24l-2.16,-3.85l-2.63,-1.04l-0.98,-1.66l-3.27,-0.67l-1.09,-0.92l-0.38,-1.47l-0.03,-4.78l-1.64,-3.19l-2.19,-10.16l-4.61,-13.96l-0.15,-2.25l0.73,-2.06l0.39,2.36l0.86,1.56l2.67,2.9l0.68,-0.16l0.57,-2.54l-0.95,-1.33l-1.59,-1.13l-0.99,-1.23l-0.04,-0.47l0.76,-1.41l0.02,-2.35l1.49,-4.6l-0.24,-2.51l-1.97,-5.62l0.36,-0.79l1.63,-1.12l1.31,-1.71l0.64,-7.56l0.52,-2.31l2.35,-3.69l1.03,-4.36l2.06,-2.88l1.35,-2.56l0.57,-0.34l1.92,0.6l1.46,-0.0l0.37,-0.53l-0.6,-2.19l3.47,-4.11l0.03,-0.5l-0.48,-0.14l-5.05,1.8l-0.77,-0.63l-0.27,-2.47l1.06,-0.95l2.61,-0.15l1.74,-0.88l0.2,-0.49l-1.28,-3.57l-3.16,-4.16l-1.38,-2.39l-0.6,-3.75ZM137.33,1367.18l-0.05,0.9l-3.83,-1.51l-0.8,-1.08l0.24,-0.31l2.24,-0.55l0.29,-0.49l-0.43,-1.63l2.48,-3.09l0.74,-1.42l0.69,0.4l0.16,1.34l-1.73,7.45ZM128.02,1365.94l0.56,1.22l5.15,2.96l1.57,1.61l0.82,2.99l0.16,11.73l-0.77,2.08l-1.18,-0.09l-1.04,-1.4l-1.53,-6.25l0.39,-1.24l1.5,-0.59l0.29,-1.29l-0.39,-2.02l-0.82,-1.06l-2.01,-0.54l-0.27,-0.4l-2.17,-4.97l-0.28,-2.76ZM102.12,1264.33l-2.1,0.59l-1.96,-0.08l-1.26,-1.12l0.85,-10.75l1.08,-0.61l1.19,-0.18l0.81,0.3l2.67,2.49l0.98,1.65l0.55,1.99l0.02,2.16l-2.16,2.19l0.03,0.59l0.33,0.28l-1.04,0.52ZM101.86,1276.2l-2.44,6.03l-0.44,-0.07l-0.81,-1.85l-0.22,-2.12l0.51,-2.35l-0.37,-6.18l0.74,-1.37l1.65,0.32l1.99,1.21l1.15,1.89l-0.38,2.0l-1.38,2.49ZM58.92,1220.45l-0.24,0.44l-1.73,-0.38l-0.79,0.15l-0.33,0.4l0.0,0.83l-1.37,-1.14l0.32,-1.7l1.72,-1.09l2.22,0.55l0.31,0.47l-0.12,1.49ZM56.5,1226.52l-0.23,0.58l-2.97,-2.33l-0.38,-0.63l0.18,-0.53l0.52,-0.5l1.13,-0.34l1.01,0.76l0.61,1.45l0.14,1.54Z",
      "พังงา",
      0,
      Colors.black,
      6),
  "TH-83": MapData(
      "M101.35,1358.04l0.81,0.55l1.04,-0.24l0.73,0.22l1.85,1.51l0.56,1.41l0.84,5.11l0.39,0.34l0.93,-0.11l0.92,-0.85l1.17,0.69l3.45,3.09l0.59,-0.1l0.74,-1.19l0.81,-0.42l0.72,0.26l0.64,1.23l-0.06,1.65l-2.15,4.24l0.02,3.58l-1.77,1.34l-0.48,1.07l-0.07,1.92l0.45,2.2l0.87,2.12l1.05,1.52l0.66,0.0l1.0,-1.01l0.55,1.08l0.02,1.45l-0.72,1.06l-3.61,1.35l-0.48,1.68l0.25,3.17l-3.42,-1.63l-1.99,-0.05l-0.39,0.26l-0.87,2.44l-0.38,2.68l-0.89,1.43l-1.2,0.28l-1.61,-0.92l-0.5,-1.36l-0.56,-6.95l-1.35,-2.61l-0.11,-0.91l1.23,-0.68l0.57,-0.75l-0.36,-1.84l-0.89,-0.67l-1.93,-0.6l1.94,-2.32l-0.75,-2.47l1.64,-3.22l-0.57,-3.37l-0.18,-3.81l1.48,-4.26l0.23,-2.41l-0.85,-6.19Z",
      "ภูเก็ต",
      0,
      Colors.black,
      6),
  "TH-32": MapData(
      "M627.37,562.38l-0.59,-0.31l-1.26,0.63l-1.5,-1.32l-0.2,-0.74l0.98,-1.5l0.59,-2.97l12.06,3.47l1.24,0.74l2.69,0.88l2.49,1.63l5.95,2.11l1.95,-0.35l6.19,-2.57l3.62,-1.96l1.59,-0.07l5.09,1.22l1.29,0.03l1.77,-0.62l2.35,-1.95l1.27,-0.53l2.34,-0.17l4.64,1.73l15.82,1.18l3.59,-1.09l3.02,-1.62l3.08,-0.04l1.4,-0.82l0.42,0.09l0.21,1.46l0.41,0.69l1.08,0.73l0.92,0.37l2.22,-0.05l-0.44,1.05l0.18,0.51l1.03,0.54l2.02,-0.17l1.18,-0.43l0.22,1.16l1.12,0.76l6.87,0.29l0.99,0.5l0.72,2.7l0.89,1.38l-0.28,1.61l-0.53,0.59l-2.55,0.97l-1.22,0.97l-0.75,1.68l-1.06,0.77l-0.72,1.75l-1.02,0.61l-0.68,1.21l-1.36,0.28l-0.52,0.68l0.04,0.65l1.02,1.59l0.17,0.85l-1.29,3.46l-0.53,4.41l0.54,1.15l1.47,1.13l0.28,0.73l1.43,7.26l1.05,1.26l0.15,2.3l-0.25,1.32l-1.6,1.91l-0.52,2.34l-1.76,1.36l-0.82,2.22l-1.93,2.03l-1.24,1.98l-2.81,6.85l0.17,1.28l1.37,1.9l3.81,1.98l3.09,0.6l0.63,0.51l0.78,1.8l-0.1,5.5l0.22,0.86l0.84,1.52l4.57,5.79l0.39,0.91l0.0,3.1l-1.08,6.59l-0.62,1.4l-0.07,1.03l0.46,4.28l1.3,5.71l-1.75,10.44l-4.34,1.19l-3.09,-2.43l-5.87,0.3l-1.26,1.02l-0.77,1.45l-1.69,0.2l-1.48,-0.29l-3.4,-2.19l-1.64,-0.55l-3.35,0.33l-1.99,-0.23l-6.34,-1.6l-3.73,-0.26l-0.56,-0.21l-0.26,-0.75l0.23,-2.54l-0.36,-1.44l-1.63,-1.35l-1.33,-0.38l-1.27,0.13l-1.04,0.61l-1.22,2.6l-2.03,1.02l-1.37,-0.3l-1.49,-0.95l-1.94,-0.65l-2.02,0.29l-4.29,2.15l-4.77,3.09l-0.94,-0.12l-2.06,-1.32l-1.69,0.51l-2.99,2.16l-1.79,0.8l-2.25,0.27l-7.32,-0.02l-2.97,0.89l-0.22,-2.54l0.61,-2.11l-0.33,-2.24l1.21,-2.85l0.31,-1.74l-0.94,-3.13l-1.2,-2.52l-0.72,-3.63l0.22,-6.93l1.67,-1.89l0.67,-2.96l2.12,-4.13l1.61,-6.62l-0.31,-2.52l0.17,-0.89l1.05,-0.98l1.64,-2.75l1.3,-0.77l1.78,-1.74l1.96,-1.15l3.9,-3.31l2.55,-4.76l1.66,-1.21l0.99,-1.48l-0.32,-7.71l0.46,-0.92l1.99,-1.44l0.38,-1.15l-0.3,-1.25l-1.18,-1.83l0.79,-2.45l-1.09,-2.87l-0.52,-8.51l1.83,-5.59l1.98,-1.34l2.15,-5.64l-0.4,-1.61l-1.78,-0.55l-1.42,-1.95l-1.59,-0.76l-2.15,-0.71l-0.52,0.38l0.0,0.69l0.39,0.39l-0.76,1.13l-1.48,0.04l-0.55,-0.51l0.9,-0.75l-0.15,-0.69l-0.53,-0.11l-0.39,-0.59l-0.87,0.05l-0.87,0.48l-2.73,-1.28l-1.52,0.4l-2.28,1.48l-1.85,0.73l-1.33,1.62l-0.77,0.27l-1.41,-0.89l-1.21,-0.2l-1.27,0.88l-0.52,-1.0l-1.9,-1.01l-0.39,-1.25l-0.38,-0.28l-1.64,0.16l-0.81,-1.4l-1.37,-1.46l-2.56,0.35l-1.83,-4.08l-0.28,-1.64l-0.39,-0.33l-0.74,0.0l-0.38,0.38Z",
      "สุรินทร์",
      0,
      Colors.black,
      3),
  "TH-40": MapData(
      "M624.7,396.97l1.66,1.8l0.31,0.82l-1.11,3.39l-0.04,1.98l0.52,1.39l1.16,0.17l1.47,-0.9l1.02,-1.23l0.3,-1.92l0.46,-0.07l1.4,0.46l0.34,0.47l1.03,3.29l-0.57,3.88l-0.68,1.28l-1.06,1.09l-0.45,1.15l-0.08,8.88l-0.6,3.56l0.05,2.93l-1.18,1.56l-2.08,1.64l-1.27,3.2l-1.68,2.93l-1.47,2.04l-1.04,0.88l-1.57,0.78l-2.52,0.35l-1.65,2.12l-1.06,0.86l-8.35,2.44l-0.11,0.69l1.41,2.4l0.14,0.69l-0.3,1.17l-1.27,2.36l-2.21,2.63l-2.36,4.82l-4.29,3.42l-0.94,1.74l-0.04,6.21l1.5,5.24l-0.1,1.77l0.43,3.81l-0.11,1.37l-0.82,1.88l0.07,1.7l0.5,1.84l0.86,1.3l2.45,1.53l1.78,3.94l0.11,2.59l-0.52,2.08l-0.08,2.64l3.29,7.29l-0.08,4.77l0.94,3.24l-3.68,1.29l-0.79,0.5l-0.82,1.18l-0.55,1.58l-0.17,6.49l-1.19,4.2l-1.02,1.69l-0.99,0.52l-3.35,1.04l-1.63,-0.14l-5.27,-4.21l-3.93,-0.94l-2.07,-2.88l-0.42,-2.06l-1.06,-0.65l-3.04,1.13l-4.02,-0.84l-1.84,-0.08l-1.73,1.38l-9.46,-1.28l-4.76,0.81l-2.53,1.24l-1.31,0.34l-0.63,-0.17l-2.17,-2.26l-3.13,-1.87l-0.11,-3.06l-2.32,-2.03l-1.69,-2.57l0.52,-1.21l-0.57,-3.64l0.31,-1.4l1.47,-1.76l0.39,-1.21l1.4,-1.93l0.73,-1.6l-0.19,-0.89l1.3,-5.08l0.93,-0.67l0.18,-0.56l-0.64,-1.15l-1.99,-0.76l-2.55,-2.24l-5.32,-2.1l-1.79,-1.13l-1.28,-2.08l2.69,-2.09l4.08,-4.27l2.28,-4.39l2.64,-3.04l3.12,-4.66l1.77,-6.05l1.44,-3.24l2.02,-6.92l0.17,-2.76l-3.74,-2.51l-0.86,-2.84l-0.78,-0.75l-1.51,0.11l-0.46,0.63l0.07,1.08l-1.82,0.47l-2.39,-1.55l-3.03,0.56l-2.21,-0.46l-1.41,-1.08l-3.08,-1.08l-2.0,-2.11l-4.13,-1.79l-1.04,-0.08l-1.79,0.63l-1.75,-0.33l-9.09,-0.08l-2.31,-1.49l-3.78,-4.84l-2.85,-1.08l-0.75,-0.62l-0.64,-0.95l-1.47,-4.07l-1.36,-1.34l-1.87,-0.3l-3.07,0.08l-6.3,-2.55l-1.98,-0.31l-1.4,0.17l-3.37,1.79l-0.57,-0.07l-3.27,-2.72l0.42,-0.92l1.91,-2.13l1.38,-2.77l0.41,-4.51l8.48,-3.24l9.23,-5.72l0.97,-0.07l2.04,0.56l0.75,-0.15l2.88,-1.82l3.18,-0.63l2.68,-2.07l7.25,0.96l2.3,1.25l3.74,0.94l1.36,-0.35l3.27,-2.12l1.08,-1.13l1.68,-0.18l1.22,0.18l1.96,1.06l1.25,1.35l0.45,1.06l1.07,0.52l0.26,1.2l1.52,2.47l1.6,0.29l4.48,1.63l2.03,1.19l2.42,0.42l4.34,-1.04l3.7,0.48l2.97,1.0l0.87,0.61l1.23,1.72l0.69,0.31l5.68,-0.9l0.72,-0.94l1.49,-6.2l5.97,-14.11l0.94,-5.34l0.07,-3.27l2.33,-4.13l0.46,2.25l0.64,1.13l6.31,3.33l1.39,1.01l1.11,1.56l2.2,1.53l0.07,0.33l-1.03,0.83l-0.15,0.54l0.85,2.16l-0.17,2.78l0.51,4.34l0.67,0.52l4.25,-0.53l1.45,0.11l2.23,1.14l2.31,2.48l1.27,0.45l1.47,0.05l17.0,-7.92Z",
      "ขอนแก่น",
      0,
      Colors.black,
      3),
  "TH-41": MapData(
      "M519.74,275.11l0.83,0.99l0.79,0.09l1.03,-0.56l1.5,-1.74l2.2,-0.6l1.07,1.13l3.12,0.91l2.09,1.7l3.42,1.35l3.53,2.58l1.29,2.32l3.06,1.72l1.04,1.37l1.79,1.26l0.98,1.89l0.51,3.12l1.84,2.36l1.98,0.99l-0.42,2.61l2.64,3.66l1.35,0.64l7.02,0.41l3.47,3.56l1.73,0.97l2.22,2.04l-0.37,1.97l0.55,3.31l-0.44,2.38l0.78,0.53l3.99,0.77l0.82,1.38l1.01,0.37l5.66,-0.83l2.2,0.34l1.81,-0.77l2.75,-2.11l0.95,-3.58l1.09,-1.27l5.33,-3.03l0.68,-1.86l1.29,-1.44l-0.25,-1.79l0.52,-1.16l0.17,-2.25l-1.74,-4.19l1.53,-2.77l1.4,-1.13l0.91,-1.78l-0.36,-2.06l0.22,-0.7l1.79,-0.12l4.75,1.02l2.19,3.25l0.95,2.53l0.76,0.38l1.98,-0.84l1.36,-1.31l1.81,-2.88l2.24,-0.83l0.69,-1.21l1.62,1.28l0.81,1.13l1.79,0.65l0.79,0.96l0.88,0.45l0.64,1.07l2.66,1.18l1.08,1.46l1.08,1.02l0.61,0.19l0.81,-0.17l1.09,-0.99l1.1,-3.54l0.96,-1.22l6.22,-2.68l1.15,0.79l2.22,3.43l1.62,0.96l1.34,-0.25l2.24,-1.64l1.39,-0.61l4.4,-1.18l-0.3,1.72l1.21,0.88l-0.95,0.28l-1.14,-0.63l-0.67,0.45l-0.66,2.51l-0.17,2.38l-0.62,0.86l0.34,1.49l1.07,1.72l0.77,0.71l1.09,0.38l0.32,1.06l0.21,2.85l-0.84,3.25l0.28,2.26l-0.28,2.14l0.23,4.96l-1.27,0.24l-1.46,1.18l-2.3,-0.2l-1.35,0.78l-1.0,1.41l-0.49,1.8l-1.05,1.19l-0.85,2.72l-1.73,1.72l-1.03,2.36l-0.2,2.18l-1.01,3.12l0.75,2.34l1.58,2.51l0.06,0.55l-1.7,1.79l-1.58,4.27l-1.62,1.74l0.02,1.06l0.62,1.55l2.4,3.45l7.13,1.59l6.96,3.74l1.96,-0.16l2.29,0.39l1.4,-0.54l1.06,-0.93l1.06,1.22l5.74,3.07l3.62,3.08l0.7,0.18l1.53,-0.5l0.91,0.39l2.42,2.41l1.64,2.63l1.25,0.77l1.18,0.23l0.42,1.53l0.12,4.55l-1.03,-0.91l-2.68,-3.75l-3.74,-1.37l-2.17,0.62l-3.91,2.41l-2.76,3.51l0.42,2.15l-0.14,3.28l-2.65,4.11l-0.44,2.68l0.14,3.45l-3.38,4.54l-1.33,3.58l-1.01,-2.76l0.17,-2.7l-1.14,-1.5l-1.6,-1.29l-5.42,-2.5l-5.52,-1.22l-2.22,-1.53l-2.08,-0.87l-2.56,-0.56l-2.37,0.78l-4.18,0.3l-3.86,-0.61l-1.03,1.09l-2.37,4.03l-16.91,7.91l-2.26,-0.4l-2.2,-2.41l-2.52,-1.29l-1.7,-0.14l-3.93,0.57l-0.65,-4.13l0.16,-2.89l-0.84,-2.0l1.13,-1.1l-0.12,-1.03l-2.38,-1.75l-1.06,-1.51l-1.53,-1.11l-6.17,-3.22l-0.44,-0.78l-0.22,-1.98l-0.89,-0.86l-1.01,0.58l-2.1,3.76l-0.2,3.76l-0.7,4.47l-0.71,1.73l-12.57,-12.1l-1.13,-1.54l-3.46,-6.96l-0.2,-1.35l1.14,-1.33l3.3,-0.58l2.87,-1.94l0.48,-0.68l0.4,-1.93l1.54,-0.97l0.21,-0.87l-1.41,-0.76l-2.84,0.34l-2.53,0.75l-2.55,1.21l-0.6,-0.05l-2.11,-2.87l-1.79,-0.88l-0.03,-1.32l0.57,-2.13l0.8,-1.41l-0.19,-1.66l-0.97,-1.3l-3.06,-0.4l-0.9,-0.47l-0.65,-0.9l-0.29,-2.85l0.71,-1.52l0.06,-2.31l-1.09,-4.41l-3.98,-7.91l-0.76,-4.86l-1.06,-2.54l0.17,-4.98l-0.29,-1.37l-1.02,-0.59l-2.92,1.34l-1.32,-0.35l-1.52,-0.89l-5.99,-1.1l-2.51,-1.02l-1.34,0.05l-1.2,0.79l-1.63,1.74l-1.49,0.84l-0.93,-0.01l-1.79,-0.93l-1.54,0.46l-2.64,3.14l-1.33,-2.37l-1.59,-1.55l-0.7,-1.65l-1.1,-4.45l-0.78,-1.61l-0.6,-0.05l-0.32,0.37l-1.17,3.18l-0.56,0.06l-0.5,-0.67l-1.41,-8.0l0.88,-3.69l1.34,-1.39l-0.11,-2.18l0.75,-2.44l0.09,-1.34l-0.35,-3.16l-1.19,-2.82l-1.52,-9.76l1.24,-0.8l0.34,-0.81l0.41,-2.73l1.42,-3.9l0.29,-3.25l2.86,2.78l2.57,-0.05l1.26,2.41l1.95,1.11l-0.33,1.32l0.68,1.56Z",
      "อุดรธานี",
      0,
      Colors.black,
      3),
  "TH-42": MapData(
      "M398.73,386.93l1.48,-1.95l0.55,-6.16l1.52,-4.22l1.02,-6.1l0.38,-1.08l1.82,-2.65l0.61,-1.96l0.02,-1.39l-2.76,-4.74l-0.86,-0.44l-2.57,-0.36l-1.48,-2.39l-2.1,-1.11l-1.8,-2.48l-1.47,-0.3l-2.25,0.26l-2.38,-0.57l-1.57,0.35l-1.1,-0.7l-0.42,-2.07l0.78,-4.05l-0.79,-4.66l-0.37,-0.95l-1.43,-1.68l-0.21,-0.81l2.04,-2.62l0.17,-2.53l0.39,-0.91l2.12,-1.46l1.09,-2.02l4.37,0.81l3.95,2.28l3.44,3.53l1.76,0.38l3.18,1.86l3.54,1.56l0.66,0.01l1.17,-0.66l2.55,-3.31l0.31,-1.64l3.8,-1.41l2.89,-5.09l1.95,-2.58l11.86,-9.64l2.99,-0.77l1.97,-2.5l0.3,-1.12l-0.28,-0.44l-1.92,-0.36l0.32,-0.46l1.29,-0.43l3.26,0.01l2.26,-1.89l1.28,3.14l0.66,0.1l1.63,-2.88l2.04,-2.09l3.59,-1.51l2.21,-1.49l0.03,-0.64l-1.86,-1.51l2.59,-0.96l0.89,-1.1l0.56,-1.38l0.28,-2.52l1.87,1.16l0.5,-0.07l1.24,-1.36l0.9,-2.03l1.61,-1.03l9.99,-1.93l3.32,-9.84l0.97,-4.77l0.84,-1.93l1.61,-1.52l0.33,0.0l1.11,1.24l4.19,1.14l4.14,2.36l2.54,-0.67l18.25,-19.28l0.64,-0.49l2.71,0.14l-0.21,3.59l-1.14,1.29l-1.79,1.19l-0.79,1.6l-1.48,5.73l-0.49,4.66l-1.28,3.26l-0.41,2.73l-0.16,0.48l-1.14,0.6l-0.28,0.6l1.52,10.03l1.2,2.9l0.33,2.98l-0.84,3.7l0.13,2.04l-1.29,1.27l-0.95,4.03l1.5,8.34l0.86,1.02l0.89,0.11l0.51,-0.25l1.32,-3.14l1.41,5.32l0.76,1.78l1.66,1.64l1.59,2.7l2.07,6.3l0.07,1.69l-2.26,3.37l-4.62,2.74l-1.24,0.29l-2.21,-0.35l-4.18,0.11l-1.36,0.26l-1.04,1.03l-0.23,2.03l0.74,2.48l3.43,4.18l-0.23,2.38l0.46,2.32l-0.64,1.08l-2.84,2.79l-1.01,1.4l-0.32,3.53l-2.87,3.41l-0.68,1.7l0.83,3.02l2.79,3.18l1.42,0.78l2.42,0.63l1.93,1.23l1.89,0.32l2.32,1.23l2.22,0.65l1.16,1.66l0.98,3.35l1.49,1.02l1.0,1.59l1.75,1.23l-4.4,1.96l-2.44,2.52l-4.41,1.7l-1.27,1.15l-0.02,1.26l1.92,3.68l1.85,2.74l-2.41,1.88l-3.1,0.59l-2.83,1.8l-1.19,0.03l-1.57,-0.52l-1.09,0.18l-9.23,5.73l-8.63,3.3l-6.18,0.84l-0.58,-0.28l-0.53,-1.02l0.56,-3.42l-0.97,-3.16l0.42,-6.18l-0.6,-3.59l-0.58,-1.51l-2.78,-3.08l-3.13,-6.78l-0.66,-2.32l-0.79,-0.71l-1.04,-0.02l-1.37,0.93l-2.32,3.82l-2.02,0.93l-2.07,0.24l-1.91,-0.73l-2.4,-5.1l-2.51,-0.98l-4.13,-2.44l-0.97,-0.15l-2.37,1.17l-2.96,-0.98l-0.73,-0.01l-1.2,0.67l-3.58,-0.52l-3.42,1.06l-1.72,-1.58l-3.26,-1.11l-4.06,-1.97l-3.14,-1.0l-1.28,0.41l-0.63,0.55l-0.15,3.02l-2.44,4.02l-1.11,0.6l-2.6,0.19l-1.05,0.92l-0.27,2.0l0.74,2.62l-0.93,3.73l0.05,2.66l-0.2,0.41l-1.38,0.63l-0.87,1.37l-3.04,0.25l-0.2,-1.44l-0.69,-0.87l-2.91,-1.49l-0.28,-0.48l1.11,-1.29l0.15,-1.4l-1.56,-2.89Z",
      "เลย",
      0,
      Colors.black,
      3),
  "TH-43": MapData(
      "M516.24,251.63l4.39,0.22l1.8,0.99l1.06,3.38l1.03,1.92l4.59,3.25l2.55,3.37l5.52,4.83l3.23,1.61l3.23,-0.14l1.96,2.44l3.01,2.5l3.72,1.88l4.03,0.75l9.17,0.03l3.24,1.63l1.3,4.2l-1.83,8.31l0.29,0.4l1.5,0.42l5.66,2.72l2.4,0.31l0.45,-0.4l-0.06,-1.03l-1.01,-1.57l-0.57,-1.87l0.49,-1.45l1.31,-0.81l3.78,-0.91l1.76,-1.01l4.01,-3.63l6.23,-3.38l0.77,-1.25l1.48,-0.86l9.25,-4.1l1.64,-0.33l1.8,0.45l3.3,2.11l1.92,0.54l2.31,-0.86l2.19,-3.16l1.14,-0.84l0.53,-1.09l-0.85,-6.74l0.16,-1.94l0.49,-1.37l1.26,-1.14l0.45,0.27l2.28,-0.79l1.88,-1.16l1.4,-1.76l0.78,-2.56l0.62,-3.71l0.66,-1.64l1.1,-1.33l1.68,-0.81l9.61,-2.06l1.39,-0.48l0.77,-0.62l0.2,1.24l-1.01,2.33l1.08,1.87l3.49,0.56l3.05,1.4l1.15,3.06l-0.97,2.35l-3.48,2.16l-1.63,3.36l0.69,4.72l4.09,4.14l4.75,2.84l3.23,2.71l-0.83,0.68l-1.97,-0.55l-1.34,0.06l-1.51,0.94l0.1,1.4l2.16,3.55l-0.77,0.41l-0.35,0.87l0.79,2.34l0.83,1.19l0.09,1.36l-0.72,1.27l-4.96,1.33l-1.54,0.69l-2.1,1.57l-0.96,0.19l-1.11,-0.7l-2.5,-3.76l-0.92,-0.69l-0.75,-0.02l-4.79,1.84l-1.73,0.99l-1.18,1.49l-1.03,3.4l-1.18,0.84l-1.21,-0.97l-1.15,-1.52l-2.66,-1.17l-0.84,-1.26l-0.71,-0.29l-1.08,-1.16l-1.52,-0.46l-0.7,-1.04l-2.06,-1.57l-0.71,0.18l-0.56,1.25l-2.1,0.69l-2.31,3.4l-1.4,1.19l-1.09,0.42l-1.08,-2.54l-2.45,-3.51l-2.06,-0.68l-3.0,-0.44l-2.19,0.17l-0.67,1.04l0.39,2.17l-0.8,1.59l-1.41,1.15l-1.68,3.1l0.71,2.49l1.02,1.83l-0.15,2.08l-0.54,1.29l0.29,1.59l-1.21,1.27l-0.3,1.34l-0.98,0.94l-4.28,2.2l-1.12,1.03l-0.51,0.82l-0.86,3.39l-2.48,1.85l-1.55,0.67l-2.09,-0.35l-5.51,0.84l-0.48,-0.1l-1.12,-1.58l-4.4,-0.97l0.52,-1.97l-0.55,-3.34l0.31,-2.28l-2.48,-2.36l-1.7,-0.95l-3.45,-3.57l-7.45,-0.58l-0.89,-0.41l-2.46,-3.39l0.55,-2.08l-0.16,-0.58l-0.6,-0.58l-1.55,-0.62l-1.68,-2.15l-0.44,-2.93l-1.1,-2.14l-1.92,-1.42l-1.1,-1.42l-3.02,-1.68l-1.26,-2.3l-3.66,-2.67l-3.46,-1.37l-2.12,-1.72l-3.06,-0.88l-1.23,-1.22l-2.85,0.68l-1.62,1.83l-0.91,0.36l-1.1,-1.87l0.27,-1.61l-0.38,-0.49l-1.74,-0.87l-1.17,-2.32l-0.84,-0.43l-2.1,0.21l-3.03,-3.03l1.41,-5.47l0.68,-1.36l1.67,-1.07l1.34,-1.57l0.28,-3.87Z",
      "หนองคาย",
      0,
      Colors.black,
      3),
  "TH-44": MapData(
      "M606.82,448.71l7.82,-2.24l1.05,-0.75l1.72,-2.25l2.33,-0.27l1.86,-0.93l1.16,-1.0l1.56,-2.16l1.7,-2.97l1.23,-3.13l2.77,-2.37l0.72,-1.78l-0.09,-1.79l2.57,0.37l0.51,0.35l0.01,1.04l-1.57,1.4l-0.34,0.97l0.46,3.92l0.91,2.22l-2.05,6.18l0.39,2.38l2.02,3.81l-2.17,4.39l0.61,2.79l1.15,0.85l3.1,0.38l6.76,-1.88l0.73,-0.61l1.07,-1.83l0.48,0.82l0.25,2.0l0.34,0.55l0.69,0.47l2.79,0.46l1.49,2.09l1.62,3.84l2.05,1.81l2.88,1.33l0.73,2.46l-0.21,1.58l2.87,3.83l0.7,2.12l0.6,0.26l0.89,-0.34l1.32,-1.85l4.49,-0.01l-4.97,8.18l-0.83,2.91l-0.15,3.17l1.46,4.04l0.13,6.92l1.22,4.05l0.21,1.97l-0.2,0.82l-1.54,2.04l-1.17,3.61l-3.54,16.96l-1.1,0.49l-4.94,-0.49l-2.7,1.13l-1.71,2.0l-2.63,6.24l-1.73,2.17l-0.27,0.82l0.35,1.06l1.79,0.99l0.33,1.93l0.51,0.83l1.88,1.37l2.87,1.17l1.54,1.49l0.74,0.11l1.64,-0.79l1.23,-0.12l1.23,0.17l1.06,0.75l0.42,2.16l-2.48,7.99l-5.97,2.48l-1.69,0.3l-5.62,-2.04l-2.45,-1.61l-2.72,-0.9l-1.28,-0.76l-12.47,-3.59l-3.05,-2.16l-0.64,-0.87l0.06,-0.76l1.06,-1.08l-0.25,-2.41l-3.63,-2.93l-0.89,-3.14l-2.41,-1.61l-4.95,-5.34l0.05,-0.6l2.66,-1.72l0.74,-0.89l0.21,-1.13l-0.36,-2.11l-2.38,-3.14l-2.1,-1.31l-2.3,-2.71l-0.92,-2.89l-0.02,-5.39l-3.28,-7.2l0.08,-2.42l0.53,-2.12l-0.15,-2.91l-1.86,-4.11l-2.49,-1.59l-0.74,-1.08l-0.46,-1.7l-0.07,-1.42l0.9,-2.52l-0.3,-6.47l-1.51,-5.32l-0.07,-4.76l0.42,-2.03l4.81,-4.04l2.37,-4.85l2.16,-2.56l1.35,-2.5l0.37,-1.4l-0.16,-1.0l-1.21,-2.36Z",
      "มหาสารคาม",
      0,
      Colors.black,
      3),
  "TH-45": MapData(
      "M725.08,449.45l0.52,3.94l0.64,0.82l1.25,0.3l8.71,-3.94l2.73,-1.54l1.1,-0.0l0.89,0.84l0.8,0.26l3.13,-0.21l2.54,0.45l0.83,-0.22l3.65,-1.51l0.61,-0.65l0.77,-1.76l0.45,-0.24l0.74,1.8l0.85,4.92l0.99,6.08l-0.07,1.98l0.69,1.03l2.09,0.61l-3.02,6.77l-1.14,0.51l-2.22,-0.08l-1.97,1.44l-2.01,2.74l-1.54,3.7l-1.22,1.75l-0.7,0.56l-1.73,0.33l-1.48,1.17l-1.79,0.69l-3.1,3.11l-3.34,1.08l-1.77,1.61l-0.47,0.79l-0.04,1.25l1.84,3.99l-0.95,5.99l-1.17,0.33l-2.99,-0.57l-3.01,0.02l-2.13,0.67l-0.55,1.13l0.06,4.9l-0.83,1.71l0.34,1.62l2.39,3.1l-1.89,1.33l-0.49,0.96l0.38,1.42l-0.93,0.55l-0.47,0.9l-0.01,1.38l0.64,1.45l0.49,0.21l4.89,-1.23l2.09,-1.27l0.06,-2.53l3.56,2.16l2.08,3.78l0.42,4.55l-0.91,4.77l0.39,0.47l0.67,0.0l1.19,-0.62l0.94,0.57l1.09,1.52l3.1,6.45l1.53,2.16l-6.07,2.36l-1.17,0.72l-1.28,1.42l-2.52,1.62l-0.62,0.8l-1.78,0.74l-3.94,5.66l-2.25,1.74l-3.84,4.87l-0.54,1.38l-0.37,-0.27l-0.08,-1.21l-0.54,-0.35l-1.54,0.58l-1.62,0.19l-0.59,-0.31l0.55,-1.32l-0.4,-0.55l-1.81,0.15l-1.51,-0.31l-1.11,-0.92l-0.35,-1.78l-1.06,-0.4l-1.6,0.85l-3.17,0.06l-3.1,1.66l-3.27,1.02l-15.66,-1.17l-3.71,-1.51l-1.67,-0.27l-3.03,0.66l-2.73,2.17l-1.46,0.51l-7.11,-1.31l-1.04,0.18l-2.83,1.47l2.28,-7.29l0.01,-1.14l-0.56,-1.61l-1.44,-1.05l-1.46,-0.22l-1.49,0.14l-1.79,0.75l-1.48,-1.45l-4.16,-1.99l-0.79,-0.97l-0.42,-2.12l-0.68,-0.65l-1.05,-0.35l-0.28,-0.58l1.91,-2.66l2.6,-6.2l1.55,-1.81l1.53,-0.79l1.61,-0.24l4.12,0.57l1.54,-0.72l0.5,-1.24l3.21,-16.04l1.13,-3.51l1.52,-2.0l0.29,-1.1l-0.23,-2.21l-1.21,-3.97l-0.14,-6.96l-1.45,-4.01l0.13,-2.92l0.76,-2.71l5.25,-8.64l2.39,-1.09l0.68,-0.23l1.09,1.85l2.28,0.51l2.15,-0.54l0.29,-0.38l0.02,-1.25l0.57,0.32l1.78,2.31l1.6,0.2l1.46,-0.67l0.62,0.51l0.54,-0.03l0.74,-0.76l0.01,-0.55l-1.37,-1.57l3.15,0.63l0.55,-0.37l0.0,-1.12l2.89,0.98l0.47,-0.25l0.9,-3.12l1.3,-1.94l0.48,-4.22l-0.44,-1.04l-2.34,-2.02l-0.42,-2.36l-1.57,-2.05l-0.21,-1.07l10.71,-8.22l1.95,-0.94l4.58,-0.27l2.48,1.44l2.17,0.31l0.97,0.84l1.0,0.34l4.44,0.33l4.17,-0.64l3.2,0.43Z",
      "ร้อยเอ็ด",
      0,
      Colors.black,
      3),
  "TH-46": MapData(
      "M682.59,381.86l-0.63,1.81l0.57,1.03l2.08,0.33l2.2,-0.57l1.37,0.55l8.96,6.89l0.27,0.64l-0.64,2.26l0.15,1.44l1.49,2.83l4.17,2.6l1.39,2.84l3.43,2.34l3.21,1.42l3.49,3.41l0.96,-0.04l0.76,-0.84l0.93,-3.14l1.73,-0.18l0.93,-1.48l2.97,-1.45l0.95,-1.15l3.66,1.2l1.58,1.11l4.93,6.94l1.44,1.48l3.71,6.28l0.61,1.93l1.26,1.59l-0.59,1.98l0.5,3.64l4.13,6.41l1.77,3.53l0.72,10.02l-2.15,-0.39l-3.13,0.21l-1.46,-1.05l-1.55,-0.04l-11.38,5.47l-0.67,-0.15l-0.38,-0.48l-0.48,-3.81l-0.56,-0.59l-3.36,-0.45l-4.27,0.64l-4.29,-0.33l-1.78,-1.13l-2.13,-0.29l-2.33,-1.46l-5.32,0.24l-2.17,1.05l-10.96,8.49l-0.0,1.4l1.62,2.13l0.58,2.71l2.46,2.18l0.23,0.57l-0.45,3.91l-1.27,1.87l-0.79,2.83l-2.4,-0.92l-0.74,0.0l-0.4,0.4l0.0,0.92l-3.27,-0.49l-0.43,0.4l0.0,0.69l1.33,1.58l-0.22,0.22l-0.92,-0.49l-1.45,0.7l-1.05,-0.06l-1.69,-2.22l-1.33,-0.78l-0.6,0.34l-0.03,1.62l-1.57,0.43l-1.99,-0.45l-0.9,-1.78l-0.48,-0.2l-3.63,1.5l-5.17,0.0l-0.83,0.51l-1.08,1.66l-0.76,-2.0l-2.79,-3.72l0.26,-1.33l-0.83,-2.79l-0.67,-0.58l-2.52,-1.05l-1.87,-1.67l-1.5,-3.68l-1.72,-2.36l-3.33,-0.79l-0.43,-2.25l-0.63,-1.17l-0.66,-0.24l-0.51,0.22l-1.16,1.96l-0.73,0.5l-6.27,1.66l-2.7,-0.36l-0.75,-0.56l-0.4,-2.48l1.87,-3.18l0.25,-1.02l-2.08,-4.13l-0.31,-1.64l0.11,-1.29l1.91,-5.33l-0.93,-2.4l-0.45,-3.73l0.35,-0.68l1.3,-0.99l0.35,-1.13l-0.12,-0.86l-0.58,-0.66l-3.31,-0.66l0.57,-3.28l0.07,-8.76l2.15,-3.41l0.62,-4.26l-1.15,-3.62l-0.61,-0.73l-1.7,-0.55l-0.81,0.08l-0.49,0.41l-0.2,1.63l-0.42,0.84l-1.29,1.04l-0.72,0.16l-0.31,-0.94l0.05,-1.76l1.1,-3.67l-0.45,-1.13l-1.71,-1.85l2.87,-4.59l3.62,0.63l4.34,-0.31l1.6,-0.71l1.93,0.18l3.43,1.35l1.79,1.32l5.56,1.23l5.22,2.39l1.48,1.19l0.99,1.28l-0.15,2.96l0.88,2.36l0.88,0.68l0.95,-0.91l0.29,-1.63l0.87,-1.73l3.31,-4.42l0.19,-0.9l-0.28,-2.82l0.42,-2.49l2.66,-4.17l0.15,-3.5l-0.43,-1.88l2.56,-3.15l3.71,-2.26l1.61,-0.54l3.44,1.21l3.41,4.67Z",
      "กาฬสินธุ์",
      0,
      Colors.black,
      3),
  "TH-47": MapData(
      "M644.39,331.02l1.7,-1.68l0.9,-2.81l1.01,-1.1l0.52,-1.86l0.83,-1.18l1.21,-0.61l1.28,0.34l0.89,-0.14l1.58,-1.23l1.26,-0.22l0.44,-0.69l-0.24,-4.99l0.28,-2.13l-0.28,-2.27l0.84,-3.18l-0.22,-3.08l-0.5,-1.46l-1.82,-1.03l-0.98,-1.56l-0.27,-1.05l0.6,-0.82l0.7,-4.59l1.44,0.48l1.52,-0.45l0.33,-0.47l-0.24,-0.55l-1.39,-0.76l0.46,-1.84l0.88,-1.69l-0.1,-1.59l-0.91,-1.38l-0.7,-2.02l0.96,-0.71l0.13,-0.77l-2.19,-3.64l-0.07,-0.81l1.64,-0.51l2.49,0.58l1.93,-1.23l1.76,-0.19l1.41,-1.15l1.25,-1.6l0.32,-1.02l-0.34,-2.17l0.19,-0.3l1.38,-0.56l1.37,-1.1l3.47,0.21l2.08,1.04l1.08,0.89l1.66,0.24l2.59,2.98l2.68,0.58l-1.71,0.73l-0.39,0.99l0.43,2.11l1.6,1.22l2.38,0.36l0.6,1.27l2.67,0.6l1.93,0.96l2.27,2.12l1.6,0.76l0.97,-0.51l0.48,-2.27l0.7,-0.8l-0.03,1.38l1.49,1.13l-0.25,1.06l0.47,1.56l-1.61,1.23l-0.17,1.26l0.81,1.24l2.07,1.79l1.75,0.64l0.82,-0.32l0.09,-0.9l-0.74,-1.29l0.26,-0.31l3.34,0.28l2.02,-1.07l0.62,1.48l0.95,0.52l0.67,-0.29l0.76,-1.08l1.97,-0.63l-0.48,1.02l-0.12,2.03l0.54,0.55l0.58,0.09l1.47,-0.97l-0.19,3.64l0.59,0.97l1.08,0.7l0.06,1.17l0.46,0.64l2.08,0.87l1.69,1.24l1.33,-1.18l1.24,-0.48l0.51,-1.44l0.99,-0.46l0.62,3.26l0.65,1.43l0.77,0.23l1.19,-0.35l0.75,0.79l0.42,1.49l1.21,0.48l0.88,3.15l-0.42,1.89l0.88,1.12l-1.79,3.12l-2.39,0.65l-0.61,0.68l-0.06,0.75l0.77,2.39l0.9,1.25l0.18,1.11l-1.25,3.32l-0.44,4.1l-2.24,4.02l-0.32,1.33l4.73,9.44l0.95,0.61l3.39,0.97l1.2,-0.71l-0.15,-1.72l2.45,1.62l1.39,0.25l0.81,-0.6l1.05,-2.15l0.75,-0.42l7.29,0.61l4.35,-0.6l1.5,-0.7l3.37,-0.55l5.17,0.34l5.65,-0.27l0.2,6.75l1.15,1.98l-0.01,2.8l0.7,1.97l-0.05,2.6l1.26,2.92l-0.32,1.01l-2.29,2.58l-1.65,4.16l-0.56,3.21l0.0,2.47l-3.4,3.43l-0.73,1.47l-0.15,1.95l0.42,1.36l3.29,2.0l-0.08,1.34l-1.05,1.16l-6.47,3.84l-2.17,4.6l-2.85,1.29l-4.02,2.96l-4.47,1.02l-1.37,-0.01l-2.52,-0.72l-2.64,0.08l-1.16,1.54l-0.76,2.46l-2.05,2.17l-2.8,0.5l-1.63,-1.13l-3.08,-1.22l-1.31,0.04l-1.03,1.21l-3.04,1.51l-0.86,1.41l-0.96,-0.11l-0.86,0.38l-1.04,3.27l-0.74,0.58l-3.32,-3.3l-3.29,-1.47l-3.34,-2.28l-1.3,-2.76l-4.15,-2.57l-0.94,-1.41l-0.5,-1.86l0.61,-3.18l-1.07,-1.33l-9.41,-6.89l-0.96,-0.23l-3.06,0.61l-0.74,-0.24l-0.07,-0.97l0.45,-0.9l0.85,-0.7l-0.37,-6.1l-0.51,-0.87l-1.37,-0.31l-0.98,-0.6l-1.57,-2.55l-2.54,-2.53l-1.3,-0.56l-2.0,0.39l-3.52,-3.02l-5.75,-3.07l-1.5,-1.51l-1.49,1.2l-1.14,0.43l-2.05,-0.4l-1.85,0.18l-6.81,-3.68l-7.33,-1.74l-1.86,-3.01l-0.58,-1.71l1.61,-1.87l1.69,-4.45l1.63,-1.72l-0.09,-1.09l-1.6,-2.56l-0.67,-2.03l0.99,-2.93l0.17,-2.06l0.99,-2.24Z",
      "สกลนคร",
      0,
      Colors.black,
      3),
  "TH-48": MapData(
      "M734.77,275.33l4.84,0.13l3.27,-2.05l5.37,11.24l0.99,3.37l0.73,1.33l1.98,2.02l6.99,4.15l1.57,2.01l2.43,4.82l2.02,2.63l1.46,3.8l3.27,3.85l3.29,2.95l16.83,8.72l2.04,0.72l5.08,3.17l1.23,1.28l2.11,3.12l1.71,3.26l0.84,0.98l2.7,1.64l1.08,1.18l2.54,5.6l0.3,1.24l-0.32,6.77l0.21,6.66l-0.9,7.55l-6.99,16.35l-0.56,2.55l1.0,10.36l1.82,4.79l0.07,1.25l-0.95,3.89l-1.69,0.65l-0.89,1.18l0.02,1.71l1.28,2.33l-0.05,1.28l-0.44,0.39l-1.34,-0.07l-4.19,-2.21l-0.35,-0.69l0.37,-2.07l-0.35,-2.6l-1.8,-0.97l-2.47,-0.43l-5.36,-0.27l-4.12,0.99l-1.98,1.15l-1.01,-0.06l-1.14,-0.72l-1.3,-2.19l-1.11,-0.92l-2.41,0.73l-3.78,-2.12l-2.99,1.33l-1.07,-0.23l-2.58,-1.67l-1.6,-0.43l-2.6,0.18l-3.95,1.76l-1.66,-0.4l-2.0,-1.14l-2.75,-2.81l3.64,-2.69l2.9,-1.32l0.92,-1.38l1.41,-3.36l6.33,-3.71l1.27,-1.38l0.04,-2.27l-3.44,-2.3l0.03,-2.39l0.53,-1.04l3.53,-3.63l0.07,-2.73l0.52,-3.06l1.25,-3.4l2.58,-3.12l0.45,-1.7l-1.26,-2.83l0.05,-2.55l-0.7,-1.98l-0.0,-2.87l-1.15,-2.0l-0.11,-6.3l-0.51,-1.01l-6.04,0.22l-5.23,-0.34l-3.53,0.57l-1.41,0.68l-4.24,0.59l-2.14,-0.38l-5.24,-0.22l-1.23,0.67l-1.41,2.51l-0.91,-0.19l-2.05,-1.49l-0.86,-0.23l-0.67,0.54l0.23,1.62l-0.96,0.29l-2.66,-0.91l-1.03,-0.85l-0.58,-1.75l-3.49,-6.43l0.17,-1.24l2.3,-4.18l0.44,-4.1l1.27,-3.43l-0.1,-1.19l-1.03,-1.55l-0.72,-2.57l2.81,-1.04l2.04,-3.66l-0.16,-0.67l-0.77,-0.74l0.45,-1.73l-0.96,-3.42l-0.38,-0.45l-0.85,-0.09l-0.43,-1.5l-0.93,-0.98l-0.63,-0.21l-1.17,0.38l-0.28,-0.3l-1.01,-4.42l0.29,-2.51l-0.24,-1.15l-2.23,-3.17l-0.2,-1.03l0.77,-1.58l0.49,-2.76l0.49,-1.12l3.39,-1.2l0.4,0.19l0.59,1.82l1.37,1.75l0.68,2.23l3.11,1.92l1.24,0.06l0.58,-0.34l2.71,-5.24l-0.42,-2.1l0.16,-3.15l-0.39,-0.75l-0.96,-0.69l-0.19,-0.59l0.62,-2.47Z",
      "นครพนม",
      0,
      Colors.black,
      3),
  "TH-49": MapData(
      "M802.64,407.6l0.01,1.73l2.4,10.32l-2.81,10.01l-0.5,4.84l0.13,2.59l0.59,2.38l1.24,2.06l1.91,1.59l6.12,3.29l1.75,1.47l2.53,3.5l1.89,5.44l1.23,2.23l1.14,0.99l2.87,1.62l2.91,2.89l1.31,0.91l-2.14,2.65l-5.39,3.6l-2.85,2.47l-5.48,2.19l-2.24,0.15l-1.23,-0.83l-9.56,-1.65l-2.22,-1.21l-0.98,-1.55l-0.71,-0.33l-1.27,0.5l-0.65,1.62l-0.72,0.58l-1.28,0.29l-0.99,-0.14l-1.56,-1.71l-3.11,-2.25l-3.01,-6.18l-1.12,-0.55l-3.08,-0.29l-1.09,-1.86l-1.64,-1.24l-3.09,0.39l-3.9,-0.64l-4.19,-0.08l-2.08,0.62l-2.29,1.69l-2.18,-0.64l-0.27,-0.52l0.08,-1.83l-1.0,-6.13l-1.38,-6.47l-0.8,-0.94l-0.87,0.16l-1.64,2.65l-3.54,1.43l-0.73,-10.09l-1.86,-3.77l-4.08,-6.31l-0.44,-3.37l0.58,-2.14l-1.34,-1.75l-0.63,-1.97l-3.73,-6.31l-1.49,-1.55l-4.59,-6.44l2.46,-0.44l1.33,-1.09l1.41,-1.83l0.56,-2.14l0.75,-1.13l2.22,-0.02l2.53,0.73l1.5,0.01l4.47,-1.01l2.95,3.02l2.29,1.3l2.08,0.42l3.99,-1.78l2.36,-0.15l1.34,0.38l2.48,1.63l1.36,0.32l0.96,-0.16l2.21,-1.16l3.48,2.1l2.32,-0.75l0.78,0.62l1.31,2.2l1.63,1.02l1.4,0.04l2.05,-1.18l3.9,-0.93l5.2,0.28l2.35,0.42l1.26,0.57l0.28,2.18l-0.37,2.19l0.58,1.15l4.46,2.38l1.09,0.21l1.01,-0.21l0.74,-0.76l0.08,-1.76l-1.06,-1.79l-0.33,-1.3l0.44,-1.11l1.28,-0.57Z",
      "มุกดาหาร",
      0,
      Colors.black,
      3),
  "TH-26": MapData(
      "M402.13,675.17l2.16,2.49l1.33,0.38l3.13,-0.09l2.64,1.75l1.51,2.02l1.22,0.15l0.84,-0.28l3.43,-2.96l-0.11,-2.49l0.93,-2.62l1.49,-2.08l0.62,-3.23l0.93,-0.94l1.91,0.32l0.58,-0.61l0.37,-1.24l1.05,-1.09l2.83,1.15l1.42,1.72l9.38,5.68l0.98,1.16l1.19,2.41l0.89,0.79l3.82,1.43l0.78,0.58l1.05,2.37l0.97,0.65l0.45,1.36l1.19,1.75l-0.09,2.55l-0.8,1.23l-3.25,0.5l-3.72,1.26l-1.59,-0.22l-2.28,-1.43l-0.93,0.34l-0.42,1.12l-0.29,3.77l-0.83,0.89l-7.59,5.47l-1.44,2.54l-0.0,1.56l1.24,1.82l0.18,1.82l1.29,2.24l0.06,1.16l-0.85,0.7l-2.9,0.78l-1.14,-0.73l-1.39,-0.24l-4.86,0.93l-2.82,3.23l-1.57,1.16l-4.89,1.89l-0.35,0.89l0.51,1.97l-7.63,-0.62l-13.14,0.66l-3.74,1.19l0.9,-6.57l-0.22,-21.21l3.56,-4.08l0.62,-1.71l-0.33,-3.1l1.84,-0.47l1.5,1.43l0.79,0.01l4.19,-2.95l1.24,-1.5l0.46,-1.48l-0.3,-1.01l2.01,-3.11l0.0,-3.22Z",
      "นครนายก",
      0,
      Colors.black,
      2),
  "TH-27": MapData(
      "M539.35,800.18l-0.86,1.12l-3.71,2.35l-1.52,3.82l-0.87,0.68l-1.42,0.12l-2.22,-0.71l-2.14,-1.8l-1.34,-2.49l-0.62,-0.34l-1.64,-0.08l-1.45,1.06l-2.31,3.91l-0.98,0.88l-1.99,0.81l-3.42,0.57l-3.08,2.1l-1.17,-0.01l-0.47,-1.61l-0.34,-4.52l0.48,-3.77l-0.14,-1.1l-2.15,-2.37l-0.59,-1.22l-3.42,-12.3l-2.63,-3.16l-0.76,-2.08l-0.05,-2.27l0.36,-0.94l3.87,-0.58l0.98,-1.62l0.3,-4.44l-0.65,-4.03l-0.32,-0.77l-0.7,-0.45l-4.66,0.75l-1.81,-0.3l-0.6,-0.58l0.63,-2.59l-0.09,-1.89l-0.55,-0.89l-2.77,-2.55l-1.41,-6.3l3.05,-3.61l0.34,-1.64l-0.15,-4.33l-0.74,-1.21l-4.13,-1.26l-0.63,-0.82l-0.08,-1.2l1.03,-3.01l-0.05,-4.57l0.53,-1.46l4.53,-3.75l0.06,-1.81l-0.53,-2.6l0.03,-1.74l0.55,-1.42l1.82,-1.26l1.3,-0.43l2.56,0.02l1.42,-0.49l1.34,-1.24l1.12,-2.72l4.06,-3.43l0.74,-0.99l0.81,-5.47l3.2,2.61l5.59,2.08l1.84,0.4l1.44,-0.24l0.72,-0.61l0.27,-1.0l-0.12,-2.26l0.67,-0.75l1.29,-0.61l0.7,0.1l1.81,1.57l0.52,2.29l0.81,0.83l1.23,0.38l3.47,-0.06l1.96,1.27l1.88,-0.28l1.71,-1.87l1.63,-0.15l2.62,-0.84l3.76,1.12l0.72,0.02l2.84,-1.05l2.92,1.61l3.66,-0.26l0.73,0.87l-0.15,1.6l0.36,2.23l0.92,1.17l1.12,0.33l2.36,-0.18l1.35,-0.49l0.47,-0.61l-0.06,-0.58l-1.7,-0.94l0.25,-1.0l2.95,-0.84l2.65,-2.09l1.64,1.25l1.16,-0.4l1.0,-1.33l2.49,1.8l6.77,0.42l5.68,-1.29l2.19,-0.86l0.94,-0.77l2.63,-0.74l5.98,1.14l3.81,-1.03l-0.27,3.05l-3.78,6.67l-0.7,5.57l-1.52,1.74l-6.21,4.84l-2.77,2.76l-2.03,3.61l-2.7,7.86l-2.46,3.35l-0.46,3.5l-0.37,0.89l-2.46,2.1l-10.86,5.28l-3.54,2.71l-0.18,2.93l2.39,2.32l3.08,2.01l-1.21,0.35l-5.07,2.93l-2.01,0.71l-6.53,0.54l-8.74,-0.74l-4.31,0.48l-2.31,2.76l0.06,1.47l1.21,2.0l0.45,1.71l0.38,9.93l-0.71,6.73l0.2,8.01Z",
      "สระแก้ว",
      0,
      Colors.black,
      5),
  "TH-24": MapData(
      "M379.0,777.27l1.87,-1.94l0.56,-3.22l1.09,-2.47l1.6,-0.35l0.95,-0.66l0.36,-3.11l1.78,-0.75l3.14,-4.32l-0.96,-3.09l-2.0,-1.14l-7.13,-2.62l-0.6,-1.09l4.78,-7.8l2.96,-3.28l0.37,-0.85l-0.3,-1.17l-2.23,-1.83l-0.35,-0.79l0.88,-11.68l3.95,-1.32l13.07,-0.66l7.87,0.64l1.44,3.51l0.15,1.2l-1.48,5.01l0.16,0.78l0.97,1.03l-0.16,1.13l0.36,0.37l1.59,-0.15l1.76,-1.37l3.13,-1.16l3.3,1.14l0.76,0.0l1.62,-0.69l7.75,1.33l1.92,-0.14l20.99,9.81l1.13,1.96l0.82,0.38l0.91,-0.6l1.03,-2.6l0.79,-0.36l1.04,0.18l6.25,2.67l1.91,0.41l1.74,-0.35l1.03,-0.82l0.12,-2.39l0.4,-0.7l5.42,-1.12l3.28,3.02l1.54,3.93l1.8,1.84l1.79,0.55l4.43,-0.68l1.45,6.36l3.28,3.32l0.06,1.61l-0.68,2.39l0.32,0.98l0.81,0.59l1.13,0.29l2.05,0.02l3.19,-0.73l0.43,0.12l0.24,0.56l0.62,3.85l-0.26,4.15l-0.6,1.16l-3.2,0.29l-0.76,0.36l-0.59,0.89l-0.12,1.51l0.1,1.62l0.83,2.28l2.62,3.15l1.89,7.42l-4.17,3.99l-1.65,1.08l-2.37,0.92l-1.17,0.96l-1.49,4.39l-0.78,1.27l-0.5,0.06l-0.3,-0.99l-0.61,-0.73l-1.64,-0.33l-2.41,0.92l-2.29,2.32l-4.07,2.64l-0.66,0.31l-2.66,0.09l-2.57,0.85l-0.27,-1.75l-3.85,-6.65l-4.87,-4.86l-3.31,-1.37l-2.65,-2.14l-2.06,-1.01l-1.56,-3.34l-2.82,-3.93l-2.02,-1.26l-1.57,-0.57l-0.97,0.09l-1.71,0.8l-1.18,-0.2l-1.25,-0.58l-1.83,-1.55l-1.32,-2.28l-0.93,-0.85l-1.58,-0.12l-1.69,0.4l-0.92,-0.23l-2.61,-2.6l-2.57,-1.83l-1.87,-3.38l-1.22,-1.48l-1.41,-1.05l-8.4,-2.0l-4.94,-2.19l-1.53,-0.1l-0.92,0.52l-1.78,2.46l-1.72,0.24l-1.67,1.25l-2.65,-0.01l-0.96,0.4l-0.55,1.25l0.52,2.05l-0.13,0.83l-0.79,0.56l-0.57,0.98l-1.39,0.61l-0.93,1.66l-1.85,1.0l-1.27,0.2l1.35,-2.51l0.0,-0.75l-0.63,-0.33l-3.45,2.69l-1.25,0.32l-6.62,0.0l-4.64,-0.94Z",
      "ฉะเชิงเทรา",
      0,
      Colors.black,
      5),
  "TH-25": MapData(
      "M412.54,736.06l0.1,-1.1l-1.08,-1.51l1.48,-5.03l-0.19,-1.42l-1.54,-3.76l-0.47,-2.63l1.5,-0.35l3.24,-1.44l1.67,-1.24l2.15,-2.6l0.95,-0.71l4.43,-0.62l1.63,0.83l0.86,0.11l2.82,-0.8l1.1,-0.73l0.32,-0.82l-0.12,-1.28l-1.31,-2.29l-0.22,-1.91l-1.2,-1.76l0.02,-1.02l1.24,-2.22l8.17,-6.04l0.64,-1.51l0.32,-3.71l2.39,1.29l1.91,0.25l3.83,-1.28l2.44,-0.21l1.06,-0.41l0.87,-0.91l0.36,-1.32l-0.0,-2.39l-1.25,-1.91l-0.52,-1.48l-0.97,-0.65l-0.67,-1.78l-0.78,-0.97l-4.92,-2.2l-1.82,-3.27l2.49,-0.16l0.8,-0.65l0.77,-1.31l1.55,-1.26l1.45,-0.62l0.89,0.33l1.3,1.68l1.33,0.91l2.75,0.83l5.64,-0.81l2.82,0.29l1.11,0.55l0.92,1.24l1.77,1.11l1.09,1.57l4.63,3.54l2.71,3.37l1.63,1.28l0.65,0.16l0.57,-0.13l0.45,-0.56l0.17,-2.23l0.32,-0.57l2.04,-0.35l1.52,-0.88l3.56,0.2l3.84,-0.85l0.83,-0.46l1.73,-2.74l0.6,0.18l2.03,2.64l1.18,0.78l1.14,-0.03l2.29,-1.9l2.44,1.44l0.01,1.72l-1.99,3.45l-1.66,1.98l-0.23,1.89l1.83,3.41l3.4,2.89l4.34,2.81l1.71,1.49l-0.8,5.74l-4.71,4.3l-1.12,2.71l-1.09,1.04l-1.07,0.41l-2.76,0.01l-1.5,0.51l-1.97,1.36l-0.79,1.92l0.44,6.03l-4.45,3.58l-0.62,1.75l0.06,4.53l-1.01,2.88l0.06,1.63l1.09,1.38l3.03,0.74l0.98,0.45l0.38,0.63l0.15,4.25l-0.3,1.37l-2.9,3.34l-4.61,0.68l-1.32,-0.43l-1.54,-1.57l-1.61,-4.03l-2.87,-2.82l-0.89,-0.49l-1.62,0.08l-4.39,1.17l-0.63,0.78l-0.18,2.64l-0.53,0.38l-1.47,0.31l-1.74,-0.38l-6.14,-2.63l-1.4,-0.24l-1.4,0.7l-1.21,2.85l-0.67,-0.59l-0.91,-1.63l-21.25,-9.92l-2.05,0.12l-7.77,-1.33l-2.33,0.7l-2.05,-0.93l-1.38,-0.21l-1.73,0.44l-1.8,0.85l-1.66,1.32l-0.8,0.17Z",
      "ปราจีนบุรี",
      0,
      Colors.black,
      5),
  "TH-22": MapData(
      "M481.77,863.4l0.43,-2.24l0.91,-1.24l0.03,-1.93l1.7,-1.57l0.04,-1.73l1.19,-6.5l-0.49,-5.85l-0.45,-0.71l-1.65,-0.31l-1.15,-3.75l-0.83,-1.22l-1.85,-1.13l-2.2,0.48l-1.06,-1.47l-0.03,-2.47l1.08,-1.37l0.02,-1.06l-1.27,-1.84l-2.55,-0.76l-2.41,-5.96l-0.65,-2.71l1.01,-4.12l2.1,-2.27l2.88,-0.95l2.61,-0.07l0.86,-0.38l4.23,-2.74l2.23,-2.28l2.12,-0.8l1.24,0.39l0.62,1.5l1.08,0.22l0.88,-0.76l0.56,-1.08l0.48,-1.95l1.25,-2.65l2.98,-1.31l1.71,-1.13l3.95,-3.77l1.9,5.29l2.07,2.21l-0.37,4.65l0.35,4.58l0.59,1.99l0.83,0.48l1.39,-0.23l3.0,-2.06l3.35,-0.55l2.2,-0.9l1.21,-1.1l2.28,-3.87l0.94,-0.77l1.66,0.26l1.2,2.36l2.41,2.01l2.45,0.78l1.82,-0.16l1.28,-1.01l1.42,-3.69l1.02,-0.85l2.03,-0.99l1.31,-1.21l5.45,14.24l2.19,3.77l4.89,5.72l1.7,3.43l1.12,1.51l1.75,1.09l-0.27,0.76l-1.85,1.19l-0.32,0.61l0.21,0.77l1.01,1.12l-1.24,1.46l-0.25,1.52l1.01,2.49l1.0,6.75l0.73,2.36l1.55,2.52l0.23,1.22l-1.15,4.24l-2.37,1.32l-2.48,0.26l-0.83,0.37l-1.54,2.2l-2.1,1.85l-1.35,1.91l-0.32,1.3l0.15,4.04l0.59,1.55l-0.72,1.56l0.66,1.45l1.24,1.46l0.08,0.61l-0.77,-0.05l-2.92,-2.59l-1.29,-0.4l-1.56,0.93l-2.53,3.37l0.01,2.15l1.93,5.22l-0.4,2.03l-1.18,1.62l-0.06,0.98l1.95,3.61l2.71,1.7l-0.09,0.91l-1.59,2.77l-1.85,-1.38l-0.47,0.04l-1.39,1.19l0.1,0.67l1.37,0.8l0.56,1.01l-1.36,1.63l-2.05,1.18l-1.63,-0.16l-0.77,-2.25l0.28,-4.76l0.64,-2.25l1.26,-2.22l-0.35,-0.6l-0.98,0.15l-2.42,3.68l-0.59,-2.35l0.56,-2.82l-0.5,-0.01l-1.2,0.9l-1.6,0.57l-1.22,-0.13l-0.57,-1.19l-0.47,-0.21l-2.36,0.78l-0.04,0.7l0.94,0.58l0.31,0.68l-0.59,1.99l0.36,0.57l0.89,-0.07l1.95,-1.34l0.49,0.82l0.52,1.89l-0.51,1.13l0.12,0.49l2.11,1.59l1.04,3.13l-0.71,1.67l-3.52,-1.71l-6.61,-6.78l-4.46,-2.63l0.06,-1.09l-4.21,-4.94l-1.53,-2.43l0.32,-1.1l2.03,0.77l0.47,-0.22l-0.14,-0.5l-1.07,-0.72l1.97,-1.79l0.72,-1.58l-0.36,-0.57l-1.17,0.21l-1.02,1.3l-0.89,-0.31l1.73,-1.1l0.25,-0.45l-0.4,-0.33l-5.26,0.12l-0.23,-0.42l2.08,-2.02l0.09,-0.45l-0.39,-0.24l-4.58,0.24l-1.5,0.46l-0.28,0.38l0.17,1.15l1.37,0.98l1.0,1.51l1.53,1.28l1.74,0.05l-0.58,2.39l-0.04,1.95l-3.03,-4.56l-1.5,-1.65l-2.08,-0.76l-2.03,-0.18l-1.01,0.3l-0.01,-4.29l-0.24,-1.26l-1.04,-1.77l-0.67,0.1l-0.41,1.1l-1.28,1.38l1.39,5.29l-4.46,-3.8l-0.32,-0.66l1.34,0.41l0.51,-0.47l-0.6,-2.1l-0.74,-0.4l-1.83,-0.04l-0.75,-0.7l-1.3,-2.86l-1.86,-2.57l-2.07,-2.06l-4.15,-2.6Z",
      "จันทบุรี",
      0,
      Colors.black,
      5),
  "TH-23": MapData(
      "M543.09,901.0l1.95,-3.41l0.17,-1.35l-0.71,-0.88l-2.23,-1.25l-1.75,-3.24l0.02,-0.49l1.18,-1.63l0.46,-2.37l-1.95,-5.36l-0.01,-1.78l2.33,-3.01l1.03,-0.67l0.76,0.25l3.0,2.65l0.95,0.24l0.88,-0.43l0.19,-0.57l-0.23,-0.89l-1.79,-2.57l0.7,-1.58l-0.6,-1.53l-0.08,-4.53l1.36,-2.09l2.12,-1.86l1.42,-2.1l2.75,-0.43l0.94,-0.43l-0.42,1.45l-0.14,2.41l0.31,2.47l0.9,1.91l1.78,1.32l6.11,2.02l3.17,2.3l8.25,8.3l3.41,2.28l0.83,3.5l1.56,1.73l3.53,1.91l1.12,1.28l0.29,1.92l-0.83,1.38l-2.84,2.51l-1.15,2.08l-0.58,2.19l-2.49,18.06l0.84,4.5l5.62,8.7l2.15,2.59l1.7,3.73l1.11,5.52l4.98,9.56l7.66,11.03l1.2,4.27l0.39,6.1l-1.14,1.73l-0.52,-1.41l0.29,-5.61l-0.21,-2.63l-1.49,-3.24l-7.4,-9.8l-4.57,-3.78l-0.6,-0.97l0.0,-7.02l-1.15,-5.08l-1.94,-3.22l-12.69,-12.21l-0.07,-0.38l2.02,0.19l0.36,-0.64l-1.4,-1.87l-3.82,-2.99l0.11,-1.73l-0.6,-0.35l-4.76,2.11l-0.69,2.27l1.55,10.36l1.36,2.69l0.17,0.62l-0.26,0.82l-2.8,-1.05l0.03,-3.17l-2.06,-2.71l-3.12,-2.25l-3.37,-1.75l-11.66,-4.08l-1.84,-1.1l-1.92,-0.03l-1.15,1.72l-3.16,-1.36l-0.34,-0.75l0.4,-2.12l-0.78,-2.29l-1.92,-3.24l-0.16,-1.33l2.57,0.58l2.85,-0.98l2.29,-1.78l1.83,-1.97l0.86,-2.58l-0.41,-1.32ZM565.51,970.96l-0.61,1.36l0.4,0.56l2.52,-0.21l1.59,2.51l0.23,3.76l-1.79,3.36l0.0,0.75l0.4,0.4l0.81,0.0l-0.87,2.01l0.33,2.5l-0.69,-0.45l-0.8,-1.7l-0.77,-0.88l-4.03,-1.37l0.99,-1.23l0.29,-0.88l-0.07,-1.47l-1.38,-3.48l-0.08,-0.93l2.44,-8.28l0.53,0.28l0.4,1.05l0.17,2.33ZM532.51,923.99l3.27,0.77l1.9,-0.07l3.32,2.38l1.31,1.31l1.15,1.43l2.21,4.34l1.36,0.99l0.12,0.75l4.58,6.35l-0.17,1.42l-1.08,0.49l-1.57,-0.98l-3.42,-3.41l-0.67,0.18l-0.34,1.28l0.06,2.01l-1.2,0.3l-1.3,-0.15l-4.11,-1.33l-0.52,0.38l0.07,0.87l-1.49,-0.49l0.41,-1.87l0.01,-6.83l-1.09,-1.33l-2.8,-6.54l0.88,0.0l0.35,-0.6l-1.21,-1.67Z",
      "ตราด",
      0,
      Colors.black,
      5),
  "TH-20": MapData(
      "M381.55,867.91l0.55,-1.62l-0.39,-0.48l-1.52,0.0l1.13,-2.42l-0.34,-0.59l-2.44,-0.59l1.72,-4.46l1.2,-1.76l1.64,0.8l1.18,-0.15l2.55,-3.42l0.52,-2.04l-0.15,-1.83l-0.61,-1.71l-4.82,-7.24l-0.38,-1.28l0.3,-0.81l2.64,-2.22l0.66,-3.3l0.88,0.3l1.27,-0.63l1.11,-1.21l0.61,-1.32l-0.11,-2.81l-2.34,-3.36l-0.63,-1.95l-0.67,-0.85l-1.84,-0.71l-0.34,-0.8l2.2,-2.88l1.74,-3.2l2.33,-3.26l0.92,-2.05l-0.09,-2.21l-1.18,-3.97l-2.26,-4.1l0.2,-0.96l1.01,-1.26l0.85,-2.32l3.48,-1.12l1.89,-1.38l0.46,-1.62l0.19,-2.55l-0.22,-2.45l-1.5,-2.18l0.73,-2.16l2.15,-0.47l2.0,-1.08l1.0,-1.71l1.39,-0.62l0.6,-1.0l0.81,-0.58l0.37,-1.07l-0.53,-2.36l0.28,-0.67l3.25,-0.21l1.78,-1.28l1.78,-0.27l2.05,-2.67l0.79,-0.28l5.78,2.31l8.3,1.97l2.31,2.28l1.93,3.45l2.6,1.85l2.74,2.7l1.37,0.35l2.84,-0.38l2.09,3.01l1.9,1.61l1.47,0.69l1.53,0.24l2.45,-0.9l3.19,1.62l2.69,3.78l1.68,3.48l2.19,1.11l2.7,2.17l3.24,1.33l4.7,4.71l3.72,6.46l0.25,1.82l-2.11,2.28l-0.44,1.46l-3.1,-1.37l-2.59,-0.34l-0.81,0.26l-1.32,1.05l-3.32,1.05l-1.12,0.95l-0.48,3.2l-1.13,1.32l-2.83,1.7l-3.18,-0.69l-0.9,0.21l-2.12,2.68l-1.81,1.45l-0.71,-0.0l-2.04,-0.88l-0.63,0.08l-2.93,2.06l-1.06,0.33l-0.77,-0.44l-2.64,-2.95l-2.07,-1.57l-1.24,-0.55l-1.62,-0.42l-1.13,0.1l-3.0,2.44l-0.55,0.08l-2.09,-0.96l-2.46,-0.53l-1.66,-0.93l-3.7,-0.83l-1.42,0.55l-1.28,1.57l0.13,1.47l1.53,1.75l-0.63,0.8l-1.18,0.31l-6.31,-0.98l-1.6,0.58l-1.85,1.75l-0.26,0.97l2.01,1.87l0.43,0.87l0.27,1.08l-0.35,2.59l0.72,2.22l-0.07,1.15l-0.96,1.71l-2.79,2.44l-0.4,3.1l-0.67,1.16l-4.45,3.47l-0.76,0.96l-0.4,4.54l-1.19,2.46l-1.59,6.72l0.03,2.43l0.37,1.2l-0.32,3.76l-4.44,-1.97l1.43,-1.32l0.13,-0.46l-0.85,-2.03l-1.84,-1.07l-2.16,0.98l-1.21,-0.61l-2.0,0.44Z",
      "ชลบุรี",
      0,
      Colors.black,
      5),
  "TH-21": MapData(
      "M393.32,869.39l-0.13,-2.71l1.56,-6.6l1.2,-2.49l0.36,-4.41l5.11,-4.27l0.82,-1.49l0.29,-2.83l2.7,-2.32l1.16,-2.07l0.08,-1.44l-0.72,-2.2l0.35,-2.52l-0.3,-1.29l-0.57,-1.15l-1.84,-1.66l1.81,-1.8l1.14,-0.41l6.2,0.98l1.67,-0.42l0.79,-0.76l0.22,-0.86l-1.46,-1.71l-0.27,-0.89l0.34,-0.76l1.25,-1.0l0.88,-0.05l2.96,0.78l1.63,0.92l2.08,0.42l3.02,1.14l0.75,-0.25l2.76,-2.32l2.28,0.32l3.03,1.98l2.58,2.89l1.37,0.68l1.39,-0.41l2.75,-2.0l1.04,0.1l1.62,0.77l0.84,-0.11l2.08,-1.63l2.09,-2.61l3.16,0.65l1.3,-0.29l2.4,-1.57l1.18,-1.19l0.9,-3.87l3.84,-1.37l1.78,-1.23l2.33,0.29l3.16,1.4l-0.48,2.51l0.68,2.82l2.15,5.53l0.87,1.04l2.21,0.53l1.0,1.47l-1.24,2.62l0.0,1.48l0.48,1.55l1.23,1.2l0.99,0.03l1.4,-0.46l1.38,0.93l0.61,0.88l1.25,3.96l1.97,0.73l0.47,5.62l-1.18,6.41l-0.02,1.61l-1.68,1.54l-0.07,2.02l-0.86,1.11l-0.41,2.19l-2.32,-0.75l-6.69,-0.22l-2.1,0.66l-1.32,1.63l-1.7,3.07l-1.73,0.88l-2.09,0.18l-4.59,-0.3l-1.07,0.6l-0.11,1.51l-0.28,0.21l-2.91,-0.05l-3.36,-0.79l-4.83,0.75l-2.56,0.92l-1.15,1.23l-0.41,1.77l-0.74,0.09l-2.67,-1.72l-7.6,-3.38l-8.14,-1.98l-17.47,-2.26l-2.53,0.53l-3.69,2.09l-4.64,0.83l-1.03,0.88Z",
      "ระยอง",
      0,
      Colors.black,
      5),
  "TH-62": MapData(
      "M276.4,421.67l-1.15,4.48l-0.05,1.64l0.93,2.35l1.77,2.95l1.03,0.69l1.73,0.01l2.62,1.45l2.22,0.46l1.43,0.9l2.16,2.31l1.18,3.99l-4.15,11.18l-1.67,3.09l0.12,1.19l1.58,2.1l-4.32,4.87l-1.16,1.88l-0.26,2.8l0.31,1.86l-1.18,4.2l-3.91,8.64l-0.52,4.76l-6.83,5.91l-2.71,3.8l-1.85,3.8l-2.54,3.67l-0.61,3.16l-3.4,7.67l-1.58,0.52l-3.8,3.33l-0.86,0.3l-1.65,-1.52l-0.74,-1.23l-1.21,-4.76l-0.6,-1.52l-1.15,-1.58l-1.65,-1.05l-3.74,-1.2l-2.52,-1.7l-1.94,0.01l-1.7,-0.39l-3.4,0.48l-1.96,2.18l-4.34,-1.46l-2.03,0.2l-5.37,-0.91l-2.91,0.9l-1.34,-0.28l-0.9,0.16l-2.93,2.23l-1.16,-1.42l-2.03,-1.08l-2.89,-2.25l-1.93,-0.46l-2.29,0.41l-0.6,0.44l-2.15,0.11l-2.78,2.58l-1.86,0.13l-0.9,0.39l-2.65,2.69l-0.27,-2.81l0.46,-2.67l-1.67,-3.03l0.58,-3.22l-0.08,-1.57l-1.09,-1.45l-2.19,-0.56l-1.12,-1.22l-1.97,-10.71l0.16,-1.64l1.38,-3.61l0.06,-2.02l-0.28,-1.59l-1.32,-1.01l-0.62,-1.07l-0.8,-5.36l0.03,-1.4l1.11,-4.58l0.7,-7.37l-0.28,-1.81l-1.62,-1.85l-0.89,-2.64l-0.03,-1.63l0.66,-1.27l0.65,-0.53l2.41,0.43l2.91,-0.41l3.17,0.99l2.35,-0.16l1.25,-0.4l5.51,-3.3l1.63,-2.42l4.9,-0.6l2.11,-1.53l1.12,-2.07l0.36,-1.54l-0.96,-5.37l0.26,-3.19l2.18,-2.19l1.3,-3.38l1.67,-2.31l0.4,-1.48l-0.44,-3.17l0.24,-2.13l1.92,-1.39l1.1,-1.84l0.39,-1.38l-0.03,-2.7l1.52,-3.75l2.77,1.86l1.44,0.37l5.85,-1.51l5.89,-0.46l2.44,0.29l1.06,0.61l1.34,1.48l0.38,1.0l0.25,2.79l0.89,1.43l14.96,9.28l1.74,0.25l3.96,-0.58l11.54,-0.07l0.82,0.34l4.62,4.75Z",
      "กำแพงเพชร",
      0,
      Colors.black,
      2),
  "TH-63": MapData(
      "M60.95,324.79l1.3,-1.18l4.52,-0.2l1.46,-0.48l1.92,-1.49l13.21,-6.2l0.95,-0.25l7.67,0.07l1.07,-0.8l1.14,-1.5l2.06,-1.59l1.2,-0.54l5.02,-1.06l-0.51,1.16l-2.76,2.05l-0.94,1.33l-0.39,1.94l0.05,4.44l0.18,1.6l0.6,0.92l1.13,0.16l1.5,-0.38l1.83,0.74l1.75,4.94l0.22,1.66l-1.12,7.04l0.4,0.79l1.49,0.74l0.38,0.73l-0.32,0.76l-1.5,1.04l-0.48,1.28l1.79,2.46l0.95,3.7l-0.03,1.63l-0.47,1.5l0.11,1.1l1.4,1.55l2.18,0.98l1.29,1.24l1.75,0.85l1.36,1.32l1.01,0.38l1.53,-0.0l4.29,-2.13l4.04,-0.26l2.84,-0.68l3.49,-1.21l0.73,-0.73l0.62,-2.51l-0.18,-3.53l-0.58,-0.82l-1.64,-0.74l-0.11,-0.44l1.57,-3.46l0.22,-3.26l-0.93,-1.88l-2.01,-1.73l-0.49,-0.79l-0.28,-2.61l0.39,-3.08l1.1,-2.94l0.94,-1.45l2.29,-1.07l3.44,-0.67l1.8,-2.69l0.31,-1.42l-0.16,-0.93l-1.19,-1.94l-0.55,-3.06l0.64,-1.07l3.42,-2.89l0.41,-1.25l-0.19,-1.5l0.45,-0.94l0.96,-0.8l2.67,-0.88l2.08,-1.09l3.08,4.72l0.47,1.32l0.0,1.32l-0.74,0.98l-3.42,1.07l-0.86,1.73l0.04,1.55l0.73,1.21l-0.7,2.02l1.42,5.12l0.0,6.89l1.26,2.23l2.69,0.28l2.96,-0.14l6.13,-2.29l4.34,-3.63l1.0,-3.24l1.39,-1.68l0.38,-4.04l1.11,-1.76l1.2,-0.83l1.26,-0.37l3.98,0.22l1.34,0.62l3.36,2.62l-0.13,1.57l1.56,3.57l0.86,5.87l-0.08,1.1l-1.7,5.19l-0.43,3.61l0.41,1.69l1.57,0.92l1.34,1.96l2.97,1.56l2.34,0.23l2.1,1.36l2.31,0.05l3.89,2.19l0.82,0.17l3.32,-3.3l0.78,-2.38l1.1,-1.22l1.22,-0.53l2.39,0.14l1.38,0.65l0.26,1.05l-0.3,2.77l0.89,3.79l4.25,7.0l-0.36,12.07l0.08,1.55l0.92,1.81l-0.39,1.2l-2.29,1.95l-2.04,3.71l-0.15,0.77l0.51,4.4l-0.35,2.75l-1.05,2.91l0.05,1.32l1.06,2.73l3.16,1.04l2.64,2.89l1.13,0.62l-1.13,2.25l-0.47,1.7l0.02,2.76l-0.33,1.18l-0.94,1.59l-1.6,0.95l-0.49,0.72l-0.29,2.4l0.44,3.11l-0.35,1.25l-1.64,2.26l-1.26,3.3l-0.72,0.87l-0.81,0.4l-0.71,1.07l-0.3,3.46l0.97,5.29l-0.3,1.29l-1.0,1.87l-1.46,1.16l-5.3,0.77l-0.68,0.57l-1.07,1.91l-5.33,3.2l-3.25,0.51l-3.14,-0.98l-2.97,0.41l-2.56,-0.42l-1.15,0.81l-0.85,1.67l0.05,1.95l0.92,2.73l1.49,1.66l0.29,0.82l-0.0,2.88l-0.63,5.26l-1.1,4.52l-0.05,1.57l0.84,5.59l0.73,1.3l1.26,0.92l0.13,0.42l0.03,2.65l-1.36,3.52l-0.21,1.49l1.76,10.74l1.18,1.88l1.17,0.65l1.3,0.14l0.98,1.09l0.07,1.32l-0.59,3.4l1.68,3.08l-0.47,2.53l0.91,7.29l0.59,1.46l3.32,2.69l0.23,0.84l-0.11,5.32l0.42,2.34l-1.64,4.48l-0.72,6.19l-1.78,2.72l-1.5,3.13l-2.83,1.95l-0.39,0.66l0.09,4.36l0.52,0.81l1.57,1.08l0.35,0.66l-1.26,3.65l-0.35,4.69l0.53,2.27l-1.71,2.98l-1.79,6.27l-0.32,3.03l-0.58,1.67l-2.05,3.52l-1.42,1.21l-4.4,-3.42l-4.75,-2.42l-1.94,-4.0l-4.46,-5.56l-3.15,-5.21l-3.18,-2.68l-0.52,-2.32l-0.68,-1.45l-4.29,-2.93l-0.21,-0.32l1.06,-0.75l-0.23,-1.31l-7.31,-11.53l-0.84,-0.77l-1.69,-0.16l-1.41,-0.96l-2.16,-0.62l-2.58,-2.08l-4.19,-1.71l-0.38,-3.82l0.29,-2.52l3.4,-11.21l0.24,-2.14l-0.79,-4.64l-0.08,-2.58l1.64,-6.3l-0.81,-2.51l-2.87,-4.08l-0.27,-1.17l0.66,-0.61l3.58,1.06l2.38,-0.13l0.96,-0.5l1.33,-1.12l1.51,-2.18l1.55,-4.0l2.07,-1.0l1.79,-0.08l6.55,0.84l2.83,1.87l1.67,-0.22l1.19,-0.8l2.56,-2.79l0.57,-1.08l0.17,-5.05l0.66,-2.1l4.42,-5.62l0.55,-1.84l0.51,-5.02l1.07,-4.83l-0.15,-2.34l-1.87,-2.73l-2.59,-1.7l-1.9,-1.85l-0.4,-3.65l-0.65,-0.26l-2.37,2.0l-0.93,1.89l-0.9,4.54l-1.39,2.52l-6.48,5.1l-3.28,4.85l-1.45,1.06l-1.74,-1.23l-0.62,-1.52l-1.57,-7.98l-1.4,-3.26l-0.12,-1.04l1.04,-2.22l0.2,-1.29l-0.91,-2.24l-7.28,-9.85l0.38,-3.27l-0.75,-2.4l-1.66,-2.14l-3.72,-2.54l-1.42,-2.01l-1.31,-4.29l-3.2,-2.53l-0.18,-1.71l0.8,-2.0l1.19,-1.69l1.56,-0.46l1.76,-1.11l1.49,-1.61l0.24,-1.61l-0.95,-1.01l-1.86,-0.9l-0.39,-1.11l0.22,-1.3l0.57,-0.35l2.77,1.21l0.15,-0.44l-1.66,-4.76l-2.73,-1.59l-0.38,-3.22l-0.67,-1.62l-1.21,-1.53l-2.99,-5.36l-2.04,-2.01l-2.02,-1.29l-2.29,-0.68l-5.37,-0.14l-1.74,-0.53l-1.37,-1.31l-1.27,-2.2l0.83,-1.27l-0.05,-1.11l-0.39,-0.35l-2.51,-0.02l-0.13,-0.54l0.43,-1.09l0.84,-0.93l-0.07,-0.6l-2.4,-1.64l-3.86,-5.51l-3.79,-2.63l-9.22,-8.7l-0.78,-0.97l-0.21,-1.29l0.45,-3.71l-0.68,-1.75l-1.45,-1.0l-3.02,-1.27l-1.35,-1.41l-1.87,-4.72l-2.37,-3.68l-0.55,-1.77l-0.96,-1.09l-5.36,-3.0l-2.45,-2.26Z",
      "ตาก",
      0,
      Colors.black,
      4),
  "TH-60": MapData(
      "M368.73,506.32l0.23,2.87l0.55,1.18l2.46,1.17l0.93,0.87l0.5,1.04l-0.52,3.44l0.22,3.15l1.34,6.79l1.05,3.43l1.34,2.97l-1.12,2.49l1.21,2.83l0.16,1.1l-3.06,3.58l-0.89,4.19l-0.68,1.2l-1.21,1.24l-2.39,0.99l-0.98,0.9l-0.85,2.33l1.06,3.68l0.09,1.34l-0.64,1.44l-1.67,2.06l-11.97,10.98l-2.99,3.64l-1.69,0.88l-1.75,1.77l-2.66,3.7l-0.7,3.75l-3.25,2.14l-0.82,1.0l-0.14,3.7l-1.11,2.73l-2.73,3.04l-1.03,2.05l-6.27,-2.54l-1.68,-1.05l-1.44,-2.87l0.38,-1.76l-0.84,-1.98l-0.87,-0.71l-3.27,-0.79l-5.0,-13.23l-3.5,-5.29l-3.11,-2.85l-3.69,-1.49l-5.56,-5.32l-1.29,0.25l-5.19,-0.11l-1.22,-2.84l-8.05,-6.73l-2.2,-0.89l-1.88,0.71l-2.97,-1.44l-3.82,-4.73l-0.94,-5.9l-0.44,-1.48l-0.52,-0.53l-1.41,-0.17l-1.2,0.39l-1.17,0.83l-1.35,-0.08l-3.51,-1.42l-3.56,-3.47l-1.69,-1.1l-3.61,0.09l-4.09,1.71l-3.86,3.33l-4.16,1.53l-3.21,3.99l-3.75,2.26l-0.97,0.31l-4.03,-0.29l-4.8,-3.95l-5.31,-2.73l-1.34,-3.3l-9.43,-4.52l-1.1,-0.97l-2.92,-1.5l-0.82,-0.72l-0.75,-1.41l-2.85,-2.18l-2.32,-1.34l-2.04,-0.73l-4.08,0.37l0.06,-2.14l-0.28,-1.09l-3.48,-2.94l-0.9,-4.34l2.97,-3.1l2.7,-0.49l2.77,-2.57l1.99,-0.04l0.64,-0.46l2.14,-0.38l1.37,0.32l2.88,2.24l1.99,1.05l0.82,1.19l0.79,0.41l0.81,-0.25l2.55,-2.06l1.98,0.19l2.87,-0.89l5.22,0.91l1.88,-0.23l4.21,1.5l1.15,-0.28l1.58,-2.01l2.0,-0.38l2.62,0.39l1.48,-0.11l2.66,1.71l3.8,1.23l1.44,0.91l0.98,1.37l1.45,5.5l1.13,2.07l2.03,1.83l1.57,-0.37l3.57,-3.17l1.71,-0.61l0.75,-0.81l3.11,-7.37l0.56,-3.05l2.5,-3.62l1.85,-3.8l1.9,-2.89l7.44,-6.46l0.47,-1.13l0.32,-4.13l3.9,-8.62l1.23,-4.37l-0.3,-2.02l0.24,-2.57l1.0,-1.57l4.22,-4.76l1.37,1.06l1.39,2.36l0.97,4.88l-0.49,1.02l0.24,2.14l1.54,6.17l3.77,2.52l1.3,1.39l0.03,2.88l2.89,4.36l2.19,6.9l3.26,6.37l2.97,1.55l2.33,1.96l1.11,0.27l1.36,-0.48l2.61,1.91l2.14,0.27l1.94,-0.44l0.3,-0.35l0.26,-2.74l1.04,-0.4l1.46,0.18l2.74,0.95l2.53,-0.26l3.7,1.39l1.11,0.14l4.31,-0.55l5.14,0.26l1.66,-0.88l2.38,0.12l2.02,-1.06l4.34,-1.1l2.74,0.57l3.93,0.12l5.62,1.6l3.82,0.15Z",
      "นครสวรรค์",
      0,
      Colors.black,
      2),
  "TH-61": MapData(
      "M293.01,564.46l-2.18,-0.11l-0.78,0.95l0.42,1.49l2.3,1.81l1.78,2.92l0.06,2.47l-1.43,3.33l0.12,1.73l0.4,0.37l-0.28,0.14l-0.45,-0.06l-0.43,-1.28l-0.66,-0.66l-4.58,-1.32l-3.19,0.23l-2.14,-0.38l-1.95,0.08l-4.91,1.0l-2.65,-1.83l-9.24,-1.2l-1.51,-0.53l-0.97,0.2l-1.25,1.17l-2.47,1.47l-0.69,1.25l-0.04,1.48l1.23,2.89l0.74,4.94l1.0,1.65l0.99,2.61l4.56,7.12l1.29,1.15l-0.15,0.79l-1.82,3.29l-1.92,1.07l-1.99,1.91l-1.68,0.54l-1.46,1.89l-0.22,1.38l0.74,1.71l-0.32,0.83l-5.7,-2.77l-2.13,-0.64l-2.43,0.7l-0.56,0.52l0.68,4.02l-1.5,0.17l-5.54,-1.44l-2.64,-0.91l-2.52,-1.68l-10.46,-2.19l-0.73,-2.8l-0.53,-0.89l-6.31,-1.88l-2.11,-2.04l-0.98,-0.38l-1.41,0.57l-1.97,1.98l-0.65,3.24l-0.92,2.33l-3.12,0.74l-1.05,-0.12l-0.84,-0.55l-4.73,-1.54l-2.67,0.21l-3.08,-1.31l-4.12,0.93l-2.43,0.2l-1.61,-2.21l-6.01,-4.87l-0.81,-1.77l-0.24,-3.03l0.29,-1.82l-0.69,-2.79l-0.09,-3.21l-0.55,-2.86l1.61,-1.39l2.14,-3.69l0.64,-1.85l0.3,-2.99l1.77,-6.19l1.41,-2.33l0.39,-1.27l-0.58,-1.9l0.35,-4.59l1.26,-3.88l-0.58,-1.1l-1.89,-1.56l-0.23,-3.31l0.33,-0.89l2.92,-2.06l1.51,-3.15l1.86,-2.91l0.74,-6.25l1.66,-4.55l-0.41,-2.52l0.04,-2.35l3.98,-0.37l4.05,1.95l2.69,2.05l0.7,1.35l1.02,0.91l2.94,1.51l1.13,0.99l9.25,4.4l1.37,3.31l5.42,2.81l4.4,3.74l1.3,0.45l3.6,0.16l1.34,-0.42l3.86,-2.33l3.16,-3.95l4.07,-1.48l3.89,-3.35l3.82,-1.61l3.24,-0.1l0.57,0.27l4.44,4.17l3.76,1.53l1.44,0.18l1.96,-1.13l1.38,-0.2l0.36,0.27l0.4,1.34l0.99,6.03l2.93,3.87l1.82,1.69l2.55,1.04l0.69,-0.0l1.38,-0.68l1.82,0.76l7.89,6.6l1.14,2.76l-0.04,1.78Z",
      "อุทัยธานี",
      0,
      Colors.black,
      2),
  "TH-66": MapData(
      "M359.33,459.76l1.94,5.06l1.25,5.3l-0.31,1.47l-0.86,1.69l-5.38,7.17l-0.48,2.29l0.5,4.58l-0.85,4.8l0.54,0.72l7.97,2.32l3.62,2.1l2.85,2.26l0.17,1.68l-1.48,4.29l-3.73,-0.12l-5.65,-1.61l-3.98,-0.13l-2.85,-0.57l-4.55,1.14l-1.94,1.04l-2.47,-0.1l-1.53,0.85l-5.02,-0.27l-4.32,0.55l-4.63,-1.52l-2.61,0.24l-2.67,-0.94l-1.66,-0.19l-1.72,0.81l-0.32,2.78l-2.76,0.34l-3.17,-2.13l-0.61,-0.1l-1.09,0.52l-0.71,-0.18l-2.27,-1.92l-2.74,-1.33l-3.18,-6.22l-2.2,-6.92l-2.87,-4.29l0.21,-2.17l-0.27,-0.79l-1.53,-1.67l-3.55,-2.26l-1.46,-5.91l-0.21,-1.95l0.48,-1.16l-1.01,-5.07l-1.51,-2.59l-1.73,-1.36l-0.46,-1.01l-1.31,-1.5l0.32,-1.12l1.36,-2.25l4.12,-11.12l2.7,-0.43l3.39,-1.16l2.76,-0.36l5.04,-5.16l1.18,-0.85l2.51,-1.44l4.31,-1.41l1.59,0.95l0.78,3.44l0.0,1.37l0.57,0.36l1.14,-0.57l0.4,0.89l0.11,1.97l0.92,0.87l2.16,-0.7l0.89,-1.01l2.45,0.79l8.91,-2.16l4.46,0.97l6.12,-1.05l1.46,0.09l0.74,0.4l0.8,0.69l0.91,1.66l0.76,2.42l1.79,3.84l0.17,3.04l1.77,2.07l7.55,6.95Z",
      "พิจิตร",
      0,
      Colors.black,
      2),
  "TH-67": MapData(
      "M480.91,413.28l-0.32,4.01l-1.33,2.66l-1.85,2.04l-0.57,1.2l-1.42,0.71l-0.86,0.89l-1.29,-0.73l-2.42,-2.41l-2.08,-0.55l-1.54,-0.03l-3.31,0.55l-1.19,-0.6l-1.27,-1.42l-0.82,-0.27l-2.84,1.59l-1.9,2.01l-0.59,0.04l-3.0,-1.14l-1.59,0.84l-0.37,1.4l0.11,1.26l0.91,2.05l-0.5,1.23l-1.41,0.97l-0.35,3.86l0.28,1.68l1.42,1.39l0.0,0.41l-5.08,3.67l-0.22,1.31l0.49,2.08l-0.38,1.15l-1.29,1.64l-0.99,1.95l-4.38,4.06l-0.28,0.82l0.19,1.71l-2.54,2.95l-1.81,8.4l-1.53,2.56l0.56,1.14l1.29,1.04l0.08,0.56l-2.36,3.69l0.17,2.76l-2.35,12.24l0.57,5.89l1.33,3.84l1.38,1.05l2.91,0.69l0.41,0.63l-1.2,2.89l-1.27,4.77l-3.33,3.13l-0.43,0.87l-0.1,1.38l0.37,9.76l0.4,1.43l3.12,2.81l2.88,0.44l0.74,1.41l-0.33,1.91l-1.7,4.99l-0.78,4.01l-0.47,4.73l0.94,6.41l-0.14,9.44l-3.26,7.3l-0.94,1.24l-3.29,3.45l-3.72,-3.05l-0.8,-1.2l-0.57,-3.22l-0.9,-1.89l-1.19,-1.13l-4.09,-0.81l-4.65,1.38l-2.59,-0.31l-4.81,-3.48l-2.52,0.21l-1.45,-0.35l-1.41,-1.65l-6.21,-4.32l-2.42,-0.09l-3.1,0.42l-5.52,1.44l-5.2,-1.51l-9.07,-1.9l0.63,-1.54l0.61,-0.56l2.2,-0.85l1.7,-1.63l0.81,-1.47l0.83,-4.05l3.09,-3.61l-0.14,-1.65l-1.17,-2.61l1.11,-1.88l0.0,-0.7l-1.38,-3.12l-1.04,-3.39l-1.32,-6.71l-0.21,-2.99l0.54,-2.62l-0.23,-1.62l-1.51,-1.75l-2.35,-1.08l-0.39,-0.79l-0.26,-3.16l1.55,-4.49l0.01,-1.95l-2.18,-2.06l-4.88,-2.95l-7.99,-2.35l0.76,-4.77l-0.5,-5.02l0.43,-1.57l0.72,-1.22l4.56,-5.77l1.15,-2.51l0.08,-2.38l-1.19,-4.3l-1.9,-4.96l2.55,-3.34l1.05,-3.71l2.37,-0.65l4.84,-3.2l2.68,-0.97l1.18,-3.25l3.6,-5.43l0.67,-1.57l0.16,-1.5l-0.8,-4.07l1.96,-5.22l1.8,-1.89l3.7,-0.9l2.11,-2.12l-0.02,-0.79l-1.21,-1.69l0.04,-2.07l-0.82,-1.72l-0.01,-1.05l-1.46,-2.12l0.42,-2.36l0.76,-0.46l1.69,-0.03l0.92,-0.5l5.02,-5.1l2.3,-1.27l4.04,-4.94l6.69,-0.34l0.9,-0.83l0.28,-0.74l1.41,-0.66l0.42,-0.86l-0.05,-2.66l0.94,-3.8l-0.75,-2.74l0.2,-1.55l0.94,-0.6l2.2,-0.09l1.49,-0.83l2.6,-4.29l0.23,-1.04l-0.15,-1.82l1.34,-0.6l10.04,4.02l1.82,1.63l2.88,-0.95l1.25,-0.09l3.13,0.52l1.39,-0.7l3.5,1.02l2.23,-1.1l0.8,0.03l4.05,2.41l2.36,0.89l2.31,5.02l2.35,0.96l2.43,-0.26l2.26,-1.03l0.64,-0.65l0.94,-2.14l0.86,-1.15l1.06,-0.74l0.47,0.0l0.37,0.31l0.66,2.29l3.16,6.84l2.82,3.15l0.49,1.32l0.55,3.32l-0.42,6.26l0.97,3.11l-0.57,2.98l0.37,1.53l0.48,0.57l1.03,0.45l5.86,-0.77Z",
      "เพชรบูรณ์",
      0,
      Colors.black,
      2),
  "TH-64": MapData(
      "M275.88,297.37l2.59,2.32l0.29,0.93l-0.39,1.35l0.13,0.9l0.85,1.23l1.81,1.45l2.38,2.68l0.8,3.11l0.06,1.65l-1.07,5.18l-1.31,1.59l-2.56,1.71l-0.27,0.56l0.09,1.15l2.38,3.55l1.49,0.59l1.03,2.26l2.54,1.83l2.32,2.66l1.6,3.72l-1.04,1.77l-2.1,0.6l-0.64,0.7l0.29,1.77l1.34,1.8l0.08,5.81l-1.26,3.67l-2.43,2.06l-1.19,2.25l0.08,0.96l0.83,1.53l0.49,2.62l-0.13,4.67l-1.12,0.37l-2.07,-0.54l-3.28,0.16l-0.89,0.69l-0.11,0.89l1.74,4.03l2.36,1.42l1.6,3.01l5.01,4.33l4.44,2.81l3.66,1.87l4.24,3.15l0.59,1.38l-1.0,3.57l0.81,2.07l-0.96,0.74l-5.73,-0.15l-3.53,0.7l-0.92,1.12l-0.39,2.68l-2.36,-0.67l-2.04,0.17l-2.18,-0.45l-0.73,0.21l-3.99,9.35l-0.55,0.93l-1.06,0.41l-1.21,0.96l-0.53,1.12l-0.02,1.57l0.56,0.74l4.45,1.27l0.5,0.6l-0.48,1.19l-2.82,1.33l-4.58,-4.7l-1.22,-0.56l-11.72,0.05l-3.51,0.57l-1.8,-0.15l-14.8,-9.17l-0.65,-1.06l-0.23,-2.67l-0.46,-1.23l-0.98,-1.24l-1.33,-0.99l-3.27,-0.59l-5.96,0.46l-5.66,1.5l-1.14,-0.28l-4.47,-2.73l-2.73,-2.96l-3.07,-0.98l-0.88,-2.82l1.22,-4.06l0.21,-2.18l-0.39,-4.98l1.94,-3.5l2.22,-1.86l0.5,-1.01l0.07,-1.23l-0.91,-1.44l-0.08,-1.42l0.35,-11.7l2.01,0.26l0.69,0.37l1.61,1.83l1.54,2.99l1.61,0.77l0.85,-0.17l0.82,-0.71l1.94,-0.61l2.49,-1.5l0.33,-1.52l0.85,-0.74l0.45,-1.05l-0.29,-2.77l0.33,-1.97l1.78,-1.85l0.59,-1.18l0.09,-1.89l-0.75,-2.38l-2.25,-1.12l-1.13,-1.33l-1.11,-0.71l0.85,-4.15l-1.6,-1.25l-1.17,-2.36l0.56,-5.04l1.74,-1.35l0.32,-0.74l-0.69,-3.39l-1.4,-0.99l0.27,-2.97l0.49,-0.59l2.13,0.26l0.92,-0.77l-0.33,-1.92l0.15,-2.06l2.54,-4.0l-0.05,-1.72l0.42,-2.13l-0.62,-2.28l5.83,-7.1l2.57,-1.47l3.83,-0.81l1.07,-0.13l2.05,0.46l4.48,1.72l3.76,4.24l1.15,0.88l1.04,2.14l1.79,1.15l1.16,-0.17l1.6,-1.66l0.91,-2.26l2.28,-2.88l3.64,-1.56l8.16,-0.56Z",
      "สุโขทัย",
      0,
      Colors.black,
      2),
  "TH-65": MapData(
      "M359.52,331.13l1.34,-1.16l4.72,-2.18l3.11,-3.06l3.18,-5.17l6.11,-4.64l1.65,-3.71l2.38,-2.8l0.72,-0.31l0.88,0.1l0.87,1.64l1.42,0.46l4.11,-1.28l-1.96,4.39l-3.59,4.16l-1.59,2.63l0.2,2.78l1.9,1.4l3.4,0.63l-0.87,1.62l-2.42,1.84l-0.42,3.33l-2.1,2.87l0.29,1.18l1.75,2.47l0.77,4.52l-0.69,3.02l0.09,2.66l0.46,0.96l1.49,0.93l1.78,-0.33l2.3,0.56l2.33,-0.26l1.05,0.19l1.66,2.38l2.03,1.03l1.64,2.53l3.34,0.73l2.52,4.31l-0.0,1.05l-0.59,1.88l-1.77,2.54l-0.46,1.3l-1.01,6.05l-1.53,4.24l-0.53,6.1l-1.55,2.18l1.6,3.07l-0.31,1.31l-0.86,0.77l0.01,0.94l1.65,1.39l1.72,0.71l0.43,0.48l0.17,1.21l-2.18,-0.08l-0.87,0.27l-4.17,5.05l-2.26,1.24l-5.03,5.1l-0.96,0.39l-0.84,-0.14l-1.06,0.29l-0.67,0.64l-0.59,2.12l0.09,0.9l1.36,1.85l0.1,1.27l0.81,1.68l-0.02,2.15l1.24,1.95l-1.82,1.76l-3.63,0.85l-2.12,2.21l-2.05,5.51l0.8,4.26l-0.13,1.19l-0.58,1.38l-3.61,5.46l-1.08,2.39l0.01,0.68l-2.46,0.82l-4.8,3.18l-2.26,0.51l-0.75,1.02l-0.77,3.14l-2.38,3.11l-7.28,-6.7l-1.63,-1.91l-0.1,-2.85l-1.81,-3.9l-0.77,-2.46l-1.07,-1.89l-1.94,-1.32l-1.71,-0.11l-6.02,1.04l-4.55,-0.97l-8.88,2.14l-2.54,-0.8l-1.21,1.16l-1.63,0.56l-0.35,-2.21l-0.75,-1.48l-0.55,-0.1l-0.78,0.45l-0.81,-4.46l-1.7,-1.25l-0.93,-0.21l-4.34,1.46l-2.66,1.52l-1.29,0.93l-4.86,5.03l-2.56,0.28l-3.44,1.18l-2.48,0.4l-1.19,-3.96l-2.31,-2.51l-1.67,-1.06l-2.21,-0.45l-2.66,-1.47l-2.08,-0.15l-2.01,-3.1l-0.85,-2.04l0.03,-1.44l1.15,-4.49l2.98,-1.41l0.93,-1.63l-0.35,-1.02l-0.65,-0.54l-4.28,-1.15l-0.34,-0.4l0.03,-1.16l0.79,-1.19l1.85,-0.92l0.64,-1.08l3.86,-9.13l2.28,0.43l2.02,-0.18l1.54,0.61l1.11,0.05l0.61,-0.57l0.34,-2.66l0.47,-0.61l3.24,-0.65l6.04,0.09l0.92,-0.52l0.49,-0.75l0.06,-0.66l-0.85,-1.65l1.0,-3.6l-0.36,-1.29l-0.54,-0.66l-4.29,-3.19l-3.69,-1.9l-4.4,-2.78l-4.92,-4.26l-1.53,-2.95l-2.49,-1.62l-1.02,-2.1l-0.37,-1.72l2.03,-0.46l4.02,0.54l3.97,-1.77l0.62,0.15l1.41,1.19l0.81,0.09l12.55,-3.81l2.13,-0.26l0.8,0.62l1.15,0.33l1.88,-0.57l5.04,-3.87l0.83,-1.0l0.39,-1.67l-1.47,-6.51l0.48,-1.52l1.13,-1.63l3.31,-2.79l1.88,-0.61l2.47,0.38l1.61,-1.49l10.37,-3.72l4.47,-0.07l1.02,1.44l0.64,0.23l7.56,-1.74l1.84,-0.97l2.32,-3.7l5.6,-4.13l0.39,-0.61Z",
      "พิษณุโลก",
      0,
      Colors.black,
      2),
  "TH-35": MapData(
      "M767.78,567.63l0.35,2.7l-1.03,2.67l-1.05,4.1l-1.39,-0.61l-0.66,-2.17l-0.9,-0.91l-1.54,0.02l-2.1,-1.41l-1.6,-0.62l-4.06,-0.26l-2.89,-2.04l-2.13,-1.07l-8.55,-12.06l-2.49,-2.54l-0.55,-3.13l-1.69,-3.7l1.11,-1.22l1.01,-0.6l5.09,-1.85l1.38,-0.71l0.14,-0.59l-1.74,-2.45l-3.1,-6.45l-1.19,-1.68l-1.33,-0.84l-1.59,0.62l0.83,-4.46l-0.48,-4.84l-2.32,-4.1l-4.3,-2.61l-0.61,0.36l0.15,2.69l-1.68,1.05l-4.6,1.13l-0.45,-1.89l0.36,-0.7l1.08,-0.79l-0.37,-1.49l0.36,-0.71l1.99,-1.22l0.17,-0.6l-2.62,-3.41l-0.24,-1.22l0.58,-0.72l0.22,-0.9l0.05,-5.41l2.8,-0.7l5.49,0.61l0.94,-0.3l0.72,-0.97l0.76,-5.86l-0.23,-1.02l-1.62,-3.06l0.02,-0.92l0.35,-0.54l1.78,-1.51l3.12,-0.98l3.05,-3.07l1.82,-0.71l1.38,-1.11l2.14,-0.57l1.86,-2.37l1.56,-3.74l1.89,-2.58l1.61,-1.22l2.11,0.11l1.36,-0.51l0.57,-0.69l3.0,-6.89l2.22,-1.66l2.66,-0.6l3.2,0.14l3.95,0.65l2.87,-0.42l1.27,1.0l1.24,2.01l3.73,0.49l0.87,1.08l2.4,5.23l3.26,2.41l1.75,1.84l1.34,0.2l1.61,-0.38l1.05,-0.87l0.52,-1.46l0.68,-0.29l0.8,1.3l1.71,1.33l10.78,2.07l0.91,0.66l-0.35,2.6l-0.94,0.77l-3.26,0.8l-10.01,1.39l-6.43,1.65l-2.2,1.16l-2.29,1.7l-1.56,2.08l-3.0,7.25l-2.53,2.68l-1.14,3.76l-4.06,5.1l-0.87,3.94l0.02,3.48l-1.74,2.51l-0.62,5.92l-0.73,1.32l-0.01,2.3l-0.36,1.67l0.37,0.99l1.01,1.26l0.36,1.39l0.32,5.99l0.63,0.51l1.28,0.06l0.35,2.57l0.86,0.95l4.37,1.8l0.76,2.08l-0.19,0.61l-1.71,0.91l-1.29,1.31l-4.94,0.09l-1.75,0.69l-1.93,-0.4l-0.74,0.38l-0.49,2.16l-0.45,5.1l-1.39,3.15l0.03,1.86l0.52,2.09l0.6,0.74l3.54,2.45l1.05,-0.33Z",
      "ยโสธร",
      0,
      Colors.black,
      3),
  "TH-34": MapData(
      "M792.56,582.28l-1.26,-1.28l-2.97,-0.07l-2.13,-0.45l-0.87,0.26l-1.8,1.53l-2.47,-1.25l-2.26,0.36l-3.52,-1.39l-3.45,-0.02l-3.31,-2.23l-1.71,-0.49l2.09,-6.8l-0.29,-4.19l-0.28,-0.39l-0.46,0.16l-0.66,1.0l-0.65,-0.09l-3.24,-2.46l-0.48,-1.96l-0.07,-1.41l1.42,-3.28l0.84,-6.97l2.1,0.35l1.72,-0.69l4.51,-0.05l1.08,-0.27l1.09,-1.27l1.87,-1.1l0.29,-1.3l-0.63,-1.51l8.51,2.61l3.37,-0.07l1.39,-0.83l2.6,-3.5l0.24,-1.16l-0.19,-0.97l-1.99,-1.51l1.67,-1.09l1.03,0.24l1.24,0.92l4.28,5.65l1.28,0.97l1.61,0.37l2.45,-0.28l1.69,0.61l1.27,2.59l0.54,2.33l0.97,1.36l1.22,0.68l1.43,0.05l2.4,-0.82l0.67,0.11l0.51,0.36l0.63,1.74l0.74,1.04l1.49,0.83l1.64,-0.37l1.64,-1.45l1.47,-2.88l0.62,-3.31l-0.06,-2.06l-0.64,-3.32l0.44,-2.74l4.82,-13.83l2.68,-3.89l1.34,-3.47l0.14,-2.08l-0.52,-3.4l0.17,-1.2l1.41,-1.8l2.13,-1.65l0.61,-1.11l-0.53,-2.85l-2.0,-1.83l-0.49,-1.13l-0.02,-1.75l0.56,-2.78l6.04,-6.02l1.13,-4.03l0.39,-0.38l13.89,4.93l5.64,0.4l12.56,3.16l1.63,0.85l0.12,0.53l-0.46,0.61l-3.46,1.59l-2.61,2.89l-0.3,4.18l1.33,4.33l4.31,9.21l1.24,1.82l1.37,1.36l1.42,0.82l1.79,0.28l4.41,-0.37l2.31,0.29l4.59,1.54l4.7,3.03l2.95,4.25l1.06,5.11l-1.08,5.58l-2.67,6.93l-0.47,2.48l-0.18,4.64l-0.61,1.85l-1.63,1.61l-3.77,2.36l-5.01,1.59l-2.26,1.45l-1.11,2.64l0.62,2.29l1.87,1.31l2.43,0.46l4.02,-0.41l0.5,2.44l-0.08,2.7l-3.34,2.11l-3.03,2.45l-4.52,4.72l-0.98,1.63l-0.74,2.3l-0.43,2.45l0.02,2.67l0.9,1.84l2.54,0.65l2.56,2.63l0.93,0.25l1.52,-0.19l0.33,2.12l3.17,4.5l1.45,1.13l2.48,0.53l-0.63,0.9l-4.23,2.67l-1.2,2.27l1.71,3.73l-0.71,2.12l-2.07,0.07l-0.73,0.38l-0.11,2.49l0.8,1.94l-1.79,0.59l-0.65,0.52l-0.86,2.11l-0.51,2.51l0.16,2.6l1.55,3.05l-0.82,4.99l-0.18,3.43l1.55,7.39l-0.27,3.14l-1.27,2.88l-3.4,4.49l-3.3,3.2l-1.86,4.27l-0.96,0.49l-4.12,0.94l-3.53,3.16l-1.13,-0.06l-2.0,-1.31l-1.37,-0.01l-0.85,0.75l-1.96,3.06l-1.85,0.75l-5.58,1.3l-1.66,-0.01l-3.18,1.69l-2.64,5.67l-3.25,5.4l-5.57,1.73l-2.17,-1.04l-1.83,-2.06l-3.39,-6.24l0.32,-7.33l-0.56,-1.48l-2.28,-0.86l-3.88,-0.7l0.12,-0.81l-2.24,-3.62l-1.13,-1.01l-1.14,-0.2l-1.8,0.27l-0.74,-0.38l1.59,-2.04l0.51,-1.54l-0.43,-2.72l-0.63,-1.69l-2.75,-3.19l-0.42,-1.22l1.86,-7.93l1.05,-1.82l1.39,-0.89l1.41,-0.06l2.19,1.33l0.93,-0.42l0.03,-0.76l-2.33,-5.41l-0.75,-0.62l-1.81,-0.67l-0.63,-0.65l-5.0,-10.05l-0.27,-1.65l0.4,-0.95l0.89,-0.95l0.31,-1.04l-0.21,-1.06l-1.68,-3.4l-0.85,-0.91l-1.89,-1.17l-2.55,-1.19l-4.46,-0.79l-0.75,-0.63l-2.33,-3.99l-0.51,-6.15l0.66,-2.7l-0.85,-5.41l0.07,-3.5l0.36,-0.54l1.71,0.78l1.34,-0.76l0.94,-0.87l0.65,-1.25l0.23,-1.62l-0.37,-0.45l-1.44,-0.08l-1.55,-0.62l0.92,-0.47l0.1,-1.42l-1.44,-1.44l-2.09,-3.93l-1.01,-1.05l-1.42,-0.22l-0.37,0.25l-0.03,1.53Z",
      "อุบลราชธานี",
      0,
      Colors.black,
      3),
  "TH-37": MapData(
      "M840.27,487.64l-1.32,4.22l-6.16,6.23l-0.59,2.94l0.02,2.02l0.65,1.48l1.92,1.71l0.43,2.42l-1.0,1.23l-2.31,1.86l-0.82,1.34l-0.18,1.46l0.51,3.33l-0.11,1.86l-1.26,3.28l-2.73,3.99l-4.85,13.92l-0.47,2.99l0.7,5.34l-0.6,3.12l-1.37,2.65l-1.41,1.21l-1.19,0.23l-1.0,-0.64l-1.16,-2.54l-1.0,-0.75l-1.06,-0.13l-2.28,0.81l-1.25,-0.05l-0.86,-0.52l-0.75,-1.11l-1.18,-3.96l-0.84,-1.21l-0.94,-0.57l-1.18,-0.2l-2.54,0.28l-1.18,-0.26l-1.06,-0.78l-4.32,-5.69l-1.56,-1.14l-1.52,-0.26l-1.55,0.77l-0.63,0.75l0.2,1.1l1.77,1.07l-0.06,1.57l-2.42,3.21l-1.11,0.64l-2.89,0.04l-9.13,-2.8l-4.3,-1.73l-0.66,-0.73l0.08,-1.04l-0.51,-1.62l-0.82,-0.45l-0.95,0.07l-0.12,-0.27l-0.14,-1.89l0.28,-1.35l-0.33,-2.35l-0.44,-1.62l-1.29,-1.98l0.36,-1.47l0.0,-2.25l0.74,-1.37l0.51,-5.45l1.72,-2.46l0.11,-4.0l0.81,-3.72l4.03,-5.05l1.14,-3.75l2.5,-2.62l3.03,-7.32l1.34,-1.82l4.22,-2.72l6.32,-1.63l10.01,-1.39l3.88,-1.05l0.96,-1.08l0.37,-2.65l2.22,-0.16l5.65,-2.27l2.91,-2.51l5.45,-3.64l2.42,-2.82l2.64,1.71l1.11,2.0l0.35,2.3l-0.09,4.99l0.4,2.92l1.1,2.75l1.83,2.42l2.3,1.75l2.5,0.91Z",
      "อำนาจเจริญ",
      0,
      Colors.black,
      3),
  "TH-33": MapData(
      "M721.34,578.42l1.05,-0.65l0.76,-1.8l1.1,-0.83l0.59,-1.49l1.03,-0.83l3.1,-1.43l0.7,-1.37l0.0,-1.23l-0.91,-1.48l-0.99,-3.11l-1.34,-0.65l-6.42,-0.22l0.47,-1.24l3.77,-4.78l2.26,-1.75l3.39,-5.12l2.17,-1.13l0.69,-0.86l2.08,-1.35l1.59,3.49l0.64,3.32l2.51,2.55l8.64,12.16l2.25,1.15l2.31,1.76l1.65,0.56l3.26,0.1l1.39,0.54l2.13,1.43l1.6,0.01l0.45,0.49l0.48,1.87l0.77,0.88l3.66,1.06l3.45,2.29l3.54,0.04l3.54,1.4l2.21,-0.37l2.62,1.27l0.94,-0.32l1.72,-1.47l2.04,0.44l2.83,0.04l0.95,1.1l0.85,0.26l0.44,-0.39l-0.06,-1.44l0.67,0.07l0.82,0.83l2.1,3.94l1.33,1.21l0.07,0.63l-1.23,0.63l-0.06,0.67l1.15,0.86l2.34,0.37l-0.63,2.01l-0.85,0.78l-1.02,0.57l-1.42,-0.84l-0.52,0.1l-0.74,1.16l-0.08,3.75l0.85,5.32l-0.66,2.64l0.55,6.45l2.45,4.22l0.94,0.8l1.22,0.47l1.85,-0.03l1.52,0.42l2.46,1.15l2.48,1.83l1.75,4.01l-1.57,2.74l0.31,2.19l5.03,10.11l0.93,0.96l2.32,1.08l2.19,5.1l-0.29,0.17l-1.44,-1.08l-1.38,-0.27l-0.99,0.21l-1.69,1.12l-1.19,2.09l-1.89,8.23l0.58,1.62l2.68,3.07l0.93,3.24l-0.01,1.37l-1.84,2.25l-0.14,1.09l0.77,0.78l3.21,-0.12l0.93,0.81l2.11,3.41l-0.13,0.41l-1.49,-0.27l-3.4,-1.92l-3.86,0.2l-4.57,-2.87l-1.97,-0.24l-1.78,0.84l-3.18,2.5l-1.36,0.28l-0.48,-0.4l-0.53,-1.85l-1.09,-0.68l-1.41,0.53l-1.57,2.13l-1.62,0.07l-2.77,-1.14l-1.94,0.09l-1.83,1.09l-3.37,4.5l-1.97,0.81l-5.51,-1.48l-1.28,0.37l-2.05,1.49l-0.86,0.02l-1.45,-0.49l-12.29,-1.79l-5.83,-2.36l-2.69,-0.25l-3.29,2.05l-1.74,0.48l-1.06,-0.39l-0.5,-0.81l0.15,-1.0l-0.3,-0.66l-0.94,-0.03l-3.35,3.9l-0.66,0.32l-1.14,-0.03l-1.28,-1.19l-0.93,-0.36l-3.96,1.07l-2.41,1.17l1.67,-9.94l-1.31,-5.9l-0.45,-4.14l0.67,-2.26l1.1,-6.67l-0.02,-3.42l-0.52,-1.16l-4.57,-5.79l-0.76,-1.39l-0.05,-6.11l-0.92,-2.17l-1.0,-0.8l-3.07,-0.59l-3.68,-1.92l-1.15,-2.05l2.68,-6.9l1.16,-1.86l2.02,-2.15l0.79,-2.17l1.79,-1.4l0.57,-2.45l1.31,-1.23l0.6,-2.21l-0.17,-2.6l-1.08,-1.38l-1.42,-7.21l-0.51,-1.1l-1.36,-1.0l-0.45,-1.31l0.6,-3.56l1.0,-2.15l0.32,-1.48l-0.07,-0.79l-1.16,-2.19l1.55,-0.45l0.8,-1.32Z",
      "ศรีสะเกษ",
      0,
      Colors.black,
      3),
  "TH-97": MapData(
      "M699.43,292.16l-1.44,-0.45l-2.58,-2.57l0.07,-0.65l1.32,-0.78l0.41,-0.78l-0.47,-1.69l0.26,-1.15l-0.49,-0.82l-1.12,-0.6l0.08,-1.62l-0.87,-0.22l-1.0,0.86l-0.86,2.82l-1.27,-0.6l-2.38,-2.19l-2.07,-1.01l-2.44,-0.49l-0.15,-0.81l-0.55,-0.51l-2.38,-0.36l-1.13,-0.66l-0.48,-1.95l0.24,-0.47l1.66,-0.7l0.1,-0.95l-0.86,-0.56l-2.18,-0.35l-2.62,-3.0l-1.64,-0.23l-0.99,-0.85l-2.25,-1.12l-4.01,-0.19l-3.3,2.17l0.14,2.94l-1.28,1.8l-1.21,1.0l-1.85,0.23l-3.52,-2.94l-4.66,-2.78l-3.85,-3.8l-0.68,-4.23l1.52,-3.14l3.5,-2.18l1.09,-2.91l-1.47,-3.59l-3.25,-1.49l-3.18,-0.38l-0.87,-1.5l1.02,-2.11l-0.48,-3.09l-0.76,-1.02l-5.36,-3.43l-0.49,-0.93l-0.1,-0.9l1.05,-2.6l1.74,-2.17l2.29,-1.67l2.55,-1.1l9.57,-1.75l7.92,2.17l3.02,-0.19l2.73,0.67l2.8,0.26l6.23,1.66l3.37,2.49l6.28,2.82l1.55,0.41l6.28,0.34l3.6,0.91l3.22,1.9l2.97,3.92l1.75,0.36l1.08,-0.18l3.18,-3.51l1.99,-1.31l2.25,-0.57l2.48,0.25l2.54,1.3l1.94,2.08l5.36,9.32l4.6,11.27l1.26,2.21l1.53,1.85l6.99,6.38l-2.96,1.93l-4.52,-0.18l-0.8,0.33l-0.77,3.06l0.36,1.0l1.21,1.17l-0.19,2.99l0.41,2.0l-2.65,4.83l-0.83,-0.04l-2.77,-1.7l-0.54,-2.04l-1.39,-1.78l-0.45,-1.52l-0.55,-0.72l-1.55,-0.13l-3.17,1.42l-0.63,1.39l-0.49,2.76l-0.78,1.6l-0.03,0.7l0.3,0.94l2.17,3.03l0.2,0.87l-0.27,2.3l-1.37,0.63l-0.46,1.42l-1.22,0.48l-0.87,1.01l-1.33,-1.13l-1.9,-0.74l-0.38,-1.65l-1.5,-1.22l-0.16,-0.83l0.39,-2.26l-0.23,-1.05l-0.78,-0.34l-1.46,0.99l-0.25,-0.16l0.16,-1.59l0.51,-1.1l-0.37,-0.74l-1.1,-0.1l-1.22,0.44l-1.53,1.53l-0.37,-0.26l-0.49,-1.4l-0.64,-0.33l-2.17,1.08l-3.42,-0.28l-0.91,0.8l0.1,0.79l0.7,1.19Z",
      "บึงกาฬ",
      0,
      Colors.black,
      3),
  "TH-36": MapData(
      "M477.05,423.96l4.0,3.04l0.72,-0.07l3.31,-1.78l1.11,-0.13l1.75,0.27l6.4,2.57l4.78,0.16l1.31,1.59l1.12,3.41l0.79,1.18l0.98,0.79l2.71,0.99l3.68,4.75l2.65,1.7l9.3,0.12l1.81,0.33l1.54,-0.57l1.08,-0.0l3.89,1.69l1.97,2.09l1.07,0.6l2.14,0.55l1.48,1.11l2.46,0.5l2.86,-0.58l1.56,1.25l0.91,0.31l2.37,-0.6l0.38,-0.49l-0.09,-1.15l1.03,-0.0l1.0,3.06l3.72,2.46l0.04,0.73l-0.19,1.56l-2.0,6.87l-1.44,3.25l-1.49,5.39l-3.26,5.07l-2.67,3.08l-2.26,4.36l-3.99,4.16l-2.8,2.09l-0.15,0.59l0.16,0.72l1.46,2.01l1.95,1.22l5.24,2.06l2.45,2.18l1.87,0.67l0.35,0.62l-0.95,0.91l-1.36,5.28l0.2,0.82l-2.08,3.39l-0.32,1.08l-1.56,1.94l-0.35,1.7l0.56,3.56l-0.4,0.86l-0.84,-0.06l-1.67,0.58l-3.38,1.91l-2.62,2.63l-1.29,0.88l-1.59,0.2l-0.68,-1.27l-0.44,-0.2l-0.34,0.77l-0.6,0.19l0.39,0.82l-0.69,0.36l-2.91,-0.07l-1.88,1.0l-0.19,0.43l0.23,1.08l-0.32,0.8l-1.39,1.82l0.01,2.13l-1.32,0.65l-1.55,3.1l-3.34,2.78l-0.62,-1.06l-4.08,-3.01l-0.58,0.11l-3.92,7.27l-4.43,3.06l-0.83,1.5l-0.53,2.07l0.04,1.04l1.27,3.84l0.11,1.71l-4.76,2.55l-1.9,1.94l-1.07,2.21l-0.97,3.44l-1.86,0.01l-2.92,-0.93l-3.86,0.97l-1.66,0.67l-6.71,3.86l-4.25,1.83l-5.14,1.45l-4.27,4.03l-3.64,2.29l-15.0,4.22l-1.98,0.14l-0.83,-0.62l-1.83,-3.77l-1.2,-1.59l-7.07,-3.51l4.18,-4.66l3.38,-7.57l0.29,-5.34l-0.13,-4.33l-0.94,-6.29l0.47,-4.69l0.76,-3.92l1.69,-4.94l0.37,-2.12l-0.47,-1.4l-0.59,-0.67l-3.28,-0.66l-2.34,-2.1l-0.47,-1.34l-0.31,-10.84l0.75,-1.15l2.5,-2.0l0.46,-0.72l1.33,-4.92l1.23,-3.06l-0.15,-0.76l-0.68,-0.63l-2.98,-0.73l-0.79,-0.49l-1.01,-2.07l-0.42,-1.74l-0.55,-6.62l2.35,-11.22l-0.18,-2.72l1.57,-2.06l0.8,-1.68l-0.21,-1.15l-1.69,-1.67l1.48,-2.39l1.8,-8.38l2.5,-2.85l0.04,-2.45l4.31,-3.96l1.04,-2.01l1.33,-1.7l0.48,-1.53l-0.49,-2.16l0.1,-0.81l4.3,-2.82l0.88,-1.06l-0.12,-1.11l-1.33,-1.22l-0.23,-1.4l0.28,-3.5l1.35,-0.88l0.63,-1.61l-0.91,-2.24l0.09,-2.03l1.31,-0.52l2.44,1.09l1.04,-0.04l2.14,-2.12l2.35,-1.44l1.87,1.72l1.26,0.54l3.5,-0.53l3.28,0.52l2.22,2.29l1.5,0.9l0.87,-0.18l0.79,-0.87l1.13,-0.56Z",
      "ชัยภูมิ",
      0,
      Colors.black,
      3),
  "TH-31": MapData(
      "M552.57,626.46l3.66,1.55l1.36,2.02l1.07,0.78l2.99,0.24l4.28,-1.04l0.77,-0.9l0.3,-1.58l-2.43,-4.45l-0.63,-2.58l1.17,-3.51l-0.03,-0.86l-0.56,-0.72l-2.75,-1.57l-0.62,-0.75l0.89,-0.02l3.95,1.15l3.59,1.64l1.79,0.4l5.68,-0.24l3.89,-1.27l5.26,-3.76l1.74,-4.76l1.5,-2.2l0.06,-1.3l-0.44,-1.64l1.5,-1.36l3.77,-4.83l2.59,-2.49l6.87,-3.02l2.4,0.73l2.96,-0.72l1.89,-1.58l0.22,-1.1l-0.93,-1.66l-0.18,-4.51l0.5,-3.39l-0.52,-1.98l0.05,-2.55l0.33,-0.87l2.09,-0.99l0.44,-1.28l-0.34,-0.63l-0.95,-0.59l-3.38,-0.77l-0.52,-1.1l2.26,-4.45l1.02,0.74l0.95,0.11l0.93,-1.11l1.67,-1.17l0.21,-0.89l-0.67,-1.39l-1.18,-1.48l-1.06,-0.54l-3.11,0.13l-0.71,-1.2l-1.12,-0.7l-0.65,-1.49l-2.54,-1.06l-3.18,-0.1l-2.61,0.76l-1.67,-0.44l-1.79,0.25l-2.1,-2.09l-1.38,-1.78l-0.24,-0.89l-0.08,-3.25l-0.66,-5.05l1.27,0.96l1.88,0.37l4.01,-1.13l1.32,-0.75l1.16,-1.93l1.11,-3.55l0.36,-7.64l0.81,-1.64l1.34,-0.92l3.2,-1.04l2.21,2.61l2.07,1.27l2.22,2.88l0.22,2.59l-3.32,2.47l-0.35,0.64l0.18,0.8l5.12,5.59l2.38,1.59l0.81,3.04l1.55,1.53l2.08,1.4l0.14,1.77l-1.0,0.93l-0.06,1.46l0.86,1.14l2.94,2.08l-0.59,2.99l-1.01,1.59l0.24,1.26l1.95,1.79l1.39,-0.37l0.4,0.45l0.74,0.0l0.4,-0.76l0.27,1.49l1.44,2.77l0.46,1.58l0.47,0.28l2.33,-0.5l1.18,1.26l0.87,1.52l1.9,0.0l0.54,1.36l1.92,1.02l0.48,1.16l0.62,0.16l1.26,-1.02l0.74,0.09l1.62,0.98l1.34,-0.35l1.41,-1.67l1.79,-0.69l2.27,-1.48l1.2,-0.29l2.59,1.29l1.39,-0.55l0.33,0.53l-0.59,0.5l-0.01,0.6l1.29,1.03l2.16,-0.23l1.2,-2.09l2.38,0.99l0.8,1.43l0.73,0.58l1.64,0.5l-0.11,1.99l-1.78,4.19l-1.99,1.37l-1.92,5.86l0.52,8.72l1.09,2.79l-0.77,2.62l1.24,1.97l0.23,0.93l-0.24,0.69l-1.94,1.39l-0.63,1.27l0.35,7.6l-0.83,1.21l-1.76,1.34l-2.47,4.65l-3.77,3.19l-1.96,1.15l-1.82,1.76l-1.28,0.76l-1.78,2.88l-1.07,1.0l-0.32,1.41l0.31,2.4l-1.58,6.45l-2.1,4.08l-0.64,2.89l-1.73,2.03l-0.23,7.25l0.73,3.72l1.22,2.59l0.89,2.9l-0.26,1.42l-1.26,3.08l0.33,2.25l-0.6,2.06l0.24,2.85l-4.49,1.38l-6.58,0.98l-2.26,0.75l-3.58,1.93l-8.73,7.44l-1.78,1.04l-3.95,1.13l-2.0,0.95l-1.68,1.71l-0.62,2.22l-3.83,1.04l-6.12,-1.13l-2.79,0.78l-1.02,0.8l-2.03,0.8l-5.52,1.26l-6.51,-0.4l-2.6,-1.82l-0.69,0.13l-1.25,1.6l-1.54,-1.17l-0.89,-5.04l0.03,-1.56l2.82,-5.62l0.57,-1.47l-0.0,-1.29l-0.48,-0.55l-1.03,-0.42l-0.24,-0.46l-0.86,-5.66l-1.87,-2.37l0.55,-3.91l-1.01,-3.29l-1.46,-2.3l-4.77,-3.85l-1.19,-2.17l-1.82,-5.18l-0.16,-1.4l2.43,-6.41l0.22,-2.68l-2.01,-4.14l-0.92,-2.89l0.02,-3.96l-1.98,-2.51l-2.26,-7.62Z",
      "บุรีรัมย์",
      0,
      Colors.black,
      3),
  "TH-94": MapData(
      "M473.44,1533.56l-3.05,-0.02l-0.9,-0.3l-1.2,-1.88l-0.18,-1.78l-0.55,-0.84l-2.24,-1.18l-1.52,0.49l-1.44,-0.39l-2.91,0.79l-1.1,1.27l0.15,1.41l2.56,1.92l0.15,0.65l-0.62,1.94l-2.3,0.97l-1.49,0.23l-1.24,-0.67l-2.91,-4.4l-1.26,-0.67l-1.56,0.34l-4.17,2.52l-4.03,-0.2l-5.49,1.06l-3.75,1.32l-1.17,-1.03l-2.11,-3.67l0.3,-2.85l-0.77,-3.13l-0.04,-2.54l-0.65,-0.51l-0.62,0.12l-1.05,1.03l-1.51,3.17l-1.0,1.29l-2.9,2.42l-2.73,0.79l-3.86,-0.68l-1.36,0.11l-1.34,-0.71l-2.56,-2.19l-6.19,-2.76l-1.09,-5.99l-1.48,-2.53l0.28,-6.93l0.85,-1.98l1.92,-3.08l0.12,-1.11l13.17,-0.48l4.35,-2.01l1.42,-2.29l3.25,0.56l1.42,1.18l2.82,1.0l3.89,0.06l0.4,-0.54l-0.84,-2.2l-1.7,-2.45l-6.32,-2.66l2.05,-0.69l2.95,0.54l2.77,2.22l4.18,2.55l3.82,1.22l7.34,1.73l7.46,3.94l0.89,0.96l11.04,18.87l5.66,8.68Z",
      "ปัตตานี",
      0,
      Colors.black,
      6),
  "TH-30": MapData(
      "M527.68,525.72l0.58,0.54l2.14,-0.31l1.46,-1.01l2.52,-2.56l3.23,-1.84l1.55,-0.54l0.66,0.08l1.79,2.71l2.19,1.84l0.06,2.94l0.46,0.65l2.97,1.64l2.12,2.22l0.63,0.3l2.11,-0.31l2.09,-1.14l4.97,-0.88l9.52,1.28l1.86,-1.4l5.68,0.94l3.16,-1.07l0.62,2.19l1.94,2.85l1.14,0.69l3.29,0.65l2.88,2.23l0.97,10.11l3.31,4.18l0.87,0.48l1.89,-0.24l1.72,0.44l1.33,-0.16l1.39,-0.61l2.84,0.08l2.32,0.97l0.42,1.24l1.21,0.81l0.91,1.35l2.74,-0.16l1.32,0.48l1.56,2.44l-1.59,1.25l-0.64,0.93l-1.51,-0.89l-0.85,0.28l-2.45,4.91l0.45,1.42l0.46,0.47l3.49,0.83l0.81,0.65l-0.17,0.5l-2.12,1.02l-0.58,1.39l-0.05,2.7l0.52,1.91l-0.5,3.33l0.18,4.61l0.94,1.96l-0.76,1.03l-0.8,0.53l-2.71,0.68l-1.64,-0.71l-1.03,0.03l-7.14,3.17l-2.64,2.53l-3.81,4.88l-1.61,1.5l-0.12,0.77l0.5,1.38l-0.04,0.94l-1.43,2.03l-1.72,4.72l-4.91,3.46l-3.64,1.2l-5.52,0.24l-3.03,-0.9l-2.16,-1.1l-4.02,-1.17l-1.04,-0.06l-0.66,0.33l-0.18,0.9l0.52,0.69l3.45,2.25l-1.13,3.31l0.0,1.58l0.64,2.11l2.29,3.91l0.08,0.78l-0.75,1.27l-3.85,0.89l-2.71,-0.21l-2.23,-2.71l-2.75,-0.96l-1.55,-1.26l-0.45,-0.11l-0.25,0.39l0.26,2.06l2.17,6.94l1.98,2.51l-0.07,3.75l0.96,3.04l1.97,3.99l-0.18,2.31l-2.45,6.48l0.18,1.81l1.84,5.23l1.3,2.38l4.86,3.95l1.28,2.06l0.93,2.98l-0.62,3.04l0.11,1.09l1.89,2.43l0.87,5.69l0.56,0.83l1.14,0.5l-0.01,0.94l-0.51,1.27l-2.88,5.85l-0.03,1.74l0.88,4.97l-2.62,2.07l-3.2,1.05l-0.45,1.21l0.14,0.71l1.66,0.88l-1.18,0.52l-2.18,0.17l-1.12,-0.66l-0.45,-1.13l0.06,-2.95l-0.84,-1.27l-1.15,-0.23l-3.0,0.32l-2.99,-1.62l-0.82,0.06l-2.29,1.0l-4.51,-1.13l-4.73,1.18l-1.44,1.77l-0.96,0.24l-2.24,-1.3l-3.67,0.03l-0.86,-0.28l-0.65,-0.87l-0.25,-1.79l-2.16,-1.97l-0.69,-0.25l-1.66,0.39l-1.08,0.77l-0.64,1.53l0.21,2.01l-0.75,0.68l-2.43,-0.26l-5.53,-2.06l-5.45,-4.66l-4.36,-2.83l-3.45,-2.97l-0.47,-1.44l-0.9,-1.19l-0.17,-0.91l3.73,-5.8l0.39,-1.4l-0.51,-1.72l-2.1,-1.38l-1.09,-0.1l-2.14,1.81l-0.78,0.12l-0.84,-0.57l-2.33,-2.9l-1.08,-0.14l-0.81,0.59l-0.94,1.9l-0.87,0.73l-3.7,0.81l-3.55,-0.2l-1.69,0.92l-2.13,0.38l-0.65,0.76l-0.07,2.13l-0.23,0.46l-0.45,-0.01l-1.46,-1.16l-2.72,-3.39l-4.65,-3.56l-1.04,-1.53l-1.85,-1.18l-0.89,-1.21l-1.34,-0.68l-3.1,-0.34l-5.49,0.83l-2.52,-0.75l-1.15,-0.79l-1.37,-1.74l-1.33,-0.5l-1.97,0.78l-1.63,1.32l-1.36,1.81l-2.97,0.12l-9.27,-5.61l-1.47,-1.76l-3.07,-1.27l-1.16,0.44l-1.35,2.57l-1.63,-0.41l-2.25,-2.33l-1.35,-2.23l-2.03,-1.47l-0.22,-0.49l0.37,-1.4l1.81,-3.07l-1.5,-18.74l2.14,0.53l1.69,1.14l1.43,0.14l3.05,1.01l0.72,-0.1l0.84,-1.22l1.31,-0.4l1.33,-1.34l2.4,-1.26l1.75,-4.27l3.13,-1.37l1.32,-1.22l1.81,-0.74l4.11,-2.54l0.86,-0.83l0.37,-1.24l-0.19,-4.41l-5.11,-10.4l-1.06,-3.64l-1.12,-1.71l-1.01,-1.06l-2.15,-0.06l-2.26,-0.67l-2.9,-1.87l-3.05,-0.04l-0.29,-3.01l0.34,-8.95l-0.22,-4.54l2.12,-3.92l0.25,-2.43l6.85,3.39l0.98,1.34l0.92,2.34l1.58,2.09l0.75,0.36l2.2,-0.15l15.22,-4.28l3.8,-2.4l4.13,-3.93l5.07,-1.42l4.3,-1.85l8.32,-4.51l3.62,-0.92l2.72,0.92l2.1,0.09l0.79,-0.78l0.62,-2.52l1.04,-2.49l1.08,-1.32l0.75,-0.68l4.36,-2.18l0.72,-0.71l0.13,-1.44l-1.44,-4.53l0.44,-2.74l0.65,-1.21l2.74,-1.66l1.78,-1.51l3.73,-6.95l3.66,2.7l0.69,1.25l0.59,0.13l3.8,-3.13l1.53,-3.06l0.9,-0.23l0.57,-0.61l0.06,-2.28l1.35,-1.72l0.39,-0.97l-0.17,-1.14l1.32,-0.75l3.1,0.03l1.23,-0.65l0.09,-0.5Z",
      "นครราชสีมา",
      0,
      Colors.black,
      3),
};
