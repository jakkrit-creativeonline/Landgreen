import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:touchable/touchable.dart';

class CeoMapDetail extends StatefulWidget {
  final List<MapData> mapData;
  final List showData;

  const CeoMapDetail({Key key, this.mapData, this.showData}) : super(key: key);

  @override
  _CeoMapDetailState createState() => _CeoMapDetailState();
}

enum CanvasState { pan, draw }

class _CeoMapDetailState extends State<CeoMapDetail> {
  int selectedReport = 0;
  CanvasState canvasState = CanvasState.draw;
  double top = 10.0, left = 20.0, h = 680.0, scale = 0.4;
  List showDataTemp = [];
  List<MapData> mapDataTemp = [];
  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  FormatMethod f = FormatMethod();

  onSelectChange(val) {
    selectedReport = val;
    switch (val) {
      case 1:
        top = 10.0;
        left = 10.0;
        h = 360.0;
        scale = 0.9;
        break;
      case 2:
        top = -280.0;
        left = -120.0;
        h = 550.0;
        scale = 1.0;
        break;
      case 3:
        top = -150.0;
        left = -250.0;
        h = 360.0;
        scale = 0.7;
        break;
      case 4:
        top = -200.0;
        left = 80.0;
        h = 550.0;
        scale = 0.7;
        break;
      case 5:
        top = -650.0;
        left = -260.0;
        h = 360.0;
        scale = 1.0;
        break;
      case 6:
        top = -720.0;
        left = 30.0;
        h = 480.0;
        scale = 0.7;
        break;
      default:
        top = 10.0;
        left = 20.0;
        h = 680.0;
        scale = 0.4;
    }
    sortData(val);
    setState(() {});
  }

