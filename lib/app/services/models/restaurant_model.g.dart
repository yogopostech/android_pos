// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantModel _$RestaurantModelFromJson(
  Map<String, dynamic> json,
) => RestaurantModel(
  name: json['name'] as String? ?? '',
  groceriesMeat: json['groceriesMeat'] as bool? ?? false,
  allowLayoutChange: json['allowLayoutChange'] as bool? ?? false,
  email: json['email'] as String? ?? '',
  password: json['password'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  address: json['address'] as String? ?? '',
  restaurantType:
      $enumDecodeNullable(
        _$RestaurantTypeEnumMap,
        json['restaurantType'],
        unknownValue: RestaurantType.fastFood,
      ) ??
      RestaurantType.fastFood,
  logo: json['logo'] as String? ?? '',
  id: json['id'] as String? ?? '',
  lightLogo: json['lightLogo'] as String? ?? '',
  darkLogo: json['darkLogo'] as String? ?? '',
  openingTime: json['openingTime'] as String? ?? '',
  closingTime: json['closingTime'] as String? ?? '',
  posMonerisTerminal: json['posMonerisTerminal'] as bool? ?? false,
  posElavonTerminal: json['posElavonTerminal'] as bool? ?? false,
  posElavonCws: json['posElavonCws'] as bool? ?? false,
  dineIn: json['dineIn'] as bool? ?? false,
  takeout: json['takeout'] as bool? ?? false,
  olo: json['olo'] as bool? ?? false,
  pickup: json['pickup'] as bool? ?? false,
  numberOfReceipt: (json['numberOfReceipt'] as num?)?.toInt() ?? 1,
  gratuityPersonCount: (json['gratuityPersonCount'] as num?)?.toInt() ?? 3,
  packagingCost: PackagingCostModel.fromJson(
    json['packagingCost'] as Map<String, dynamic>,
  ),
  allowPriceChange: json['allowPriceChange'] as bool? ?? false,
  deliveryAudited: json['deliveryAudited'] as bool? ?? false,
  posDelivery: json['posDelivery'] as bool? ?? false,
  oloDelivery: json['oloDelivery'] as bool? ?? false,
  posReservation: json['posReservation'] as bool? ?? false,
  posDeliveryPrint: json['posDeliveryPrint'] as bool? ?? false,
  oloOrderPrint: json['oloOrderPrint'] as bool? ?? false,
  notificationSoundEnabled: json['notificationSoundEnabled'] as bool? ?? false,
  customKeyboardEnabled: json['customKeyboardEnabled'] as bool? ?? false,
  keyboardSoundEnabled: json['keyboardSoundEnabled'] as bool? ?? false,
  posCombinePrint: json['posCombinePrint'] as bool? ?? false,
  posCategoryDisplayMode:
      $enumDecodeNullable(
        _$PosDisplayModeEnumMap,
        json['posCategoryDisplayMode'],
        unknownValue: PosDisplayMode.itemsOnly,
      ) ??
      PosDisplayMode.itemsOnly,
  callerIdType:
      $enumDecodeNullable(
        _$CallerIdTypeEnumMap,
        json['callerIdType'],
        unknownValue: CallerIdType.typeOne,
      ) ??
      CallerIdType.typeOne,
  allowCallerIdTypeChange: json['allowCallerIdTypeChange'] as bool? ?? false,
);

Map<String, dynamic> _$RestaurantModelToJson(RestaurantModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'groceriesMeat': instance.groceriesMeat,
      'allowLayoutChange': instance.allowLayoutChange,
      'email': instance.email,
      'password': instance.password,
      'phone': instance.phone,
      'address': instance.address,
      'restaurantType': _$RestaurantTypeEnumMap[instance.restaurantType]!,
      'id': instance.id,
      'logo': instance.logo,
      'lightLogo': instance.lightLogo,
      'darkLogo': instance.darkLogo,
      'closingTime': instance.closingTime,
      'openingTime': instance.openingTime,
      'dineIn': instance.dineIn,
      'posMonerisTerminal': instance.posMonerisTerminal,
      'posElavonTerminal': instance.posElavonTerminal,
      'posElavonCws': instance.posElavonCws,
      'olo': instance.olo,
      'posDelivery': instance.posDelivery,
      'oloDelivery': instance.oloDelivery,
      'takeout': instance.takeout,
      'posReservation': instance.posReservation,
      'allowPriceChange': instance.allowPriceChange,
      'deliveryAudited': instance.deliveryAudited,
      'numberOfReceipt': instance.numberOfReceipt,
      'gratuityPersonCount': instance.gratuityPersonCount,
      'packagingCost': instance.packagingCost,
      'posDeliveryPrint': instance.posDeliveryPrint,
      'oloOrderPrint': instance.oloOrderPrint,
      'notificationSoundEnabled': instance.notificationSoundEnabled,
      'customKeyboardEnabled': instance.customKeyboardEnabled,
      'keyboardSoundEnabled': instance.keyboardSoundEnabled,
      'posCombinePrint': instance.posCombinePrint,
      'posCategoryDisplayMode':
          _$PosDisplayModeEnumMap[instance.posCategoryDisplayMode]!,
      'callerIdType': _$CallerIdTypeEnumMap[instance.callerIdType]!,
      'allowCallerIdTypeChange': instance.allowCallerIdTypeChange,
    };

const _$RestaurantTypeEnumMap = {
  RestaurantType.italian: 'italian',
  RestaurantType.indian: 'indian',
  RestaurantType.fastFood: 'fast food',
  RestaurantType.pizza: 'pizza',
};

const _$PosDisplayModeEnumMap = {
  PosDisplayMode.itemsOnly: 'ITEMS_ONLY',
  PosDisplayMode.categoryWithItems: 'CATEGORY_WITH_ITEMS',
  PosDisplayMode.both: 'BOTH',
};

const _$CallerIdTypeEnumMap = {
  CallerIdType.typeOne: 'TYPE_ONE',
  CallerIdType.typeTwo: 'TYPE_TWO',
  CallerIdType.both: 'BOTH',
};
