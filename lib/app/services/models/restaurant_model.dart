// import 'package:json_annotation/json_annotation.dart';
// import 'package:yogo_pos/app/services/models/packaging_cost_model.dart';

// part 'restaurant_model.g.dart';

// @JsonEnum()
// enum RestaurantType {
//   @JsonValue('italian')
//   italian,
//   @JsonValue('indian')
//   indian,
//   @JsonValue('fast food')
//   fastFood,
//   @JsonValue('pizza')
//   pizza,
// }

// @JsonEnum()
// enum PosDisplayMode {
//   @JsonValue('ITEMS_ONLY')
//   itemsOnly,
//   @JsonValue('CATEGORY_WITH_ITEMS')
//   categoryWithItems,
//   @JsonValue('BOTH')
//   both,
// }

// extension PosDisplayModeLabel on PosDisplayMode {
//   String get label {
//     switch (this) {
//       case PosDisplayMode.itemsOnly:
//         return 'Layout 1';
//       case PosDisplayMode.categoryWithItems:
//         return 'Layout 2';
//       case PosDisplayMode.both:
//         return 'Layout 3';
//     }
//   }
// }
// @JsonSerializable()
// class RestaurantModel {
//   RestaurantModel({
//     required this.name,
//     required this.groceriesMeat,
//     required this.allowLayoutChange,
//     required this.email,
//     required this.password,
//     required this.phone,
//     required this.address,
//     required this.restaurantType,
//     required this.logo,
//     required this.id,
//     required this.lightLogo,
//     required this.darkLogo,
//     required this.openingTime,
//     required this.closingTime,
//     required this.posMonerisTerminal,
//     required this.posElavonTerminal,
//     required this.posElavonCws,
//     required this.dineIn,
//     required this.takeout,
//     required this.olo,
//     required this.pickup,
//     required this.numberOfReceipt,
//     required this.gratuityPersonCount,
//     required this.packagingCost,
//     required this.allowPriceChange,
//     required this.deliveryAudited,
//     required this.posDelivery,
//     required this.oloDelivery,
//     required this.posReservation,
//     required this.posDeliveryPrint,
//     required this.oloOrderPrint,
//     required this.notificationSoundEnabled,
//     required this.customKeyboardEnabled,
//     required this.keyboardSoundEnabled,
//     required this.posCombinePrint,
//     required this.posCategoryDisplayMode,
//     // JSON theke pora hoy na — constant behavior, tai default (required na)
//     this.printLogo = '',
//     this.allowDualScreen = false,
//     this.hybridPaymentOption = true,
//   });

//   @JsonKey(defaultValue: '')
//   final String name;

//   @JsonKey(defaultValue: false)
//   final bool groceriesMeat;

//   @JsonKey(defaultValue: false)
//   final bool allowLayoutChange;

//   @JsonKey(defaultValue: '')
//   final String email;

//   @JsonKey(defaultValue: '')
//   final String password;

//   @JsonKey(defaultValue: '')
//   final String phone;

//   @JsonKey(defaultValue: '')
//   final String address;

//   @JsonKey(
//     unknownEnumValue: RestaurantType.fastFood,
//     defaultValue: RestaurantType.fastFood,
//   )
//   final RestaurantType restaurantType;

//   @JsonKey(defaultValue: '')
//   final String id;

//   @JsonKey(defaultValue: '')
//   final String logo;

//   @JsonKey(defaultValue: '')
//   final String lightLogo;

//   @JsonKey(defaultValue: '')
//   final String darkLogo;

//   @JsonKey(defaultValue: '')
//   final String closingTime;

//   @JsonKey(defaultValue: '')
//   final String openingTime;

//   // JSON theke pora hoy na, kintu toJson e output hoy (always "")
//   @JsonKey(includeFromJson: false)
//   final String printLogo;

//   @JsonKey(defaultValue: false)
//   final bool dineIn;

//   // JSON theke pora hoy na, always true
//   @JsonKey(includeFromJson: false)
//   final bool hybridPaymentOption;

