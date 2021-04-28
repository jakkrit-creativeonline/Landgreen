import 'package:new_version/new_version.dart';
import 'package:version/version.dart';

class CheckVersionUpdate {
  check(context) async {
    final newVersion = NewVersion(
        iOSId: 'com.atsoft.landgreen',
        androidId: 'com.atsoft.landgreen',
        dialogTitle: 'อัพเดทเวอร์ชั่นใหม่ !!!',
        dialogText:
            'ทำการอัพเดทเวอร์ชั่นแลนด์กรีนของคุณให้เป็นเวอร์ชั่นล่าสุด 1.0.1 กดอัพเดทได้เลย',
        context: context);
    // var status = await newVersion.getVersionStatus();
    // Version local = Version.parse(status.localVersion);
    // Version store = Version.parse(status.storeVersion);
    // if(store > local){
    //   newVersion.showAlertIfNecessary();
    // }
  }
}
