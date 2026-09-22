class URLS {
  URLS._();
  // ***** Base URL
  //   static String baseURL = 'https://qa.yogoeats.com/api/v1'; //for QA server
  // static String baseURL =
  // 'https://yogo-pos-mongoose-1.vercel.app/api/v1'; // nabil
  // static String baseURL = 'https://test.yogoeats.com/api/v1'; // aws test server

  // static String baseURL = 'https://5577.yogoeats.com/api/v1'; //for Line 1
  // static String baseURL =
  //     'https://squelchily-phylic-tamala.ngrok-free.dev/api/v1'; //for  ngrok
  // static String baseURL = 'https://yogopos.onrender.com/api/v1'; //for   Y2

  // static String baseURL = 'https://l1.yogoeats.com/api/v1'; //for new Line 1
  // static String baseURL = 'https://l2.yogoeats.com/api/v1'; //for new Line 2
  // static String baseURL = 'http://localhost:7000/api/v1'; //for new local host
  // static String baseURL = 'https://qa.yogoeats.com/api/v1'; //for new QA server

  // static String baseURL = 'https://c1.yogoeats.com/api/v1'; //For Line c1
  //   static String baseURL = 'https://server2.yogoeats.com/api/v1';//For Line 2
  static String baseURL =
      'https://yogopos-backend-1.onrender.com/api/v1'; //For Yogo Server Y1
  // static String baseURL = 'https://v3.yogoeats.com/api/v1'; //For new Line 3

  //** end popint **
  static String login = '$baseURL/restaurants';
  static String employeeLogin = '$baseURL/employees/login';
  static String employees = '$baseURL/employees/pos';
  static String clockIn = '$baseURL/clocks/clock-in';

  static String clockOut = '$baseURL/clocks/clock-out';
  static String categories = '$baseURL/categories';
  // static String mainCategories = '$baseURL/main-categories';
  static String orderStatus = '$baseURL/orders/order-status';
  static String orders = '$baseURL/orders';
  static String changeOrderType = '$baseURL/orders/switch';
  static String takeoutOrders = '$baseURL/orders/takeout';
  static String posCategories = '$baseURL/categories/pos';

  static String items = '$baseURL/items/pos';
  static String transferItems = '$baseURL/orders/transfer-items';
  static String placeOrder = '$baseURL/orders/place-order';
  static String searchAddress = '$baseURL/maps/search/pos';

  static String tableCategory = '$baseURL/table-categories';
  static String tableHold = '$baseURL/tables';
  static String barList = '$baseURL/bars/list';
  static String allBarList = '$baseURL/bars/area';
  static String hallList = '$baseURL/table/hall-area';
  static String restrurentUpdate = '$baseURL/restaurants/pos';
  static String monerisPlaceOrder(String terminalId) =>
      '$baseURL/orders/moneris-place-order/$terminalId';

  static String ordersList = '$baseURL/table/order/list';
  static String orderOfBookedTable(int tableId) =>
      '$baseURL/table/$tableId/current-order';
  static String updateOrder(String orderId) => '$baseURL/orders/$orderId';
  static String transactionsStatus(String orderId) =>
      '$baseURL/orders/transactions-status/$orderId';
  //split
  static String splitAmount(String orderId) =>
      '$baseURL/orders/split-amount/$orderId';
  static String splitOrder(String orderId) =>
      '$baseURL/orders/split-order/$orderId';
  // cashout
  static String allCashOut = '$baseURL/orders/cashout/all';
  static String dineInCashOut = '$baseURL/orders/cashout/dine-in';
  static String takeoutCashOut = '$baseURL/orders/cashout/takeout';
  static String deliveryCashOut = '$baseURL/orders/cashout/delivery';
  static String oloCashOut = '$baseURL/orders/cashout/olo';
  //new summary report
  static String summaryReport = '$baseURL/orders/report-summary';

  // modifiers
  static String modifiers = '$baseURL/modifiers/pos';
  //details
  static String restaurantsDetails = '$baseURL/restaurants/details';
  // static String restaurantsAddress = '$baseURL/delivery/pos';
  static String deliveryCost = '$baseURL/delivery/pos/calculate-delivery-cost';
  // table reservations
  static String tableBooks = '$baseURL/olo/table-books/pos';
  //   static String callerId = '$baseURL/restaurants/calls/broadcast';//for test
  static String callerId = '$baseURL/caller-id/calls/broadcast'; // for prod

  // printers
  static String printers = '$baseURL/printers/pos';
  //SecurityCheck
  static String securityCheck = '$baseURL/device/check-device';
  static String employeeTimeSheet = '$baseURL/employees/pos/time-sheet-report';

  /// ***** Data candy gift Card URL ******
  // card-activation
  static String cardActivate = '$baseURL/datacandy/pos/transection/order-card';
  // committed-transaction
  static String commitedTransaction =
      '$baseURL/datacandy/pos/commit-transaction';
  static String activeCard = '$baseURL/datacandy/pos/transection/order-card';
  static String reloadCard =
      '$baseURL/datacandy/pos/transection/reload-card-with-check';
  // increment-blance
  static String incrementBlance =
      '$baseURL/datacandy/pos/transection/increment-balance-commit';
  // all data candy gift-card
  // static String allGiftCard = '$baseURL/datacandy/pos/cards';
  // search card
  static String cardSearch = '$baseURL/datacandy/pos/transection/restaurant';
  // all -transaction
  static String getAllCardTransaction =
      '$baseURL/datacandy/pos/transection/restaurant';
  // get-blance
  static String checkBlance =
      '$baseURL/datacandy/pos/transection/balance-check';
  // redeem-blance
  static String redeemBlance =
      '$baseURL/datacandy/pos/transection/redeem-commit';
  //cancel-transaction
  static String cancelTransaction =
      '$baseURL/datacandy/pos/transection/cancel-transaction-commit';
  static String datacandyPayment =
      '$baseURL/datacandy/pos/transection/redeem-commit-with-order';

  // ******* Terminal URL Moneris ********
  // Moneris
  static String monerisTestUtl =
      'https://ippostest.moneris.com/v3/terminal'; // for test
  static String monerisProdUtl =
      'https://ippos.moneris.com/v3/terminal'; // for production
  static String monerisPostBackURL = '$baseURL/moneris/postback';
  // https://test-node-rosy.vercel.app/api/v1/terminals/pos
  static String terminalData = '$baseURL/terminals/pos';

  // ******* Terminal URL Elavon ********
  static String converge = '$baseURL/converge/pos'; // for production

  // ******* rewards  ********
  static String activate = '$baseURL/giftcards/pos/activate';

  // POST bulk activate — sob card ek shathe
  static String activateBulk = '$baseURL/giftcards/pos/activate/bulk';

  static String transactions({String q = '', int page = 1, int pageSize = 6}) {
    final params = <String>[];
    if (q.trim().isNotEmpty) {
      params.add('q=${Uri.encodeQueryComponent(q.trim())}');
    }
    params.add('page=$page');
    params.add('pageSize=$pageSize');
    return '$baseURL/giftcards/pos/transactions?${params.join('&')}'; // baseUrl -> tomar real base
  }

  // GET balance — path e cardNumber boshe
  static String balance(String cardNumber) =>
      '$baseURL/giftcards/pos/cards/$cardNumber/balance';

  // GET activation-check — bulk add er age eligibility check (balance er moto)
  static String activationCheck(String cardNumber) =>
      '$baseURL/giftcards/pos/cards/$cardNumber/activation-check';

  static String addFunds(String cardNumber) =>
      '$baseURL/giftcards/pos/cards/$cardNumber/reload';

  // activate er moto, no path param — card body te jacche
  static String reverse = '$baseURL/giftcards/pos/reverse';

  // static String redeem = '$baseURL/giftcards/pos/redeem';
  static String reloadCheck(String cardNumber) =>
      '$baseURL/giftcards/pos/cards/$cardNumber/reload-check';
  static String redeem = '$baseURL/giftcards/pos/redeem';

  // ******* socket server ********
  // static String socketServer =
  //     "https://socket-server-1xbj.onrender.com"; // for test
  // static String socketServer = 'https://sockets.yogoeats.com/'; //for production
  static String socketServer = 'https://s1.yogoeats.com/'; //for production
  // static String socketServer = 'https://qa.yogoeats.com'; // for QA server
  // static String socketServer =
  //     'https://squelchily-phylic-tamala.ngrok-free.dev'; // for ngrok server

  // static String socketServer =
  // 'https://yogo-pos-mongoose-1.vercel.app'; // for test
}
