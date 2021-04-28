import 'package:cached_network_image/cached_network_image.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SubmanagerHeadCard extends StatelessWidget {
  final String username;
  final String imgAvatar;
  final String name;
  final String surname;
  final String saleProvince;
  final String plateNumber;
  final int headId;
  final int teamGoal;
  final int cashProductCat1;
  final int cashMoneyTotal;
  final int creditProductCat1;
  final int creditMoneyTotal;
  final int saleCount;

  const SubmanagerHeadCard(
      {Key key,
      this.username = '',
      this.imgAvatar = '',
      this.name = '',
      this.surname = '',
      this.saleProvince = '',
      this.plateNumber = '',
      this.headId = 0,
      this.teamGoal = 0,
      this.cashProductCat1 = 0,
      this.cashMoneyTotal = 0,
      this.creditProductCat1 = 0,
      this.creditMoneyTotal = 0,
      this.saleCount = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sell = cashProductCat1 + creditProductCat1;
    int remain = 0;
    Map<String, TeamGoal> data = {
      'sell':
          TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sell)
    };
    if (teamGoal - sell < 0) {
      remain = 0;
      data['goal'] = TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 0);
    } else {
      remain = teamGoal - sell;
      data['goal'] = TeamGoal(charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)),
          'goal', teamGoal - sell);
    }

    var percentage =
        ((cashProductCat1 + creditProductCat1) / teamGoal * 100).floor();

    var series = [
      charts.Series(
          domainFn: (TeamGoal data, i) => data.text,
          measureFn: (TeamGoal data, i) => data.total,
          colorFn: (TeamGoal data, i) => data.color,
          labelAccessorFn: (TeamGoal data, i) => data.text,
          id: 'TeamGoal',
          data: data.values.toList())
    ];

    double progressSum = (cashProductCat1 + creditProductCat1) / teamGoal;
    double progressCash = (cashProductCat1) / (teamGoal / 2);
    double progressCredit = (creditProductCat1) / (teamGoal / 2);

    FormatMethod f = FormatMethod();

    Widget showTeamGoal() {
      TextStyle _baseFontStyle = TextStyle(fontSize: 15,color: whiteFontColor,height: 1.2);
      return Stack(
        alignment: Alignment.topCenter,
        overflow: Overflow.visible,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('เป้ายอดขาย',style: _baseFontStyle,),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: HalfDonut(series, animate: true,formPage: 'margin0',)),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Text('$percentage %',style: TextStyle(fontSize: 25,color: whiteFontColor),),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เป้าหมายยอดขาย',style: _baseFontStyle,),
                    Container(
                        width: 130,
                        padding: EdgeInsets.symmetric(vertical: 2),
                        color: grayColor,
                        child: Center(
                            child: Text('${f.SeperateNumber(teamGoal)} กระสอบ',style: _baseFontStyle,))),
                    Text('ขายได้แล้ว',style: _baseFontStyle,),
                    Container(
                        width: 130,
                        padding: EdgeInsets.symmetric(vertical: 2),
                        color: grayColor,
                        child:
                            Center(child: Text('${f.SeperateNumber(sell)} กระสอบ',style: _baseFontStyle,))),
                    Text('ขายอีก',style: _baseFontStyle,),
                    Container(
                      width: 130,
                      padding: EdgeInsets.symmetric(vertical: 2),
                      color: grayColor,
                      child: Center(child: Text('${f.SeperateNumber(remain)} กระสอบ',style: _baseFontStyle,)),
                    ),
                  ],
                ),
              ))
        ],
      );
    }

    Widget showTeamSell() {
      Size size = MediaQuery.of(context).size;
      double ratio = size.width*0.105;
      TextStyle _baseFontStyle = TextStyle(fontSize: 15,color: whiteFontColor);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12,bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider('$storagePath/$imgAvatar'),
                    radius: ratio,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ทีม : $name',style: _baseFontStyle,softWrap: true,),
                      Text('เขต : $saleProvince',style: _baseFontStyle,softWrap: true,),
                      Text('ทะเบียนรถ : $plateNumber',style: _baseFontStyle,softWrap: true,),
                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                          child: Text('ดูเพิ่มเติม',style: _baseFontStyle),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('ยอดขายรวม (เดือนปัจจุบัน)',style: _baseFontStyle,),
                Container(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          minHeight: 22,
                          backgroundColor: grayColor,
                          value: progressSum,
                        ),
                      ),
                      Positioned(
                        left: 5,top: 2,
                          child: Text('${f.SeperateNumber(cashMoneyTotal + creditMoneyTotal)} บาท',style: _baseFontStyle)),
                    ],
                  ),
                ),
                Text('ขายเงินสด (เดือนปัจจุบัน)',style: _baseFontStyle),
                Container(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          minHeight: 22,
                          backgroundColor: grayColor,
                          value: progressCash,
                        ),
                      ),
                      Positioned(
                          left: 5,top: 2,
                          child: Text('${f.SeperateNumber(cashMoneyTotal)} บาท',style: _baseFontStyle)),
                    ],
                  ),
                ),

                Text('ขายเครดิต (เดือนปัจจุบัน)',style: _baseFontStyle),
                Container(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          minHeight: 22,
                          backgroundColor: dartBackgroundColor,
                          value: progressCredit,
                        ),
                      ),
                      Positioned(
                          left: 5,top: 2,
                          child: Text('${f.SeperateNumber(creditMoneyTotal)} บาท',style: _baseFontStyle)),
                    ],
                  ),
                ),

              ],
            ),
          )

        ],
      );
    }

    Size size = MediaQuery.of(context).size;
    int setFlex = 6;
    if(size.width <=375){
      setFlex = 5;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Card(
          color: darkColor,
          elevation:2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 240,
                    child: showTeamGoal(),
                  ),
                ),
                Expanded(
                  flex: setFlex,
                  child: Container(
                    height: 240,
                    child: showTeamSell(),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
