
import 'package:system/components/custom_button.dart';
import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class ShowModalBottom {
  final Function onConfirm;
  final Function onClear;
  final Function onCancel;

  ShowModalBottom({this.onConfirm, this.onClear, this.onCancel});
  // ignore: missing_return
  void showModal(context, SignatureController _controller) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              color: subFontColor,
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:20,right: 20,top: 10,bottom: 10),
                    child: Text('เซ็นยืนยันบริเวณพื้นที่สีขาวนี้ได้เลย',style: TextStyle(color: Colors.white,fontSize: 22),),
                  ),
                  Signature(
                    controller: _controller,
                    width: size.width*0.9,
                    height: 300,
                    backgroundColor: Colors.white,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        onPress: onCancel,
                        color: dangerColor,
                        text: 'ยกเลิก',
                      ),
                      CustomButton(
                        onPress: onClear,
                        color: warningColor,
                        text: 'ลบ',
                      ),

                      CustomButton(
                        onPress: onConfirm,
                        color: kPrimaryColor,
                        text: 'ยืนยัน',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<bool> alertDialog(context, String text) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Center(child: Text(text)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "ตกลง",
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
