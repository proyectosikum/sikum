import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:sikum/entities/patient.dart';
import 'package:sikum/presentation/widgets/screen_subtitle.dart';
import 'package:sikum/core/theme/app_colors.dart'; 
import 'package:sikum/presentation/widgets/custom_text_field.dart';
import 'package:sikum/presentation/widgets/custom_dropdown_field.dart';
import 'package:sikum/presentation/widgets/custom_app_bar.dart';
import 'package:sikum/presentation/widgets/side_menu.dart';
import 'package:sikum/presentation/providers/maternal_data_provider.dart';


class MaternalStep1 extends ConsumerWidget {
  final VoidCallback onNext;
  final Patient patient;

  const MaternalStep1({Key? key, required this.onNext, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

        final form = ref.watch(maternalDataFormProvider);
        final formNotifier = ref.read(maternalDataFormProvider.notifier);
        final idTypeOptions = ['DNI', 'Pasaporte', 'LC', 'LE'];

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
              const Center(child: ScreenSubtitle(text:'Datos maternos')),
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
                        '${patient.lastName}, ${patient.firstName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'DNI: ${patient.dni}',
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
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Apellido',
                initialValue: form.lastName,
                errorText: form.errors['lastName'],
                onChanged: formNotifier.updateLastName,
              ),

              const SizedBox(height: 12),

              CustomDropdownField(
                label: 'Tipo de documento',
                value: form.idType.isEmpty ? null : form.idType,
                items: idTypeOptions,
                errorText: form.errors['idType'],
                onChanged: (val) {
                  if (val != null) formNotifier.updateIdType(val);
                },
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Número de documento',
                initialValue: form.idNumber,
                errorText: form.errors['idNumber'],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: formNotifier.updateIdNumber,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Edad',
                initialValue: form.age,
                errorText: form.errors['age'],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: formNotifier.updateAge,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Localidad',
                initialValue: form.locality,
                errorText: form.errors['locality'],
                onChanged: formNotifier.updateLocality,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Domicilio',
                initialValue: form.address,
                errorText: form.errors['address'],
                onChanged: formNotifier.updateAddress,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Email',
                initialValue: form.email,
                errorText: form.errors['email'],
                keyboardType: TextInputType.emailAddress,
                onChanged: formNotifier.updateEmail,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: 'Teléfono',
                initialValue: form.phoneNumber,
                errorText: form.errors['phoneNumber'],
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: formNotifier.updatePhoneNumber,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final isValid = formNotifier.validateAll();
                    if (isValid) {
                      onNext();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor corrige los errores')),
                      );
                    }
                  },
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
