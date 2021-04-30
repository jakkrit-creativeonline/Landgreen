import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CeoRanking extends StatefulWidget {
  @override
  _CeoRankingState createState() => _CeoRankingState();
}

class _CeoRankingState extends State<CeoRanking> {
  var client = Client();
  List saleRankData = [];
  int lastRank;
  GetReport s = GetReport();

  Future getCache() async {
    var res = await Sqlite().getJson('CEO_SALE_RANKINKG', 'CEO_SALE_RANKINKG');
    if (res != null) {
      var data = jsonDecode(res['JSON_VALUE']);
      saleRankData.addAll(data);
    } else {
      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        saleRankData = await s.getCeoSaleRanking();
      }
    }
    //print(saleRankData);
    setState(() {});
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
    return Padding(
      padding: const EdgeInsets.only(left: 20,right: 20,top: 10),
      child: Card(
        color: Color(0xFF252E3A),
        child: Column(
          children: [
            HeaderText(text:'อันดับพนักงานขายที่มีผลงานยอดเยี่ยม',textSize: 20,gHeight: 26,),
            Column(
              children: showSaleRank(),
            ),
            SizedBox(height: 20,),

            InkWell(
              onTap: (){
                locator<NavigationService>().navigateTo(
                    'showRankAll',
                    ScreenArguments(
                    )
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: grayFontColor,
                ),
                width: size.width*0.8,
                height: 45,
                child: Center(
                  child: Text('ดูข้อมูลเพิ่มเติมคลิ๊ก',style: TextStyle(fontSize: 25,color: whiteFontColor),),
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  List<CeoRankingCard> showSaleRank() {
    return List.generate(saleRankData.length, (index) {
      var item = saleRankData[index];
      return CeoRankingCard(
        rank: item['rank'],
        username: item['sale_username'],
        name: item['sale_name'],
        surname: item['sale_surname'],
        plateNumber: item['sale_car_plate_number'],
        goal: item['sale_goal'],
        sumProduct: item['sumcountcat'],
        saleId: item['sale_id'],
        avatar: item['sale_Image'],
      );
    });
  }
}

class CeoRankingCard extends StatelessWidget {
  final int rank;
  final String username;
  final String name;
  final String surname;
  final String plateNumber;
  final int goal;
  final int sumProduct;
  final int saleId;
  final String avatar;

  const CeoRankingCard(
      {Key key,
      this.rank = 0,
      this.username = '',
      this.name = '',
      this.surname = '',
      this.plateNumber = '',
      this.goal = 0,
      this.sumProduct = 0,
      this.saleId = 0,
      this.avatar = ''})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    FormatMethod f = FormatMethod();
    List<TeamGoal> data = [
      new TeamGoal(
          charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sumProduct)
    ];
    if (goal > sumProduct) {
      data.add(new TeamGoal(charts.ColorUtil.fromDartColor(ltFontColor), 'goal',
          goal - sumProduct));
    } else {
      data.add(
          new TeamGoal(charts.ColorUtil.fromDartColor(ltFontColor), 'goal', 0));
    }
    List<charts.Series<TeamGoal, String>> series = [
      new charts.Series(
        id: 'sale$rank',
        data: data,
        domainFn: (TeamGoal sale, _) => sale.text,
        measureFn: (TeamGoal sale, _) => sale.total,
        colorFn: (TeamGoal sale, _) => sale.color,
      )
    ];
    Size size = MediaQuery.of(context).size;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 150,
              child: Stack(
                overflow: Overflow.visible,
                children: [
                    Positioned(
                      left: 55,
                      top: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          color: Color(0xFFEAEEF6),
                          width: size.width*0.6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment(1.1, 0.0),
                                        colors: [
                                          Color(0xFFE52C7C),
                                          Color(0xFFEDBC11),
                                        ]),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 35,right: 15,top: 10,bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('$name $surname',style: TextStyle(fontSize: 24,color: whiteFontColor,height: 1),overflow: TextOverflow.ellipsis,),
                                          Text('รหัสพนักงาน $username',style: TextStyle(fontSize: 18,color: whiteFontColor,height: 1),),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.white,
                                                child: Center(child: Text('$rank',style: TextStyle(fontSize: 20,),))
                                            ),
                                          ),
                                          Text('อันดับที่',style: TextStyle(fontSize: 15,color: whiteFontColor),)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30,right: 30,top: 10,bottom: 10),
                                      child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('เป้ายอดขาย',style: TextStyle(fontSize: 18,height: 1),),
                                                    Text('${f.SeperateNumber(goal)} กระสอบ',style: TextStyle(fontSize: 18,height: 1)),
                                                  ],
                                                ),

                                                Divider(color: Colors.grey.shade900,height: 3,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('ขายได้แล้ว',style: TextStyle(fontSize: 18,height: 1),),
                                                    Text('${f.SeperateNumber(sumProduct)} กระสอบ',style: TextStyle(fontSize: 18,height: 1)),
                                                  ],
                                                ),
                                                Divider(color: Colors.grey.shade900,height: 3,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('ขายอีก',style: TextStyle(fontSize: 18,height: 1),),
                                                    (goal > sumProduct)
                                                    ? Text('${f.SeperateNumber(goal - sumProduct)} กระสอบ',style: TextStyle(fontSize: 18,height: 1,))
                                                    : Text('0 กระสอบ',style: TextStyle(fontSize: 18,height: 1,))
                                                  ],
                                                ),
                                                SizedBox(height: 5,),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: LinearProgressIndicator(
                                                    minHeight: 10,
                                                    backgroundColor: dartBackgroundColor,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC00EC9)),
                                                    value: (goal!=0)?(sumProduct/goal):0,
                                                  ),
                                                ),

                                              ],
                                      ),
                                    ),
                                  )

                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment(1, 0.0),
                              colors: [
                                Color(0xFFE52C7C),
                                Color(0xFFEDBC11),
                              ]),
                          //border: Border.all(),
                          borderRadius: BorderRadius.circular(50)),
                      child: ClipOval(
                        child: (avatar !=null)
                            ? CachedNetworkImage(
                                imageUrl: '$storagePath/${avatar}',
                                errorWidget: (context, url, error){
                                  return Image.asset('assets/avatar.png');
                                },
                              )
                            :Image.asset('assets/avatar.png'),
                      )
                      // CircleAvatar(
                      //   backgroundImage:
                      //   // CachedNetworkImageProvider('$storagePath/$avatar'),
                      //   radius: 30,
                      // ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
