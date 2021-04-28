import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/components/custom_list_tile.dart';
import 'package:system/configs/constants.dart';

class CEOMenu extends StatelessWidget {
  final int userId;
  const CEOMenu({
    Key key,
    this.userId,
  }) : super(key: key);

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("isLogin", null);
    preferences.setInt("levelid", null);
    preferences.setInt("user_id", null);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          height: 42,
          color: Color(0xFF003319),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Container(
                  color: Color(0xFF92BFA4),
                  width: 5,
                  height: 12,
                ),
                Text(' เลือกเมนูย่อยได้จากลิสด้านล่างนี้',style: TextStyle(fontSize: 21,color: Colors.white),)
              ],
            ),
          ),
        ),
        // Container(
        //   height: 100,
        //   child: DrawerHeader(
        //       margin: EdgeInsets.all(0.0),
        //       padding: EdgeInsets.all(0.0),
        //     child: Image.asset('assets/img/logo.png'),
        //     decoration: BoxDecoration(
        //         color: backgroundColor
        //     ),
        //   ),
        // ),
        CustomListTile(
            text: 'แดชบอร์ด',
            icon: FontAwesomeIcons.home,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);

            }),
        CustomListTile(
            text: 'ยอดขายรายวัน',
            icon: FontAwesomeIcons.chartLine,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_report_day');
              locator<NavigationService>().navigateTo('ceo_report_day',ScreenArguments());

            }),
        CustomListTile(
            text: 'รายงานรายรับ-จ่าย',
            icon: FontAwesomeIcons.calculator,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_income_expense');
              locator<NavigationService>().navigateTo('ceo_income_expense',ScreenArguments());
            }),
        CustomListTile(
            text: 'Top Sales',
            icon: FontAwesomeIcons.medal,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_topsale');
              locator<NavigationService>().navigateTo('ceo_topsale',ScreenArguments());
            }),
        CustomListTile(
            text: 'Top Teams',
            icon: FontAwesomeIcons.star,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_topteam');
              locator<NavigationService>().navigateTo('ceo_topteam',ScreenArguments());
            }),
        CustomListTile(
            text: 'ยอดขายทีมเป้า 300 กส.',
            icon: FontAwesomeIcons.flag,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_report_car');
              locator<NavigationService>().navigateTo('ceo_report_car',ScreenArguments());

            }),

        CustomListTile(
            text: 'เครดิตค้างชำระ(สีส้ม)',
            icon: FontAwesomeIcons.chartBar,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('report_creditmanager');
              locator<NavigationService>().navigateTo('report_creditmanager',ScreenArguments());
            }),
        CustomListTile(
            text: 'เครดิตค้างชำระ(คันรถ)',
            icon: FontAwesomeIcons.chartBar,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('report_creditcar');
              locator<NavigationService>().navigateTo('report_creditcar',ScreenArguments());
            }),
        CustomListTile(
            text: 'KPI สินเชื่อ',
            icon: FontAwesomeIcons.chartPie,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_creditKPI');
              locator<NavigationService>().navigateTo('ceo_creditKPI',ScreenArguments());
            }),
        CustomListTile(
            text: 'รายงาน ใบมอบอำนาจ',
            icon: FontAwesomeIcons.addressBook,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_pta');
              locator<NavigationService>().navigateTo('ceo_pta',ScreenArguments());
            }),
        CustomListTile(
            text: 'รายงานรายได้ฝ่ายสินเชื่อ',
            icon: FontAwesomeIcons.chalkboardTeacher,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('commision_employee');
              locator<NavigationService>().navigateTo('commision_employee',ScreenArguments());
            }),
        CustomListTile(
            text: 'รายงานใบอนุญาตขายปุ๋ย',
            icon: FontAwesomeIcons.certificate,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_doc_certificate');
              locator<NavigationService>().navigateTo('ceo_doc_certificate',ScreenArguments());
            }),
        CustomListTile(
            text: 'รายงานแจกสินค้าทดลอง',
            icon: FontAwesomeIcons.fileAlt,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_report_trail');
              locator<NavigationService>().navigateTo('ceo_report_trail',ScreenArguments());
            }),

        CustomListTile(
            text: 'รายการเรื่องร้องเรียน',
            icon: FontAwesomeIcons.comments,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              // Navigator.of(context).pushNamed('ceo_complaint');
              locator<NavigationService>().navigateTo('ceo_complaint',ScreenArguments());
            }),

        if(userId == 807)
        CustomListTile(
            text: 'ประวัติรายได้',
            icon: FontAwesomeIcons.handHoldingUsd,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              locator<NavigationService>().navigateTo('historyIncome',
                  ScreenArguments(userId: userId));
            }),
        CustomListTile(
            text: 'ตั้งค่าส่วนตัว',
            icon: FontAwesomeIcons.userCog,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              locator<NavigationService>().navigateTo('userSetting',
                  ScreenArguments(userId: userId));
            }),
        CustomListTile(
          text: 'ออกจากระบบ',
          onTap: () {
            signOut();
            Navigator.pop(context);
            Navigator.of(context).pushReplacementNamed(LOGIN_PAGE);
          },
          icon: FontAwesomeIcons.powerOff,
        ),
      ],
    );
  }
}
