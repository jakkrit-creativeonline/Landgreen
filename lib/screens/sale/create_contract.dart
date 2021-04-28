import 'dart:convert';

import 'package:system/components/custom_button.dart';
import 'package:system/components/show_modal_bottom_sheet.dart';
import 'package:system/components/show_sign.dart';
import 'package:system/components/sign_part.dart';
import 'package:system/components/square_input.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;

class CreateContract extends StatefulWidget {
  final int billId;
  final int userId;
  final Map contractInfo;
  final int contractId;
  final bool isOnline;

  const CreateContract(
      {Key key,
      this.billId,
      this.userId,
      this.contractInfo,
      this.contractId,
      this.isOnline})
      : super(key: key);

  @override
  _CreateContractState createState() => _CreateContractState();
}

class _CreateContractState extends State<CreateContract> {
  var _book = TextEditingController(),
      other1 = TextEditingController(),
      other1Rela = TextEditingController(),
      other1Tel = TextEditingController(),
      other2 = TextEditingController(),
      other2Rela = TextEditingController(),
      other2Tel = TextEditingController(),
      ref1 = TextEditingController(),
      ref2 = TextEditingController(),
      contractNumber = TextEditingController();
  String saleSign, customerSign, ref1Sign, ref2Sign;
  final SignatureController _sale = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _customer = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _ref1 = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final SignatureController _ref2 = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Map<String, dynamic> product = {'qty': 0, 'sumPrice': 0};

  String customerSignDate;

  Future<Null> getProduct() async {
    saleSign = widget.contractInfo['companyInfo']['sign'];
    _book.text = DateTime.now().year.toString();
    var orderDetails =
        jsonDecode(widget.contractInfo['billData']['billOrderDetail']);
    for (var order in orderDetails) {
      if (order['cat_id'] == 1) {
        product['brand'] = order['name'].split('ตรา')[1];
        product['qty'] += order['qty'];
        product['sumPrice'] += order['qty'] * order['price_sell'];
        product['price'] = order['price_sell'];
      }
    }
  }

  Future<Null> getContractData() async {
    if (widget.contractId != null) {
      if (widget.isOnline) {
        var client = http.Client();
        var res = await client.post(
            'https://landgreen.ml/system/public/api/getContractOnline',
            body: {
              'Bill_number': '${widget.contractInfo['billData']['billNumber']}'
            });
        var tmp = jsonDecode(res.body);
        var dataSet = tmp[0];
        _book.text = dataSet['Book_number'];
        contractNumber.text = dataSet['Contract_number'];
        other1.text = dataSet['Other_name_1'];
        other1Rela.text = dataSet['Other_relationship_1'];
        other1Tel.text = dataSet['Other_phone_1'];
        other2.text = dataSet['Other_name_2'];
        other2Rela.text = dataSet['Other_relationship_2'];
        other2Tel.text = dataSet['Other_phone_2'];
        customerSign = dataSet['Image_signature'].split('base64,')[1];
        ref1Sign = dataSet['Image_signature_witness_1'].split('base64,')[1];
        ref2Sign = dataSet['Image_signature_witness_2'].split('base64,')[1];
        ref1.text = dataSet['Witness_name_1'];
        ref2.text = dataSet['Witness_name_2'];
      } else {
        var res = await Sqlite().query('CONTRACT',
            firstRow: true, where: 'ID = ${widget.contractId}');
        _book.text = res['Book_number'];
        contractNumber.text = res['Contract_number'];
        other1.text = res['Other_name_1'];
        other1Rela.text = res['Other_relationship_1'];
        other1Tel.text = res['Other_phone_1'];
        other2.text = res['Other_name_2'];
        other2Rela.text = res['Other_relationship_2'];
        other2Tel.text = res['Other_phone_2'];
        customerSign = res['Image_signature'];
        ref1Sign = res['Image_signature_witness_1'];
        ref2Sign = res['Image_signature_witness_2'];
        ref1.text = res['Witness_name_1'];
        ref2.text = res['Witness_name_2'];
      }
      setState(() {});
    }
  }

  void _clearSign(SignatureController controller) {
    controller.clear();
    setState(() {});
  }

  void _cancelSign(context, SignatureController controller) {
    controller.clear();
    Navigator.of(context).pop();
    setState(() {});
  }

