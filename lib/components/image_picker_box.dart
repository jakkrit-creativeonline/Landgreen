import 'package:flutter/material.dart';

class ImagePickerBox extends StatelessWidget {
  final String showText;
  const ImagePickerBox({
    Key key,
    this.onTap,
    this.showText='คลิ๊กแนบรูปภาพทั้งหมดที่นี่',
  }) : super(key: key);
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: size.width * 0.9,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_search_outlined,
                size: 36.0,
                color: Colors.grey,
              ),
              Text(
                showText,
                style: TextStyle(fontSize: 18.0),
              )
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
