import 'package:new_version/new_version.dart';
import 'package:version/version.dart';

class CheckVersionUpdate {
  check(context) async {
    final newVersion = NewVersion(
        iOSId: 'com.atsofts.landgreen',
        androidId: 'com.atsofts.landgreen',
        dialogTitle: 'อัพเดทเวอร์ชั่นใหม่ !!!',
        dialogText:
            'ทำการอัพเดทเวอร์ชั่นแลนด์กรีนของคุณให้เป็นเวอร์ชั่นล่าสุด 1.0.0 กดอัพเดทได้เลย',
        context: context);
    // final status = await newVersion.getVersionStatus();
    // if(status != null){
    //   Version local = Version.parse(status.localVersion);
    //   Version store = Version.parse(status.storeVersion);
    //   if(store > local){
    //     newVersion.showAlertIfNecessary();
    //   }
    // }
  }
}
