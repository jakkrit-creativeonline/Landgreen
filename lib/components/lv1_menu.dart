import 'package:system/configs/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:system/components/custom_list_tile.dart';

class SellMenu extends StatelessWidget {
  final int userId;
  const SellMenu({
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
              //print('แดชบอร์ด');
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(DASHBOARD_PAGE);

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
        //   text: 'สร้างใบรับสินค้าทดลอง',
        //   onTap: () {
        //     //print('สร้างใบบันทึกลูกค้า');
        //     Navigator.pop(context);
        //
        //   },
        //   icon: FontAwesomeIcons.edit,
        // ),
        // CustomListTile(
        //   text: 'สร้างใบสั่งจองสินค้า',
        //   onTap: () {
        //     //print('สร้างใบสั่งจองสินค้า');
        //     Navigator.pop(context);
        //     //CREATEBILL_PAGE
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
            text: 'ประวัติรายได้',
            icon: FontAwesomeIcons.handHoldingUsd,
            onTap: () {
              //print('แดชบอร์ด');
              Navigator.pop(context);
              locator<NavigationService>().navigateTo('historyIncome',
                          ScreenArguments(userId: userId));
            }),
        // CustomListTile(
        //     text: 'ใบอนุญาติขายปุ๋ย',
        //     icon: FontAwesomeIcons.certificate,
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
