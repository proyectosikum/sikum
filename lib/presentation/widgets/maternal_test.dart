import 'package:flutter/material.dart';
import 'package:sikum/presentation/widgets/custom_checkbox.dart';
import 'package:sikum/presentation/widgets/custom_date_picker.dart';

class MaternalTest extends StatelessWidget {
  final String testName;
  final bool isTreponemalTest;
  final String result;
  final String date;
  final bool isDataSaved;
  final bool hasError;
  final ValueChanged<String> onResultChanged;
  final ValueChanged<String> onDateChanged;

  const MaternalTest({
    super.key,
    required this.testName,
    this.isTreponemalTest = false,
    required this.result,
    required this.date,
    required this.isDataSaved,
    required this.hasError,
    required this.onResultChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:Color.fromARGB(121, 216, 216, 216),
        border: hasError ? Border.all(color: Colors.red, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(testName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomCheckBox(
                  label: 'Negativa',
                  value: result == 'Negativa',
                  onChanged: (value) =>
                      onResultChanged(value ? 'Negativa' : ''),
                  isDataSaved: isDataSaved,
                ),
              ),
              Expanded(
                child: CustomCheckBox(
                  label: 'Positiva',
                  value: result == 'Positiva',
                  onChanged: (value) =>
                      onResultChanged(value ? 'Positiva' : ''),
                  isDataSaved: isDataSaved,
                ),
              ),
              Expanded(
                child: CustomCheckBox(
                  label: 'Sin dato',
                  value: result == 'Sin dato',
                  onChanged: (value) =>
                      onResultChanged(value ? 'Sin dato' : ''),
                  isDataSaved: isDataSaved,
                ),
              ),
            ],
          ),
          if (isTreponemalTest)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomCheckBox(
                label: 'No requerido',
                value: result == 'No requerido',
                onChanged: (value) =>
                    onResultChanged(value ? 'No requerido' : ''),
                isDataSaved: isDataSaved,
              ),
            ),
          const SizedBox(height: 12),
          CustomDatePicker(
            label: 'Fecha de la prueba',
            initialDate: date,
            onDateChanged: onDateChanged,
            isDataSaved: isDataSaved,
          ),
        ],
      ),
    );
  }
}
