import 'package:flutter/material.dart';
import 'package:sikum/core/theme/app_colors.dart';

class CustomCheckBox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDataSaved;

  const CustomCheckBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDataSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: isDataSaved
              ? null // Si está guardado, no se puede interactuar
              : (bool? newValue) {
                  onChanged(newValue ?? false);
                },
          activeColor: AppColors.green,
        ),
        Text(label),
      ],
    );
  }
}
