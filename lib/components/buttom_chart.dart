import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';

class ButtomChart extends StatelessWidget {
  final String totalMoney;
  final String workTime;
  final String sellProvince;
  final String updateTime;
  final String updateDate;

  const ButtomChart({
    Key key,
    this.totalMoney,
    this.workTime,
    this.sellProvince,
    this.updateTime,
    this.updateDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Color(0xFFE8EBEE),
          child: Column(
            children: [
              ClipRRect(
                child: Container(
                    child: Column(

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4,bottom: 0),
                          child: Text(
                            'รายได้ทั้งหมด',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0,bottom: 4),
                          child: Text(
                            totalMoney,
                            style: TextStyle(color: kSecondaryColor, fontSize: 20,height: 1),

                          ),
                        ),
                      ],
                    ),
                    width: 160,
                    color: darkColor),
                borderRadius: BorderRadius.circular(3),
              ),
              Text('อายุงาน $workTime'),
              Text('เขตการขาย : $sellProvince'),
            ],
          ),
        ),
        Text('อัพเดทเมื่อเวลา $updateTime น.'),
        Text('วันที่ $updateDate')
      ],
    );
  }
}