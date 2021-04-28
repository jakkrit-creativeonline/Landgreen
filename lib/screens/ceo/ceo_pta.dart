import 'dart:convert';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:system/screens/sale/doc_pta.dart';
import 'package:http/http.dart' as http;


class CEOShowPTA extends StatefulWidget {
  @override
  _CEOShowPTAState createState() => _CEOShowPTAState();
}

class _CEOShowPTAState extends State<CEOShowPTA> {
  GetReport s = GetReport();
  FormatMethod f = FormatMethod();
  Future<bool> isLoaded;
  List _listDocPTA = [];

  var _userId;
  TextStyle _baseFontStyle = TextStyle(fontSize: 18);
  String selectedMonth = '';
  String startDate ='';
  String endDate='';

  DateTime initDate = DateTime.now();

  var monthSelectText = TextEditingController();


  @override
  void initState() {
    // _userId = widget.userId;
    getData();
    super.initState();
  }


  getData() async{
    selectedMonth = '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
    var lastDayOfMonth = DateTime(initDate.year,initDate.month+1,0);
    startDate = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
    endDate = '${lastDayOfMonth.toString().split(' ')[0]}';

    var res = await Sqlite().getJson('DOC_PTA_FOR_CEO', selectedMonth);
    isLoaded = Future.value();
    if (res != null) {
      _listDocPTA = jsonDecode(res['JSON_VALUE']);
    } else {

      bool isConnect = await DataConnectionChecker().hasConnection;
      if (isConnect) {
        AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
        try {

          var res = await http.post('$apiPath-credit-doc',
                                      body: {
                                        'func': 'getDocPTAApproved',
                                        'startDate': startDate,
                                        'endDate': endDate
                                      }
                                       );
          if (res.statusCode == 200) {
            print('online');
            Sqlite().insertJson('DOC_PTA_FOR_CEO', selectedMonth, res.body);
            List data = jsonDecode(res.body);
            _listDocPTA = data;
            // return data;
          }
        } catch (e) {
          print('error $e');
          setState(() {});
          // return [];
          _listDocPTA =[];
        }
        Navigator.pop(context);
      }

    }
    isLoaded = Future.value(true);
    setState(() {});

  }

  Future<void> _refresh() async {
    bool isConnect = await DataConnectionChecker().hasConnection;

    if (isConnect) {
      isLoaded = Future.value();
      var lastDayOfMonth = DateTime(initDate.year,initDate.month+1,0);
      startDate = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
      endDate = '${lastDayOfMonth.toString().split(' ')[0]}';
      AlertNewDesign().showLoading(context,MediaQuery.of(context).size);
      try {

        var res = await http.post('$apiPath-credit-doc',
            body: {
              'func': 'getDocPTAApproved',
              'startDate': startDate,
              'endDate': endDate
            }
        );
        if (res.statusCode == 200) {
          print('online');
          Sqlite().insertJson('DOC_PTA_FOR_CEO', selectedMonth, res.body);
          List data = jsonDecode(res.body);
          _listDocPTA = data;
          // return data;
        }
        Navigator.pop(context);
      } catch (e) {
        print('error $e');
        Navigator.pop(context);
        setState(() {});
        // return [];
        _listDocPTA =[];

      }



      isLoaded = Future.value(true);
      setState(() {});
    }
  }

