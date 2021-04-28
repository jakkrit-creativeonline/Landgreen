import 'package:shared_preferences/shared_preferences.dart';
import 'package:system/configs/constants.dart';

class HrServices {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> setValue(String _key, String _val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, _val);

    print("setValue =>$_val");
  }
  Future<String> getValue(String _key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _val = prefs.getString(_key);
    print("getValue =>$_val");
    return _val;
  }

}