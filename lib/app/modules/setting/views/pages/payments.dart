import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/payments_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';

class Payments extends GetView<PaymentsController> {
  const Payments({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //moneris terminal
        Visibility(
          visible: BaseController.to.posMonerisTerminal,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moneris', style: theme.textTheme.headlineMedium),
                SizedBox(height: 8),
                Text('Terminal IP', style: theme.textTheme.titleSmall),
                GetBuilder<PosController>(
                  builder: (pc) {
                    return CustomSearchTextField(
                      hintText: controller.terminalId.isEmpty
                          ? "Select Terminal"
                          : controller.terminalId,
                      dropDownList: List.generate(
                        pc.terminals!.terminalIds.length,
                        (index) {
                          return DropDownValueModel(
                            value: pc.terminals!.terminalIds[index].terminalId,
                            name: pc.terminals!.terminalIds[index].terminalId,
                          );
                        },
                      ),
                      onChanged: (value) {
                        controller.setTerminalId(value.name);
                      },
                    );
                  },
                ),
                SizedBox(height: 42),
              ],
            ),
          ),
        ),
        //elavon terminal
        Visibility(
          visible: BaseController.to.posElavonTerminal,
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //title
                Text(
                  'Elavon Series 5000',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: 8),

                //IP
                Text('Terminal IP', style: theme.textTheme.titleSmall),
                SizedBox(height: 4),
                CustomTextField(
                  controller: controller.terminalIpController,
                  focusNode: controller.terminalIpFocus,
                  keyboardType: KeyboardType.alphaNumeric,
                  onChange: (value) {
                    controller.setTerminalIp(value);
                  },
                  onKeyboardChang: (value) {
                    controller.setTerminalIp(value);
                  },
                  // allowRegex: RegExp(r'^(?!.*\.\.)[\d.]*$'),
                  // allowRegex: RegExp(r'^(?!\.)(?!.*\.\.)[\d.]*$'),
                  allowRegex: RegExp(r'^(?!\.)(?!.*\.\.)[\d.]{0,25}$'),
                ),
                SizedBox(height: 12),
                // port
                Text('Terminal Port', style: theme.textTheme.titleSmall),
                SizedBox(height: 4),
                CustomTextField(
                  controller: controller.terminalPortController,
                  focusNode: controller.terminalPortFocus,
                  keyboardType: KeyboardType.numeric,
                  allowRegex: RegExp(r'^\d{0,6}$'),
                  onChange: (value) {
                    int? val = int.tryParse(value);
                    if (val != null) {
                      controller.setTerminalPort(val);
                    }
                  },
                  onKeyboardChang: (value) {
                    int? val = int.tryParse(value);
                    if (val != null) {
                      controller.setTerminalPort(val);
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        // elavon cws terminal
        // Visibility(
        //   visible: BaseController.to.posElavonCws,
        //   child: SizedBox(
        //     width: 500,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         //title
        //         Text('Elavon CWS', style: theme.textTheme.headlineMedium),
        //         SizedBox(height: 8),

        //         //IP
        //         Text('CWS is Connected', style: theme.textTheme.titleSmall),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
