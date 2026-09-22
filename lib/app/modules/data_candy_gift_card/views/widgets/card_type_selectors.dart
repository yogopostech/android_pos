// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';

class CardTypeSelector extends StatefulWidget {
  const CardTypeSelector({super.key});

  @override
  _CardTypeSelectorState createState() => _CardTypeSelectorState();
}

class _CardTypeSelectorState extends State<CardTypeSelector> {
  String _selectedCardType = "gift_card";

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Card Type:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 20),

        // Gift Card
        Row(
          children: [
            Radio<String>(
              value: "gift_card",
              groupValue: _selectedCardType,
              onChanged: (value) {
                setState(() {
                  _selectedCardType = value!;
                });
              },
            ),
            Text("Gift Card"),
          ],
        ),
        SizedBox(width: 20),

        // Gift Voucher
        Row(
          children: [
            Radio<String>(
              value: "gift_voucher",
              groupValue: _selectedCardType,
              onChanged: (value) {
                setState(() {
                  _selectedCardType = value!;
                });
              },
            ),
            Text("Gift Voucher"),
          ],
        ),
      ],
    );
  }
}
