import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';

class EditNotes extends StatefulWidget {
  final OrderModel order;
  final void Function(String notes) onPressed;
  const EditNotes({super.key, required this.order, required this.onPressed});

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  late final TextEditingController _notesController =
      TextEditingController(text: widget.order.notes);
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _notesController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if(widget.order.notes.isNotEmpty){
      _notesController.text = widget.order.notes;
    }
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Edit Notes',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          initOpenKeyboard: true,
          allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
          maxLines: 5,
          focusNode: _focusNode,
          controller: _notesController,
        ),
        const SizedBox(height: 16),
        PrimaryBtn(
          onPressed: () {
            widget.onPressed(_notesController.text);
          },
          width: 200,
          textMinSize: 18,
          textMaxSize: 20,
          fontWeight: FontWeight.bold,
          text: 'Save',
          textColor: Colors.white,
        ),
      ],
    );
  }
}
