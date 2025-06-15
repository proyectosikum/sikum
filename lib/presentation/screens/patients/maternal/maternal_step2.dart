import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_text_field.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/utils/navigation_utils.dart';
import 'maternal_header.dart';

class MaternalStep2 extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Patient patient;

  const MaternalStep2({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.patient,
  });

  @override
  MaternalStep2State createState() => MaternalStep2State();
}

class MaternalStep2State extends ConsumerState<MaternalStep2> {
  final List<String> complications = [
    'Colestasis',
    'Diabetes gestacional (tto con dieta)',
    'Diabetes gestacional (tto Insulina)',
    'Diabetes Pre-Gestacional',
    'Eclampsia',
    'Hipertensión / HIE',
    'Hipotiroidismo',
    'Infección urinaria',
    'Pre eclampsia',
    'RPM',
    'Sme Anti-fosfolipidico',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(
      maternalDataFormProvider(widget.patient.id),
    ); // solo agregué el (widget.patient.id)
    final formNotifier = ref.read(
      maternalDataFormProvider(widget.patient.id).notifier,
    ); // solo agregué el (widget.patient.id)
    final isDataSaved = form.isDataSaved;

    return PopScope(
      canPop: false, // Interceptamos el botón de atrás del sistema
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await handleExit(
            context: context,
            isDataSaved: isDataSaved,
            patientId: widget.patient.id,
            ref: ref,
          );
        }
      },

      child: Scaffold(
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
                  MaternalHeader(patientId: widget.patient.id),
                  const SizedBox(height: 16),

                  /// Tarjetita con datos del paciente
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

                  /// Título de sección
                  const Text(
                    'Antecedentes médicos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Cantidad de gestas',
                    initialValue: form.gravidity,
                    onChanged: formNotifier.updateGravidity,
                    errorText: form.errors['gravidity'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: isDataSaved,
                  ),
                  CustomTextField(
                    label: 'Cantidad de partos',
                    initialValue: form.parity,
                    onChanged: formNotifier.updateParity,
                    errorText: form.errors['parity'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: isDataSaved,
                  ),
                  CustomTextField(
                    label: 'Cantidad de cesáreas',
                    initialValue: form.cesareans,
                    onChanged: formNotifier.updateCesareans,
                    errorText: form.errors['cesareans'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: isDataSaved,
                  ),
                  CustomTextField(
                    label: 'Cantidad de abortos',
                    initialValue: form.abortions,
                    onChanged: formNotifier.updateAbortions,
                    errorText: form.errors['abortions'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: isDataSaved,
                  ),

                  // Complicaciones
                  const SizedBox(height: 16),
                  const Text(
                    'Complicaciones del embarazo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...complications.map((complication) {
                    return CheckboxListTile(
                      title: Text(complication),
                      value: form.complications[complication] ?? false,
                      onChanged:
                          (isDataSaved) // Si está guardado, no se puede cambiar
                              ? null
                              : (bool? value) {
                                formNotifier.updateComplication(
                                  complication,
                                  value ?? false,
                                );
                              },
                    );
                  }),

                  const SizedBox(height: 32),
                  // Botones: Volver y Siguiente
                  Row(
                    children: [
                      // Botón Volver
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.green),
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

                      // Botón Siguiente
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: AppColors.cream,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            final isValid = formNotifier.validateStep2();
                            if (isValid) {
                              widget.onNext();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor corrige los errores',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Siguiente'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
