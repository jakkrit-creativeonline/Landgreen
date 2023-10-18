import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_list_tile.dart';

class RedMenu extends StatelessWidget {
  final int userId;
  const RedMenu({
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
          color: Color(0xff001f82),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Container(
                  color: Color(0xff3e5fd7),
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
        //     margin: EdgeInsets.all(0.0),
        //     padding: EdgeInsets.all(0.0),
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
              Navigator.pop(context);
            }),
        // CustomListTile(
        //     text: 'HR',
        //     icon: FontAwesomeIcons.peopleArrows,
        //     onTap: () {
        //       Navigator.pop(context);
        //       locator<NavigationService>()
        //           .navigateTo('hr_screen', ScreenArguments(userId: userId));
        //     }),
        // CustomListTile(
        //     text: 'ข้อมูลลูกทีม',
        //     icon: FontAwesomeIcons.users,
        //     onTap: () {
        //       Navigator.pop(context);
        //       locator<NavigationService>().navigateTo(
        //           'head_dashboard',
        //           ScreenArguments(userId: userId));
        //     }),
        // CustomListTile(
        //   text: 'สร้างใบบันทึกลูกค้า',
        //   onTap: () {
        //     Navigator.pop(context);
        //     locator<NavigationService>().navigateTo('createBillTrail',
        //         ScreenArguments(editStatus: 0, userId: userId));
        //   },
        //   icon: FontAwesomeIcons.edit,
        // ),
        // CustomListTile(
        //   text: 'สร้างใบสั่งจองสินค้า',
        //   onTap: () {
        //     Navigator.pop(context);
        //     locator<NavigationService>().navigateTo(CREATEBILL_PAGE,
        //         ScreenArguments(editStatus: 0, userId: userId));
        //   },
        //   icon: FontAwesomeIcons.tasks,
        // ),
        CustomListTile(
            text: 'Top Sales',
            icon: FontAwesomeIcons.medal,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              Navigator.of(context).pushNamed('ceo_topsale');
            }),
        CustomListTile(
            text: 'Top Teams',
            icon: FontAwesomeIcons.star,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              Navigator.of(context).pushNamed('ceo_topteam');
            }),
        CustomListTile(
            text: 'แจ้งโอนเงินสด',
            icon: FontAwesomeIcons.moneyBillAlt,
            onTap: () {
              Navigator.pop(context);
              locator<NavigationService>()
                  .navigateTo('moneyTransfer', ScreenArguments(userId: userId));
            }),
        CustomListTile(
            text: 'บันทึกรายจ่ายรายวัน',
            icon: FontAwesomeIcons.fileInvoiceDollar,
            onTap: () {
              Navigator.pop(context);
              locator<NavigationService>()
                  .navigateTo('carPayDay', ScreenArguments(userId: userId));
            }),
        // CustomListTile(
        //     text: 'สร้างใบสั่งขาย',
        //     icon: FontAwesomeIcons.clipboard,
        //     onTap: () {
        //       Navigator.pop(context);
        //       locator<NavigationService>()
        //           .navigateTo('createSaleOrder', ScreenArguments(userId: userId,editStatus: 0));
        //     }),
        // CustomListTile(
        //     text: 'คลังสินค้าทีม',
        //     icon: FontAwesomeIcons.boxes,
        //     onTap: () {
        //       Navigator.pop(context);
        //       locator<NavigationService>()
        //           .navigateTo('teamStock', ScreenArguments(userId: userId));
        //     }),
        CustomListTile(
            text: 'ประวัติรายได้',
            icon: FontAwesomeIcons.handHoldingUsd,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              locator<NavigationService>().navigateTo('historyIncome',
                  ScreenArguments(userId: userId));
            }),
        // CustomListTile(
        //     text: 'ใบอนุญาตขายปุ๋ย',
        //     icon: FontAwesomeIcons.certificate,
        //     onTap: () {
        //       //print('แดชบอร์ด');
        //       Navigator.pop(context);
        //       locator<NavigationService>().navigateTo('docCertificate',
        //           ScreenArguments(userId: userId));
        //     }),
        // CustomListTile(
        //     text: 'ใบมอบอำนาจจากฝ่ายสินเชื่อ',
        //     icon: FontAwesomeIcons.fileInvoice,
        //     onTap: () {
        //       //print('แดชบอร์ด');
        //       Navigator.pop(context);
        //       locator<NavigationService>().navigateTo('docCertificate',
        //           ScreenArguments(userId: userId));
        //     }),
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