//   @JsonKey(defaultValue: false)
//   final bool posMonerisTerminal;

//   @JsonKey(defaultValue: false)
//   final bool posElavonTerminal;

//   @JsonKey(defaultValue: false)
//   final bool posElavonCws;

//   @JsonKey(defaultValue: false)
//   final bool olo;

//   // Original toJson e pickup chilo na — tai output e rakhlam na
//   @JsonKey(defaultValue: false, includeToJson: false)
//   final bool pickup;

//   @JsonKey(defaultValue: false)
//   final bool posDelivery;

//   @JsonKey(defaultValue: false)
//   final bool oloDelivery;

//   @JsonKey(defaultValue: false)
//   final bool takeout;

//   @JsonKey(defaultValue: false)
//   final bool posReservation;

//   @JsonKey(defaultValue: false)
//   final bool allowPriceChange;

//   @JsonKey(defaultValue: false)
//   final bool deliveryAudited;

//   // JSON theke pora hoy na, always false
//   @JsonKey(includeFromJson: false)
//   final bool allowDualScreen;

//   @JsonKey(defaultValue: 1)
//   final int numberOfReceipt;

//   @JsonKey(defaultValue: 3)
//   final int gratuityPersonCount;

//   final PackagingCostModel packagingCost;

//   @JsonKey(defaultValue: false)
//   final bool posDeliveryPrint;

//   @JsonKey(defaultValue: false)
//   final bool oloOrderPrint;

//   @JsonKey(defaultValue: false)
//   final bool notificationSoundEnabled;

//   @JsonKey(defaultValue: false)
//   final bool customKeyboardEnabled;

//   @JsonKey(defaultValue: false)
//   final bool keyboardSoundEnabled;

//   @JsonKey(defaultValue: false)
//   final bool posCombinePrint;

//   @JsonKey(
//     unknownEnumValue: PosDisplayMode.itemsOnly,
//     defaultValue: PosDisplayMode.itemsOnly,
//   )
//   final PosDisplayMode posCategoryDisplayMode;

//   factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
//       _$RestaurantModelFromJson(json);

//   Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
// }

import 'package:json_annotation/json_annotation.dart';
import 'package:yogo_pos/app/services/models/packaging_cost_model.dart';

part 'restaurant_model.g.dart';

@JsonEnum()
enum RestaurantType {
  @JsonValue('italian')
  italian,
  @JsonValue('indian')
  indian,
  @JsonValue('fast food')
  fastFood,
  @JsonValue('pizza')
  pizza,
}

@JsonEnum()
enum PosDisplayMode {
  @JsonValue('ITEMS_ONLY')
  itemsOnly,
  @JsonValue('CATEGORY_WITH_ITEMS')
  categoryWithItems,
  @JsonValue('BOTH')
  both,
}

extension PosDisplayModeLabel on PosDisplayMode {
  String get label {
    switch (this) {
      case PosDisplayMode.itemsOnly:
        return 'Layout 1';
      case PosDisplayMode.categoryWithItems:
        return 'Layout 2';
      case PosDisplayMode.both:
        return 'Layout 3';
    }
  }
}

@JsonEnum()
enum CallerIdType {
  @JsonValue('TYPE_ONE')
  typeOne,
  @JsonValue('TYPE_TWO')
  typeTwo,
  @JsonValue('BOTH')
  both,
}

extension CallerIdTypeLabel on CallerIdType {
  String get label {
    switch (this) {
      case CallerIdType.typeOne:
        return 'Type 1';
      case CallerIdType.typeTwo:
        return 'Type 2';
      case CallerIdType.both:
        return 'Both';
    }
  }
}

