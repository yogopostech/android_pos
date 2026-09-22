import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class EditGratuity extends StatefulWidget {
  final bool isNewOrder;
  const EditGratuity({super.key, required this.isNewOrder});

  @override
  State<EditGratuity> createState() => _EditGratuityState();
}

class _EditGratuityState extends State<EditGratuity> {
  final _gratuityController = TextEditingController();
  final _gratuityFocusNode = FocusNode();

  @override
  void dispose() {
    _gratuityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Edit Gratuity %",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(height: 6),
          CustomTextField(
            initOpenKeyboard: true,
            keyboardType: KeyboardType.numeric,
            controller: _gratuityController,
            focusNode: _gratuityFocusNode,
            // should ne number and 100 <=
            allowRegex: RegExp(r'^(100|\d{0,2})$'),
          ),
          SizedBox(height: 18),

          PrimaryBtn(
            onPressed: () async {
              final int? gratuity = int.tryParse(_gratuityController.text);
              if (gratuity != null && gratuity >= 0 && gratuity <= 100) {
                PosController.to.onChangeGratuity(gratuity);
                Get.back();
                if (!widget.isNewOrder) {
                  PopupDialog.showLoadingDialog();
                  await PosController.to.onUpdateOrder(
                    PosController.to.myOrder.id,
                  );
                  PopupDialog.closeLoadingDialog();
                }
              } else {
                debugPrint("invalid gratuity");
              }
            },
            color: StaticColors.greenColor,
            textColor: Colors.white,
            text: "Save".toLowerCase(),
            textMaxSize: 35,
            textMinSize: 30,
            height: 80,
            width: 120,
          ),
        ],
      ),
    );
  }
}
