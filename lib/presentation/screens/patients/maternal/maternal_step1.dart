import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/core/theme/app_colors.dart';
import 'package:sikum/presentation/widgets/custom_text_field.dart';
import 'package:sikum/presentation/widgets/custom_dropdown_field.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';
import 'package:sikum/utils/navigation_utils.dart';
import 'maternal_header.dart';

class MaternalStep1 extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Patient patient;

  const MaternalStep1({super.key, required this.onNext, required this.patient});
  @override
  MaternalStep1State createState() => MaternalStep1State();
}

class MaternalStep1State extends ConsumerState<MaternalStep1> {
  @override
  Widget build(BuildContext context) {
    final form = ref.watch(maternalDataFormProvider(widget.patient.id));
    final formNotifier = ref.read(maternalDataFormProvider(widget.patient.id));
    final idTypeOptions = ['DNI', 'Pasaporte', 'LC', 'LE'];
    final isDataSaved = form.isDataSaved;

    return PopScope(
      canPop: false,
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
                    'Datos filiatorios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Nombre',
                    initialValue: form.firstName,
                    errorText: form.errors['firstName'],
                    onChanged: formNotifier.updateFirstName,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Apellido',
                    initialValue: form.lastName,
                    errorText: form.errors['lastName'],
                    onChanged: formNotifier.updateLastName,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomDropdownField(
                    label: 'Tipo de documento',
                    value: form.idType.isEmpty ? null : form.idType,
                    items: idTypeOptions,
                    errorText: form.errors['idType'],
                    onChanged: (val) {
                      if (val != null && !isDataSaved) {
                        formNotifier.updateIdType(val);
                      }
                    },
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Número de documento',
                    initialValue: form.idNumber,
                    errorText: form.errors['idNumber'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: formNotifier.updateIdNumber,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Edad',
                    initialValue: form.age,
                    errorText: form.errors['age'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: formNotifier.updateAge,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Localidad',
                    initialValue: form.locality,
                    errorText: form.errors['locality'],
                    onChanged: formNotifier.updateLocality,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Domicilio',
                    initialValue: form.address,
                    errorText: form.errors['address'],
                    onChanged: formNotifier.updateAddress,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Email',
                    initialValue: form.email,
                    errorText: form.errors['email'],
                    keyboardType: TextInputType.emailAddress,
                    onChanged: formNotifier.updateEmail,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Teléfono',
                    initialValue: form.phoneNumber,
                    errorText: form.errors['phoneNumber'],
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: formNotifier.updatePhoneNumber,
                    readOnly: isDataSaved,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child:
                            isDataSaved
                                ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: AppColors.cream,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    final notifier = ref.read(
                                      maternalDataFormProvider(
                                        widget.patient.id,
                                      ).notifier,
                                    );
                                    notifier.enableEditing();
                                  },
                                  child: const Text('Editar'),
                                )
                                : OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.green),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed:
                                      () => handleExit(
                                        context: context,
                                        isDataSaved: isDataSaved,
                                        patientId: widget.patient.id,
                                        ref: ref,
                                      ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: AppColors.cream,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            final isValid = formNotifier.validateStep1();
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
