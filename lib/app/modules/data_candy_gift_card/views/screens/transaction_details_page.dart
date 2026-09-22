import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/all_card_data_candy_model.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';
import '../../controller/transaction_controller.dart';
import '../widgets/user_transaction_table.dart';

class GiftCardTransactionDetailsPage extends StatefulWidget {
  final GiftCardModel card;

  const GiftCardTransactionDetailsPage({super.key, required this.card});

  @override
  State<GiftCardTransactionDetailsPage> createState() =>
      _GiftCardTransactionDetailsPageState();
}

class _GiftCardTransactionDetailsPageState
    extends State<GiftCardTransactionDetailsPage> {
  final GiftCardController giftCardController = Get.put(GiftCardController());
  final TransactionController transactionController =
      Get.put(TransactionController());

  @override
  void initState() {
    // Get.put(GiftCardController());
    get();
    transactionController.fetchTransactions(cardSearch: widget.card.cid);
    super.initState();
  }

  Future<void> get() async {
    await giftCardController.checkBlance();
  }

  @override
  Widget build(BuildContext context) {
    // Get.put(TransactionController());

    // final TransactionController transactionController = Get.put(TransactionController());

    // transactionController.fetchTransactions(cardSearch:widget.card.cid);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const TitleBar(),
        toolbarHeight: 30,
      ),
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: StaticColors.cartColor,
          title: Text("${widget.card.customerName}"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyCustomText(
                        "Card Number:",
                        fontSize: 20,
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      MyCustomText(
                        widget.card.cid,
                        fontSize: 20,
                      ),
                      // MyCustomText("${card.cid}"),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyCustomText(
                        "Customer Name: ",
                        fontSize: 20,
                      ),
                      SizedBox(
                        width: 68,
                      ),
                      MyCustomText(
                        "${widget.card.customerName}",
                        textAlign: TextAlign.start,
                        fontSize: 20,
                      ),
                    ],
                  ),

                  // Expanded(flex:2,child: Container()),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyCustomText(
                        "Phone:",
                        fontSize: 20,
                      ),
                      SizedBox(
                        width: 165,
                      ),
                      MyCustomText(
                        "${widget.card.customerPhone}",
                        fontSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyCustomText(
                        "Balance:",
                        fontSize: 20,
                      ),
                      SizedBox(
                        width: 150,
                      ),
                      // MyCustomText("\$${widget.card.balance}"),
                      Obx(() => MyCustomText(
                            "\$${giftCardController.cardController.value}",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      // MyCustomText("\$${giftCardController.totalBlance.value}"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(),

              SizedBox(
                height: 25,
              ),
              MyCustomText(
                "All Transaction",
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(
                height: 25,
              ),
              Expanded(child: TransactionTable()),
            ],
          ),
        ),
      ),
    );
  }
}