import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:system/configs/constants.dart';

class AlertNewDesign {
  Future<void> showEarlyMonth(context, size) async {
    var now = DateTime.now();
    print('now =>${now.day}');

    if ((now.day >= 28 && now.day <= 31) || (now.day >= 1 && now.day <= 5)) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              content: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: Container(
                    width: size.width * 0.98,
                    height: size.height * 0.41,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/bgAlert.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.28,
                          child: Image.asset("assets/icons/icon_alert.png"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "อยู่ในช่วงการคิดคอมมิชชั่น",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "ท่านสามารถดูระบบได้ แต่ข้อมูล จะมีการ\nอัพเดทที่ไม่เท่ากันบ้าง ในช่วงเวลานี้ และทุกอย่าง\nจะอัพเดทตรงกันหลังจากวันที่ 5 เป็นต้นไป",
                            style: TextStyle(
                                fontSize: 23, color: Colors.white, height: 1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: InkWell(
                            onTap: () {
                              print("click ok");
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: size.width * 0.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: warningColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "ตกลงฉันเข้าใจแล้ว",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
              ),
              // actions: <Widget>[
              //   TextButton(
              //     child: Text('Approve'),
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ],
          );
        },
      );

    }
  }

  Future<void> showLoading(context, size) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            width: size.width * 0.98,
            height: size.height * 0.41,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/bgAlert.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.28,
                  child: SpinKitCircle(
                    color: Colors.white,
                    size: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    "กำลังโหลดข้อมูล !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "ท่านจะไปทำอย่างอื่น หน้าอื่นก่อนก็ได้\nจากนั้นแล้วค่อยกลับมาเปิดหน้านี้อีกครั้งหนึ่ง\nรอประมาณประมาณ 1-2 นาที",
                    style: TextStyle(
                        fontSize: 23, color: Colors.white, height: 1),
                    textAlign: TextAlign.center,
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showNoData(context, size) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            width: size.width * 0.98,
            height: size.height * 0.42,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/bgAlert.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.28,
                  child: Image.asset("assets/icons/icon_alert.png"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    "ไม่มีข้อมูลที่ท่านเรียก",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "วันที่คุณเลือกระบบไม่มีข้อมูลที่จะแสดงผล\nเพราะคุณอาจจะยัง ไม่ได้เปิดบิล ไม่ได้ออกใบเสร็จ\nหรือ ไม่ได้ออกแจกสินค้าทดลอง ในวันเวลา\nดังกล่าวที่คุณเลือกมานี้",
                    style: TextStyle(
                        fontSize: 23, color: Colors.white, height: 1),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: InkWell(
                    onTap: () {
                      print("click ok");
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: warningColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "ตกลงฉันเข้าใจแล้ว",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
