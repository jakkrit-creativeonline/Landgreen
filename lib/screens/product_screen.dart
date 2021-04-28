import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var client = http.Client();
  List productList = [];
  Future<bool> isLoaded;

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  Future getData() async {
    isLoaded = Future.value();
    productList = await Sqlite().rawQuery('''SELECT * FROM PRODUCT
        WHERE Category_id IN(1,2) and Product_display = 1
        ORDER BY Category_id
        ''');
    isLoaded = Future.value(true);
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (!isConnect) {
      showNoInternet();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text('แคตตาล็อกสินค้า'),
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
              onRefresh: getData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FutureBuilder(
                        future: isLoaded,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (productList.length > 0) {
                              return ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: productList.length - 1,
                                itemBuilder: (context, index) {
                                  var obj = productList[index];
                                  print(obj);
                                  return Card(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: (obj['Image'] != null &&
                                                      obj['Image'] != 'null' &&
                                                      obj['Image'] != "")
                                                  ? CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              ShimmerLoading(
                                                        type: 'imageSquare',
                                                      ),
                                                      imageUrl:
                                                          'https://landgreen.ml/system/storage/app/${obj['Image']}',
                                                      errorWidget: (context,
                                                          url, error) {
                                                        // print(rank);
                                                        // print(error);

                                                        return Image.asset(
                                                            'assets/avatar.png');
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/avatar.png'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${obj['Name']}',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'รายละเอียด',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${obj['Detail']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                (obj['Price_display'] == 1)
                                                    ? Text(
                                                        'ราคา ${obj['Price_sell']} บาท',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      )
                                                    : Text(
                                                        '',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Card(
                                child: Column(
                                  children: [
                                    Text(
                                      'ไม่ผบข้อมูลรายการสินค้า',
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            return ShimmerLoading(
                              type: 'boxItem',
                            );
                          }
                        },
                      ),
                    ),
                  ),
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

  showNoInternet() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contexts) {
        return AlertDialog(
          title: Center(child: Text('แจ้งเตือน !!! ')),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'หน้าแคตตาล็อกสินค้า ต้องใช้อินเทอร์เน็ตดึงข้อมูลรูปภาพนะครับ\nรบกวนต้องอยู่ในที่ ที่มีสัญญาณอินเทอร์เน็ต\nถึงจะใช้งานได้ครับ',
                textAlign: TextAlign.center,
              ),
              FlatButton(
                  color: kPrimaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'ok',
                    style: TextStyle(color: btTextColor),
                  ))
            ],
          ),
        );
      },
    );
  }
}
