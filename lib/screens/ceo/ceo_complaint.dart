import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:http/http.dart' as http;

class CEOComplaint extends StatefulWidget {
  @override
  _CEOComplaintState createState() => _CEOComplaintState();
}

class _CEOComplaintState extends State<CEOComplaint> {

  FormatMethod f = FormatMethod();
  Future<List> _listData;

  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  String selectedMonth = '';
  String startDate ='';
  String endDate='';

  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();


  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async{

    var res = await Sqlite().getJson('CEO_COMPLAINT', 'CCP');
    _listData = Future.value();
    if (res != null) {
      List data = jsonDecode(res['JSON_VALUE']);
      _listData = Future.value(data);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        try {
          AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
          var res = await http.post('$apiPath-complaint',
              body: {
                'func': 'display_list_complaint',
              }
          );
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('CEO_COMPLAINT', 'CCP', res.body);
            List data = jsonDecode(res.body);
            _listData = Future.value(data);
            // return data;
          }
          Navigator.pop(context);
        } catch (e) {
          print('error $e');
          Navigator.pop(context);
          _listData = Future.value([]);
        }

      }
    }

    setState(() {});

  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      _listData = Future.value();
      try {
        AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        var res = await http.post('$apiPath-complaint',
            body: {
              'func': 'display_list_complaint',
            }
        );
        if (res.statusCode == 200) {
          print('online');
          Sqlite().insertJson('CEO_COMPLAINT', 'CCP', res.body);
          List data = jsonDecode(res.body);
          _listData = Future.value(data);
          // return data;
        }
        Navigator.pop(context);
      } catch (e) {
        print('error $e');
        _listData = Future.value([]);
        Navigator.pop(context);
      }


      setState(() {});
    }
  }




  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
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
                                child: Icon(FontAwesomeIcons.comments,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายการเรื่องร้องเรียน',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('ระบบจะไม่ทำการเก็บประวัติว่าผู้ใดเป็นคนแจ้ง',style: TextStyle(fontSize: 16.0,height: 1),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FutureBuilder(
                          future: _listData,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              List data = snapshot.data.toList();
                              return Container(
                                height: _size.height*0.74,
                                child: ListView.builder(
                                  primary: true,
                                  shrinkWrap: false,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          HeaderText(text:'${index+1}.',textSize: 20,gHeight: 26,),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex:1,
                                                      child: Text('หัวข้อ :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    ),
                                                    if(data[index]['Title'] != null)
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text('${data[index]['Title']}',style: _baseFontStyle,),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex:1,
                                                      child: Text('รายละเอียด :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    ),
                                                    if(data[index]['Detail'] != null)
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text('${data[index]['Detail']}',style: _baseFontStyle,),
                                                      ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex:1,
                                                      child: Text('วันที่แจ้ง :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    ),
                                                    if(data[index]['Timestamp'] != null)
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text('${f.ThaiDateTimeFormat(data[index]['Timestamp'])}',style: _baseFontStyle,),
                                                      ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex:1,
                                                      child: Text('ไฟล์แนบ :',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    ),
                                                    if(data[index]['File'] != null && data[index]['File'] !='null')
                                                      Expanded(
                                                        flex: 5,
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            maxHeight: 100,
                                                            maxWidth: 100,
                                                          ),
                                                          child: (data[index]['File'] != null && data[index]['File'] !='null')?
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                                return ImageFullScreen(urlImg: '$storagePath${data[index]['File']}',index: index,);
                                                              }));
                                                            },
                                                            child: Hero(
                                                              tag: "imgHero${index}",
                                                              child: CachedNetworkImage(
                                                                progressIndicatorBuilder: (context, url, progress) {
                                                                  return LinearProgressIndicator(
                                                                    value: progress.progress,
                                                                  );
                                                                },
                                                                imageUrl: '$storagePath${data[index]['File']}',
                                                                errorWidget: (context, url, error) {
                                                                  return Container(child: Text(''),);
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                              :Center(child: Text(''),),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }else{
                              return ShimmerLoading(type: 'boxText',);
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
        )
    );
  }
}

class ImageFullScreen extends StatelessWidget {
  final String urlImg;
  final int index;
  const ImageFullScreen({Key key,this.urlImg,this.index}) :super(key: key);
  @override
  Widget build(BuildContext context) {
    print('urlImg ${urlImg}');
    return Scaffold(
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(
          child: Hero(
            tag: "imgHero${index}",
            child: CachedNetworkImage(
              progressIndicatorBuilder: (context, url, progress) {
                return LinearProgressIndicator(
                  value: progress.progress,
                );
              },
              imageUrl: '$urlImg',
              errorWidget: (context, url, error) {
                return Container(child: Text('ไม่มีรูป'),);
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(

        onPressed: () async {
          Navigator.pop(context);
        },
        child: Icon(Icons.close, color: Colors.white),
      ),
    );
  }
}