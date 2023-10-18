import 'dart:convert';

// import 'package:background_fetch/background_fetch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:new_version/new_version.dart';
import 'package:system/components/ceo_menu.dart';
import 'package:system/components/header_text.dart';
import 'package:system/screens/ceo/components/ceo_car_rank.dart';
import 'package:system/screens/ceo/components/ceo_income.dart';
import 'package:system/screens/ceo/components/ceo_manager_rank.dart';
import 'package:system/screens/ceo/components/ceo_map.dart';
import 'package:system/screens/ceo/components/ceo_map_test.dart';
import 'package:system/screens/ceo/components/ceo_ranking.dart';
import 'package:system/screens/ceo/components/ceo_team_rank.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'package:system/services/check_update_version.dart';

class CEODashboard extends StatefulWidget {
  final int userId;
  const CEODashboard({Key key, this.userId}) : super(key: key);
  @override
  _CEODashboardState createState() => _CEODashboardState();

}

class _CEODashboardState extends State<CEODashboard> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  GetReport s = GetReport();

  int userId;

  var client = Client();

  var userData = new Map();
  Future<bool> userDataFuture;

  String incomeSelected = '13';

  var lastAvaliable;
  DateTime currentTime = DateTime.now();
  FormatMethod f = new FormatMethod();


  Future<int> getPref() async {
    final SharedPreferences prefs = await _prefs;

    //Mock userId
    // return 3;

    //Real userId
    return prefs.getInt('user_id');
  }

  Future getUserData() async {
    var res = await Sqlite().rawQuery('SELECT * FROM USER WHERE ID = ${widget.userId}');
    userData = res[0];
    userDataFuture = Future.value(true);

    // bool isConnect = await DataConnectionChecker().hasConnection;
    // if (isConnect) {
    //   var body = {'func': 'get_userdata', 'User_id': '$userId'};
    //   var res = await client.post('$apiPath-ceo', body: body);
    //   userData = jsonDecode(res.body)[0];
    // } else {
    //   //userData = await Sqlite().getUserData(userId);

    //   //print(userData);
    // }
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => CeoIncome()));
  }

  Future getData() async {
    // userId = await getPref();
    userId = widget.userId;
    print('userId => ${userId}');
    await getUserData();
    await getAvailableReport();
    setState(() {});
    CheckEarlyMonth();

  }

  Future getAvailableReport() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      var res = await client.get('$apiPath/avaliableReport');
      print('avaliableReport');
      print(res.body);
      await Sqlite().insertJson('AVALIABLE_REPORT', '1', res.body);
      setState(() {});
    }
  }

  testCallBack(String test) {
    incomeSelected = test;
  }

  Future refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;
    if (isConnect) {
      s.getCeoMap();
      s.getCeoSaleRanking();
      s.getCeoTeamRanking();
      s.getCeoCarRanking();
      s.getCeoManagerRank();
      await s.getCeoIncome(
          noResult: true, isThisMonth: true, selectedReport: incomeSelected);
      await s.getCeoIncome(
          noResult: true, isThisMonth: false, selectedReport: incomeSelected);
      Navigator.popAndPushNamed(context, 'ceo_dashboard',arguments: ScreenArguments(userId: widget.userId));
    }
  }

  CheckEarlyMonth() async{
    print('CheckEarlyMonth');
    AlertNewDesign().showEarlyMonth(context,MediaQuery.of(context).size);
  }

  @override
  void initState() {
    print('init state ceo dashboard');
    CheckVersionUpdate().check(context);


    getData();
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        color:kPrimaryColor,
        child: SafeArea(
          bottom: false,

          child: WillPopScope(
            onWillPop: _onBackPressed,
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
              drawer: Drawer(
                elevation: 8.0,
                child: Container(
                  color: kPrimaryColor,
                  child: CEOMenu(userId: userId,),
                ),
              ),
              // floatingActionButton: FloatingActionButton(
              //   child: Icon(Icons.text_snippet, color: Colors.white),
              //   onPressed: () => refresh(),
              // ),
              body: RefreshIndicator(
                onRefresh: () => refresh(),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 26,right: 20,top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder(
                                        future:userDataFuture,
                                        builder: (context, snapshot) {
                                          if(snapshot.hasData){
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                                Text('${userData['Name']} ',style: TextStyle(fontSize: 35,height:1,color: mainFontColor),),
                                                Text('${userData['Surname']} ',style: TextStyle(fontSize: 35,height:1,color: mainFontColor),)
                                              ],
                                            );
                                          }else{
                                            return Container();
                                          }
                                        },
                                      ),

                                      VerticalDivider(color: mainFontColor,thickness: 1,indent: 10,endIndent: 10,),

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('',style: TextStyle(fontSize: 24,color: mainFontColor),),
                                          Text('CEO',style: TextStyle(fontSize: 45,height:1,color: mainFontColor),)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          width: 35,
                                          height: 35,
                                          child: Image.asset('assets/icons/icon_mail.png'),
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('อัพเดทเมื่อเวลา ${currentTime.hour}:${currentTime.minute} น.',style: TextStyle(fontSize: 18,height: 1),),
                                          Text('วันที่ ${f.ThaiDateFormat(currentTime.year.toString()+'-'+currentTime.month.toString()+'-'+currentTime.day.toString())}',style: TextStyle(fontSize: 18,height: 1),)
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  if (userData['Image'] != null)
                                    Container(
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child:CachedNetworkImage(
                                                  imageUrl: '$storagePath/${userData['Image']}',
                                                  errorWidget: (context, url, error){
                                                    return Image.asset('assets/avatar.png');
                                                  },
                                                ),
                                      ),
                                      width: size.width * 0.30,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: CeoIncome(testCallBack),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CeoMap(),
                    ),
                    SliverToBoxAdapter(
                      child: CeoManagerRank(),
                    ),
                    SliverToBoxAdapter(
                      child: CeoTeamRank(),
                    ),
                    SliverToBoxAdapter(
                      child: CeoRanking(),
                    ),
                    SliverToBoxAdapter(
                      child: CeoCarRank(),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Footer(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Center(child: Text('คุณต้องการออกจากแอพหรือไม่ ?',style: TextStyle(fontSize: 23),)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 5),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("ไม่",style: TextStyle(color: Colors.white),),
              color: kPrimaryLightColor,
            ),
            SizedBox(width: 16),
            FlatButton(
              onPressed: () {
                //SystemNavigator.pop();
                //exit(0);
                Navigator.of(context).pop(true);
              },
              child: Text(
                "ยืนยัน",
                style: TextStyle(color: Colors.white),
              ),
              color: kPrimaryColor,
            ),
          ],
        ),
      ),
    ) ??
        false;
  }



}
