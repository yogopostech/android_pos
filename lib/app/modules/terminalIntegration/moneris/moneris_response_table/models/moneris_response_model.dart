// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';

class MonerisResponseModel {
  final List<MonerisPurchaseModel> data;
  final MetaModel meta;

  MonerisResponseModel({
    required this.data,
    required this.meta,
  });

  factory MonerisResponseModel.fromJson(Map<String, dynamic> json) {
    return MonerisResponseModel(
      data: (json['data'] as List)
          .map((e) => MonerisPurchaseModel.fromJson(e))
          .toList(),
      meta: MetaModel.fromJson(json['meta']),
    );
  }
}
