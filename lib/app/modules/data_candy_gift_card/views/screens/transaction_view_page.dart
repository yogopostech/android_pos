import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

class TransactionDetailsViewpage extends StatelessWidget {
  const TransactionDetailsViewpage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const TitleBar(),
          toolbarHeight: 30,
        ),
      body: Scaffold(
        appBar: AppBar(
          title: MyCustomText("Transaction",fontSize: 24,),
          centerTitle: true,
          backgroundColor: StaticColors.cartColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

          MyCustomText("All Transaction",fontSize: 18,fontWeight: FontWeight.w700,),



            ],
          ),
        ),
      ),
    );
  }
}