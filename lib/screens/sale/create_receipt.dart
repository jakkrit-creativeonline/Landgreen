import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:printing/printing.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/divider_widget.dart';
import 'package:system/components/form_card.dart';
import 'package:system/components/image_picker_box.dart';
import 'package:system/components/receipt_header.dart';
import 'package:system/components/show_modal_bottom_sheet.dart';
import 'package:system/components/sign_part.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class CreateReceipt extends StatefulWidget {
  final int billId;
  final int userId;
  final int receiptId;
  final bool isOnline;
  final String receiptNumber;

  const CreateReceipt(
      {Key key,
      this.billId,
      this.userId,
      this.receiptId,
      this.isOnline,
      this.receiptNumber})
      : super(key: key);

  @override
  _CreateReceiptState createState() => _CreateReceiptState();
}

class _CreateReceiptState extends State<CreateReceipt> {
  Map<String, dynamic> settingCompany = {
    'name': '',
    'address': '',
    'taxCode': '',
    'zipCode': '',
    'phone': '',
    'mobile': ''
  };
  Map<String, dynamic> billData = {
    'cName': '',
    'cAddress': '',
    'cProvince': '',
    'cDistrict': '',
    'cSubDistrict': '',
    'cZipCode': '',
    'cTel': '',
    'cYearOld': '',
    'sendDate': '',
    'saleUserId': '',
    'saleUsername': '',
    'saleProvince': '',
    'saleName': '',
    'billNumber': '',
    'billPayType': '',
    'billId': '',
    'billOrderDetail': ''
  };
  List<Map<String, dynamic>> _productCanSell;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<DataRow> rows = [];
  List<Widget> rowsWidget = [];
  List<pw.TableRow> rowsPDF = [];

  Future<bool> isLoaded;

  List<File> imageList = [];

  final picker = ImagePicker();

  bool hasImage = false;

  var ttf;

  var client = http.Client();
  var chkImgRcvNet = false;

  String signatureBase64, signatureDate, contractNumber, receiptNumber;

  int contractId, receiptStatus = 0;

  List<String> imageUrl = [];

  Future<Null> getData() async {
    try {
      await getSettingCompany();
      await getBillData();
      await getContract();
      await getReceipt();
      isLoaded = Future.value(true);
    } catch (e) {
      isLoaded = Future.value();
      print('GET DATA ERROR $e');
    }
    setState(() {});
  }

