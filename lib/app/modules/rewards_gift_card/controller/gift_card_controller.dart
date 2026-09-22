import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/redeem_balance_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/Acrivate_card_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/bulk_activate_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/gift_card_transaction.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/reload_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/reverse_card_response.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/card_activation_check.dart';
import 'package:yogo_pos/app/services/base/api_service.dart';
import 'package:yogo_pos/app/services/base/base_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/string_extensions.dart';
import 'package:yogo_pos/app/utils/idempotency_key.dart';
import 'package:yogo_pos/app/utils/urls.dart';


class RewardsGiftCardController extends GetxController {
  final ApiService _api = BaseController.to.apiService;
  

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ActivateCardResponse> lastActivated = Rxn<ActivateCardResponse>();
  final Rxn<ReloadCardResponse> lastReload = Rxn<ReloadCardResponse>();
  final Rxn<GiftCard> currentCard = Rxn<GiftCard>();
  final Rxn<ReverseCardResponse> lastReversed = Rxn<ReverseCardResponse>();
  final Rxn<RedeemResponse> lastRedeemed = Rxn<RedeemResponse>();
  final Rxn<BulkActivateResponse> lastBulk = Rxn<BulkActivateResponse>();

  /// Idempotency key of the last mutating operation. On timeout (-1) the UI
  /// can pass this same key to retry, so the server won't apply a duplicate.
  /// NOTE: the key now goes in the request BODY (`idempotencyKey`), not a header.
  String? lastIdempotencyKey;

  // ==========================================================================
  // ENUM MAPPERS — TWO SEPARATE ENUMS:
  //   1) source          -> Cash, Moneris, Elavon, Stripe, Visa, MasterCard,
  //                         Interac, Amex, CancelledOrderCredit, GiftCard
  //   2) methods/cardType -> DEBIT_CARD, CASH, OTHERS, CASH_AND_CARD, VISA,
  //                         MASTERCARD, AMEX, DISCOVER, JCB, UNIONPAY, DINERS,
  //                         CARTES BANCAIRES, INTERAC, DATACANDY_GIFT_CARD,
  //                         GIFT CARD
  // ==========================================================================

  /// UI label -> methods/cardType enum value.
  String _toApiMethod(String m) {
    switch (m.toUpperCase().trim()) {
      case 'DEBIT CARD':
      case 'DEBIT_CARD':
        return 'DEBIT_CARD';
      case 'CASH & CARD':
      case 'CASH AND CARD':
      case 'CASH_AND_CARD':
        return 'CASH_AND_CARD';
      case 'GIFT CARD':
        return 'GIFT CARD';
      case 'CARTES BANCAIRES':
        return 'CARTES BANCAIRES';
      default:
        return m
            .toUpperCase()
            .trim(); // VISA, MASTERCARD, AMEX, CASH, OTHERS ...
    }
  }

  /// UI label -> source enum value.
  String _mapSource(String m) {
    switch (m.toUpperCase()) {
      case 'CASH':
        return 'Cash';
      case 'VISA':
        return 'Visa';
      case 'MASTERCARD':
        return 'MasterCard';
      case 'AMEX':
        return 'Amex';
      case 'DEBIT CARD':
      case 'DEBIT_CARD':
        return 'Interac'; // source enum: debit = Interac
      case 'OTHERS':
        return 'Cash'; // 'Others' not in source enum -> Cash fallback
      default:
        return 'Cash';
    }
  }

  // ==========================================================================
  // TRANSACTION TABLE + PAGINATION STATE
  // ==========================================================================
  final RxList<GiftCardTransaction> transactions = <GiftCardTransaction>[].obs;
  final RxBool isLoadingTxns = false.obs;
  final RxnString txnError = RxnString();
  final RxString searchQuery = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 6.obs;
  final RxInt totalItems = 0.obs;
  final RxInt totalPages = 1.obs;

