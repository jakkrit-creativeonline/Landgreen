
import 'package:flutter/widgets.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/form_card.dart';
import 'package:system/components/header_text.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class ReceiptHeader extends StatelessWidget {
  const ReceiptHeader({
    Key key,
    this.billData,
    this.settingCompany,
    this.rows,
    this.isOnline,
  }) : super(key: key);
  final Map billData;
  final Map settingCompany;
  final List<DataRow> rows;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.26,
              child: Image.asset('assets/img/logo.png'),
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${settingCompany['name']}',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  Text('เลขประจำตัวผู้เสียภาษี ${settingCompany['taxCode']}'),
                  Text(
                      '${settingCompany['address']} ${settingCompany['zipCode']}'),
                  Text(
                      'โทร ${settingCompany['phone']}, ${settingCompany['mobile']}')
                ],
              ),
            )),
          ],
        ),
        Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ใบส่งสินค้า / ใบเสร็จรับเงิน',
                  style: TextStyle(fontSize: 36.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 24.0),
                  child: Text(
                    '${billData['billPayType'] == 1 ? 'เงินสด' : 'เครดิต'}',
                    style: TextStyle(fontSize: 35.0, color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle, color: Color(0xff808080)),
                )
              ],
            )),
        SizedBox(
          height: 20,
        ),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeaderText(text:'ข้อมูลลูกค้า',textSize: 20,gHeight: 26,),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,top: 10,right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ชื่อลูกค้า : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${billData['cName']}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ที่อยู่ลูกค้า : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${billData['cAddress']} ตำบล${billData['cSubDistrict']} อำเภอ${billData['cDistrict']} จังหวัด${billData['cProvince']} ${billData['cZipCode']}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10,bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'โทรศัพท์ : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: InkWell(
                              onTap: (){
                                print('click call');
                                MyFunction().openURL(linkStr: 'tel:${billData['cTel']}');
                              },
                              child: Text(
                                '${billData['cTel']}',
                                style: TextStyle(fontSize: 20.0,color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeaderText(text:'ข้อมูลพนักงานขาย',textSize: 20,gHeight: 26,),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,top: 10,right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'วันที่จัดส่ง : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${FormatMethod().ThaiFormat(billData['sendDate'])}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'รหัสพนักงานขาย : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${billData['saleUsername']}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10 ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'เขตการขาย : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${billData['saleProvince']}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'ผู้ส่งสินค้า : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              '${billData['saleName']}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18,right: 10,bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'เลขที่ใบสั่งจอง : ',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              // onTap: () {
                              //   locator<NavigationService>().navigateTo(
                              //       'createBill',
                              //       ScreenArguments(
                              //           userId: billData['saleUserId'],
                              //           billId: billData['billId'],
                              //           isBillOnline: isOnline));
                              // },
                              child: Text('${billData['billNumber']}',
                                  style: TextStyle(fontSize: 20.0,)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 2,
        ),
        if (billData['billPayType'] == 2)
          FormCard(
            title: 'ข้อมูลเครดิต',
            setBGColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18,top: 0,right: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'เงินมัดจำ : ',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${FormatMethod().SeperateNumber(billData['moneyEarnest'].toString().split('.')[0])} บาท',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18,top: 0,right: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ค้างชำระ : ',
                            style: TextStyle(fontSize: 20.0,color: dangerColor),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${FormatMethod().SeperateNumber(billData['moneyDue'].toString().split('.')[0])} บาท',
                            style: TextStyle(fontSize: 20.0,color: dangerColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18,top: 0,right: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ครบกำหนดชำระ : ',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${FormatMethod().ThaiFormat(billData['dateDue'])}',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Expanded(
              //         child: Column(
              //           children: [
              //
              //           ],
              //         ),
              //     )
              //
              //     Text(
              //         'เงินมัดจำ ${FormatMethod().SeperateNumber(billData['moneyEarnest'].toString().split('.')[0])}'),
              //     Text(
              //         'ค้างชำระ ${FormatMethod().SeperateNumber(billData['moneyDue'].toString().split('.')[0])}'),
              //     Text(
              //         'ครบกำหนดชำระ ${FormatMethod().ThaiFormat(billData['dateDue'])}')
              //   ],
              // ),
            ),
          ),

        // SingleChildScrollView(
        //   scrollDirection: Axis.vertical,
        //   child: SingleChildScrollView(
        //     scrollDirection: Axis.horizontal,
        //     child: DataTable(columns: [
        //       DataColumn(label: Text('#'), numeric: true),
        //       DataColumn(label: Text('รูปสินค้า')),
        //       DataColumn(label: Text('รายการสินค้า')),
        //       DataColumn(label: Text('จำนวน'), numeric: true),
        //       DataColumn(label: Text('ราคาต่อหน่วย'), numeric: true),
        //       DataColumn(label: Text('รวมเป็นเงิน'), numeric: true),
        //     ], rows: rows),
        //   ),
        // ),
        // SizedBox(
        //   height: 20,
        // ),
        // Text(
        //   '''หมายเหตุ : เมื่อโอนเงินเข้าบัญชี แล้วกรุณาโทรแจ้งที่หมายเลข ${settingCompany['mobile']} ทันทีที่โอน การส่งมอบสินค้าตามที่ระบุ ประเภท ชนิด และปริมาณตามที่ระบุไว้ ไม่ว่าจะผู้ซื้อหรือผู้แทนของผู้ซื้อหรือบุคคลใดที่เกี่ยวข้องกับผู้ซื้อหรือได้ส่งมอบสินค้า ณ ที่ทำการของผู้ซื้อหรือสาถานที่ตามที่ผู้ซื้อกำหนดไว้แล้ว ถือว่าผู้ขายได้ส่งมอบสินค้าแก่ผู้ซื้อเรียบร้อยแล้ว กรณีสินค้าไม่ถูกต้องครบถ้วนหรือชำรุดบกพร่อง ผู้ซื้อจะต้องแจ้งให้ผู้ขายทราบโดยทันที มิฉะนั้นจะไม่รับผิดชอบใดๆ ทั้งสิ้น''',
        //   style: TextStyle(fontSize: 16.0),
        // ),
        // SizedBox(
        //   height: 20,
        // ),
      ],
    );
  }
}
