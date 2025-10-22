
import 'package:flutter/material.dart';
import "package:localization_lite/translate.dart";


import '../../../models/PrimaryContainer.dart';
class NumericField extends StatelessWidget {
  const NumericField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.maxValue});
  final TextEditingController controller;
  final int maxValue;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      paddingHorizontal: 20,
      padding: 0,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(),
        validator: (value) {
          int? val = int.tryParse(value??"" );
          if (value == null || value.isEmpty) {
            return tr("pleaseEnterNumber");
          } else if (val! > maxValue) {
            return "${tr("valueMustBeLessThan")} $maxValue";
          } else if (val < 0) {
            return "${tr("valueMustBeGreaterThan")} 0";
          }
          return null;
        },
        decoration:
            InputDecoration(hintText: hintText, border: InputBorder.none),
      ),
    );
  }
}
