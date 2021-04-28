
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:system/components/custom_button.dart';
import 'package:system/components/show_modal_bottom_sheet.dart';
import 'package:system/configs/constants.dart';

class SignPart extends StatelessWidget {
  const SignPart({
    Key key,
    @required this.size,
    @required SignatureController controller,
    this.confirm,
    this.clear,
    this.cancel,
    this.text = 'ได้รับสินค้าตามรายการถูกต้องแล้ว',
    this.textButton = 'เซ็นยืนยัน',
    this.rear,
  })  : _controller = controller,
        super(key: key);

  final Size size;
  final SignatureController _controller;
  final Function confirm;
  final Function clear;
  final Function cancel;
  final String text;
  final String textButton;
  final Widget rear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.6,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 20.0),
          ),
          CustomButton(
            onPress: () {
              ShowModalBottom(
                      onConfirm: confirm, onClear: clear, onCancel: cancel)
                  .showModal(context, _controller);
            },
            text: textButton,
          ),
          if (rear != null) rear
        ],
      ),
    );
  }
}
