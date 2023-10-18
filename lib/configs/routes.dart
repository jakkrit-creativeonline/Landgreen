import 'package:flutter/material.dart';
import 'package:system/screens/ceo/ceo_complaint.dart';
import 'package:system/screens/ceo/ceo_credit_kpi.dart';
import 'package:system/screens/ceo/ceo_doc_certificate.dart';
import 'package:system/screens/ceo/ceo_income_expense.dart';
import 'package:system/screens/ceo/ceo_pta.dart';
import 'package:system/screens/ceo/ceo_report_car.dart';
import 'package:system/screens/ceo/ceo_report_day.dart';
import 'package:system/screens/ceo/ceo_report_trail.dart';
import 'package:system/screens/ceo/ceo_top_sale.dart';
import 'package:system/screens/ceo/ceo_top_team.dart';
import 'package:system/screens/ceo/commission_employee.dart';
import 'package:system/screens/ceo/components/ceo_map_stat.dart';
import 'package:system/screens/ceo/credit_report_car.dart';
import 'package:system/screens/ceo/credit_report_manager.dart';
import 'package:system/screens/ceo/dashboard_screen.dart';
import 'package:system/screens/head/car_pay_day.dart';
import 'package:system/screens/head/head_dashboard.dart';
import 'package:system/screens/head/money_transfer.dart';
import 'package:system/screens/head/survey_team_stock.dart';
import 'package:system/screens/head/team_stock.dart';
import 'package:system/screens/hr/hr_screen.dart';
import 'package:system/screens/login_screen.dart';
import 'package:system/screens/manager/manager_dashboard.dart';
import 'package:system/screens/product_screen.dart';
import 'package:system/screens/register.dart';
import 'package:system/screens/sale/create_bill.dart';
import 'package:system/screens/sale/create_bill_trail.dart';
import 'package:system/screens/sale/create_contract.dart';
import 'package:system/screens/sale/create_receipt.dart';
import 'package:system/screens/sale/create_sale_order.dart';
import 'package:system/screens/sale/dashboard_screen.dart';
import 'package:system/screens/sale/doc_certificate.dart';
import 'package:system/screens/sale/history_income.dart';
import 'package:system/screens/sale/show_bill.dart';
import 'package:system/screens/sale/show_pta.dart';
import 'package:system/screens/sale/show_rankall.dart';
import 'package:system/screens/sale/show_trail.dart';
import 'package:system/screens/splash_screen.dart';
import 'package:system/screens/submanager/submanager_dashborad.dart';
import 'package:system/screens/user_setting.dart';
import 'package:system/services/screen_arguments.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'login':
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),
          settings: RouteSettings(name: 'LoginPage'),
        );
      case 'dashboard':
        return MaterialPageRoute(
          builder: (context) => DashboardScreen(),
          settings: RouteSettings(name: 'SaleDashboard'),
        );
      case 'createBill':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CreateBill'),
            builder: (context) => CreateBill(
                  userId: args.userId,
                  editStatus: args.editStatus,
                  billId: args.billId,
                  customerId: args.customerId,
                  isBillOnline: args.isBillOnline,
                ));
      case 'createBillTrail':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CreateTrail'),
            builder: (context) => CreateBillTrail(
                  userId: args.userId,
                  trailId: args.trailId,
                  editStatus: args.editStatus,
                ));
      case 'showBill':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ShowBill'),
            builder: (context) => ShowBill(
                  userId: args.userId,
                ));
      case 'showTrail':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ShowTrail'),
            builder: (context) => ShowTrail(
                  userId: args.userId,
                ));
      case 'createReceipt':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CreateReceipt'),
            builder: (context) => CreateReceipt(
                  billId: args.billId,
                  userId: args.userId,
                  receiptId: args.receiptId,
                  isOnline: args.isBillOnline,
                  receiptNumber: args.receiptNumber,
                ));
      case 'createContract':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CreateContract'),
            builder: (context) => CreateContract(
                  billId: args.billId,
                  userId: args.userId,
                  contractInfo: args.contractInfo,
                  contractId: args.contractId,
                  isOnline: args.isBillOnline,
                ));
      case 'showRankAll':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'หน้าจัดอันดับยอดขายเซล'),
            builder: (context) => ShowRankAll(
                // userId: args.userId,
                ));
      case 'moneyTransfer':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'หน้าหัวหน้าทีมแจ้งโอนเงินสด'),
            builder: (context) => MoneyTransfer(
                  userId: args.userId,
                ));
      case 'carPayDay':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'บันทึกรายจ่ายประจำวัน'),
            builder: (context) => CarPayDay(
                  userId: args.userId,
                ));
      case 'head_dashboard': //ข้อมูลทีมขาย
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ข้อมูลทีมขายหัวหน้าทีม'),
            builder: (context) => HeadDashboard(
                  userId: args.userId,
                ));
      case 'submanager_dashboard': //ข้อมูลทีมขายผู้จัดการ
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ข้อมูลทีมขายผู้จัดการ'),
            builder: (context) => SubmanagerDashboard(
                  userId: args.userId,
                ));
      case 'manager_dashboard': //ข้อมูลทีมขายผู้จัดการ
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ข้อมูลทีมขายผู้อำนวยการ'),
            builder: (context) => ManagerDashboard(
                  userId: args.userId,
                ));
      case 'teamStock':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'จัดการคลังสินค้า'),
            builder: (context) => TeamStock(
                  userId: args.userId,
                ));
      case 'ceo_dashboard':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEODashobard'),
            builder: (context) => CEODashboard(
                  userId: args.userId,
                ));
      case 'ceo_topsale':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'TopSales'),
            builder: (context) => CeoTopSale());
      case 'ceo_topteam':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'TopTeams'),
            builder: (context) => CeoTopTeam());
      case 'report_creditcar':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'รายงานเครดิต(คันรถ)'),
            builder: (context) => CreditReportCar());
      case 'report_creditmanager':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'รายงานเครดิต(ผู้อำนวยการ)'),
            builder: (context) => CreditReportManager());
      case 'historyIncome':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ประวัติรายได้รายคน'),
            builder: (context) => HistoryIncome(
                  userId: args.userId,
                ));
      case 'ceo_mapStat':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOHeatmap'),
            builder: (context) => CeoMapStat());
      case 'ceo_creditKPI':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CeoKPICredit'),
            builder: (context) => CeoCreditKPI());
      case 'userSetting':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ตั้งค่าพนักงาน'),
            builder: (context) => UserSetting(
                  userId: args.userId,
                ));
      case 'docCertificate':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'เอกสารใบอนุญาตขายปุ๋ย'),
            builder: (context) => DocCertificate(
                  userId: args.userId,
                ));
      case 'createSaleOrder':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'สร้างใบสั่งขาย'),
            builder: (context) => CreateSaleOrder(
                  userId: args.userId,
                  editStatus: args.editStatus,
                  docId: args.docId,
                ));
      case 'showPTA':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ดูใบมอบอำนาจ'),
            builder: (context) => ShowPTA(
                  userId: args.userId,
                ));

      case 'ceo_report_day':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOยอดขายรายวัน'),
            builder: (context) => CEOReportDay());
      case 'ceo_report_car':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOยอดทีมเป้า 300 กส.'),
            builder: (context) => CEOReportCar());
      case 'ceo_pta':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานใบมอบอำนาจ'),
            builder: (context) => CEOShowPTA());
      case 'commision_employee':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานรายได้ฝ่ายสินเชื่อ'),
            builder: (context) => CommissionEmployee());
      case 'ceo_doc_certificate':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานใบอนุญาตขายปุ๋ย'),
            builder: (context) => CEODocCertificate());
      case 'ceo_report_trail':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานแจกสินค้าทดลอง'),
            builder: (context) => CEOReportTrail());
      case 'ceo_complaint':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานเรื่องร้องเรียน'),
            builder: (context) => CEOComplaint());
      case 'ceo_income_expense':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'CEOรายงานรายรับ-จ่าย'),
            builder: (context) => CEOIncomeExpense());
      case 'product_screen':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ดูแคตตาล็อกสินค้า'),
            builder: (context) => ProductScreen());
      case 'survey_team_stock':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'ประเมินการส่งสินค้า'),
            builder: (context) => SurveyTeamStock(
                  userId: args.userId,
                  docId: args.docId,
                ));
      case 'hr_screen':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'เปิดข้อมูลเอชอาร์'),
            builder: (context) => HrScreen(
                  userId: args.userId,
                ));
      case 'register':
        final ScreenArguments args = settings.arguments;
        return MaterialPageRoute(
            settings: RouteSettings(name: 'สมัครสมาชิก'),
            builder: (context) => Register());
      case 'splash':
      default:
        return MaterialPageRoute(
            builder: (context) => SafeArea(child: SplashScreen()));
    }
  }
}