@JsonSerializable()
class RestaurantModel {
  RestaurantModel({
    required this.name,
    required this.groceriesMeat,
    required this.allowLayoutChange,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.restaurantType,
    required this.logo,
    required this.id,
    required this.lightLogo,
    required this.darkLogo,
    required this.openingTime,
    required this.closingTime,
    required this.posMonerisTerminal,
    required this.posElavonTerminal,
    required this.posElavonCws,
    required this.dineIn,
    required this.takeout,
    required this.olo,
    required this.pickup,
    required this.numberOfReceipt,
    required this.gratuityPersonCount,
    required this.packagingCost,
    required this.allowPriceChange,
    required this.deliveryAudited,
    required this.posDelivery,
    required this.oloDelivery,
    required this.posReservation,
    required this.posDeliveryPrint,
    required this.oloOrderPrint,
    required this.notificationSoundEnabled,
    required this.customKeyboardEnabled,
    required this.keyboardSoundEnabled,
    required this.posCombinePrint,
    required this.posCategoryDisplayMode,
    required this.callerIdType,
    required this.allowCallerIdTypeChange,
    // JSON theke pora hoy na — constant behavior, tai default (required na)
    this.printLogo = '',
    this.allowDualScreen = false,
    this.hybridPaymentOption = true,
  });

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: false)
  final bool groceriesMeat;

  @JsonKey(defaultValue: false)
  final bool allowLayoutChange;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String password;

  @JsonKey(defaultValue: '')
  final String phone;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(
    unknownEnumValue: RestaurantType.fastFood,
    defaultValue: RestaurantType.fastFood,
  )
  final RestaurantType restaurantType;

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String logo;

  @JsonKey(defaultValue: '')
  final String lightLogo;

  @JsonKey(defaultValue: '')
  final String darkLogo;

  @JsonKey(defaultValue: '')
  final String closingTime;

  @JsonKey(defaultValue: '')
  final String openingTime;

  // JSON theke pora hoy na, kintu toJson e output hoy (always "")
  @JsonKey(includeFromJson: false)
  final String printLogo;

  @JsonKey(defaultValue: false)
  final bool dineIn;

  // JSON theke pora hoy na, always true
  @JsonKey(includeFromJson: false)
  final bool hybridPaymentOption;

  @JsonKey(defaultValue: false)
  final bool posMonerisTerminal;

  @JsonKey(defaultValue: false)
  final bool posElavonTerminal;

  @JsonKey(defaultValue: false)
  final bool posElavonCws;

  @JsonKey(defaultValue: false)
  final bool olo;

  // Original toJson e pickup chilo na — tai output e rakhlam na
  @JsonKey(defaultValue: false, includeToJson: false)
  final bool pickup;

  @JsonKey(defaultValue: false)
  final bool posDelivery;

  @JsonKey(defaultValue: false)
  final bool oloDelivery;

  @JsonKey(defaultValue: false)
  final bool takeout;

  @JsonKey(defaultValue: false)
  final bool posReservation;

  @JsonKey(defaultValue: false)
  final bool allowPriceChange;

  @JsonKey(defaultValue: false)
  final bool deliveryAudited;

  // JSON theke pora hoy na, always false
  @JsonKey(includeFromJson: false)
  final bool allowDualScreen;

  @JsonKey(defaultValue: 1)
  final int numberOfReceipt;

  @JsonKey(defaultValue: 3)
  final int gratuityPersonCount;

  final PackagingCostModel packagingCost;

  @JsonKey(defaultValue: false)
  final bool posDeliveryPrint;

  @JsonKey(defaultValue: false)
  final bool oloOrderPrint;

  @JsonKey(defaultValue: false)
  final bool notificationSoundEnabled;

  @JsonKey(defaultValue: false)
  final bool customKeyboardEnabled;

  @JsonKey(defaultValue: false)
  final bool keyboardSoundEnabled;

  @JsonKey(defaultValue: false)
  final bool posCombinePrint;

  @JsonKey(
    unknownEnumValue: PosDisplayMode.itemsOnly,
    defaultValue: PosDisplayMode.itemsOnly,
  )
  final PosDisplayMode posCategoryDisplayMode;

  @JsonKey(
    unknownEnumValue: CallerIdType.typeOne,
    defaultValue: CallerIdType.typeOne,
  )
  final CallerIdType callerIdType;

  @JsonKey(defaultValue: false)
  final bool allowCallerIdTypeChange;

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
}
