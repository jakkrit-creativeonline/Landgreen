import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system/components/sale_ranking_item.dart';


import 'package:system/configs/constants.dart';

class ShowRankAll extends StatefulWidget {
  @override
  _ShowRankAllState createState() => _ShowRankAllState();
}

class _ShowRankAllState extends State<ShowRankAll> {
  var saleRanking = null;
  FormatMethod f = new FormatMethod();
  List<Widget> saleRankList  = new List();
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future getData() async {
    await getSaleRanking();

  }

  Future getSaleRanking() async {

    var res = await Sqlite().query('JSON_TABLE',
        firstRow: true, where: 'DATA_TABLE = "SaleRanking"');
    // print('getSaleRanking');
    // print(res);
    if (res != null) {
      var dataSet = jsonDecode(res['JSON_VALUE']);
      dataSet.sort((a, b) =>
          int.parse(b['sumcountcat'].compareTo(a['sumcountcat']).toString()));
      saleRanking = dataSet;
      if(saleRanking != null ) {
        print(saleRanking);
        int i=0;
        for(var item in saleRanking){
            var _widget = SaleRankingItem(
              imgUrl: item['sale_Image'],
              name: item['sale_name'],
              sumqty: item['sumcountcat'],
              rank: i + 1,
            );
            saleRankList.add(_widget);
          i++;
        }
        // saleRanking.forEach((index, item) {

        // });
        print(saleRankList);
      }
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;


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
            body: CustomScrollView(
              slivers: [
                if(saleRanking!=null)SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'อันดับยอดขาย อัพเดท ${saleRanking[0]['time_gen']} น. ${f.ThaiDateFormat(saleRanking[0]['day_gen'])}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  // Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //
                  //     GridView.builder(
                  //       itemCount:saleRanking.length,
                  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //           crossAxisCount: 5),
                  //       itemBuilder: (BuildContext context, int index) {
                  //         return SizedBox(
                  //           width: 10,
                  //           height: 10,
                  //         );
                  //       },
                  //     ),
                  //     Footer()
                  //   ],
                  // ),
                ),
                if(saleRankList.length>0)
                  SliverPadding(
                    padding: EdgeInsets.only(left: 15, right: 15,bottom: 10),
                    sliver: SliverGrid.count(
                      crossAxisCount: 5,
                      childAspectRatio: 0.7,
                      children: saleRankList,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Footer(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget rankingSaleWidget(){
    Size size = MediaQuery.of(context).size;
    var _widthImg   = size.width*0.17;
    var _heightImg  = size.width*0.17;
    // print("rankingSaleWidget");
    // print(saleRanking);
    if(saleRanking != null ){

      saleRanking.forEach((index,item){
        var _widget = SaleRankingItem(
                        imgUrl: item['sale_Image'],
                        name: item['sale_name'],
                        sumqty: item['sumcountcat'],
                        rank: index+1,
                      );
        saleRankList.add(_widget);
      });

      List<Widget> _row1 = new List();
      for(var i=0;i<5;i++){
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i+1,
        );
        _row1.add(_widget);
      }
      List<Widget> _row2 = new List();
      for(var i=5;i<10;i++){
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i+1,
        );
        _row2.add(_widget);
      }
      List<Widget> _row3 = new List();
      for(var i=10;i<15;i++){
        var _widget = SaleRankingItem(
          imgUrl: saleRanking[i]['sale_Image'],
          name: saleRanking[i]['sale_name'],
          sumqty: saleRanking[i]['sumcountcat'],
          rank: i+1,
        );
        _row3.add(_widget);
      }


      return Padding(
        padding: const EdgeInsets.only(left: 16,right: 16),
        child: Card(
          color: Color(0xFFEFEFEF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 10),
                child: Text('อันดับยอดขาย อัพเดท ${saleRanking[0]['time_gen']} น. ${f.ThaiDateFormat(saleRanking[0]['day_gen'])}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _row1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _row2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _row3,
                ),
              )
            ],
          ),
        ),
      );
    }
    return Container();


  }

}
