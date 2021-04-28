import 'package:flutter/foundation.dart';

class NotificationModel extends ChangeNotifier {
  int offlineBill = 0;

  void add(int total) {
    offlineBill += total;
    notifyListeners();
  }

  void setTotal(int total) {
    offlineBill = total;
    notifyListeners();
  }

  void remove(int total) {
    offlineBill -= total;
    notifyListeners();
  }

  void removeAll() {
    offlineBill = 0;
    notifyListeners();
  }
}
