/// Elavon Commerce Web Services (CWS) — Gratuity (Tip) Models
///
/// Mirrors the CWS gratuity request shape:
///   gratuityFlowEnabled, gratuityAmount, gratuityCustomAmountEntryAllowed,
///   gratuityQuickSelections { selection1..3 : { type, currencyCode, value } }
library;

/// A single quick-tip selection shown on the terminal — either a percentage
/// (e.g. 15%) or a fixed monetary amount (in minor units / cents).
class CwsTipOption {
  final bool isPercentage;
  final int value; // percentage (15) OR minor units (300 = $3.00)

  const CwsTipOption.percent(this.value) : isPercentage = true;
  const CwsTipOption.amount(this.value) : isPercentage = false;

  Map<String, String> toJson(String currency) => {
    'type': isPercentage ? 'PERCENTAGE' : 'MONETARY_AMOUNT',
    'currencyCode': currency,
    'value': value.toString(),
  };

  @override
  String toString() =>
      isPercentage ? '$value%' : '\$${(value / 100).toStringAsFixed(2)}';
}

/// Gratuity configuration for a sale. Build one of:
///   - [CwsGratuity.prompt]   → terminal prompts the customer for a tip
///   - [CwsGratuity.fixed]    → a pre-entered tip added to the sale
///   - [CwsGratuity.none]     → no gratuity (default)
class CwsGratuity {
  /// Show the gratuity flow on the terminal.
  final bool flowEnabled;

  /// Allow the customer to key a custom amount on the terminal.
  final bool customAmountAllowed;

  /// Up to 3 quick-tip selections. Null → terminal defaults (15% / 18% / 20%).
  final List<CwsTipOption>? quickSelections;

  /// Pre-entered fixed tip in minor units (used when the reader can't collect
  /// an amount, or when the tip is already known from the POS). Null otherwise.
  final int? fixedTipCents;

  const CwsGratuity._({
    required this.flowEnabled,
    required this.customAmountAllowed,
    this.quickSelections,
    this.fixedTipCents,
  });

  /// No tip.
  static const CwsGratuity none = CwsGratuity._(
    flowEnabled: false,
    customAmountAllowed: false,
  );

  /// Terminal prompts the customer. Optionally override quick selections and
  /// whether a custom amount can be keyed.
  const CwsGratuity.prompt({
    List<CwsTipOption>? quickSelections,
    bool customAmountAllowed = true,
  }) : this._(
         flowEnabled: true,
         customAmountAllowed: customAmountAllowed,
         quickSelections: quickSelections,
       );

  /// A tip already determined by the POS (no terminal prompt).
  const CwsGratuity.fixed(int tipCents)
    : this._(
        flowEnabled: false,
        customAmountAllowed: false,
        fixedTipCents: tipCents,
      );

  bool get isEnabled => flowEnabled || (fixedTipCents != null);

  /// Merge the gratuity parameters into a startPaymentTransaction body.
  /// `amountFor` builds the { value, currencyCode } object for a cents value.
  Map<String, dynamic> toParams(
    String currency,
    Map<String, dynamic> Function(int cents, String currency) amountFor,
  ) {
    if (!isEnabled) return const {};

    return {
      if (flowEnabled) 'gratuityFlowEnabled': true,
      if (flowEnabled) 'gratuityCustomAmountEntryAllowed': customAmountAllowed,
      if (fixedTipCents != null)
        'gratuityAmount': amountFor(fixedTipCents!, currency),
      if (flowEnabled &&
          quickSelections != null &&
          quickSelections!.isNotEmpty)
        'gratuityQuickSelections': {
          for (var i = 0; i < quickSelections!.length && i < 3; i++)
            'selection${i + 1}': quickSelections![i].toJson(currency),
        },
    };
  }
}
