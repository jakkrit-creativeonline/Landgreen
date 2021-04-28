import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';

class DocPTA extends StatefulWidget {
  final obj;
  const DocPTA({Key key,this.obj}):super(key: key);

  @override
  _DocPTAState createState() => _DocPTAState();
}

class _DocPTAState extends State<DocPTA> {

  var _obj;
  var _userData;
  Future<bool> _isLoaded;
  TextStyle _baseFontStyle = TextStyle(fontSize: 14,height: 1.0);
  TextStyle _baseFontStyleBody = TextStyle(fontSize: 16,height: 1.0);
  FormatMethod f = FormatMethod();
  Size _size;
  
  @override
  void initState() {
    _obj = widget.obj;
    print('_obj.runtimetype =>${_obj.runtimeType}');
    print('_obj =>${_obj}');
    getData();
    super.initState();
  }

  getData() async{

    var res = await Sqlite().rawQuery('''
    SELECT USER.*,PROVINCE.PROVINCE_NAME,DISTRICT.DISTRICT_NAME,AMPHUR.AMPHUR_NAME
    FROM USER 
    JOIN PROVINCE ON PROVINCE.PROVINCE_ID = USER.Province_id
    JOIN DISTRICT ON DISTRICT.DISTRICT_ID = USER.District_id
    JOIN AMPHUR ON AMPHUR.AMPHUR_ID = USER.Amphur_id
    WHERE USER.ID = ${_obj['Sale_id']}
    ''');
    _userData = res[0];
    _isLoaded = Future.value(true);
    if(mounted)setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
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
              body: CustomScrollView(
                slivers: [

                  SliverToBoxAdapter(
                    child: FutureBuilder(
                    future: _isLoaded,
                        builder: (context, snapshot) {
                          print('snapshot =>${snapshot.hasData}');
                          if(snapshot.hasData){
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 15),
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 5.0,
                                child: Card(
                                  // color: Colors.amber,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text('หนังสือมอบอำนาจ',style: TextStyle(fontSize: 22),),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Container(),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('เขียนที่ บริษัท แลนด์กรีนอะโกร จำกัด',style: _baseFontStyle,),
                                                  Text('วันที่ ${f.ThaiFormat(_obj['Create_date'].toString().split(' ')[0])}',style: _baseFontStyle,),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('โดยหนังสือฉบับนี้ ข้าพเจ้า คุณ ตรีพิพัฒน์ ศิลปการสกุล',style: _baseFontStyleBody,),
                                              Text('เกิดเมื่อวันที่ 24 ก.พ. 2523 เลขบัตรประจำตัวประชาชน 3 6403 00128 10 9',style: _baseFontStyleBody,),
                                              Text('บ้านเลขที่ 90/5 หมู่ 1 แขวง/ตำบล บ่อพลอย เขต/อำเภอ บ่อพลอย จังหวัด กาญจนบุรี',style: _baseFontStyleBody,),
                                              Text('ได้มอบอำนาจให้ คุณ ${_obj['Sale_name']}',style: _baseFontStyleBody,),
                                              Text('เกิดเมื่อวันที่ ${f.ThaiFormat(_userData['Birthday'])} เลขบัตรประจำตัวประชาชน ${_userData['Id_card']}',style: _baseFontStyleBody,),
                                              Text('บ้านเลขที่ ${_userData['Address']} ต.${_userData['DISTRICT_NAME'].toString().trim()} อ.${_userData['AMPHUR_NAME'].toString().trim()} จ.${_userData['PROVINCE_NAME'].toString().trim()} ',style: _baseFontStyleBody,),
                                              Text('เป็นผู้มีอำนาจจัดการใดๆ อันเกี่ยวกับ การเก็บเครดิตรายละเอียดดังนี้',style: _baseFontStyleBody,),
                                              SizedBox(height: 15,),
                                              Text('${_obj['Doc_text']}',style: _baseFontStyleBody,),
                                              Text('ตามความหนังสือฉบับนี้ข้าพเจ้ายอมรับผิดชอบตามที่ผู้รับมอบอำนาจของข้าพเจ้าได้ทำไปเสมือนหนึ่งข้าพเจ้าได้ทำการเองด้วยตัวเอง เพื่อเป็นหลักฐานข้าพเจ้าได้ลงลายมือชื่อไว้เป็นสำคัญต่อหน้าพยานแล้ว',style: _baseFontStyleBody,),
                                              SizedBox(
                                                width: _size.width*0.3,
                                                child: Image.asset('assets/stamp.png'),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                              width: _size.width*0.2,
                                                              child: Image.asset('assets/sign.png'),
                                                            ),
                                                            Text('ผู้มอบอำนาจ',style: _baseFontStyleBody,)
                                                          ],
                                                        ),
                                                        Text('( นางตรีพิพัฒน์  ศิลปการสกุล )',style: _baseFontStyleBody),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      children: [
                                                        Text('...............................ผู้รับมอบอำนาจ',style: _baseFontStyleBody),
                                                        Text('(${_obj['Sale_name']})',style: _baseFontStyleBody),
                                                      ],
                                                    )
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15,),
                                              Text('ข้าพเจ้าขอรับรองว่าเป็นลายมือหรือลายนิ้วมืออันแท้จริงของผู้มอบอำนาจกับผู้รับมอบอำนาจและผู้รับมอบอำนาจกับผู้มอบอำนาจได้ลงลายมือชื่อต่อหน้าข้าพเจ้าแล้ว',style: _baseFontStyleBody,),
                                              SizedBox(height: 15,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Flexible(child: Text('..........ประภาศิริ แตงอ่อน..........พยาน',style: _baseFontStyleBody)),
                                                          ],
                                                        ),
                                                        Text('( ประภาศิริ แตงอ่อน )',style: _baseFontStyleBody),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        children: [
                                                          Wrap(
                                                            children: [
                                                              Text('...........${_obj['Credit_create']}.........พยาน',style: _baseFontStyleBody),
                                                            ],
                                                          ),
                                                          Text('(${_obj['Credit_create']})',style: _baseFontStyleBody),
                                                        ],
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }else{
                            return ShimmerLoading(type: 'boxText',);
                          }

                        },
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
    );
  }
}
