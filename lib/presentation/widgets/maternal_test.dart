import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/presentation/widgets/custom_checkbox.dart';
import 'package:sikum/presentation/widgets/custom_date_picker.dart';

class MaternalTest extends ConsumerWidget {
  final String testName;
  final bool isTreponemalTest;

  const MaternalTest({
    super.key,
    required this.testName,
    this.isTreponemalTest = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(maternalDataFormProvider);
    final maternalDataProvider = ref.watch(maternalDataFormProvider);
    final isDataSaved = form.isDataSaved;

    // Asegurar claves para evitar null
    maternalDataProvider.testResults.putIfAbsent(testName, () => '');
    maternalDataProvider.testDates.putIfAbsent(testName, () => '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(121, 216, 216, 216),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            testName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Primera fila: siempre los 3 primeros checkboxes en línea
          Row(
            children: [
              Expanded(
                child: CustomCheckBox(
                  label: 'Negativa',
                  value: maternalDataProvider.testResults[testName] == 'Negativa',
                  onChanged: (value) {
                    maternalDataProvider.updateTestResult(testName, value ? 'Negativa' : '');
                  },
                  isDataSaved: isDataSaved,
                ),
              ),
              Expanded(
                child: CustomCheckBox(
                  label: 'Positiva',
                  value: maternalDataProvider.testResults[testName] == 'Positiva',
                  onChanged: (value) {
                    maternalDataProvider.updateTestResult(testName, value ? 'Positiva' : '');
                  },
                  isDataSaved: isDataSaved,
                ),
              ),
              Expanded(
                child: CustomCheckBox(
                  label: 'Sin dato',
                  value: maternalDataProvider.testResults[testName] == 'Sin dato',
                  onChanged: (value) {
                    maternalDataProvider.updateTestResult(testName, value ? 'Sin dato' : '');
                  },
                  isDataSaved: isDataSaved,
                ),
              ),
            ],
          ),

          // Segunda fila solo si es Treponemica
          if (isTreponemalTest)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomCheckBox(
                label: 'No requerido',
                value: maternalDataProvider.testResults[testName] == 'No requerido',
                onChanged: (value) {
                  maternalDataProvider.updateTestResult(testName, value ? 'No requerido' : '');
                },
                isDataSaved: isDataSaved,
              ),
            ),

          const SizedBox(height: 12),

          // DatePicker alineado
          CustomDatePicker(
            label: 'Fecha de la prueba',
            initialDate: maternalDataProvider.testDates[testName],
            onDateChanged: (date) {
              maternalDataProvider.updateTestDate(testName, date);
            },
            isDataSaved: isDataSaved,
          ),
        ],
      ),
    );
  }
}

