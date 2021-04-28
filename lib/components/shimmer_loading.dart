import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/configs/constants.dart';

class ShimmerLoading extends StatefulWidget {
  final String type ;
  ShimmerLoading({this.type});

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();

}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  String _type;
  @override
  Widget build(BuildContext context) {
    _type = widget.type;
    Size size = MediaQuery.of(context).size;

    switch(_type){

      case 'userInfo':{
         return Container(
           width: size.width,
           child: Shimmer.fromColors(
             baseColor: Colors.grey[300],
             highlightColor: Colors.grey[100],
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Expanded(
                   child: Column(
                     children: [
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Container(
                                 width: size.width*0.4,
                                 height: 20.0,
                                 color: Colors.white,
                               ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Container(
                           width: size.width*0.4,
                           height: 20.0,
                           color: Colors.white,
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Container(
                           width: size.width*0.4,
                           height: 20.0,
                           color: Colors.white,
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Container(
                           width: size.width*0.4,
                           height: 20.0,
                           color: Colors.white,
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(2.0),
                         child: Container(
                           width: size.width*0.4,
                           height: 20.0,
                           color: Colors.white,
                         ),
                       ),
                     ],
                   ),
                 ),
                 Expanded(child:  Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                     width: size.width*0.4,
                     height: 120.0,
                     color: Colors.red,
                   ),
                 ),)

               ],
             ),
             ) ,
         );

      }break;
      case 'imageSquare':{
        return SizedBox(
          width: 100.0,
          height: 100.0,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              color: Colors.white,
            ),
          ),
        );

      }break;
      case 'boxInput1Row':{
        return SizedBox(
          width: size.width,
          height: 40,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              color: Colors.white,
            ),
          ),
        );

      }break;
      case 'boxText':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );

      }break;
      case 'boxText1row':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        );

      }break;
      case 'boxText2row':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.6,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),

          ],
        );

      }break;
      case 'boxItem':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: size.width*0.3,
                      height: size.width*0.3,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width*0.4,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: size.width*0.3,
                      height: size.width*0.3,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width*0.4,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      }break;
      case 'boxItem1Row':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: size.width*0.3,
                      height: size.width*0.3,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width*0.4,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width*0.5,
                          height: 20,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            MyDivider(),
          ],
        );

      }break;
      case 'boxGraph1row':{
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 15,top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width*0.9,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.7,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.8,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: size.width*0.7,
                      height: 20,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        );

      }break;




      case 'colorgold':{
        return SizedBox(
          width: 100.0,
          height: 100.0,
          child: Shimmer.fromColors(
            baseColor: Color(0xFFDAA520),
            highlightColor: Color(0xFFDAA520),
            child: Container(
              color: Colors.white,
            ),
          ),
        );

      }break;

      case 'loadTextCarPayDay':{
        return SizedBox(
          width: 200.0,
          height: 100.0,
          child: Shimmer.fromColors(
            baseColor: lightLoadingColor,
            highlightColor: darkLoadingColor,
            child: Text(
              'กำลังโหลดประเภทค่าใช้จ่าย',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        );
      }break;

      default: {
        return SizedBox(
          width: 200.0,
          height: 100.0,
          child: Shimmer.fromColors(
            baseColor: lightLoadingColor,
            highlightColor: darkLoadingColor,
            child: Text(
              'กำลังโหลดรอแปปนะ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        );
      }
      break;


    }

  }


}

