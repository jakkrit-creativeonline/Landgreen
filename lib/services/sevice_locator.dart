import 'package:system/services/screen_arguments.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:system/services/service_analytic.dart';

// จะได้ Instance ของ GetIt มาซึ่งมีเพียงตัวเดียวในโปรแกรม เรียกที่ไหนก็ได้ตัวเดียวกัน
GetIt locator = GetIt.instance;

// ฟังก์ชันเริ่มต้นในการกำหนดว่าจะสร้าง Singleton หรือ อะไรบ้าง
void setupLocator() {
  // สร้าง Singleton ของ class NavigationService
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, ScreenArguments args) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: args);
  }

  Future<dynamic> moveTo(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  Future<dynamic> moveWithArgsTo(String routeName, ScreenArguments args) {
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: args);
  }





  BuildContext getContext() {
    return navigatorKey.currentContext;
  }

}
