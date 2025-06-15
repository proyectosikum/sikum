import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/presentation/widgets/maternal_test.dart';

class MaternalStep3 extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Patient patient;

  const MaternalStep3({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.patient,
  });

  @override
  MaternalStep3State createState() => MaternalStep3State();
}

class MaternalStep3State extends ConsumerState<MaternalStep3> {
  bool showSecondHalf = false;

  @override
  Widget build(BuildContext context) {
    final maternalNotifier = ref.read(maternalDataFormProvider(widget.patient.id).notifier); // solo agregué el (widget.patient.id) 
    //cambios tres finals
    final maternalDataProvider = ref.watch(maternalDataFormProvider(widget.patient.id)); //->vane cambio: usar ref.watch y guardar en variable para no repetir
    final firstHalfTests = allTests.take(5).toList(); //->vane cambio: primeros 5 tests
    final secondHalfTests = allTests.skip(5).toList(); //->vane cambio: últimos 4 tests

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      endDrawer: const SideMenu(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: ScreenSubtitle(text: 'Datos maternos')),
                const SizedBox(height: 16),

                // Tarjetita con datos del paciente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.patient.lastName}, ${widget.patient.firstName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'DNI: ${widget.patient.dni}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Antecedentes médicos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8.0),

              // Primer grupo de pruebas (siempre se muestra)
                Column(
                  children: firstHalfTests.map((testName) {
                    return MaternalTest(
                      testName: testName,
                      result: maternalDataProvider.testResults[testName] ?? '',
                      date: maternalDataProvider.testDates[testName] ?? '',
                      isDataSaved: maternalDataProvider.isDataSaved,
                      isTreponemalTest: testName == 'Prueba Treponemica',
                      hasError: maternalDataProvider.hasTestError(testName),
                      onResultChanged: (val) => maternalNotifier.updateTestResult(testName, val),
                      onDateChanged: (val) => maternalNotifier.updateTestDate(testName, val),
                    );
                  }).toList(),
                ),

                // Segundo grupo de pruebas (solo si se mostró la segunda mitad)
                if (showSecondHalf)
                  Column(
                    children: secondHalfTests.map((testName) {
                      return MaternalTest(
                        testName: testName,
                        result: maternalDataProvider.testResults[testName] ?? '',
                        date: maternalDataProvider.testDates[testName] ?? '',
                        isDataSaved: maternalDataProvider.isDataSaved,
                        isTreponemalTest: false,
                        hasError: maternalDataProvider.hasTestError(testName),
                        onResultChanged: (val) => maternalNotifier.updateTestResult(testName, val),
                        onDateChanged: (val) => maternalNotifier.updateTestDate(testName, val),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 32),
                
                Row(
                  children: [
                    // Botón Volver
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.green),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: widget.onBack,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.arrow_back, color: AppColors.green),
                            SizedBox(width: 8),
                            Text(
                              'Volver',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Botón Siguiente o Mostrar más pruebas
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.cream,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (showSecondHalf) {
                            if (maternalNotifier.validateTests()) {
                              widget.onNext();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, complete todos los campos requeridos en ambas secciones de pruebas.'),
                                ),
                              );
                            }
                          } else {
                            if (maternalNotifier.validateFirstHalfTests()) {
                              setState(() {
                                showSecondHalf = true;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, complete todos los campos de la primera mitad.'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(showSecondHalf ? 'Siguiente' : 'Mostrar más pruebas'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