  Future _showMonthPicker() async {
    return showMonthPicker(
      context: context,
      firstDate: DateTime(2020, 6),
      // lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      initialDate: initDate,
      locale: Locale("th"),
    ).then((date) {
      if (date != null) {
        initDate = date;
        selectedMonth =
        '${initDate.toString().split('-')[0]}/${initDate.toString().split('-')[1]}';
        var _str = '${initDate.toString().split('-')[0]}-${initDate.toString().split('-')[1]}-01';
        monthSelectText.text="บิลกำหนดชำระเดือน "+f.ThaiMonthFormat(_str);
        getData();
      }
    });
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
                                child: Icon(FontAwesomeIcons.addressBook,color: btTextColor,),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายงานใบมอบอำนาจ',style: TextStyle(fontSize: 24.0,height: 1),),
                                  Text('หน้านี้สรุปข้อมูลจากวันที่กำหนดชำระ',style: TextStyle(fontSize: 16.0,height: 1),),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () {
                                  // _showDateTimeRange(context);
                                  _showMonthPicker();
                                },
                                child: AbsorbPointer(
                                  child: ClipRRect(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                                    child: TextField(
                                                      controller: monthSelectText,
                                                      textAlign: TextAlign.center,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      decoration: InputDecoration(
                                                        // labelText:'ข้อมูล ณ วันที่',
                                                        hintText: 'บิลกำหนดชำระประจำเดือนนี้',
                                                        contentPadding: EdgeInsets.all(5),
                                                        border: InputBorder.none,
                                                        isDense: true,

                                                      ),

                                                      style: TextStyle(fontSize: 18,),
                                                    ),
                                                  ),

                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(width: 2,color: subFontColor),
                                                      bottom: BorderSide(width: 2,color: subFontColor),
                                                    ),
                                                    color: bgInputColor,
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 5,
                                                  child: Container(
                                                    child: Icon(Icons.arrow_drop_down_outlined,color: Colors.black,size: 28,),
                                                  ),
                                                )
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
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
                          future: isLoaded,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              if(_listDocPTA.length>0){
                                int sumMoneyDue = 0;
                                _listDocPTA.forEach((element) {
                                  sumMoneyDue+=element['Money_due'];
                                });
                                
                                print(sumMoneyDue);

                                return Column(
                                  children: [
                                    SizedBox(height: 5,),
                                    Card(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          HeaderText(text:'สรุปรวม',textSize: 20,gHeight: 26,),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15,top: 8),
                                            child: Text('ใบมอบอำนาจจำนวน ${_listDocPTA.length} ใบ',style: _baseFontStyle,),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15,bottom: 8),
                                            child: Text('จำนวนเงินที่ให้ไปเก็บรวม ${f.SeperateNumber(sumMoneyDue)} บาท',style: _baseFontStyle,),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _listDocPTA.length,
                                      itemBuilder: (context, index) {
                                        var obj = _listDocPTA[index];
                                        return Card(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              HeaderText(text:'${index+1}. ลูกค้าชื่อ ${obj['Customer_name']}',gHeight: 26,textSize: 20,),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 16,right: 10,top: 8,bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex:5,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('ที่อยู่ ${obj['Customer_address'].toString().replaceAll('  ', ' ')}',style: _baseFontStyle,),
                                                          Text('เบอร์โทร ${obj['Phone']}',style: _baseFontStyle,),
                                                          // Text('บิลเลขที่ ${obj['Bill_number']}',style: _baseFontStyle,),
                                                          Text('กำหนดชำระ ${f.ThaiDateFormat(obj['Date_due'])}',style: _baseFontStyle,),
                                                          Text('ผู้สร้างใบมอบอำนาจ ${obj['Credit_create']}',style: _baseFontStyle,),
                                                          Text('มอบอำนาจให้ ${obj['Sale_name']}',style: _baseFontStyle,),
                                                          Text('จำนวนเงินที่ให้ไปเก็บลูกค้า ${f.SeperateNumber(obj['Money_due'])} บาท',style: TextStyle(fontSize: 20,
                                                              color: (obj['Money_due']>0)?dangerColor:Colors.black,height: 1
                                                          ),),

                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:2,
                                                      child: Wrap(
                                                        children: [
                                                          InkWell(
                                                            onTap: (){
                                                              MyFunction().openURL(linkStr: "tel:${obj['Phone']}");

                                                            },
                                                            child: Card(
                                                              child: ConstrainedBox(
                                                                constraints: BoxConstraints(
                                                                    minWidth: 80,
                                                                    minHeight: 40
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Icon(Icons.phone,color: dangerColor,size: 22,),
                                                                    Text('โทรหาลูกค้า',style: TextStyle(fontSize: 12,color: dangerColor),)
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: (){
                                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>DocPTA(obj: obj)));
                                                            },
                                                            child: Card(
                                                              color: kPrimaryColor,
                                                              child: ConstrainedBox(
                                                                constraints: BoxConstraints(
                                                                    minWidth: 80,
                                                                    minHeight: 40
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Icon(FontAwesomeIcons.search,color: Colors.white,size: 18,),
                                                                    Text('กดดูใบมอบอำนาจ',style: TextStyle(fontSize: 12,color: Colors.white),)
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }else{
                                return Card(
                                  child: Column(
                                    children: [
                                      Text('ยังไม่มีรายการ',style: _baseFontStyle,),
                                      Text('ใบมอบอำนาจจากฝ่ายสินเชื่อ',style: _baseFontStyle)
                                    ],
                                  ),
                                );
                              }

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
