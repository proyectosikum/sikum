import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/presentation/widgets/custom_dropdown_field.dart';
import 'package:sikum/presentation/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:sikum/utils/navigation_utils.dart';
import 'maternal_header.dart';

class MaternalStep4 extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Patient patient;

  const MaternalStep4({super.key, required this.onBack, required this.patient});

  static const List<String> bloodTypeOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    '0+',
    '0-',
    'Resultado pendiente',
  ];

  @override
  MaternalStep4State createState() => MaternalStep4State();
}

class MaternalStep4State extends ConsumerState<MaternalStep4> {
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

                  /// Tarjeta con datos del paciente
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

                  const SizedBox(height: 24),

                  // Campo libre: Serologías maternas
                  const Text(
                    'Serologías maternas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Escriba serologías relevantes',
                    initialValue: form.serologies,
                    onChanged: formNotifier.updateSerologies,
                    maxLines: 5,
                    readOnly: isDataSaved,
                  ),

                  const SizedBox(height: 24),

                  // Grupo sanguíneo
                  CustomDropdownField(
                    label: 'Grupo y factor de la madre',
                    value: form.bloodType.isEmpty ? null : form.bloodType,
                    items: MaternalStep4.bloodTypeOptions,
                    errorText: form.errors['bloodType'],
                    onChanged: (val) {
                      if (val != null && !isDataSaved) {
                        formNotifier.updateBloodType(val);
                      }
                    },
                    readOnly: isDataSaved,
                  ),

                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      // Volver
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.green),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: widget.onBack,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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

                      // Enviar
                      Expanded(
                        child:
                            form.isDataSaved
                                ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: AppColors.cream,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: formNotifier.enableEditing,
                                  child: const Text('Editar'),
                                )
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: AppColors.cream,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final goRouter = GoRouter.of(context);

                                    final valid = formNotifier.validateStep4();

                                    if (valid) {
                                      try {
                                        final patientId = widget.patient.id;
                                        await formNotifier.submitMaternalData(
                                          patientId,
                                        );

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '¡Datos maternos guardados exitosamente!',
                                            ),
                                          ),
                                        );

                                        goRouter.pop();
                                      } catch (e) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al guardar: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Por favor, complete los campos obligatorios.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Guardar'),
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