  bool get hasPrev => currentPage.value > 1;
  bool get hasNext => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    debounce<String>(searchQuery, (q) {
      final query = q.trim();
      if (query.isEmpty) {
        _resetTable();
        return;
      }
      fetchTransactions(q: query, page: 1);
    }, time: const Duration(milliseconds: 400));
  }

  void _resetTable() {
    transactions.clear();
    txnError.value = null;
    isLoadingTxns.value = false;
    currentPage.value = 1;
    totalItems.value = 0;
    totalPages.value = 1;
  }

  // ==========================================================================
  // SEARCH / TRANSACTIONS (GET) — no idempotency key, session in body
  // ==========================================================================
  Future<void> fetchTransactions({String q = '', int? page, int? size}) async {
    final p = page ?? currentPage.value;
    final ps = size ?? pageSize.value;

    isLoadingTxns.value = true;
    txnError.value = null;
    try {
      final url = URLS.transactions(q: q, page: p, pageSize: ps);
      final res = await _api.makeGetRequest(
        url,
        // tenant/location/staff in GET body
      );
      final data = res.data;

      if (_ok(res) && data is Map) {
        final inner = data['data'];
        final list = inner is Map ? inner['transactions'] : null;

        if (list is List) {
          transactions.assignAll(
            list.whereType<Map>().map(
              (e) => GiftCardTransaction.fromJson(_asMap(e)),
            ),
          );
          currentPage.value = p;
          pageSize.value = ps;
          _applyPagination(inner is Map ? inner : const {});
        } else {
          transactions.clear();
          totalItems.value = 0;
          totalPages.value = 1;
          txnError.value = _msgFrom(data) ?? 'No transactions';
        }
        return;
      }

      transactions.clear();
      totalItems.value = 0;
      totalPages.value = 1;
      txnError.value =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty
              ? res.message
              : 'Failed to load transactions');
    } catch (e) {
      transactions.clear();
      totalItems.value = 0;
      totalPages.value = 1;
      txnError.value = 'Something went wrong: $e';
    } finally {
      isLoadingTxns.value = false;
    }
  }

  /// Parse pagination meta defensively, whatever shape the backend returns.
  void _applyPagination(Map inner) {
    final meta = inner['pagination'] is Map
        ? (inner['pagination'] as Map)
        : (inner['meta'] is Map ? (inner['meta'] as Map) : inner);

    int? asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);

    final total =
        asInt(meta['total']) ??
        asInt(meta['totalCount']) ??
        asInt(meta['count']);
    final tp = asInt(meta['totalPages']) ?? asInt(meta['pages']);
    final ps =
        asInt(meta['pageSize']) ?? asInt(meta['limit']) ?? pageSize.value;
    final p = asInt(meta['page']) ?? currentPage.value;

    currentPage.value = p;
    pageSize.value = ps > 0 ? ps : pageSize.value;

    if (total != null) {
      totalItems.value = total;
      totalPages.value = tp ?? (total <= 0 ? 1 : ((total + ps - 1) ~/ ps));
    } else if (tp != null) {
      totalPages.value = tp;
      totalItems.value = 0;
    } else {
      totalItems.value = 0;
      totalPages.value = transactions.length < ps
          ? currentPage.value
          : currentPage.value + 1;
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value || page == currentPage.value)
      return;
    final q = searchQuery.value.trim();
    if (q.isEmpty) return;
    fetchTransactions(q: q, page: page);
  }

  void nextPage() => goToPage(currentPage.value + 1);
  void prevPage() => goToPage(currentPage.value - 1);

  void changePageSize(int size) {
    if (size == pageSize.value) return;
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      pageSize.value = size;
      return;
    }
    fetchTransactions(q: q, page: 1, size: size);
  }

  void refreshTable() {
    final q = searchQuery.value.trim();
    if (q.isEmpty) return;
    fetchTransactions(q: q);
  }

  // ==========================================================================
  // ACTIVATE CARD (POST) — session + idempotencyKey in body
  // ==========================================================================
  Future<ActivateCardResponse?> activate({
    required String cardNumber,
    required String amountText,
    required String name,
    required String phone,
    String source = 'Cash',
    String? idempotencyKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    final key = _keyFor('activate', idempotencyKey);
    try {
      final body = _mutBody(
        ActivateCardRequest(
          cardNumber: _clean(cardNumber),
          initialAmount: _toDollars(amountText),
          owner: Owner(name: name.trim(), phone: phone.trim()),
          source: source,
        ).toJson(),
        key,
      );

      final res = await _api.makePostRequest(URLS.activate, body);

      if (_unknownStatus(res)) return _fail(_unknownMsg);

      final data = res.data;

      if (_ok(res) && data is Map) {
        final parsed = ActivateCardResponse.fromJson(_asMap(data));
        if (parsed.success && parsed.data != null) {
          lastActivated.value = parsed;
          currentCard.value = parsed.data!.card;
          return parsed;
        }
        return _fail(_msgFrom(data) ?? 'Activation failed');
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message : 'Activation failed');
      return _fail(msg);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // ACTIVATION CHECK (GET) — verifies a card is eligible before bulk-adding.
  //   status == true  -> eligible (caller adds to list)
  //   status == false -> not eligible; caller shows [message] as the error
  // Both 200 (eligible) and 409 (already active) return a JSON body,
  // so we parse the data regardless of status code.
  // ==========================================================================
  Future<ActivationCheckResponse?> checkActivation(String cardNumber) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final url = URLS.activationCheck(_clean(cardNumber));
      final res = await _api.makeGetRequest(url);
      final data = res.data;

      if (data is Map) {
        return ActivationCheckResponse.fromJson(_asMap(data));
      }

      final msg = res.message.isNotEmpty ? res.message : 'Card check failed';
      errorMessage.value = _titleCase(msg);
      return null;
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // RELOAD CHECK (GET) — verifies a card is eligible for reload (must be Active).
  //   status == true  -> eligible (caller proceeds)
  //   status == false -> not eligible; caller shows [message] as the error
  // ==========================================================================
  Future<ActivationCheckResponse?> checkReload(String cardNumber) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final url = URLS.reloadCheck(_clean(cardNumber));
      final res = await _api.makeGetRequest(url);
      final data = res.data;

      if (data is Map) {
        return ActivationCheckResponse.fromJson(_asMap(data));
      }

      final msg = res.message.isNotEmpty ? res.message : 'Card check failed';
      errorMessage.value = _titleCase(msg);
      return null;
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<BulkActivateResponse?> activateBulk({
    required List<BulkCardInput> cards,
    required List<BulkPaymentInput> payments,
    String? note,
    String? idempotencyKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    final key = _keyFor('activate-bulk', idempotencyKey);
    try {
      // payments -> array of { methods: <string>, paidAmount: <num> }
      // (Postman e ei shape-e kaj kore)
      final paymentsList = payments
          .map(
            (p) => {
              'methods': p.methods, // single string: VISA / CASH / OTHERS ...
              'paidAmount': p.paidAmount,
            },
          )
          .toList();

      final body = _mutBody({
        'cards': cards.map((c) => c.toJson()).toList(),
        'payments': paymentsList,
        if (note != null && note.isNotEmpty) 'note': note,
      }, key);
      print('[bulk] => $body');
      final res = await _api.makePostRequest(URLS.activateBulk, body);

      if (_unknownStatus(res)) return _fail(_unknownMsg);

      final data = res.data;

      if (_ok(res) && data is Map) {
        final parsed = BulkActivateResponse.fromJson(_asMap(data));
        if (parsed.success) {
          lastBulk.value = parsed;
          return parsed;
        }
        return _fail(_msgFrom(data) ?? 'Activation failed');
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message : 'Activation failed');
      return _fail(msg);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // RELOAD / ADD FUNDS (POST) — session + idempotencyKey + payments object.
  //   source           -> _mapSource enum (Cash, Visa, MasterCard, Interac...)
  //   methods/cardType -> _toApiMethod enum (CASH, VISA, MASTERCARD, DEBIT_CARD...)
  // ==========================================================================
  Future<ReloadCardResponse?> reload({
    required String cardNumber,
    required String amountText,
    String? source, // explicit override (optional)
    String? relatedOrderId,
    String? relatedPaymentId,
    String? note,
    required PaymentSelection paymentSelection,
    String? providerName,
    String? transactionId,
    String? idempotencyKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    final key = _keyFor('reload', idempotencyKey);
    try {
      final url = URLS.addFunds(_clean(cardNumber));

      // Build the single payments object from PaymentSelection.
      final payments = paymentSelection.payments;
      final methods = payments.map((p) => _toApiMethod(p.methods)).toList();

      final cashPaid = payments
          .where((p) => _toApiMethod(p.methods) == 'CASH')
          .fold<num>(0, (sum, p) => sum + p.paidAmount);
      final cardPaid = payments
          .where((p) => _toApiMethod(p.methods) != 'CASH')
          .fold<num>(0, (sum, p) => sum + p.paidAmount);

      // First non-CASH method = cardType.
      String? cardType;
      for (final p in payments) {
        if (_toApiMethod(p.methods) != 'CASH') {
          cardType = _toApiMethod(p.methods);
          break;
        }
      }

      // Resolve source enum.
      final String actualSource;
      if (source != null && source.isNotEmpty) {
        actualSource = source;
      } else {
        final hasCash = methods.contains('CASH');
        final hasCard = methods.any((m) => m != 'CASH');
        if (hasCash && !hasCard) {
          actualSource = 'Cash';
        } else if (methods.isNotEmpty) {
          final firstCard = methods.firstWhere(
            (m) => m != 'CASH',
            orElse: () => 'CASH',
          );
          actualSource = _mapSource(firstCard);
        } else {
          actualSource = 'Cash';
        }
      }

      final body = _mutBody({
        'amount': _toDollars(amountText),
        'source': actualSource,
        if (relatedOrderId != null && relatedOrderId.isNotEmpty)
          'relatedOrderId': relatedOrderId,
        if (relatedPaymentId != null && relatedPaymentId.isNotEmpty)
          'relatedPaymentId': relatedPaymentId,
        if (note != null && note.isNotEmpty) 'note': note,
        'payments': {
          'methods': methods,
          'cashPaidAmount': cashPaid,
          'cashTipAmount': 0,
          if (cardPaid > 0) 'cardPaidAmount': cardPaid,
          if (cardPaid > 0) 'cardTipAmount': 0,
          if (cardType != null) 'cardType': cardType,
          if (providerName != null && providerName.isNotEmpty)
            'providerName': providerName,
          if (transactionId != null && transactionId.isNotEmpty)
            'transactionId': transactionId,
        },
      }, key);

      final res = await _api.makePostRequest(url, body);

      if (_unknownStatus(res)) return _fail(_unknownMsg);

      final data = res.data;

      if (_ok(res) && data is Map) {
        final parsed = ReloadCardResponse.fromJson(_asMap(data));
        if (parsed.success && parsed.data != null) {
          lastReload.value = parsed;
          currentCard.value = parsed.data!.card;
          return parsed;
        }
        return _fail(_msgFrom(data) ?? 'Reload failed');
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message.titleCase : 'Reload failed');
      return _fail(msg.titleCase);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // CHECK BALANCE (GET) — no idempotency key, session in body
  // ==========================================================================
  Future<int?> checkBalance(String cardNumber) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final url = URLS.balance(_clean(cardNumber));
      final res = await _api.makeGetRequest(url);
      final data = res.data;

      if (_ok(res) && data is Map) {
        final cents = _extractBalanceCents(data);
        if (cents != null) return cents;
        return _fail(_msgFrom(data) ?? 'Could not read balance');
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message : 'Balance check failed');
      return _fail(msg);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // REVERSE / CANCEL (POST) — session + idempotencyKey + payments object
  // ==========================================================================
  Future<ReverseCardResponse?> reverse({
    required String cardNumber,
    required String tcn,
    required String invoiceNumber,
    required String amountText,
    String? reason,
    String? approverId,
    PaymentSelection? paymentSelection, // optional — refund method
    String? idempotencyKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    final key = _keyFor('cancel', idempotencyKey);

    try {
      final amount = _toDollars(amountText);

      // Build the payments object.
      Map<String, dynamic> paymentsBody;

      if (paymentSelection != null && paymentSelection.payments.isNotEmpty) {
        final payments = paymentSelection.payments;
        final methods = payments.map((p) => _toApiMethod(p.methods)).toList();

        final cashPaid = payments
            .where((p) => _toApiMethod(p.methods) == 'CASH')
            .fold<num>(0, (sum, p) => sum + p.paidAmount);

        final cardPaid = payments
            .where((p) => _toApiMethod(p.methods) != 'CASH')
            .fold<num>(0, (sum, p) => sum + p.paidAmount);

        String? cardType;
        for (final p in payments) {
          final m = _toApiMethod(p.methods);
          if (m != 'CASH') {
            cardType = m;
            break;
          }
        }

        paymentsBody = {
          'methods': methods,
          'cashPaidAmount': cashPaid,
          'cashTipAmount': 0,
          if (cardPaid > 0) 'cardPaidAmount': cardPaid,
          if (cardPaid > 0) 'cardTipAmount': 0,
          if (cardType != null) 'cardType': cardType,
        };
      } else {
        // Default: full cash refund.
        paymentsBody = {
          'methods': ['CASH'],
          'cashPaidAmount': amount,
        };
      }

      final body = _mutBody({
        'cardNumber': _clean(cardNumber),
        'tcn': tcn.trim(),
        'invoiceNumber': invoiceNumber.trim(),
        'amount': amount,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (approverId != null && approverId.trim().isNotEmpty)
          'approverId': approverId.trim(),
        'payments': paymentsBody,
      }, key);

      final res = await _api.makePostRequest(URLS.reverse, body);

      if (_unknownStatus(res)) return _fail(_unknownMsg);

      final data = res.data;

      if (_ok(res) && data is Map) {
        final parsed = ReverseCardResponse.fromJson(_asMap(data));
        if (parsed.success && parsed.data != null) {
          lastReversed.value = parsed;
          return parsed;
        }
        return _fail(
          parsed.message.isNotEmpty ? parsed.message : 'Reversal failed',
        );
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message : 'Reversal failed');
      return _fail(msg);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<RedeemResponse?> redeem({
    required String cardNumber,
    required String amountText,
    String? orderId,
    int? maxRedeemableCents,
    String? idempotencyKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final requestedCents = _toCents(amountText);
      if (requestedCents <= 0) {
        return _fail('Enter A Valid Redeem Amount');
      }

      // final cap = maxRedeemableCents ?? currentCard.value?.balanceCents;
      // TODO: POS merge korle order amount theke maxRedeemableCents asbe.
      // Apatoto static fallback (backend required field).
      final cap =
          maxRedeemableCents ??
          currentCard.value?.balanceCents ??
          50000; // static: $500.00

      if (cap != null && requestedCents > cap) {
        return _fail('Amount Exceeds Available Balance');
      }

      final key = _keyFor('redeem', idempotencyKey);
      final order = (orderId != null && orderId.trim().isNotEmpty)
          ? orderId.trim()
          : 'POS-${DateTime.now().millisecondsSinceEpoch}';

      final body = _mutBody({
        'cardNumber': _clean(cardNumber),
        'orderId': order,
        'requestedAmountCents': requestedCents,
        'maxRedeemableCents': cap,

        // if (cap != null) 'maxRedeemableCents': cap,
      }, key);
      // DEBUG (pore muche dio)
      // ignore: avoid_print
      print('[redeem] body => $body');

      final res = await _api.makePostRequest(URLS.redeem, body);

      if (_unknownStatus(res)) return _fail(_unknownMsg);

      final data = res.data;

      if (_ok(res) && data is Map) {
        final parsed = RedeemResponse.fromJson(_asMap(data));
        if (parsed.success && parsed.data != null) {
          lastRedeemed.value = parsed;
          return parsed;
        }
        return _fail(_msgFrom(data) ?? 'Redeem Failed');
      }

      final msg =
          (data is Map ? _msgFrom(data) : null) ??
          (res.message.isNotEmpty ? res.message : 'Redeem Failed');
      return _fail(msg);
    } catch (e) {
      return _fail('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================================
  // helpers
  // ==========================================================================

  /// Mutating body: idempotencyKey (in body) + session + actual fields.
  /// Order matches the example JSON — idempotencyKey first.
  // Map<String, dynamic> _mutBody(Map<String, dynamic> body, String key) => {
  //   'idempotencyKey': key,
  //   ...AppHeaders.session, // tenant/location/staff
  //   ...body,
  // };
  Map<String, dynamic> _mutBody(Map<String, dynamic> body, String key) => {
    'idempotencyKey': key,
    // NOTE: session (tenant/location/staff) ekhon HEADER + TOKEN e jay.
    // Body te ar pathano hobe na.
    ...body,
  };

  /// Builds a prefixed key (activate-<guid>, reload-<guid>, cancel-<guid>...).
  /// On retry the caller passes the same key as [provided] so it is reused
  /// instead of generating a new one. Also stored in lastIdempotencyKey.
  String _keyFor(String prefix, String? provided) {
    final key = (provided != null && provided.isNotEmpty)
        ? provided
        : '$prefix-${IdempotencyKey.generate()}';
    lastIdempotencyKey = key;
    return key;
  }

  static const String _unknownMsg =
      'Connection Issue — Transaction Status Unknown. '
      'Please Retry (Same Transaction) Or Check Card Balance.';

  bool _unknownStatus(BaseModel r) =>
      r.statusCode == -1 ||
      r.statusCode == 502 ||
      r.statusCode == 503 ||
      r.statusCode == 504;

  bool _ok(BaseModel r) => r.statusCode == 200 || r.statusCode == 201;
  Map<String, dynamic> _asMap(dynamic d) => Map<String, dynamic>.from(d as Map);

  String? _msgFrom(Map data) {
    final m = data['message'];
    return (m != null && m.toString().isNotEmpty)
        ? _titleCase(m.toString())
        : null;
  }

  String _titleCase(String input) => input
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  int? _extractBalanceCents(Map body) {
    Map? m;
    final inner = body['data'];
    if (inner is Map) {
      m = inner['card'] is Map ? (inner['card'] as Map) : inner;
    }
    m ??= body;
    final v = m['balanceCents'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  Null _fail(String msg) {
    errorMessage.value = msg;
    return null;
  }

  String _clean(String input) => input.replaceAll(RegExp(r'\D'), '');

  int _toCents(String text) {
    final v = double.tryParse(text.trim()) ?? 0;
    return (v * 100).round();
  }

  num _toDollars(String text) {
    final v = double.tryParse(text.trim()) ?? 0;
    return v % 1 == 0 ? v.toInt() : v;
  }
}
