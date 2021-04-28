import 'package:flutter/foundation.dart';

class ShowDetail extends ChangeNotifier {
  bool showIncome = false;
  bool showExpense = false;

  void changeIncome() {
    showIncome = !showIncome;
    notifyListeners();
  }

  void changeExpense() {
    showExpense = !showExpense;
    notifyListeners();
  }
}
