import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/clockIn/views/clock_in_view.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/binding/data_candy_page_bindings.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/binding/gift_card_bindings.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/binding/gift_card_transaction_bindings.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/all_card_data_candy_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/screens/data_candy_page.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/screens/gift_card_view.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/screens/transaction_details_page.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/screens/transaction_view_page.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/bindings/rewards_gift_card_binding.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/screens/gift_card_screen.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/moneris_response_table/views/moneris_respnse_table_view.dart';

import '../middleware/router_welcome.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/auth/views/signin_view.dart';
import '../modules/employee/bindings/employee_binding.dart';
import '../modules/employee/views/employee_view.dart';
import '../modules/pos/bindings/pos_binding.dart';
import '../modules/pos/tableReservations/bindings/table_reservations_binding.dart';
import '../modules/pos/tableReservations/views/table_reservations_view.dart';
import '../modules/pos/views/pos_view.dart';
import '../modules/setting/bindings/setting_binding.dart';
import '../modules/setting/views/setting_view.dart';
import '../modules/terminalIntegration/moneris/moneris_response_table/bindings/moneris_response_table_binding.dart'
    show MonerisResponseTableBinding;

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SIGN_IN;
  static final routes = [
    // GetPage(
    //   name: _Paths.ENTRY_POINT,
    //   page: () => const EntryPointView(),
    //   binding: EntryPointBinding(),
    // ),
    GetPage(
      name: _Paths.POS,
      page: () => const PosView(),
      binding: PosBinding(),
      children: [
        GetPage(
          name: _Paths.TABLE_RESERVATIONS,
          page: () => const TableReservationsView(),
          binding: TableReservationsBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.EMPLOYEE,
      page: () => const EmployeeView(),
      binding: EmployeeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SigninView(),
      binding: AuthBinding(),
      middlewares: [RouteWlcomMiddleware()],
    ),
    GetPage(name: _Paths.CLOCK_IN, page: () => const ClockInView()),
    GetPage(
      name: _Paths.SETTING,
      page: () => const SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: _Paths.MONERIS_RESPONSE_TABLE,
      page: () => const MonerisResponseTableView(),
      binding: MonerisResponseTableBinding(),
    ),
    GetPage(
      name: _Paths.Gift_Card,
      page: () => const GiftCardScreen(),
      binding: GiftCardBindings(),
    ),
    GetPage(
      name: _Paths.Gift_Card_page,
      page: () => const DataCandyPage(),
      binding: DataCandyPageBindings(),
    ),
    GetPage(
      name: _Paths.Gift_Card_Transaction_Details,
      page: () {
        final card = Get.arguments as GiftCardModel;
        return GiftCardTransactionDetailsPage(card: card);
      },
      binding: GiftCardTransactionBindings(),
    ),
    GetPage(
      name: _Paths.Gift_Card_Transaction_Details2,
      page: () => const TransactionDetailsViewpage(),
      binding: GiftCardTransactionBindings(),
    ),

    GetPage(
      name: _Paths.Rewards_Gift_Card,
      page: () => const GiftCardMasterScreen2(),
      binding: RewardsGiftCardBinding(),
    ),
  ];
}