  Future<String> getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return '${position.latitude},${position.longitude}';
  }

  Future<Null> onPopContract(var value) async {
    if (value['status'] != false) {
      contractId = value['contractId'];
      var res = await Sqlite().query('CONTRACT',
          select: 'Contract_number', where: 'ID = $contractId', firstRow: true);
      contractNumber = res['Contract_number'];
      setState(() {});
    }
  }

  Future<Null> getContract() async {
    if (widget.isOnline) {
      // billData['billNumber']
      var res = await client.post(
          'https://landgreen.ml/system/public/api/getContractOnline',
          body: {'Bill_number': '${billData['billNumber']}'});
      var tmp = jsonDecode(res.body);
      print(tmp.toString() == '[]');
      if (tmp.toString() != '[]') {
        var dataSet = tmp[0];
        contractId = dataSet['ID'];
        contractNumber = dataSet['Contract_number'];
      }
    } else {
      var res = await Sqlite().query('CONTRACT',
          firstRow: true,
          where: 'Bill_id = ${widget.billId}',
          select: 'Contract_number,ID');
      if (res != null) {
        contractId = res['ID'];
        contractNumber = res['Contract_number'];
      }
    }
  }

  Future<Null> getReceipt() async {
    if (widget.receiptId != null) {
      if (widget.isOnline) {
        print('getReceipt isOnline');
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        var res = await client.get(
            'https://landgreen.ml/system/public/api/getReceiptByDocNumber/${widget.receiptNumber}');
        // var res = await client.post(
        //     'https://landgreen.ml/system/public/api/getDocBillOnline',
        //     body: {'Docbill_id': '${widget.billId}'});
        var tmp = jsonDecode(res.body);
        var dataSet = tmp[0];
        billData['receiptNumber'] = dataSet['Receipt_number'];
        signatureBase64 = dataSet['Image_signature'].split('base64,')[1];
        signatureDate = dataSet['Signature_date'];
        receiptNumber = dataSet['Receipt_number'];
        var imgText = dataSet['Image_receive'];
        if (imgText != null) {
          var imgList = jsonDecode(imgText);
          imgList.forEach((val) {
            print(val);
            if (File('$appDocPath/${val.split('/')[2]}').existsSync()) {
              imageList.add(File('$appDocPath/${val.split('/')[2]}'));
            } else {
              imageUrl.add(val);
            }
            // imageList.add(File('$appDocPath/${val.split('/')[4]}'));
          });
          print(imageUrl);
        }
      } else {
        print('getReceipt isOffline');
        var res = await Sqlite().query('RECEIPT',
            firstRow: true, where: 'ID = ${widget.receiptId}');
        billData['receiptNumber'] = res['Receipt_number'];
        if (res['Image_signature'].startsWith('data')) {
          signatureBase64 = res['Image_signature'].split('base64,')[1];
        } else {
          signatureBase64 = res['Image_signature'];
        }
        signatureDate = res['Signature_date'];
        receiptNumber = res['Receipt_number'];
        var imgText = res['Image_receive'];
        if (imgText != null) {
          var imgList = jsonDecode(imgText);
          print(widget.isOnline);
          imgList.forEach((val) {
            print(val.toString());
            if (val.toString().split('sales_receipt/').length > 1) {
              chkImgRcvNet = true;
              imageUrl.add(val);
            } else {
              imageList.add(File(val));
            }
          });
        }
      }
      // signatureBase64, signatureDate
    }
  }

  Future<Null> getSettingCompany() async {
    var res = await Sqlite().query('SETTING_COMPANY', firstRow: true);
    settingCompany['name'] = res['Name'];
    settingCompany['address'] = res['Address'];
    settingCompany['taxCode'] = res['Tax_code'];
    settingCompany['zipCode'] = res['Zip_code'];
    settingCompany['phone'] = res['Phone'];
    settingCompany['mobile'] = res['Mobile'];
    settingCompany['sign'] = res['Img_sign_ceo'];
    // isLoaded = Future.value(true);
  }

  Future<String> getSaleProvince(int provinceId) async {
    var res = await Sqlite()
        .query('PROVINCE', where: 'PROVINCE_ID = $provinceId', firstRow: true);
    return res['PROVINCE_NAME'];
  }

  Future<Null> genRows(String orderDetail) async {
    List orderDetails = jsonDecode(orderDetail);
    rowsWidget = [];
    Size size = MediaQuery.of(context).size;
    rowsPDF = [];
    print("genRows");
    ttf = pw.Font.ttf(await rootBundle.load("assets/fonts/Heven.ttf"));

    var baseFontStype = pw.TextStyle(font: ttf, fontSize: 13.0);
    rowsPDF.add(pw.TableRow(children: [
      pw.Text('#', style: baseFontStype),
      pw.Text('รายการสินค้า', style: baseFontStype),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('จำนวน', style: baseFontStype),
      ),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('ราคาต่อหน่วย', style: baseFontStype),
      ),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('รวมเป็นเงิน', style: baseFontStype),
      )
    ]));

    var sumQty = 0;
    var sumMoney = 0;
    var i = 0;
    for (var order in orderDetails) {
      File img = File(
          "${(await getApplicationDocumentsDirectory()).path}/product_image_${order['product_id']}.png");
      print(img.existsSync());
      // img = await getImage(order['product_id']);
      rows.add(DataRow(cells: [
        DataCell(Text('${i + 1}')),
        DataCell(!img.existsSync()
            ? SizedBox(
                height: 100,
                child: Image.asset('assets/no_image.png'),
              )
            : SizedBox(
                height: 100,
                width: 50,
                child: Image.file(img),
              )), //รูปภาพ รอแปปนะ
        DataCell(Text('${order['name']}')),
        DataCell(Text('${order['qty']}')),
        DataCell(Text('${order['price_sell']}')),
        DataCell(Text('${order['qty'] * order['price_sell']}'))
      ]));

      rowsPDF.add(pw.TableRow(children: [
        pw.Text('${i + 1}', style: baseFontStype),
        pw.Text('${order['name']}', style: baseFontStype),
        pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text('${order['qty']}', style: baseFontStype),
        ),
        pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text('${order['price_sell']}', style: baseFontStype),
        ),
        pw.Align(
          alignment: pw.Alignment.bottomRight,
          child: pw.Text('${order['qty'] * order['price_sell']}',
              style: baseFontStype),
        ),
      ]));

      var _imageProduct;
      if (File(
              "${(await getApplicationDocumentsDirectory()).path}/product_image_${order['product_id']}.png")
          .existsSync()) {
        _imageProduct = Image.file(File(
            "${(await getApplicationDocumentsDirectory()).path}/product_image_${order['product_id']}.png"));
      } else {
        _imageProduct = Image.asset('assets/no_image.png');
      }

      rowsWidget.add(Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
                child: SizedBox(
              child: _imageProduct,
              width: size.width * 0.35,
              height: size.height * 0.2,
            )),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายการที่ : ${(i + 1)}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'ชื่อสินค้า : ${order['name']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'จำนวน : ${order['qty']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'ราคาต่อหน่วย : ${order['price_sell']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'รวมเป็นเงิน : ${(order['qty'] * order['price_sell'])}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
          //
        ),
      ));

      sumQty += order['qty'];
      sumMoney += order['qty'] * order['price_sell'];
      i++;
    }
    rows.add(DataRow(cells: [
      DataCell(Text('')),
      DataCell(Text('')),
      DataCell(Text('รวมทั้งสิ้น')),
      DataCell(Text('$sumQty')),
      DataCell(Text('')),
      DataCell(Text('$sumMoney'))
    ]));

    rowsPDF.add(pw.TableRow(children: [
      pw.Text(' ', style: baseFontStype),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('รวมทั้งสิ้น', style: baseFontStype),
      ),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('$sumQty', style: baseFontStype),
      ),
      pw.Text(' ', style: baseFontStype),
      pw.Align(
        alignment: pw.Alignment.bottomRight,
        child: pw.Text('$sumMoney', style: baseFontStype),
      ),
    ]));

    rowsWidget.add(Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 25, top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'รวมทั้งสิ้น',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'จำนวน : ${sumQty} ชิิ้น',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'เป็นเงิน : ${sumMoney} บาท',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
        //
      ),
    ));
  }

  Future<Null> getProductCanSell(int saleId) async {
    _productCanSell = await Sqlite().getProductCanSell(saleId);
  }

  Future<String> getAge(String date) async {
    DateTime dob = DateTime.parse(date);
    DateTime now = DateTime.now();
    var age = now.year - dob.year;
    int dobDayOfYear = int.parse(DateFormat("D").format(dob));
    int nowDayOfYear = int.parse(DateFormat("D").format(now));
    if (nowDayOfYear < dobDayOfYear) {
      age--;
    }
    return age.toString();
  }

  Future<Null> getBillData() async {
    var res;
    var dataSet;
    if (widget.isOnline) {
      res = await client.post(
          'https://landgreen.ml/system/public/api/getDocBillOnline',
          body: {'Docbill_id': '${widget.billId}'});
      var tmp = jsonDecode(res.body);
      print(tmp);
      dataSet = tmp[0];
      await getProductCanSell(dataSet['User_id']);
      await genRows(dataSet['Order_detail']);
      billData['billOrderDetail'] = dataSet['Order_detail'];
      billData['cName'] = dataSet['Name'] + " " + dataSet['Surname'];
      billData['cAddress'] = dataSet['Address'];
      billData['cProvince'] = dataSet['PROVINCE_NAME'];
      billData['cDistrict'] = dataSet['AMPHUR_NAME'];
      billData['cSubDistrict'] = dataSet['DISTRICT_NAME'];
      billData['cZipCode'] = dataSet['Zipcode'];
      billData['cTel'] = dataSet['Phone'];
      billData['sendDate'] = dataSet['Date_send'];
      billData['saleUsername'] = dataSet['Username'];
      billData['saleProvince'] =
          await getSaleProvince(dataSet['Sales_Province_id']);
      billData['saleName'] =
          dataSet['sales_name'] + " " + dataSet['sales_surname'];
      billData['billNumber'] = dataSet['Bill_number'];
      billData['billPayType'] = dataSet['Pay_type'];
      billData['saleUserId'] = dataSet['User_id'];
      billData['billId'] = widget.billId;
      billData['cYearOld'] = await getAge(dataSet['Birthday']);
      billData['moneyEarnest'] = dataSet['Money_earnest'];
      billData['moneyDue'] = dataSet['Money_due'];
      billData['dateDue'] = dataSet['Date_due'];
      print(billData);
    } else {
      res = await Sqlite().getOfflineBill(widget.billId);
      dataSet = res[0];
      await getProductCanSell(dataSet['User_id']);
      await genRows(dataSet['Order_detail']);
      billData['billOrderDetail'] = dataSet['Order_detail'];
      billData['cName'] = dataSet['Name'] + " " + dataSet['Surname'];
      billData['cAddress'] = dataSet['Address'];
      billData['cProvince'] = dataSet['PROVINCE_NAME'];
      billData['cDistrict'] = dataSet['AMPHUR_NAME'];
      billData['cSubDistrict'] = dataSet['DISTRICT_NAME'];
      billData['cZipCode'] = dataSet['Zipcode'];
      billData['cTel'] = dataSet['Phone'];
      billData['sendDate'] = dataSet['Date_send'];
      billData['saleUsername'] = dataSet['Username'];
      billData['saleProvince'] =
          await getSaleProvince(dataSet['saleProvinceId']);
      billData['saleName'] = dataSet['saleName'] + " " + dataSet['saleSurname'];
      billData['billNumber'] = dataSet['Bill_number'];
      billData['billPayType'] = dataSet['Pay_type'];
      billData['saleUserId'] = dataSet['User_id'];
      billData['billId'] = widget.billId;
      billData['cYearOld'] = await getAge(dataSet['Birthday']);
      billData['moneyEarnest'] = dataSet['Money_earnest'];
      billData['moneyDue'] = dataSet['Money_due'];
      billData['dateDue'] = dataSet['Date_due'];
    }
  }

  void pickImage(BuildContext context) async {
    showPicker(context);
  }

  Widget PrintPDF() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomButton(
          text: 'ดาวน์โหลดใบเสร็จ',
          onPress: () async {
            print('ดาวน์โหลดใบเสร็จ');
            var pdf = pw.Document();

            // final ttf = pw.Font.ttf(await rootBundle.load("assets/fonts/Heven.ttf"));

            // pdf.addPage(
            //     pw.Page(
            //     pageFormat: PdfPageFormat.a4,
            //     build: (pw.Context context) {
            //       return pw.Center(
            //         child: pw.Text('test\n', style: pw.TextStyle(font: ttf, fontSize: 40)),
            //       ); // Center
            //     })
            // );
            var pdfImageSign = pw.MemoryImage(base64Decode(signatureBase64));
            Uint8List imglogo = (await rootBundle.load("assets/img/logo.png"))
                .buffer
                .asUint8List();
            var pdfImageLogo = pw.MemoryImage(imglogo);
            var baseFontStype = pw.TextStyle(font: ttf, fontSize: 13.0);

            pdf.addPage(
              pw.MultiPage(
                  pageFormat: PdfPageFormat.a4,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  build: (pw.Context context) => <pw.Widget>[
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.SizedBox(
                                width: 80,
                                child: pw.Image(pdfImageLogo),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      '${settingCompany['name']}',
                                      style: pw.TextStyle(
                                          font: ttf, fontSize: 16.0),
                                    ),
                                    pw.Text(
                                      'เลขประจำตัวผู้เสียภาษี ${settingCompany['taxCode']}',
                                      style: pw.TextStyle(
                                          font: ttf, fontSize: 14.0),
                                    ),
                                    pw.Text(
                                      '${settingCompany['address']} ${settingCompany['zipCode']}',
                                      style: pw.TextStyle(
                                          font: ttf, fontSize: 10.0),
                                    ),
                                    pw.Text(
                                      'โทร ${settingCompany['phone']}, ${settingCompany['mobile']}',
                                      style: pw.TextStyle(
                                          font: ttf, fontSize: 10.0),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            pw.Expanded(
                                flex: 3,
                                child: pw.Column(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    children: [
                                      pw.Text(
                                        'ใบส่งสินค้า / ใบเสร็จรับเงิน',
                                        style: pw.TextStyle(
                                            font: ttf, fontSize: 20.0),
                                      ),
                                      pw.Text(
                                        '${billData['billPayType'] == 1 ? 'เงินสด' : 'เครดิต'}',
                                        style: pw.TextStyle(
                                            font: ttf, fontSize: 20.0),
                                      ),
                                      pw.Text(
                                        'เอกสารเลขที่ : ${billData['receiptNumber']}',
                                        style: pw.TextStyle(
                                            font: ttf, fontSize: 14.0),
                                      )
                                    ]))
                          ],
                        ),
                        pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                  flex: 5,
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                            'ชื่อลูกค้า : ${billData['cName']}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'ที่อยู่ลูกค้า : ${billData['cAddress']} ตำบล${billData['cSubDistrict']} อำเภอ${billData['cDistrict']} จังหวัด${billData['cProvince']} ${billData['cZipCode']}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'โทรศัพท์ : ${billData['cTel']}',
                                            style: baseFontStype),
                                      ])),
                              pw.Expanded(
                                  flex: 2,
                                  child: pw.Column(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                            'วันที่จัดส่ง : ${FormatMethod().ThaiFormat(billData['sendDate'])}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'รหัสพนักงานขาย : ${billData['saleUsername']}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'เขตการขาย : ${billData['saleProvince']}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'ผู้ส่งสินค้า : ${billData['saleName']}',
                                            style: baseFontStype),
                                        pw.Text(
                                            'เลขที่ใบสั่งจอง : ${billData['billNumber']}',
                                            style: baseFontStype),
                                      ])),
                            ]),
                        pw.SizedBox(
                          height: 20,
                        ),
                        pw.Table(
                          children: rowsPDF,
                          border: pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                  width: 1,
                                  color: PdfColor.fromHex('999999'),
                                  style: pw.BorderStyle.solid)),
                          tableWidth: pw.TableWidth.max,
                        ),
                        pw.SizedBox(
                          height: 20,
                        ),
                        pw.Text(
                          '''หมายเหตุ : เมื่อโอนเงินเข้าบัญชี แล้วกรุณาโทรแจ้งที่หมายเลข ${settingCompany['mobile']} ทันทีที่โอน \nการส่งมอบสินค้าตามที่ระบุ ประเภท ชนิด และปริมาณตามที่ระบุไว้ ไม่ว่าจะผู้ซื้อหรือ\nผู้แทนของผู้ซื้อหรือบุคคลใดที่เกี่ยวข้องกับผู้ซื้อหรือได้ส่งมอบสินค้า ณ ที่ทำการของผู้ซื้อ\nหรือสถานที่ตามที่ผู้ซื้อกำหนดไว้แล้ว ถือว่าผู้ขายได้ส่งมอบสินค้าแก่ผู้ซื้อเรียบร้อยแล้ว \nกรณีสินค้าไม่ถูกต้องครบถ้วนหรือชำรุดบกพร่อง ผู้ซื้อจะต้องแจ้งให้ผู้ขายทราบโดยทันที \nมิฉะนั้นจะไม่รับผิดชอบใดๆ ทั้งสิ้น''',
                          style: pw.TextStyle(font: ttf, fontSize: 11.0),
                        ),
                        pw.SizedBox(
                          height: 30,
                        ),
                        pw.Text('ได้รับสินค้าตามรายการถูกต้องแล้ว',
                            style: baseFontStype),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Image(pdfImageSign),
                        ),
                        pw.SizedBox(
                          height: 10,
                        ),
                        pw.Text(
                            'วันที่รับสินค้า ${FormatMethod().ThaiDateFormat(signatureDate == null ? DateTime.now().toString().split(' ')[0] : signatureDate.split(' ')[0])}',
                            style: baseFontStype)
                      ]),
            );

            await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => await pdf.save())
                .then((value) {
              locator<NavigationService>().moveWithArgsTo(
                  'createReceipt',
                  ScreenArguments(
                      billId: widget.billId,
                      userId: widget.userId,
                      isBillOnline: widget.isOnline,
                      receiptId: widget.receiptId));
            });
          }),
    );
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
                titleSpacing: 0.00,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bgTop2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: size.width,
                // height: double.infinity, //ใส่ ScrollView แล้วกำหนด height ไม่ได้ มั้ง
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          FutureBuilder(
                              future: isLoaded,
                              builder: (context, data) {
                                if (data.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      children: [
                                        if (billData['receiptNumber'] != null)
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'เอกสารเลขที่ : ${billData['receiptNumber']}',
                                                  style:
                                                      TextStyle(fontSize: 18.0),
                                                ),
                                              ),
                                              if (signatureBase64 != null)
                                                Expanded(
                                                  flex: 1,
                                                  child: PrintPDF(),
                                                ),
                                            ],
                                          ),
                                        if (billData['receiptNumber'] != null)
                                          MyDivider(),
                                        ReceiptHeader(
                                          settingCompany: settingCompany,
                                          billData: billData,
                                          rows: rows,
                                          isOnline: widget.isOnline,
                                        ),
                                        FormCard(
                                          title:
                                              'รายการสินค้าที่ลูกค้าสั่งซื้อ',
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, top: 8.0, right: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: (rowsWidget.isNotEmpty)
                                                  ? rowsWidget
                                                  : [
                                                      ShimmerLoading(
                                                        type: 'boxItem',
                                                      )
                                                    ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            '''หมายเหตุ : เมื่อโอนเงินเข้าบัญชี แล้วกรุณาโทรแจ้งที่หมายเลข ${settingCompany['mobile']} ทันทีที่โอน การส่งมอบสินค้าตามที่ระบุ ประเภท ชนิด และปริมาณตามที่ระบุไว้ ไม่ว่าจะผู้ซื้อหรือผู้แทนของผู้ซื้อหรือบุคคลใดที่เกี่ยวข้องกับผู้ซื้อหรือได้ส่งมอบสินค้า ณ ที่ทำการของผู้ซื้อหรือสาถานที่ตามที่ผู้ซื้อกำหนดไว้แล้ว ถือว่าผู้ขายได้ส่งมอบสินค้าแก่ผู้ซื้อเรียบร้อยแล้ว กรณีสินค้าไม่ถูกต้องครบถ้วนหรือชำรุดบกพร่อง ผู้ซื้อจะต้องแจ้งให้ผู้ขายทราบโดยทันที มิฉะนั้นจะไม่รับผิดชอบใดๆ ทั้งสิ้น''',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                        if (contractId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: InkWell(
                                              onTap: () {
                                                locator<NavigationService>()
                                                    .navigateTo(
                                                        'createContract',
                                                        ScreenArguments(
                                                            billId:
                                                                widget.billId,
                                                            userId:
                                                                widget.userId,
                                                            contractId:
                                                                contractId,
                                                            isBillOnline:
                                                                widget.isOnline,
                                                            contractInfo: {
                                                              'companyInfo':
                                                                  settingCompany,
                                                              'billData':
                                                                  billData
                                                            }));
                                              },
                                              child: Text(
                                                'ไฟล์แนบสัญญาซื้อขายเลขที่ $contractNumber',
                                                style: TextStyle(
                                                    color: kPrimaryColor),
                                              ),
                                            ),
                                          ),
                                        if (billData['billPayType'] == 2)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              'คำเตือน: ให้แนบภาพถ่ายทั้งหมดตามนี้นะครับ \nหากไม่ปฎิบัติตามระบบจะทำการตัดบิลเป็นบิล "ไม่ได้รับค่าคอม" ทันที\n' +
                                                  '1) แนบรูปภาพผู้รับสินค้า\n' +
                                                  '2) แนบสำเนาบัตรประจำตัวประชาชนลูกค้า พร้อมลายเซ็นว่า "ใช้ในการซื้อปุ๋ยเท่านั้น"\n' +
                                                  '3) แนบสำเนาทะเบียนบ้านลูกค้า พร้อมลายเซ็นว่า "ใช้ในการซื้อปุ๋ยเท่านั้น"',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: dangerColor),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: ShimmerLoading(
                                      type: 'boxItem',
                                    ),
                                  );
                                }
                              }),
                          if (widget.receiptId == null || imageList.isNotEmpty)
                            imageList.isEmpty && widget.receiptId == null
                                ? Center(
                                    child: ImagePickerBox(
                                      onTap: () {
                                        showPicker(context);
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: size.width * 0.9,
                                          height: size.height * 0.3,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: imageList.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Row(
                                                  children: [
                                                    Image.file(
                                                        imageList[index]),
                                                    SizedBox(
                                                      width: 10,
                                                    )
                                                  ],
                                                );
                                              })),
                                      widget.receiptId == null
                                          ? Center(
                                              child: ImagePickerBox(
                                                onTap: () {
                                                  showPicker(context);
                                                  print(imageList);
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Container(
                                              child: Text(''),
                                            ))
                                    ],
                                  ),
                          if (widget.isOnline == true &&
                              imageList.isEmpty &&
                              imageUrl.isNotEmpty)
                            Column(
                              children: [
                                Container(
                                    width: size.width * 0.9,
                                    height: size.height * 0.3,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrl.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      ShimmerLoading(
                                                    type: 'imageSquare',
                                                  ),
                                                  imageUrl:
                                                      'https://landgreen.ml/system/storage/app/${imageUrl[index]}',
                                                  errorWidget:
                                                      (context, url, error) {
                                                    // print(rank);
                                                    // print(error);
                                                    return ShimmerLoading(
                                                      type: 'imageSquare',
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        })),
                              ],
                            ),
                          if (chkImgRcvNet == true &&
                              imageList.isEmpty &&
                              imageUrl.isNotEmpty)
                            Column(
                              children: [
                                Container(
                                    width: size.width * 0.9,
                                    height: size.height * 0.3,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrl.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      ShimmerLoading(
                                                    type: 'imageSquare',
                                                  ),
                                                  imageUrl:
                                                      'https://landgreen.ml/system/storage/app/${imageUrl[index]}',
                                                  errorWidget:
                                                      (context, url, error) {
                                                    // print(rank);
                                                    // print(error);
                                                    return ShimmerLoading(
                                                      type: 'imageSquare',
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        })),
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          FutureBuilder(
                              future: isLoaded,
                              builder: (context, data) {
                                if (data.hasData) {
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: signatureBase64 != null
                                                ? SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: Image.memory(
                                                        base64Decode(
                                                            signatureBase64)),
                                                  )
                                                : SignPart(
                                                    size: size,
                                                    controller: _controller,
                                                    clear: _clearSign,
                                                    cancel: () =>
                                                        _cancelSign(context),
                                                    confirm: () =>
                                                        _confirmSign(context),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          if (billData['billPayType'] == 2 &&
                                              contractId == null)
                                            Flexible(
                                              child: Column(
                                                children: [
                                                  Text('สัญญาการซื้อขาย',
                                                      style: TextStyle(
                                                          fontSize: 20.0)),
                                                  CustomButton(
                                                    text: 'เซ็นสัญญาซื้อขาย',
                                                    onPress: () {
                                                      locator<NavigationService>()
                                                          .navigateTo(
                                                              'createContract',
                                                              ScreenArguments(
                                                                  billId: widget
                                                                      .billId,
                                                                  userId: widget
                                                                      .userId,
                                                                  isBillOnline:
                                                                      widget
                                                                          .isOnline,
                                                                  contractInfo: {
                                                                    'companyInfo':
                                                                        settingCompany,
                                                                    'billData':
                                                                        billData
                                                                  }))
                                                          .then((value) =>
                                                              onPopContract(
                                                                  value));
                                                    },
                                                  )
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                      MyDivider(),
                                      Text(
                                          'วันที่รับสินค้า ${FormatMethod().ThaiDateFormat(signatureDate == null ? DateTime.now().toString().split(' ')[0] : signatureDate.split(' ')[0])}'),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (widget.receiptId == null)
                                            CustomButton(
                                              onPress: () async {
                                                await submitReceipt(context);
                                              },
                                              text: 'บันทึก',
                                            ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CustomButton(
                                            onPress: () =>
                                                Navigator.of(context).pop(),
                                            text: 'กลับ',
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                        ],
                      ),
                    ),
                    Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> submitReceipt(context) async {
    if (billData['billPayType'] == 2 && contractId == null) {
      ShowModalBottom().alertDialog(context, 'กรุณาสร้างสัญญาซื้อขาย');
    } else {
      if (signatureBase64 != null) {
        FormatMethod f = FormatMethod();
        DateTime now = DateTime.now();
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        String location = await getPosition();
        Map<String, dynamic> data = {
          'ID': widget.receiptId,
          'Bill_id': widget.billId,
          'User_id': billData['saleUserId'],
          'Image_signature': signatureBase64,
          'Signature_date': signatureDate,
          'Edit_user_id': widget.userId,
          'receipt_location': location,
        };
        if (widget.receiptId == null) {
          var recNumber =
              'R${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
          data['Receipt_number'] = recNumber;
        } else {
          data['Receipt_number'] = receiptNumber;
        }
        List imageListCopy = [];
        File tmp;
        var filename =
            '${now.year}${f.PadLeft(now.month)}${f.PadLeft(now.day)}${f.PadLeft(now.hour)}${f.PadLeft(now.minute)}${f.PadLeft(now.second)}_${widget.userId}';
        if (imageList.length > 0) {
          imageList.asMap().forEach((i, val) {
            tmp = val.copySync('$appDocPath/${filename}_$i.jpeg');
            imageListCopy.add(tmp.path);
          });
          data['Image_receive'] = jsonEncode(imageListCopy);
        }
        await Sqlite().insertReceipt(data);
        Navigator.pop(context);
        await locator<NavigationService>()
            .moveWithArgsTo('showBill', ScreenArguments(userId: widget.userId));
      } else {
        ShowModalBottom().alertDialog(context, 'กรุณาเซ็นยืนยัน');
      }
    }
  }

  void _clearSign() {
    _controller.clear();
    setState(() {});
  }

  void _cancelSign(context) {
    _controller.clear();
    Navigator.of(context).pop();
    setState(() {});
  }

  Future<void> _confirmSign(context) async {
    if (_controller.isNotEmpty) {
      signatureBase64 = base64Encode(await _controller.toPngBytes());
      signatureDate = DateTime.now().toString().split('.')[0];
      setState(() {});
    }
    Navigator.of(context).pop();
  }

  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('รูปภาพในเครื่อง'),
                      onTap: () {
                        pickImg(true);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('กล้อง'),
                    onTap: () {
                      pickImg(false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future pickImg(bool isFromGallary) async {
    if (isFromGallary) {
      //Pick from gallary
      final pickedFile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageList.add(File(pickedFile.path));
        setState(() {});
      }
    } else {
      //Pick from camera
      final pickedFile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        imageList.add(File(pickedFile.path));
        setState(() {});
      }
    }
  }
}