  void _confirmSign(context, int i) async {
    switch (i) {
      case 1:
        if (_sale.isNotEmpty) {
          saleSign = base64Encode(await _sale.toPngBytes());
        }
        break;
      case 2:
        if (_customer.isNotEmpty) {
          customerSign = base64Encode(await _customer.toPngBytes());
          customerSignDate = DateTime.now().toString().split('.')[0];
        }
        break;
      case 3:
        if (_ref1.isNotEmpty) {
          ref1Sign = base64Encode(await _ref1.toPngBytes());
        }
        break;
      case 4:
        if (_ref2.isNotEmpty) {
          ref2Sign = base64Encode(await _ref2.toPngBytes());
        }
        break;
    }
    Navigator.of(context).pop();
    setState(() {});
  }

  Future<Null> submitContract(context) async {
    if (other1.text.isEmpty ||
        other1Rela.text.isEmpty ||
        other1Tel.text.isEmpty ||
        saleSign == null ||
        customerSign == null ||
        ref1Sign == null ||
        ref2Sign == null) {
      ShowModalBottom().alertDialog(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
    } else {
      DateTime now = DateTime.now();
      String contractNumber =
          'CV${now.year}${FormatMethod().PadLeft(now.month)}${FormatMethod().PadLeft(now.day)}${FormatMethod().PadLeft(now.hour)}${FormatMethod().PadLeft(now.minute)}${FormatMethod().PadLeft(now.second)}_${widget.userId}';
      var data = {
        'id': widget.contractId,
        'contractNumber': contractNumber,
        'billId': widget.billId,
        'userId': widget.contractInfo['billData']['saleUserId'],
        'imageSignature': customerSign,
        'signatureDate': customerSignDate,
        'imageSignatureWitness1': ref1Sign,
        'witnessName1': ref1.text,
        'imageSignatureWitness2': ref2Sign,
        'witnessName2': ref2.text,
        'otherName1': other1.text,
        'otherRela1': other1Rela.text,
        'otherPhone1': other1Tel.text,
        'otherName2': other2.text,
        'otherRela2': other2Rela.text,
        'otherPhone2': other2Tel.text,
        'bookNumber': _book.text,
        'editUserId': widget.userId,
      };
      int contractId = await Sqlite().insertContract(data);
      Navigator.of(context).pop({'status': true, 'contractId': contractId});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getProduct();
    getContractData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _book.dispose();
    other1.dispose();
    other1Rela.dispose();
    other1Tel.dispose();
    other2.dispose();
    other2Rela.dispose();
    other2Tel.dispose();
    ref1.dispose();
    ref2.dispose();
    super.dispose();
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
            body: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0.0),
                width: size.width,
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/logo.png'),
                        colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.2), BlendMode.dstATop))),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'เล่มที่ : ',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                Flexible(
                                    child: SquareInput(
                                  hintText: '${DateTime.now().year}',
                                  textController: _book,
                                )),
                                if (contractNumber.text.isNotEmpty)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'เลขที่ : ',
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                        Expanded(
                                          child: SquareInput(
                                            textController: contractNumber,
                                            enable: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Center(
                              child: Text(
                                'สัญญาซื้อปุ๋ยทางการเกษตร',
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ),
                            Center(
                              child: Text(
                                '(สินเชื่อโครงการใช้สบายจ่ายสบาย)',
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                      'วันที่ ${FormatMethod().ThaiFormat(DateTime.now().toString().split(' ')[0])}'),
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'ทำที่ ',
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '${widget.contractInfo['companyInfo']['name']}',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            )),
                                        // can add more TextSpans here...
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text.rich(
                              TextSpan(
                                text:
                                    '    สัญญาฉบับนี้ทำขึ้นระหว่าง ${widget.contractInfo['companyInfo']['name']} โดยนางโดยนางตรีพิพัฒน์  ศิลปการสกุล',
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        'กรรมการผู้มีอำนาจ สำนักงานตั้งอยู่เลขที่ 9/69 ถนนนวมินทร์ 70 แขวงคลองกุ่ม เขตบึงกุ่ม กรุงเทพฯ ซึ่งต่อไปในสัญญานี้จะเรียกว่า "ผู้ขาย" ฝ่ายหนึ่งกับ ',
                                  ),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cName']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' อายุ '),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cYearOld']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' ปี บ้านเลขที่ '),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cAddress']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' แขวง/ตำบล '),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cSubDistrict']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: 'เขต/อำเภอ '),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cDistrict']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: 'จังหวัด '),
                                  TextSpan(
                                      text:
                                          '${widget.contractInfo['billData']['cProvince']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(
                                      text:
                                          'ซึ่งต่อไปในสัญญานี้จะเรียกว่า "ผู้ซื้อ" อีกฝ่ายหนึ่ง คู่สัญญาทั้งสองฝ่ายตกลงทำสัญญากันมีข้อความ ดังต่อไปนี้'),
                                  // can add more TextSpans here...
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text:
                                    '     ข้อ 1. ผู้ซื้อและผู้ขายตกลงซื้อขาย ปุ๋ยยาทางการเกษตร ตรา ',
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${product['brand']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' จำนวน '),
                                  TextSpan(
                                      text: '${product['qty']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' น้ำหนักบรรจุ/ราคาต่อหน่วย '),
                                  TextSpan(
                                      text: '${product['price']}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' ราคา '),
                                  TextSpan(
                                      text:
                                          '${FormatMethod().SeperateNumber(product['sumPrice'])}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' บาท ('),
                                  TextSpan(
                                      text:
                                          '${BahtText().convertFullMoney(product['sumPrice'])}',
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(
                                      text:
                                          ') และ/หรือตาม กำหนดไว้ใบส่งสินค้าใบเสร็จซึ่งระบุจำนวนประเภทชนิด ราคาและปริมาณซึ่งต่อไปในสัญญานี้จะเรียกว่า "สินค้า"'),
                                  // can add more TextSpans here...
                                ],
                              ),
                            ),
                            Text(
                                '     ข้อ 2. ผู้ซื้อจะต้องชำระราคาตามใบส่งสินค้า/ใบเสร็จที่ตกลงไว้กับผู้ขายภายในการกำหนดระยะเวลาที่ผู้ขายแจ้งระบุไว้ในข้อ 1.และให้ถือว่าเอกสารดังกล่าวป็นส่วนหนึ่งของสัญญาฉบับนี้'),
                            Text(
                                '     ข้อ 3. ถ้าปรากฎว่าสินค้าผู้ขายส่งมอบไม่ตรงตามสัญญาข้อ 1.ผู้ซื้อทรงไว้ซึ่งสิทธิที่จะไม่รับสินค้าโดยต้องปฎิเสธไม่รับสินค้าทันที ณ วันส่งมอบสินค้าดังกล่าว'),
                            Text(
                                '     ข้อ 4. กรณีสินค้าเกิดความชำรุดบกพร่อง ผู้ขายยินยอมดำเนินการแก้ไขให้ถูกต้องโดยผู้ซื้อไม่ต้องใช้ค่าเสียหายหรือค่าใช้จ่ายแต่ประการใดแต่ผู้ซื้อจะต้องแจ้งข้อชำรุดบกพร่องดังกล่าวให้แก่ผู้ขายทราบอย่างช้าไม่น้อยกว่า 7 วันนับตั้งแต่วันส่งมอบสินค้าดังกล่าว มิฉะนั้นจะถือว่าผู้ซื้อได้รับสินค้าในสภาพสมบูรณ์เรียบร้อย ทุกประการ'),
                            Text(
                                '     ข้อ 5. การส่งมอบสินค้าตามที่ระบุ ประเภท ชนิด และปริมาณตามข้อ 1. ไม่ว่าจะผู้ซื้อหรือผู้แทนของผู้ซื้อหรือบุคคลใดที่เกี่ยวข้องกับผู้ซื้อหรือได้ส่งมอบสินค้า ณ ที่ทำการของผู้ซื้อหรือสถานที่ตามที่ผู้ซื้อกำหนดไว้แล้วถือว่าผู้ขายได้ส่งมอบสินค้าแก่ผู้ซื้อเรียบร้อยแล้ว'),
                            Text(
                                '     ข้อ 6. กรณีที่ผู้ซื้อผิดนัดไม่ไม่ชำระราคาสินค้าให้แก่ผู้ขายภายในกำหนดตามตามข้อ 2.ผู้ซื้อตกลงให้ผู้ขายรับค่ามัดจำที่ผู้ซื้อชำระแก่ผู้ขายได้ทันทีและผู้ซื้อยินยอมให้ผู้ขายคิดดอกเบี้ยในเวลาผิดนัดนั้นในอัตราร้อยละ 15 ต่อปีนับแต่วันที่ผิดนัดถึงจนกว่าจะชำระราคาสินค้านั้นเสร็จ'),
                            Text(
                                '     ข้อ 7. กรณีผู้ซื้อผิดสัญญาทำให้ไม่สามารถส่งมอบคืนสินค้าหรือสินค้าเสื่อมสภาพหรือไร้ประโยชน์บางส่วนหรือทั้งหมดแก่ผู้ขายได้ ผู้ซื้อจะต้องชดใช้ค่าเสียหายตามราคาของสินค้าดังกล่าวและหากเป็นกรณีอื่นใดๆ ที่เกิดขึ้นหลังจากผิดนัดชำระราคาผู้ขายทรงไว้ซึ่งสิทธิจะปฎิเสธการรับคืนสินค้าได้โดยสิ้นเชิงและมีสิทธิ เรียกดอกเบี้ยได้ตามข้อ 6. และค่าเสียหายได้'),
                            Text(
                                '     ข้อ 8. กรณีที่มีเหตุสุดวิสัยหรือเหตุใดๆ อันเนื่องมาจากความผิดหรือความบกพร่องของฝ่ายผู้ซื้อหรือจากพฤติการณ์อันใดอันหนึ่งซึ่งผู้ขายไม่ต้องรับผิดชอบตามกฏหมายเป็นเหตุให้ผู้ขายไม่สามารถส่งมอบสินค้าตามเงื่อนไขและกำหนดเวลาแห่งสัญญานี้ได้ ผู้ขายมีสิทธิขอขยายเวลาในการส่งมอบสินค้าให้ผู้ซื้อทราบภายใน 15 วันนับแต่วันที่เหตุนั้นสิ้นสุดลง'),
                            Text(
                                '     ข้อ 9. หากผู้ซื้อผิดนัดสัญญาหรือไม่ปฏิบัติตามสัญญาข้อหนึ่งข้อใด ผู้ขายมีสิทธิบอกเลิกสัญญาได้ทันทีโดยผู้ซื้อยินยอมให้คิดค่าขนส่งสินค้าค่าติดตามทวงถาม ค่าทนายความ ค่าธรรมเนียมและค่าเสียหายอื่นใดอันเกิดจากผู้ซื้อเป็นฝ่ายผิดสัญญานี้ได้'),
                            Text(
                                '     ข้อ 10. บรรดาหนังสือบอกกล่าวทวงถามหรือเอกสารอื่นใดที่ผู้ขายได้ดำเนินการจัดส่งไปยังผู้ซื้อไม่ว่าจะจัดส่งโดยวิธีการใด หากได้จัดส่งไปยังภูมิลำเนาของผู้ซื้อตามที่ระบุไว้ในสัญญานี้ให้ถือว่าผู้ซื้อหรือผู้รับไว้แทนผู้ซื้อได้รับหนังสือและทราบรายละเอียดแล้ว'),
                            Text(
                                '     ข้อ 11. ผู้ซื้อยินยอมให้ผู้ขายหรือได้รับมอบหมายจากผู้ขายต่อติดบุคคลอ้างอิงตามกฏหมายหรือบุคคลที่ผู้ซื้อกำหนดในการตรวจสอบถามข้อมูลเพื่อพิจารณาสินเชื่อ สถานที่ติดต่อและทวงถามยอดค้างชำระผู้ซื้อ ดังนี้'),
                            SizedBox(
                              height: 10,
                            ),
                            Text('บุคคลที่ 1'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 80, child: Text('ชื่อ-สกุล ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: 'ชื่อ-นามสกุล',
                                  textController: other1,
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 80, child: Text('ความสัมพันธ์ ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: '',
                                  textController: other1Rela,
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 80, child: Text('เบอร์โทรศัพท์ ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: '',
                                  textController: other1Tel,
                                )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('บุคคลที่ 2'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 80, child: Text('ชื่อ-สกุล ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: 'ชื่อ-นามสกุล',
                                  textController: other2,
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 80, child: Text('ความสัมพันธ์ ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: '',
                                  textController: other2Rela,
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 80, child: Text('เบอร์โทรศัพท์ ')),
                                Flexible(
                                    child: SquareInput(
                                  hintText: '',
                                  textController: other2Tel,
                                )),
                              ],
                            ),
                            Text(
                                'สัญญานี้ทำขึ้นเป็นสองฉบับมีข้อความถูกต้องตรงกัน คู่สัญญาต่างยึดถือไว้ฝ่ายละฉบับและทั้งสองฝ่ายได้เข้าใจและทราบเนื้อหาหรือข้อความในสัญญานี้ดีโดยตลอดแล้ว จึงได้ลงลายมือชื่อและประทับตราสำคัญไว้เป็นหลักฐานต่อพยาน'),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Flexible(
                                    child: Container(
                                  width: size.width * 0.6,
                                  child: Column(
                                    children: [
                                      Text('ลงชื่อผู้ขาย'),
                                      SizedBox(
                                          width: 150,
                                          height: 100,
                                          child:
                                              Image.asset('assets/sign.png')),
                                      Text('(นางตรีพิพัฒน์ ศิลปการสกุล)')
                                    ],
                                  ),
                                )),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                    child: customerSign == null
                                        ? SignPart(
                                            size: size,
                                            controller: _customer,
                                            clear: () => _clearSign(_customer),
                                            cancel: () =>
                                                _cancelSign(context, _customer),
                                            confirm: () =>
                                                _confirmSign(context, 2),
                                            rear: Text(
                                                '(${widget.contractInfo['billData']['cName']})'),
                                            text: 'ลงชื่อผู้ซื้อ',
                                            textButton: 'ลงชื่อ',
                                          )
                                        : ShowSign(
                                            sign: customerSign,
                                            text: 'ลงชื่อผู้ซื้อ',
                                            rear: Text(
                                                '(${widget.contractInfo['billData']['cName']})'),
                                          )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Flexible(
                                    child: ref1Sign == null
                                        ? SignPart(
                                            size: size,
                                            controller: _ref1,
                                            clear: () => _clearSign(_ref1),
                                            cancel: () =>
                                                _cancelSign(context, _ref1),
                                            confirm: () =>
                                                _confirmSign(context, 3),
                                            rear: SquareInput(
                                              hintText: 'ชื่อ-นามสกุล พยาน',
                                              textController: ref1,
                                            ),
                                            text: 'ลงชื่อพยาน/บุคคลอ้างอิง',
                                            textButton: 'ลงชื่อ',
                                          )
                                        : ShowSign(
                                            sign: ref1Sign,
                                            text: 'ลงชื่อพยาน/บุคคลอ้างอิง',
                                            rear: SquareInput(
                                              hintText: 'ชื่อ-นามสกุล พยาน',
                                              textController: ref1,
                                            ),
                                          )),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                    child: ref2Sign == null
                                        ? SignPart(
                                            size: size,
                                            controller: _ref2,
                                            clear: () => _clearSign(_ref2),
                                            cancel: () =>
                                                _cancelSign(context, _ref2),
                                            confirm: () =>
                                                _confirmSign(context, 4),
                                            rear: SquareInput(
                                              hintText: 'ชื่อ-นามสกุล พยาน',
                                              textController: ref2,
                                            ),
                                            text: 'ลงชื่อพยาน/บุคคลอ้างอิง',
                                            textButton: 'ลงชื่อ',
                                          )
                                        : ShowSign(
                                            sign: ref2Sign,
                                            text: 'ลงชื่อพยาน/บุคคลอ้างอิง',
                                            rear: SquareInput(
                                              hintText: 'ชื่อ-นามสกุล พยาน',
                                              textController: ref2,
                                            ),
                                          )),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.contractId == null)
                                  CustomButton(
                                    onPress: () => submitContract(context),
                                    text: 'บันทึก',
                                  ),
                                SizedBox(
                                  width: 10,
                                ),
                                CustomButton(
                                  onPress: () {
                                    Navigator.of(context).pop(
                                        {'status': false, 'contractId': ''});
                                  },
                                  text: 'กลับ',
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
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
      ),
    );
  }
}