  sortData(val) {
    if (val != 0) {
      showDataTemp =
          widget.showData.where((element) => element['GEO_ID'] == val).toList();
      showDataTemp.sort(
          (a, b) => b['sum_count_product_cat1'] - a['sum_count_product_cat1']);
    } else {
      showDataTemp = widget.showData;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    showDataTemp = widget.showData;
    mapDataTemp = widget.mapData;
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
              // floatingActionButton: FloatingActionButton(
              //   child: Text(
              //     canvasState == CanvasState.draw ? "Draw" : "Pan",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   backgroundColor:
              //       canvasState == CanvasState.draw ? Colors.red : Colors.blue,
              //   onPressed: () {
              //     canvasState = canvasState == CanvasState.draw
              //         ? CanvasState.pan
              //         : CanvasState.draw;
              //     setState(() {});
              //   },
              // ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
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
                                    child: Icon(FontAwesomeIcons.mapMarkedAlt,color: btTextColor,),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Heatmap',style: TextStyle(fontSize: 24.0,height: 1),),
                                      Text('รายงานยอดขายแยกตามภูมิภาค',style: TextStyle(fontSize: 16.0,height: 1),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropDown(
                            items: optionReport,
                            value: selectedReport,
                            hintText: '',
                            onChange: (val) => onSelectChange(val),
                            fromPage: 'ceo_dashboard',
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: size.width,
                              height: h,
                              //color: kPrimaryColor,
                              child: Stack(
                                // alignment: Alignment.topCenter,
                                // fit: StackFit.loose,
                                children: [
                                  Positioned(
                                    top: top,
                                    left: left,
                                    child: CanvasTouchDetector(
                                      builder: (context) => CustomPaint(
                                        size: size,
                                        painter: PathTestPainter(
                                          context,
                                          geo: selectedReport,
                                          paths: widget.mapData,
                                          scale: scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          HeaderText(text:'ข้อมูลสถิติยอดขายแต่ละจังหวัด',textSize: 20,gHeight: 26,),
                          GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              itemCount: showDataTemp.length,
                              primary: false,
                              shrinkWrap: true,
                              itemBuilder: (bc, i) {
                                var result = showDataTemp[i];
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
                          // ListView.builder(
                          //     itemCount: showDataTemp.length,
                          //     primary: false,
                          //     shrinkWrap: true,
                          //     itemBuilder: (bc, i) {
                          //       var result = showDataTemp[i];
                          //       return Card(
                          //         child: Column(
                          //           children: [
                          //             Text('อันดับ ${i + 1}'),
                          //             Text('จังหวัด${result['PROVINCE_NAME']}'),
                          //             Text(
                          //                 'เงินสด ${result['cash_count_product_cat1']} กระสอบ'),
                          //             Text(
                          //                 'เครดิต ${result['credit_count_product_cat1']} กระสอบ'),
                          //             Text(
                          //                 'รวม ${result['sum_count_product_cat1']} กระสอบ'),
                          //           ],
                          //         ),
                          //       );
                          //     })

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Footer(),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

const List<DropdownMenuItem> optionReport = [

  DropdownMenuItem(value: 0, child: Center(child: Text('ทั่วประเทศ',style: TextStyle(fontSize: 18),))),
  DropdownMenuItem(value: 2, child: Center(child: Text('ภาคกลาง',style: TextStyle(fontSize: 18)))),
  DropdownMenuItem(value: 1, child: Center(child: Text('ภาคเหนือ',style: TextStyle(fontSize: 18)))),
  DropdownMenuItem(value: 3, child: Center(child: Text('ภาคอีสาน',style: TextStyle(fontSize: 18)))),
  DropdownMenuItem(value: 5, child: Center(child: Text('ภาคตะวันออก',style: TextStyle(fontSize: 18)))),
  DropdownMenuItem(value: 4, child: Center(child: Text('ภาคตะวันตก',style: TextStyle(fontSize: 18)))),
  DropdownMenuItem(value: 6, child: Center(child: Text('ภาคใต้',style: TextStyle(fontSize: 18))))
];

class PathTestPainter extends CustomPainter {
  final BuildContext context;
  final List<MapData> paths;
  final int geo;
  final double scale;

  PathTestPainter(this.context, {this.paths, this.geo, this.scale});

  @override
  bool shouldRepaint(PathTestPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    //Main paint
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    //Background paint
    Paint background = Paint()..color = Colors.white;

    //Define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    //canvas.drawRect(rect, background);
    //canvas.clipRect(rect);

    //a single line is defined as a series of points followed by a null at the end
    // for (int x = 0; x < points.length - 1; x++) {
    //   //drawing line between the points to form a continuous line
    //   if (points[x] != null && points[x + 1] != null) {
    //     canvas.drawLine(points[x] + offset, points[x + 1] + offset, paint);
    //   }
    //   //if next point is null, means the line ends here
    //   else if (points[x] != null && points[x + 1] == null) {
    //     canvas.drawPoints(PointMode.points, [points[x] + offset], paint);
    //   }
    // }

    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.pink), text: 'อันดับ 1');
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();

    // canvas.scale(0.4);
    // Path path = parseSvgPathData(paths[0].path);
    // var pathRect = path.getBounds();
    // var rectCenter = pathRect.center;
    //canvas.drawRect(pathRect, paint);
    //paint.color = Colors.white;
    // canvas.drawPath(path, paint);
    // paint.color = Colors.pink;
    // tp.paint(canvas, rectCenter + Offset(-25, 0));
    // paint.color = Colors.black;

    // canvas.drawLine(rectCenter + Offset(-20, 0) + offset,
    //     rectCenter + Offset(20, 0) + offset, paint);

    var myCanvas = TouchyCanvas(context, canvas);

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(scale);
    // path = parseSvgPathData(paths[6].path);
    // pathRect = path.getBounds();
    // rectCenter = pathRect.center;
    // path.transform(matrix4.storage);
    //canvas.drawRect(pathRect, paint);
    //paint.color = Colors.white;
    // canvas.drawPath(path, paint);
    // paint.color = Colors.pink;
    // tp.paint(canvas, rectCenter + Offset(-25, -20));
    // paint.color = Colors.black;

    List<Offset> itemOffset = [];
    int i = 0;
    if (geo == 0) {
      paths.forEach((element) {
        Path path = parseSvgPathData(element.path);
        if (i < 5) {
          var pathRect = path.transform(matrix4.storage).getBounds();
          var rectCenter = pathRect.center;
          itemOffset.add(rectCenter);
        }
        paint.color = element.color;
        // var bbox = path.transform(matrix4.storage).getBounds();
        // myCanvas.drawRect(bbox, background);
        myCanvas.drawPath(path.transform(matrix4.storage), paint,
            onTapDown: (detail) {
          showDetail(context, element);
        });
        i++;
      });
    } else {
      paths.forEach((element) {
        if (geo == element.geo) {
          Path path = parseSvgPathData(element.path);
          if (i < 5) {
            var pathRect = path.transform(matrix4.storage).getBounds();
            var rectCenter = pathRect.center;
            itemOffset.add(rectCenter);
          }
          paint.color = element.color;
          // var bbox = path.transform(matrix4.storage).getBounds();
          // myCanvas.drawRect(bbox, background);
          myCanvas.drawPath(path.transform(matrix4.storage), paint,
              onTapDown: (detail) {
            showDetail(context, element);
          });
          i++;
        }
      });
    }

    for (int i = 0; i < itemOffset.length; i++) {
      TextSpan span = new TextSpan(
          style: new TextStyle(fontSize: 14, color: darkColor),
          text: 'อันดับ ${i + 1}');
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, itemOffset[i] + Offset(-25, -10));
    }
  }

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
}
