import 'package:cached_network_image/cached_network_image.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/horizontal_bar_chart.dart';
import 'package:system/components/pie_chart.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TeamSellCard extends StatelessWidget {
  final int saleId;
  final String userName;
  final String name;
  final String surname;
  final String imgAvatar;
  final int workCarId;
  final int goal;
  final String workCar;
  final int cashProductCat1;
  final int cashMoneyTotal;
  final int creditProductCat1;
  final int creditMoneyTotal;

  const TeamSellCard({
    Key key,
    this.saleId,
    this.userName,
    this.name,
    this.surname,
    this.imgAvatar,
    this.workCarId,
    this.goal,
    this.workCar,
    this.cashProductCat1 = 0,
    this.cashMoneyTotal = 0,
    this.creditProductCat1 = 0,
    this.creditMoneyTotal = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sell = cashProductCat1 + creditProductCat1;
    Map<String, TeamGoal> data = {
      'sell':
          TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sell)
    };
    if (goal - sell < 0) {
      data['goal'] = TeamGoal(
          charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 0);
    } else {
      data['goal'] = TeamGoal(charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)),
          'goal', goal - sell);
    }
    var series = [
      charts.Series(
          domainFn: (TeamGoal data, i) => data.text,
          measureFn: (TeamGoal data, i) => data.total,
          colorFn: (TeamGoal data, i) => data.color,
          labelAccessorFn: (TeamGoal data, i) => data.text,
          id: 'TeamGoal',
          data: data.values.toList())
    ];
    FormatMethod f = FormatMethod();

    int max = 10000;

    double cashProgress = cashMoneyTotal / max;
    double creditProgress = creditMoneyTotal / max;

    Widget testChart() {
      return LinearProgressIndicator(
        value: 0,
        backgroundColor: darkColor,
      );
    }

    Widget cashSell() {
      TextStyle _baseFontStyle = TextStyle(fontSize: 20,color: whiteFontColor);
      TextStyle _miniFontStyle = TextStyle(fontSize: 10,color: whiteFontColor);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Text('ขายเงินสด',style: _baseFontStyle,), Text('(ยอดขายเดือนปัจจุบัน)',style: _miniFontStyle,)],
                ),
              ),

              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    minHeight: 20,
                    backgroundColor: dartBackgroundColor,
                    value: cashProgress,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                  child: Container(
                      child: Align(
                        alignment: Alignment.bottomRight,
                      child: Text('${f.SeperateNumber(cashMoneyTotal)} บาท',style: _baseFontStyle,),

                      ),
                  ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(

                  children: [Text('ขายเครดิต',style: _baseFontStyle,), Text('(ยอดขายเดือนปัจจุบัน)',style: _miniFontStyle,)],
                ),
              ),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    minHeight: 20,
                    backgroundColor: dartBackgroundColor,
                    value: creditProgress,
                    valueColor: AlwaysStoppedAnimation<Color>(kSecondaryColor),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                  child: Container(
                      child:Align(
                        alignment: Alignment.centerRight,
                          child: Text('${f.SeperateNumber(creditMoneyTotal)} บาท',style: _baseFontStyle,)),
                  ),
              ),
            ],
          ),
        ],
      );
    }

    Widget creditSell() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('ขายเครดิต'),
          Text('--------------bar--------------'),
          Text('xxxx บาท')
        ],
      );
    }

    Widget userInfo(Size size) {
      TextStyle _baseFontStyle = TextStyle(fontSize: 22,color: whiteFontColor,height: 1);
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: size.width * 0.25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(360),
                  child: (imgAvatar != null)
                      ? CachedNetworkImage(
                          imageUrl: '$storagePath/$imgAvatar',
                        )
                      : Image.asset('assets/avatar.png'),
                ),
              ),
            ),
            Expanded(
              flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('รหัสพนักงาน : $userName',style: _baseFontStyle,),
                      Text('คุณ $name $surname',style: _baseFontStyle,),
                      Text('ทะเบียน : $workCar',style: _baseFontStyle,),
                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(2)
                          ),
                        ),
                        width: size.width*0.2,
                        // color: kPrimaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child:Text('ดูเพิ่มเติม',style: TextStyle(fontSize: 16,color: whiteFontColor),)),
                        ),
                      )
                      // CustomButton(
                      //   onPress: (){},
                      //   text: 'ดูเพิ่มเติม',
                      //   textColor: Colors.white,
                      // )

                    ],
                  ),
                ))
          ],
        ),
      );
    }

    Widget userCommission(Size size) {
      TextStyle _baseFontStyle = TextStyle(fontSize: 20,color: whiteFontColor);
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
              child: Column(
            children: [
              Container(
                // color: Colors.amber,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  overflow: Overflow.visible,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: HalfDonut(series, animate: true,formPage: 'margin0',),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: goal > 0
                          ? Text(
                              '${(((cashProductCat1 + creditProductCat1) / goal) * 100).floor()} %',
                              style: _baseFontStyle,
                            )
                          : Text('0 %',style: _baseFontStyle,),
                    ),
                  ],
                ),
              )
            ],
          )),
          Expanded(
            flex: 3,
              child: Container(
            height: 180,
            padding: EdgeInsets.only(top: 15,left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('เป้ายอดขาย',style: _baseFontStyle,),
                    Text('${f.SeperateNumber(goal)} กระสอบ',style: _baseFontStyle,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขายได้แล้ว',style: _baseFontStyle,),
                    Text(
                        '${f.SeperateNumber(cashProductCat1 + creditProductCat1)} กระสอบ',style: _baseFontStyle,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ขาดอีก',style: _baseFontStyle,),
                    goal > cashProductCat1 + creditProductCat1
                        ? Text(
                            '${f.SeperateNumber(goal - (cashProductCat1 + creditProductCat1))} กระสอบ',style: _baseFontStyle,)
                        : Text('0 กระสอบ',style: _baseFontStyle,),
                  ],
                )
              ],
            ),
          ))
        ],
      );
    }

    Size size = MediaQuery.of(context).size;
    return Card(
      color: darkColor,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userInfo(size),
              //testChart(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  userCommission(size),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0,),
                    child: cashSell(),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:faarunsystem/components/pie_chart.dart';
// import 'package:faarunsystem/constants/constants.dart';
// import 'package:faarunsystem/models/TeamGoal.dart';
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;

// class TeamSellCard extends StatelessWidget {
//   final int saleId;
//   final String userName;
//   final String name;
//   final String surname;
//   final String imgAvatar;
//   final int workCarId;
//   final int goal;
//   final String workCar;
//   final int cashProductCat1;
//   final int cashMoneyTotal;
//   final int creditProductCat1;
//   final int creditMoneyTotal;

//   const TeamSellCard({
//     Key key,
//     this.saleId,
//     this.userName,
//     this.name,
//     this.surname,
//     this.imgAvatar,
//     this.workCarId,
//     this.goal,
//     this.workCar,
//     this.cashProductCat1 = 0,
//     this.cashMoneyTotal = 0,
//     this.creditProductCat1 = 0,
//     this.creditMoneyTotal = 0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     int sell = cashProductCat1 + creditProductCat1;
//     Map<String, TeamGoal> data = {
//       'sell':
//           TeamGoal(charts.ColorUtil.fromDartColor(kPrimaryColor), 'sell', sell)
//     };
//     if (goal - sell < 0) {
//       data['goal'] = TeamGoal(
//           charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)), 'goal', 0);
//     } else {
//       data['goal'] = TeamGoal(charts.ColorUtil.fromDartColor(Color(0xFFf1f1f1)),
//           'goal', goal - sell);
//     }
//     var series = [
//       charts.Series(
//           domainFn: (TeamGoal data, i) => data.text,
//           measureFn: (TeamGoal data, i) => data.total,
//           colorFn: (TeamGoal data, i) => data.color,
//           labelAccessorFn: (TeamGoal data, i) => data.text,
//           id: 'TeamGoal',
//           data: data.values.toList())
//     ];
//     FormatMethod f = FormatMethod();

//     Widget cashSell() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text('ขายเงินสด'),
//           Text('--------------bar--------------'),
//           Text('xxxx บาท')
//         ],
//       );
//     }

//     Widget creditSell() {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text('ขายเครดิต'),
//           Text('--------------bar--------------'),
//           Text('xxxx บาท')
//         ],
//       );
//     }

//     return Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     flex: 5,
//                     child: CircleAvatar(
//                       child: ClipOval(
//                           child: CachedNetworkImage(
//                         imageUrl: '$storagePath/$imgAvatar',
//                       )),
//                       radius: 65,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 5,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('รหัสพนักงาน : $userName'),
//                         Text('คุณ $name $surname'),
//                         Text('ทะเบียน : $workCar')
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                       flex: 5,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             height: 160,
//                             child: HalfDonut(series),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 30),
//                             child: goal > 0
//                                 ? Text(
//                                     '${(((cashProductCat1 + creditProductCat1) / goal) * 100).floor()} %',
//                                     //style: TextStyle(fontSize: 18),
//                                   )
//                                 : Text('0 %'),
//                           ),
//                         ],
//                       )),
//                   Expanded(
//                       flex: 5,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 50),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('เป้ายอดขาย'),
//                                 Text('${f.SeperateNumber(goal)} กระสอบ')
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('ขายได้แล้ว'),
//                                 Text(
//                                     '${f.SeperateNumber(cashProductCat1 + creditProductCat1)} กระสอบ'),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('ขาดอีก'),
//                                 goal > cashProductCat1 + creditProductCat1
//                                     ? Text(
//                                         '${f.SeperateNumber(goal - (cashProductCat1 + creditProductCat1))} กระสอบ')
//                                     : Text('0 กระสอบ'),
//                               ],
//                             )
//                           ],
//                         ),
//                       )),
//                 ],
//               ),
//             ],
//           ),
//         ));
//   }
// }
